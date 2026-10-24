// Diagnostic examples are explicitly limited; counters include all scanned nodes.
const P = %PARAMS%;
const root = await loadPage(P.rootId);
const limit = P.examples === undefined ? 5 : P.examples;
if (!Number.isSafeInteger(limit) || limit < 0) throw new Error('examples must be a nonnegative integer');
const res = { rootId: root.id, exampleLimit: limit };
for (const key of ['unstyledText', 'unboundPaint', 'hidden', 'missingMain', 'oddNames']) res[key] = { count: 0, examples: [] };
const add = (key, value) => { res[key].count++; if (res[key].examples.length < limit) res[key].examples.push(value); };
const nodes = root.findAll(() => true);
for (const node of nodes) {
  if (!P.includeInstances && insideInstance(node)) continue;
  if (node.visible === false) add('hidden', { id: node.id, path: pathOf(node) });
  if (/\s{2,}|^\s|\s$/.test(node.name)) add('oddNames', { id: node.id, name: node.name });
  if (node.type === 'TEXT' && (!node.textStyleId || node.textStyleId === figma.mixed)) add('unstyledText', { id: node.id, styleId: raw(node.textStyleId) });
  if (node.type === 'INSTANCE') {
    let main = null; try { main = await node.getMainComponentAsync(); } catch (error) {}
    if (!main) add('missingMain', unresolved('main-component', node.id));
  }
  for (const field of ['fills', 'strokes']) {
    if (!(field in node) || !Array.isArray(node[field])) continue;
    for (const paint of node[field]) if (paint.type === 'SOLID' && paint.visible !== false && !paint.boundVariables?.color) {
      add('unboundPaint', { id: node.id, field, paint: raw(paint) }); break;
    }
  }
}
res.scanned = nodes.length;
return out(res);
