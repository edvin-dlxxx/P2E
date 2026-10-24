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

const root=await loadPage('16433:9027'); return out({pageId:root.id,sets:root.findAllWithCriteria({types:['COMPONENT_SET']}).sort(byId).map(s=>({id:s.id,name:s.name,variantIds:children(s).map(v=>v.id).sort(cmp)})),textNodeIds:root.findAllWithCriteria({types:['TEXT']}).map(n=>n.id).sort(cmp)});