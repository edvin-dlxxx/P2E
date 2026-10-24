// Assemble/verify captured read-only responses. No Figma or network access.
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const assert = require('node:assert/strict');
const root = path.resolve(process.argv.find(a => a.startsWith('--source='))?.slice(9) ||
  'docs/snapshots/2026-10-19_development-buttons-complete');
const check = process.argv.includes('--check');
const read = name => JSON.parse(fs.readFileSync(path.join(root, name), 'utf8'));
const sha = bytes => crypto.createHash('sha256').update(bytes).digest('hex');
const sorted = x => Array.isArray(x) ? x.map(sorted) : x && typeof x === 'object'
  ? Object.fromEntries(Object.keys(x).sort().map(k => [k, sorted(x[k])])) : x;
const json = x => JSON.stringify(sorted(x), null, 2) + '\n';
const outputs = new Map();
const emit = (file, value) => outputs.set(file, typeof value === 'string' ? value : json(value));
const calls = read('calls.json');
const records = [];
function decode(text) { let value = JSON.parse(text); if (typeof value === 'string') value = JSON.parse(value); return value; }
for (const call of calls) {
  const response = read('raw/' + call.response);
  for (const [i, content] of response.content.filter(c => c.type === 'text').entries()) {
    assert.equal(fs.readFileSync(path.join(root, 'raw', call.textFiles[i]), 'utf8'), content.text, 'Raw response text changed');
  }
  if (response.isError) throw Error('Unresolved tool error: ' + call.response);
  const data = decode(response.content.find(c => c.type === 'text').text);
  for (const item of data.batches ? data.batches.map(decode) : [data]) {
    if (!item.error) records.push({ call, data: item });
    else assert.equal(item.error, 'OUTPUT_TOO_LARGE', 'Unexpected extraction error');
  }
}
const named = name => records.filter(r => r.call.name === name);
const one = name => { const rows = named(name); assert.equal(rows.length, 1, name); return rows[0].data; };
function pages(rows, field) {
  rows.sort((a, b) => a.data.offset - b.data.offset);
  let offset = 0; const output = [];
  for (const { data } of rows) {
    assert.equal(data.offset, offset, 'Missing/overlapping page');
    assert.equal(data.total, rows[0].data.total, 'Total changed');
    output.push(...data[field]); offset += data[field].length;
    assert.equal(data.next, offset === data.total ? null : offset, 'Invalid continuation');
  }
  assert.equal(offset, rows[0].data.total, 'Incomplete page chain');
  return output;
}
const inventories = named('component_sets_list');
assert.equal(inventories.length, 2);
assert.deepEqual(inventories[0].data, inventories[1].data, 'Before/after inventory changed');
const sets = inventories[0].data.entries;
assert(sets.every(s => s.kind === 'set'));
const componentPages = records.filter(r => r.call.name.startsWith('component_set_spec'));
const variants = pages(componentPages, 'rows');
const visualPages = named('visual_layout_batch');
const layouts = pages(visualPages, 'rows');
const expectedIds = visualPages.find(p => p.data.offset === 0).data.expectedVariantIds;
assert.equal(new Set(variants.map(v => v.id)).size, variants.length, 'Duplicate variants');
assert.deepEqual(variants.map(v => v.id).sort(), [...expectedIds].sort());
assert.deepEqual(layouts.map(v => v.variantId).sort(), [...expectedIds].sort());
assert.equal(variants.length, sets.reduce((n, s) => n + s.variantCount, 0));
for (const v of variants) {
  assert(!v.children.some(c => c.childrenNotExpanded), 'Depth boundary remains');
  const layout = layouts.find(l => l.variantId === v.id);
  assert.deepEqual(layout.nodes.map(n => n.id).sort(), [v.id, ...v.children.map(n => n.id)].sort());
  const ids = new Set(layout.nodes.map(n => n.id));
  for (const n of layout.nodes) {
    assert(n.parentId === null || ids.has(n.parentId), 'Missing parent');
    assert(n.childIds.every(id => ids.has(id)), 'Missing child');
  }
}
const values = one('scoped_variable_values');
assert.equal(values.complete, true); assert.equal(values.next, null);
const references = pages(named('scoped_variable_provenance'), 'references');
assert.equal(references.length, values.provenanceTotal);
const variables = values.vars.map(v => ({ ...v, provenance: references.filter(r => r.variableId === v.id).map(r => r.origin) }));
const varIds = new Set(variables.map(v => v.id));
assert.equal(varIds.size, variables.length);
for (const v of variables) {
  assert(v.provenance.length); assert.equal(v.status, 'available'); assert.equal(v.missingModeIds.length, 0);
  assert.equal(new Set(v.provenance.map(json)).size, v.provenance.length, 'Duplicate origins');
}
function aliases(value) {
  if (!value || typeof value !== 'object') return;
  if (value.type === 'VARIABLE_ALIAS') assert(varIds.has(value.id), 'Missing bound Variable: ' + value.id);
  for (const v of Object.values(value)) aliases(v);
}
for (const v of variants) aliases(v);
for (const v of variables) aliases(v.valuesByMode);
const diagnostics = values.diagnostics;
assert.equal(diagnostics.unresolvedReferences.length + diagnostics.unresolvedScope.length + diagnostics.aliasCycles.length, 0);
const collections = values.collections.filter(c => variables.some(v => v.collectionId === c.id))
  .map(c => ({ ...c, includedVariableIds: variables.filter(v => v.collectionId === c.id).map(v => v.id).sort() }));
const lookupOnlyResolutions = diagnostics.lookupOnlyIds.filter(id => varIds.has(id)).map(id => {
  const v = variables.find(v => v.id === id), c = collections.find(c => c.id === v.collectionId);
  // This capture has no aliases; keep original mode values and resolved values separate.
  assert(!Object.values(v.valuesByMode).some(value => value?.type === 'VARIABLE_ALIAS'));
  return { id, name: v.name, collectionId: c.id, collectionName: c.name, modes: c.modes,
    valuesByMode: v.valuesByMode, resolvedValuesByMode: v.valuesByMode,
    reason: 'Lookup succeeded, but ID is absent from local collection enumeration.', provenance: v.provenance };
});
emit('variables.json', { schemaVersion: '2.0.0', scope: values.scope, complete: true, collections,
  vars: variables, diagnostics, lookupOnlyResolutions, provenanceRecordCount: references.length });
const styles = one('scoped_text_styles');
const styleIds = new Set(styles.styles.map(s => s.id));
const textNodes = variants.flatMap(v => v.children.filter(n => n.type === 'TEXT'));
for (const n of textNodes) {
  assert(styleIds.has(n.style.id), 'Missing text style');
  assert(Array.isArray(n.segments), 'Text segment API unresolved');
}
emit('text_styles.json', styles);
emit('visual_layout.json', { schemaVersion: 'button-visual-layout/1.0.0', scopeNodeIds: ['16433:9027'], variants: layouts });
const componentFiles = [];
for (const set of [...sets].sort((a, b) => a.name.localeCompare(b.name))) {
  const file = 'components/' + set.name.toLowerCase().replace(/[^a-z0-9]+/g, '_').replace(/^_|_$/g, '') + '.json';
  const rows = variants.filter(v => v.setId === set.id).sort((a, b) => a.name.localeCompare(b.name));
  assert.equal(rows.length, set.variantCount);
  emit(file, { schemaVersion: '2.0.0', depth: 8, set, variants: rows,
    visualLayoutFile: '../visual_layout.json', rawResponses: [...new Set(componentPages.filter(p => p.data.rows.some(r => r.setId === set.id))
      .flatMap(p => p.call.textFiles.map(f => 'raw/' + f)))] });
  componentFiles.push(file);
}
const iconExports = named('button_icon_svg').map(r => r.data);
const instances = layouts.flatMap(l => l.nodes.filter(n => n.type === 'INSTANCE').map(n => ({ ...n, variantId: l.variantId })));
for (const instance of instances) assert(iconExports.some(i => i.id === instance.mainComponent.id), 'Missing icon SVG');
const icons = iconExports.map(i => {
  assert(i.svg.startsWith('<svg') && /<\/svg>\s*$/.test(i.svg), 'Invalid SVG');
  const iconId = i.variantProperties.Icon.toLowerCase().replace(/[^a-z0-9]+/g, '_');
  const file = 'icons/' + i.setName.toLowerCase() + '/' + iconId + '.svg';
  emit(file, i.svg);
  return { id: i.id, iconId, rawName: i.name, style: i.setName, setId: i.setId,
    geometry: i.geometry, file, sha256: sha(i.svg), instanceReferences: instances.filter(n => n.mainComponent.id === i.id)
      .map(n => ({ variantId: n.variantId, nodeId: n.id, visible: n.visible, parentId: n.parentId })) };
});
emit('icons.json', { scope: 'Exact main components referenced by Buttons, including hidden Outline slots; not the complete icon library.', icons });
emit('lint.json', one('design_lint'));
emit('component_sets.json', { before: inventories[0].data, after: inventories[1].data });
const csvCell = v => '"' + String(v).replaceAll('"', '""') + '"';
emit('variant-index.csv', [['set_id', 'set_name', 'variant_id', 'variant_name', 'width', 'height', 'visible_icon_component_ids'],
  ...variants.map(v => [v.setId, v.setName, v.id, v.name, v.geometry.width, v.geometry.height,
    layouts.find(l => l.variantId === v.id).nodes.filter(n => n.type === 'INSTANCE' && n.visible === true)
      .map(n => n.mainComponent.id).join(';')])].map(row => row.map(csvCell).join(',')).join('\n') + '\n');
const hashes = {};
for (const file of fs.readdirSync(path.join(root, 'raw')).sort()) hashes['raw/' + file] = sha(fs.readFileSync(path.join(root, 'raw', file)));
emit('raw-inputs.sha256.json', hashes);
const previous = path.resolve('docs/snapshots/2026-10-19_development-buttons');
const previousIds = JSON.parse(fs.readFileSync(path.join(previous, 'manifest.json'), 'utf8')).artifacts.components
  .flatMap(file => JSON.parse(fs.readFileSync(path.join(previous, file), 'utf8')).variants.map(v => v.id));
assert.deepEqual(previousIds.sort(), [...expectedIds].sort());
const lint = one('design_lint');
emit('manifest.json', {
  schemaVersion: '2.0.0', status: 'DEVELOPMENT', fileKey: '7PGTHT5CQzbTsWZQnPIQce', date: '2026-10-19', completionDate: '2026-10-20',
  source: { copyFile: true, scopeNodeIds: ['16433:9027'], scopeName: 'Buttons', fileNameFromCanonicalMap: 'P2E Platform - Design System (Copy)' },
  versionControl: 'owner-managed', technicalVersionLock: 'unverified', versionLabel: null, designerApproved: false,
  scope: { fullDesignSystemCoverage: false, excluded: ['Other components', 'EN/FA screens and usage', 'Whole icon library', 'Dart/tokens generation', 'Flutter implementation'], rawEnumerationIncludesUnrelatedLocalVariables: true },
  counts: { sets: sets.length, variants: variants.length, textNodes: textNodes.length, textStyles: styles.styles.length,
    scopedVariables: variables.length, collections: collections.length, lookupOnlyIds: lookupOnlyResolutions.length,
    nodeRecords: layouts.reduce((n, l) => n + l.nodes.length, 0), iconInstances: instances.length,
    iconSvgs: icons.length, provenanceReferences: references.length, calls: calls.length },
  artifacts: { components: componentFiles, variables: 'variables.json', textStyles: 'text_styles.json', icons: 'icons.json',
    visualLayout: 'visual_layout.json', lint: 'lint.json', changes: 'CHANGES.md', extractionContract: 'EXTRACTION-CONTRACT.md' },
  completeness: { complete: true, componentProof: { expectedVariantIds: expectedIds, actualVariantIds: variants.map(v => v.id).sort(),
    missingIds: [], duplicateIds: [], paginatedThroughNextNull: true, unexpandedDescendants: 0, inventoryUnchanged: true },
    variables: { complete: true, provenanceComplete: true, unresolvedReferences: [], missingModes: [], aliasCycles: [] },
    sourceIconReferencesResolved: true, meaning: 'Data completeness for declared scope; not version stability or Flutter visual-equivalence approval.' },
  diagnostics: { unboundPaints: lint.unboundPaint.count, hiddenNodes: lint.hidden.count,
    unstyledText: lint.unstyledText.count, missingMainComponents: lint.missingMain.count },
  rawInputs: { calls: 'calls.json', hashIndex: 'raw-inputs.sha256.json', fileCount: Object.keys(hashes).length,
    aggregateSha256: sha(json(hashes)), responseTextPreservation: 'Exact text blocks verified against recorded MCP wrapper content.' },
  extensions: ['button-visual-layout/1.0.0', 'scoped-variable-graph/1.0.0', 'scoped-variable-provenance/1.0.0'],
  latestPointerUpdated: false, previousSnapshot: '2026-10-19_development-buttons',
  scriptVersions: { contract: '2.0.0', assemblerSha256: sha(fs.readFileSync(__filename)) },
});
for (const file of ['README.md', 'CHANGES.md', 'EXTRACTION-CONTRACT.md']) {
  assert(fs.existsSync(path.join(root, file)), 'Missing package document: ' + file);
}
for (const [file, content] of outputs) {
  const target = path.join(root, file);
  if (check) assert.equal(fs.readFileSync(target, 'utf8'), content, 'Stale artifact: ' + file);
  else { fs.mkdirSync(path.dirname(target), { recursive: true }); fs.writeFileSync(target, content, 'utf8'); }
}
console.log(`${check ? 'Verified' : 'Assembled'} ${sets.length} sets / ${variants.length} variants / ${variables.length} variables / ${icons.length} SVGs; ${references.length} origins; raw text and ${Object.keys(hashes).length} hashes verified.`);
