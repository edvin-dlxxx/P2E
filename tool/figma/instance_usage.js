// P = {pageId, frameIds?:[id]}. Traversal includes nested and hidden instances.
const P = %PARAMS%;
const root = await loadPage(P.pageId);
const roots = [];
for (const id of P.frameIds === undefined ? [root.id] : [...new Set(P.frameIds)].sort(cmp)) {
  const node = id === root.id ? root : await figma.getNodeByIdAsync(id);
  if (!node) throw new Error('Unresolved usage root: ' + id);
  let owner = node; while (owner && owner.id !== root.id) owner = owner.parent;
  if (!owner) throw new Error('Usage root lies outside requested page: ' + id);
  if (roots.some(other => { for (let p = node; p; p = p.parent) if (p.id === other.id) return true; return false; })) throw new Error('Overlapping usage roots');
  roots.push(node);
}
for (const a of roots) for (const b of roots) if (a !== b) {
  for (let p = a.parent; p; p = p.parent) if (p.id === b.id) throw new Error('Overlapping usage roots');
}
const counts = new Map(), diagnostics = [];
async function rec(node, nested) {
  for (const child of children(node)) {
    if (child.type === 'INSTANCE') {
      let main, lookupError;
      try { main = await child.getMainComponentAsync(); }
      catch (error) { lookupError = error.message; }
      if (!main) diagnostics.push(unresolved('main-component', child.id, lookupError));
      const set = main ? (main.parent?.type === 'COMPONENT_SET' ? main.parent : main) : null;
      const key = JSON.stringify([set?.id || child.id, nested]);
      if (!counts.has(key)) counts.set(key, { componentId: set ? set.id : unresolved('main-component', child.id), nested, count: 0 });
      counts.get(key).count++;
      await rec(child, true);
    } else await rec(child, nested);
  }
}
for (const node of roots) await rec(node, false);
return out({ roots: roots.map(r => r.id), total: [...counts.values()].reduce((sum, r) => sum + r.count, 0),
  counts: [...counts.entries()].sort((a, b) => cmp(a[0], b[0])).map(e => e[1]), diagnostics });
