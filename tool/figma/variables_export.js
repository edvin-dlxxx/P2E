// P = {nodeIds?:[], variableIds?:[], offset?:0, limit?:100, include?:['vars','collections','diagnostics']}.
const P = %PARAMS%;
const parts = P.include === undefined ? ['vars', 'collections', 'diagnostics'] : P.include;
if (!Array.isArray(parts) || parts.some(part => !['vars', 'collections', 'diagnostics'].includes(part))) {
  throw new Error('include must be an array containing only vars, collections or diagnostics');
}
const include = new Set(parts);
function inputIds(value, key) {
  if (value === undefined) return [];
  if (!Array.isArray(value) || value.some(id => typeof id !== 'string' || !id.trim())) throw new Error(key + ' must be an array of nonempty IDs');
  return [...new Set(value)].sort(cmp);
}
const nodeIds = inputIds(P.nodeIds, 'nodeIds');
const normalizeId = id => /^\d+:\d+$/.test(id) ? 'VariableID:' + id : id;
const explicitInputs = inputIds(P.variableIds, 'variableIds');
const explicitIds = [...new Set(explicitInputs.map(normalizeId))].sort(cmp);
const scope = { enumeration: 'local-collections', nodeIds, variableIds: explicitIds, inputVariableIds: explicitInputs, includeHidden: true };
const collections = (await figma.variables.getLocalVariableCollectionsAsync()).slice().sort(byId);
const collectionMap = new Map(collections.map(c => [c.id, c]));
const origins = new Map(), records = new Map(), enumerated = new Set(), problems = [], edges = new Map();
function discover(id, origin) {
  if (typeof id !== 'string' || !id) throw new Error('Invalid variable reference ID');
  if (!origins.has(id)) origins.set(id, new Map());
  origins.get(id).set(JSON.stringify(raw(origin)), origin);
}
for (const c of collections) for (const id of c.variableIds) {
  enumerated.add(id);
  discover(id, { kind: 'enumeration', collectionId: c.id });
}
for (const inputId of explicitInputs) discover(normalizeId(inputId), { kind: 'explicit-lookup', inputId });
function aliases(value, callback, path) {
  if (value === null || value === undefined || value === figma.mixed) return;
  if (Array.isArray(value)) return value.forEach((v, i) => aliases(v, callback, path.concat(i)));
  if (typeof value !== 'object') return;
  if (value.type === 'VARIABLE_ALIAS') { callback(value.id, path); return; }
  for (const key of Object.keys(value).sort(cmp)) aliases(value[key], callback, path.concat(key));
}
async function scan(node, rootId, ancestry) {
  if (ancestry.has(node.id)) throw new Error('Cycle in scoped node tree: ' + node.id);
  const chain = new Set(ancestry); chain.add(node.id);
  for (const field of ['boundVariables', 'fills', 'strokes', 'effects', 'layoutGrids', 'componentProperties']) {
    if (!(field in node)) continue;
    aliases(node[field], (id, path) => discover(id, {
      kind: 'node-binding', rootId, nodeId: node.id, propertyPath: [field, ...path],
    }), []);
  }
  if (node.type === 'COMPONENT_SET' || (node.type === 'COMPONENT' && node.parent?.type !== 'COMPONENT_SET')) {
    aliases(node.componentPropertyDefinitions, (id, path) => discover(id, {
      kind: 'node-binding', rootId, nodeId: node.id, propertyPath: ['componentPropertyDefinitions', ...path],
    }), []);
  }
  if (node.type === 'TEXT') {
    const segments = await textSegments(node);
    if (!Array.isArray(segments)) problems.push({ kind: 'text-segments', id: node.id, rootId, reason: segments });
    else segments.forEach((segment, index) => aliases(segment, (id, path) => discover(id, {
      kind: 'node-binding', rootId, nodeId: node.id,
      propertyPath: ['textSegments', index, ...path], textRange: { start: segment.start, end: segment.end },
    }), []));
  }
  for (const child of children(node)) await scan(child, rootId, chain);
}
const roots = [], pageIds = new Set();
for (const id of nodeIds) {
  let node;
  try { node = await figma.getNodeByIdAsync(id); }
  catch (error) { problems.push({ kind: 'node', id, reason: 'lookup-error', error: String(error.message) }); continue; }
  if (!node) { problems.push({ kind: 'node', id, reason: 'not-found' }); continue; }
  if (node.type === 'DOCUMENT') throw new Error('Document roots are not allowed; specify a bounded page/node');
  let owner = node;
  while (owner && owner.type !== 'PAGE') owner = owner.parent;
  if (!owner) throw new Error('Scoped root has no page: ' + id);
  pageIds.add(owner.id); roots.push({ node, pageNode: owner });
}
if (pageIds.size > 1) throw new Error('Use one extraction call per page; merge records and provenance by variable ID');
if (roots.length) await figma.setCurrentPageAsync(roots[0].pageNode);
for (const { node } of roots) await scan(node, node.id, new Set());
const visited = new Set();
while (visited.size < origins.size) {
  const id = [...origins.keys()].filter(k => !visited.has(k)).sort(cmp)[0];
  visited.add(id);
  let variable;
  try { variable = await figma.variables.getVariableByIdAsync(id); }
  catch (error) { records.set(id, { id, status: 'unresolved', reason: 'lookup-error', error: String(error.message) }); continue; }
  if (!variable) { records.set(id, { id, status: 'unresolved', reason: 'not-found' }); continue; }
  const record = {
    id, status: 'available', name: variable.name, resolvedType: variable.resolvedType,
    collectionId: variable.variableCollectionId, scopes: raw(variable.scopes),
    valuesByMode: raw(variable.valuesByMode),
  };
  records.set(id, record);
  if (!collectionMap.has(variable.variableCollectionId)) {
    try {
      const c = await figma.variables.getVariableCollectionByIdAsync(variable.variableCollectionId);
      if (c) collectionMap.set(c.id, c);
      else problems.push({ kind: 'collection', id: variable.variableCollectionId, variableId: id, reason: 'not-found' });
    } catch (error) { problems.push({ kind: 'collection', id: variable.variableCollectionId, variableId: id, reason: 'lookup-error', error: String(error.message) }); }
  }
  const modes = collectionMap.get(variable.variableCollectionId)?.modes || [];
  record.missingModeIds = modes.filter(m => !Object.hasOwn(variable.valuesByMode, m.modeId)).map(m => m.modeId).sort(cmp);
  const targets = new Set(); edges.set(id, targets);
  for (const modeId of Object.keys(variable.valuesByMode).sort(cmp)) aliases(variable.valuesByMode[modeId], (targetId, path) => {
    targets.add(targetId);
    discover(targetId, { kind: 'alias', variableId: id, modeId, propertyPath: path });
  }, []);
}
// Deterministic DFS back edges diagnose cycles without enumerating all simple cycles.
const colors = new Map(), stack = [], cycles = [];
function visit(id) {
  colors.set(id, 1); stack.push(id);
  for (const target of [...(edges.get(id) || [])].sort(cmp)) {
    if (colors.get(target) === 1) cycles.push([...stack.slice(stack.indexOf(target)), target]);
    else if (!colors.has(target)) visit(target);
  }
  stack.pop(); colors.set(id, 2);
}
for (const id of [...records.keys()].sort(cmp)) if (!colors.has(id)) visit(id);
const rows = [...records.values()].sort(byId).map(record => ({
  ...record, enumerated: enumerated.has(record.id),
  provenance: [...origins.get(record.id).values()].sort((a, b) => cmp(JSON.stringify(raw(a)), JSON.stringify(raw(b)))),
}));
const diagnostics = {
  lookupOnlyIds: rows.filter(r => r.status === 'available' && !r.enumerated).map(r => r.id),
  unresolvedReferences: rows.filter(r => r.status === 'unresolved').map(r => ({
    id: r.id, reason: r.reason, provenance: r.provenance, ...(r.error ? { error: r.error } : {}),
  })),
  unresolvedScope: problems.sort((a, b) => cmp(JSON.stringify(raw(a)), JSON.stringify(raw(b)))),
  aliasCycles: cycles,
};
const collectionRows = [...collectionMap.values()].sort(byId).map(c => ({
  id: c.id, name: c.name, defaultModeId: raw(c.defaultModeId),
  modes: raw(c.modes.slice().sort((a, b) => cmp(a.modeId, b.modeId))),
  variableIds: [...c.variableIds].sort(cmp),
}));
const pg = page(rows, P, 100);
return out({ scope, total: pg.total, offset: pg.offset, next: pg.next,
  ...(include.has('vars') ? { vars: pg.slice } : {}),
  ...(include.has('collections') ? { collections: collectionRows } : {}),
  ...(include.has('diagnostics') ? { diagnostics } : {}),
  complete: !diagnostics.unresolvedReferences.length && !problems.length && !cycles.length && rows.every(r => !r.missingModeIds?.length),
});
