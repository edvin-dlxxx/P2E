// Synthetic fixtures only. No Figma connector or network is used.
const fs = require('node:fs');
const path = require('node:path');
const base = path.resolve(__dirname, '..');
const fixture = JSON.parse(fs.readFileSync(path.join(__dirname, 'fixtures/variables.json'), 'utf8'));
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
const alias = id => ({ type: 'VARIABLE_ALIAS', id });

function container(id, type, name, kids = [], extra = {}) {
  const node = { id, type, name, parent: null, visible: true, children: kids, ...extra };
  for (const child of kids) child.parent = node;
  node.findAll = predicate => {
    const result = [];
    function walk(n) { for (const child of n.children || []) { if (predicate(child)) result.push(child); walk(child); } }
    walk(node); return result;
  };
  node.findAllWithCriteria = ({ types }) => node.findAll(n => types.includes(n.type));
  return node;
}
function mock() {
  const collection = structuredClone(fixture.collection);
  const variables = new Map(fixture.variables.map(v => [v.id, {
    ...structuredClone(v), variableCollectionId: collection.id, scopes: ['ALL_SCOPES'],
  }]));
  const mixed = Symbol('figma.mixed');
  const paint = { type: 'SOLID', color: { r: 0.123456789, g: 0.345678912, b: 0.765432198, a: 0.30000001192092896 },
    opacity: 0.987654321, visible: false, boundVariables: { color: alias('VariableID:16447:59') } };
  const text = { id: 'text:1', type: 'TEXT', name: 'Text', parent: null, visible: true,
    width: 18.123456789, height: 24.987654321, fontName: mixed, fontSize: 18.123456789,
    lineHeight: { unit: 'AUTO' }, letterSpacing: { unit: 'PERCENT', value: -4.123456789 },
    textStyleId: '', fills: [paint], boundVariables: { fontSize: alias('VariableID:1:1') },
    getStyledTextSegments: () => [],
  };
  const frame = container('frame:1', 'FRAME', 'Frame', [text], {
    width: 402.123456789, height: 100.987654321, x: 0, y: 0,
    minWidth: 0, paddingTop: 8.123456789, paddingRight: 16.234567891,
    paddingBottom: 8.345678912, paddingLeft: 16.456789123, itemSpacing: 8.567891234,
    cornerRadius: mixed, topLeftRadius: 1.123456789, topRightRadius: 2.234567891,
    bottomRightRadius: 3.345678912, bottomLeftRadius: 4.456789123,
    fills: [paint], strokes: [], effects: [], opacity: 0.987654321,
    boundVariables: { itemSpacing: alias('VariableID:1:1'),
      fills: fixture.lookupOnlyInputs.map(id => alias('VariableID:' + id)) },
  });
  const outside = container('outside:1', 'FRAME', 'Outside', [], {
    boundVariables: { width: alias('VariableID:99:99') },
  });
  const page = container('page:1', 'PAGE', 'Fixture page', [frame, outside]);
  const root = container('document:1', 'DOCUMENT', 'Mock only', [page]);
  const nodes = new Map([root, page, frame, outside, text].map(n => [n.id, n]));
  const styles = [{ id: 'style:1', name: 'Fixture', fontName: mixed, fontSize: 18.123456789,
    lineHeight: { unit: 'AUTO' }, letterSpacing: { unit: 'PIXELS', value: -0.123456789 },
    boundVariables: { fontSize: alias('VariableID:1:1') } }];
  const calls = { variables: [], nodes: [], switchedPages: [] };
  const figma = {
    mixed, root, variables: {
      getLocalVariableCollectionsAsync: async () => [collection],
      getVariableCollectionByIdAsync: async id => id === collection.id ? collection : null,
      getVariableByIdAsync: async id => { calls.variables.push(id); return variables.get(id) || null; },
    },
    getLocalTextStylesAsync: async () => styles,
    getStyleByIdAsync: async id => styles.find(s => s.id === id) || null,
    getNodeByIdAsync: async id => { calls.nodes.push(id); return nodes.get(id) || null; },
    setCurrentPageAsync: async p => { calls.switchedPages.push(p.id); },
  };
  return { figma, collection, variables, nodes, page, frame, text, paint, styles, calls };
}
async function run(script, params, figma) {
  const helper = fs.readFileSync(path.join(base, 'helpers.js'), 'utf8');
  const source = fs.readFileSync(path.join(base, script + '.js'), 'utf8');
  return JSON.parse(await new AsyncFunction('figma', helper + '\n' + source.replaceAll('%PARAMS%', JSON.stringify(params)))(figma));
}
async function helpers(code, figma) {
  return JSON.parse(await new AsyncFunction('figma', fs.readFileSync(path.join(base, 'helpers.js'), 'utf8') + '\n' + code)(figma));
}
module.exports = { mock, run, helpers, alias, container, fixture, base };
