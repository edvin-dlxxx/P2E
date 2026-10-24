// Read-only helpers. This traversal setting does not edit document nodes.
figma.skipInvisibleInstanceChildren = false;
const SCHEMA_VERSION = '2.0.0';
const OUT_LIMIT = 19000;
const cmp = (a, b) => a < b ? -1 : a > b ? 1 : 0;
const byId = (a, b) => cmp(a.id, b.id);
const missing = () => ({ $state: 'missing' });
const unresolved = (kind, id, error) => ({
  $state: 'unresolved', kind, id,
  ...(error === undefined ? {} : { error: String(error) }),
});
// API Numbers are retained, with no extra precision or intentional rounding.
function raw(value) {
  if (value === figma.mixed) return { $state: 'mixed' };
  if (value === undefined) return missing();
  if (typeof value === 'number' && !Number.isFinite(value)) return { $state: 'non-finite', value: String(value) };
  if (Object.is(value, -0)) return { $state: 'negative-zero' };
  if (Array.isArray(value)) return value.map(raw);
  if (value !== null && typeof value === 'object') return Object.fromEntries(
    Object.keys(value).sort(cmp).map(k => [k, raw(value[k])]));
  if (['symbol', 'function', 'bigint'].includes(typeof value)) throw new Error('Unsupported raw API value: ' + typeof value);
  return value;
}
function props(node, names) {
  return Object.fromEntries(names.map(k => [k, raw(k in node ? node[k] : undefined)]));
}
const children = node => 'children' in node ? node.children : [];
function geometry(node) {
  return props(node, [
    'x', 'y', 'width', 'height', 'minWidth', 'maxWidth', 'minHeight', 'maxHeight',
    'rotation', 'relativeTransform', 'layoutMode', 'layoutSizingHorizontal',
    'layoutSizingVertical', 'primaryAxisSizingMode', 'counterAxisSizingMode',
    'primaryAxisAlignItems', 'counterAxisAlignItems', 'paddingTop', 'paddingRight',
    'paddingBottom', 'paddingLeft', 'itemSpacing', 'counterAxisSpacing',
    'cornerRadius', 'topLeftRadius', 'topRightRadius', 'bottomRightRadius',
    'bottomLeftRadius', 'strokeWeight', 'strokeAlign',
  ]);
}
const typography = node => props(node, [
  'fontName', 'fontSize', 'fontWeight', 'lineHeight', 'letterSpacing',
  'textCase', 'textDecoration', 'textStyleId', 'paragraphIndent', 'paragraphSpacing',
]);
async function textSegments(node) {
  if (!('getStyledTextSegments' in node)) return unresolved('text-segments', node.id, 'API unavailable');
  const fields = ['fontName', 'fontSize', 'fontWeight', 'lineHeight', 'letterSpacing', 'textStyleId', 'fills', 'boundVariables'];
  try {
    return node.getStyledTextSegments(fields).map(segment => raw({
      start: segment.start, end: segment.end,
      ...Object.fromEntries(fields.map(field => [field, segment[field]])),
    }));
  } catch (error) { return unresolved('text-segments', node.id, error.message); }
}
// Derived Hex is presentation only; raw RGBA and paint opacity remain separate.
const h2 = v => Math.round(v * 255).toString(16).padStart(2, '0');
function displayHex(color) {
  if (!color || !['r', 'g', 'b'].every(k => Number.isFinite(color[k]) && color[k] >= 0 && color[k] <= 1)) return null;
  if (color.a !== undefined && (!Number.isFinite(color.a) || color.a < 0 || color.a > 1)) return null;
  return '#' + ['r', 'g', 'b'].map(k => h2(color[k])).join('') +
    (color.a !== undefined && color.a !== 1 ? h2(color.a) : '');
}
async function pf(paints) {
  return { raw: raw(paints), display: Array.isArray(paints) ? paints.map(p => ({ hex: displayHex(p.color) })) : [] };
}
async function bvn(node) { return raw('boundVariables' in node ? node.boundVariables : undefined); }
async function styleName(id) {
  if (id === figma.mixed) return { $state: 'mixed' };
  if (!id) return missing();
  try {
    const style = await figma.getStyleByIdAsync(id);
    return style ? { id, name: style.name } : unresolved('style', id);
  } catch (error) { return unresolved('style', id, error.message); }
}
async function loadPage(id) {
  if (typeof id !== 'string' || !id) throw new Error('An explicit root/page ID is required');
  const node = await figma.getNodeByIdAsync(id);
  if (!node) throw new Error('Unresolved node: ' + id);
  let owner = node;
  while (owner && owner.type !== 'PAGE') owner = owner.parent;
  if (owner) await figma.setCurrentPageAsync(owner);
  return node;
}
function pathOf(node) {
  const names = [];
  for (let n = node; n && n.type !== 'PAGE'; n = n.parent) names.unshift(n.name);
  return names.join(' / ');
}
function insideInstance(node) {
  for (let n = node.parent; n && n.type !== 'PAGE'; n = n.parent) if (n.type === 'INSTANCE') return true;
  return false;
}
async function walk(node, depth, acc) {
  for (const child of children(node)) {
    const record = { id: child.id, name: child.name, type: child.type,
      visible: raw(child.visible), opacity: raw('opacity' in child ? child.opacity : undefined),
      geometry: geometry(child), bindings: await bvn(child) };
    for (const key of ['fills', 'strokes']) if (key in child) record[key] = await pf(child[key]);
    if ('effects' in child) record.effects = raw(child.effects);
    if (child.type === 'TEXT') {
      record.typography = typography(child);
      record.style = await styleName(child.textStyleId);
      record.segments = await textSegments(child);
    }
    acc.push(record);
    if (depth > 0) await walk(child, depth - 1, acc);
    else if (children(child).length) record.childrenNotExpanded = children(child).length;
  }
}
function page(array, params, defaultLimit) {
  const offset = params.offset === undefined ? 0 : params.offset;
  const limit = params.limit === undefined ? defaultLimit : params.limit;
  if (!Number.isSafeInteger(offset) || offset < 0 || !Number.isSafeInteger(limit) || limit < 1) throw new Error('Invalid pagination: use safe integer offset >= 0 and limit > 0');
  if (offset > array.length) throw new Error('offset exceeds total');
  const end = Math.min(offset + limit, array.length);
  return { slice: array.slice(offset, end), offset, next: end < array.length ? end : null, total: array.length };
}
function byteLength(text) {
  let bytes = 0;
  for (const c of text) { const code = c.codePointAt(0); bytes += code <= 0x7f ? 1 : code <= 0x7ff ? 2 : code <= 0xffff ? 3 : 4; }
  return bytes;
}
function out(data) {
  const text = JSON.stringify(raw({ ...data, schemaVersion: SCHEMA_VERSION }));
  const bytes = byteLength(text);
  return bytes > OUT_LIMIT ? JSON.stringify({
    schemaVersion: SCHEMA_VERSION, error: 'OUTPUT_TOO_LARGE', bytes,
    hint: 'No data returned. Lower limit/depth or narrow scope. Never advance a cursor on an error.',
  }) : text;
}

// P = {nodeIds?:[], variableIds?:[], offset?:0, limit?:100, include?:['vars','collections','diagnostics']}.
const P = {"nodeIds":["16433:9027"],"include":["vars"],"offset":35,"limit":1};
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
