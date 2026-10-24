const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const { mock, run, helpers, alias, container, fixture, base } = require('./mock.cjs');
const fullIds = fixture.lookupOnlyInputs.map(id => 'VariableID:' + id).sort();

test('enumeration discovers multi-hop aliases in every mode without resolving/replacing values', async () => {
  const m = mock(), result = await run('variables_export', {}, m.figma);
  assert.equal(result.schemaVersion, '2.0.0');
  assert.equal(result.total, 3);
  assert.equal(result.complete, true);
  const a = result.vars.find(v => v.id === 'VariableID:2:1');
  assert.deepEqual(a.valuesByMode.light, alias('VariableID:2:2'));
  assert.deepEqual(a.valuesByMode.dark, alias('VariableID:1:1'));
  assert.equal(result.vars.find(v => v.id === 'VariableID:1:1').valuesByMode.light, 1.23456789);
  assert.equal(result.vars.find(v => v.id === 'VariableID:2:2').valuesByMode.dark, 0);
  assert.equal(m.calls.nodes.length, 0);
});
test('all four lookup-only fixtures work as configurable bare or full explicit IDs', async () => {
  const m = mock(), result = await run('variables_export', { variableIds: fixture.lookupOnlyInputs }, m.figma);
  assert.equal(result.total, 7);
  assert.deepEqual(result.diagnostics.lookupOnlyIds.filter(id => id.startsWith('VariableID:16447:')), fullIds);
  assert.deepEqual(result.scope.variableIds, fullIds);
  const sameName = result.vars.filter(v => v.name === 'Duplicate name');
  assert.equal(sameName.length, 2);
  assert.notEqual(sameName[0].id, sameName[1].id);
});
test('node scan discovers fixtures independently of explicit inputs and stays inside scope', async () => {
  const m = mock(), result = await run('variables_export', { nodeIds: ['frame:1'] }, m.figma);
  assert.equal(result.total, 7);
  assert.equal(result.vars.some(v => v.id === 'VariableID:99:99'), false);
  assert.deepEqual(m.calls.nodes, ['frame:1']);
  assert.deepEqual(m.calls.switchedPages, ['page:1']);
});
test('all origins/paths retained once per ID, including enumeration, aliases, explicit and nested bindings', async () => {
  const m = mock();
  const result = await run('variables_export', { nodeIds: ['frame:1', 'frame:1'], variableIds: ['1:1', 'VariableID:1:1'] }, m.figma);
  const v = result.vars.find(v => v.id === 'VariableID:1:1');
  assert.deepEqual([...new Set(v.provenance.map(p => p.kind))].sort(), ['alias', 'enumeration', 'explicit-lookup', 'node-binding']);
  assert.equal(v.provenance.filter(p => p.kind === 'node-binding').length, 2);
  assert.equal(v.provenance.filter(p => p.kind === 'alias').length, 2);
  assert.equal(v.provenance.filter(p => p.kind === 'explicit-lookup').length, 2);
  assert.equal(new Set(result.vars.map(v => v.id)).size, result.total);
  assert.equal(m.calls.variables.filter(id => id === v.id).length, 1);
});
test('alias cycle terminates, retains original aliases and marks incomplete', async () => {
  const result = await run('variables_export', { variableIds: ['3:1'] }, mock().figma);
  assert.deepEqual(result.diagnostics.aliasCycles, [['VariableID:3:1', 'VariableID:3:2', 'VariableID:3:1']]);
  assert.equal(result.complete, false);
  assert.deepEqual(result.vars.find(v => v.id === 'VariableID:3:2').valuesByMode.light, alias('VariableID:3:1'));
});
test('unresolved aliases, explicit lookups and scope roots remain explicit with every origin', async () => {
  const m = mock(); m.variables.get('VariableID:1:1').valuesByMode.light = alias('VariableID:9:9');
  const result = await run('variables_export', { variableIds: ['9:9'], nodeIds: ['missing:root'] }, m.figma);
  assert.equal(result.complete, false);
  const item = result.vars.find(v => v.id === 'VariableID:9:9');
  assert.equal(item.status, 'unresolved');
  assert.equal('valuesByMode' in item, false);
  assert.equal(result.diagnostics.unresolvedReferences[0].provenance.length, 2);
  assert.equal(result.diagnostics.unresolvedScope[0].id, 'missing:root');
});
test('lookup exceptions are reported and missing modes are never synthesized', async () => {
  const m = mock(); delete m.variables.get('VariableID:1:1').valuesByMode.dark;
  const original = m.figma.variables.getVariableByIdAsync;
  m.figma.variables.getVariableByIdAsync = async id => { if (id === 'VariableID:2:2') throw Error('fixture lookup error'); return original(id); };
  const result = await run('variables_export', {}, m.figma);
  assert.equal(result.complete, false);
  const v = result.vars.find(v => v.id === 'VariableID:1:1');
  assert.deepEqual(v.missingModeIds, ['dark']); assert.equal('dark' in v.valuesByMode, false);
  assert.equal(result.diagnostics.unresolvedReferences[0].reason, 'lookup-error');
});
test('pagination includes every record exactly once and no unresolved placeholder is skipped', async () => {
  const m = mock(), params = { nodeIds: ['frame:1'], variableIds: ['9:9'] };
  const all = await run('variables_export', params, m.figma), rows = [];
  let offset = 0;
  do { const part = await run('variables_export', { ...params, offset, limit: 2 }, m.figma);
    assert.equal(part.offset, offset); rows.push(...part.vars); offset = part.next;
  } while (offset !== null);
  assert.deepEqual(rows, all.vars);
  assert.equal(rows.length, new Set(rows.map(v => v.id)).size);
  await assert.rejects(run('variables_export', { limit: 0 }, m.figma), /Invalid pagination/);
  await assert.rejects(run('variables_export', { offset: 500 }, m.figma), /offset exceeds/);
});
test('API ordering and input ordering do not change deterministic output', async () => {
  const m = mock(); const params = { nodeIds: ['frame:1'], variableIds: fixture.lookupOnlyInputs };
  const a = await run('variables_export', params, m.figma);
  m.collection.variableIds.reverse(); m.collection.modes.reverse();
  const b = await run('variables_export', { ...params, variableIds: [...params.variableIds].reverse() }, m.figma);
  assert.equal(JSON.stringify(a), JSON.stringify(b));
});
test('collections alone above OUT_LIMIT do not prevent independently selected variable pages', async () => {
  const m = mock(), template = m.variables.get('VariableID:1:1');
  m.collection.variableIds = Array.from({ length:1100 }, (_, i) => 'VariableID:123456789:' + i);
  for (const id of m.collection.variableIds) m.variables.set(id, { ...template, id });
  assert.ok(Buffer.byteLength(JSON.stringify([m.collection]), 'utf8') > 19000);
  const oversized = await run('variables_export', { include:['collections'], limit:1 }, m.figma);
  assert.equal(oversized.error, 'OUTPUT_TOO_LARGE');
  const first = await run('variables_export', { include:['vars'], limit:1 }, m.figma);
  const last = await run('variables_export', { include:['vars'], offset:1099, limit:1 }, m.figma);
  assert.equal(first.error, undefined); assert.equal(first.total, 1100);
  assert.equal(first.offset, 0); assert.equal(first.next, 1); assert.equal(first.complete, true);
  assert.equal(first.vars.length, 1); assert.equal('collections' in first, false);
  assert.equal('diagnostics' in first, false);
  assert.equal(last.total, 1100); assert.equal(last.offset, 1099);
  assert.equal(last.next, null); assert.equal(last.complete, true);
  assert.notEqual(first.vars[0].id, last.vars[0].id);
  const diagnostics = await run('variables_export', { include:['diagnostics'], limit:1 }, m.figma);
  assert.equal(diagnostics.error, undefined); assert.equal(diagnostics.complete, true);
  assert.equal(diagnostics.total, 1100); assert.equal(diagnostics.offset, 0); assert.equal(diagnostics.next, 1);
  assert.equal('vars' in diagnostics, false); assert.equal('collections' in diagnostics, false);
  assert.deepEqual(diagnostics.diagnostics.unresolvedReferences, []);
  await assert.rejects(run('variables_export', { include:['unknown'] }, m.figma), /include must be an array/);
});
test('raw paints retain hidden paint, original channels, alpha, opacity and original binding ID', async () => {
  const m = mock(); const result = await helpers('return out(await pf(figma.fixturePaints));', { ...m.figma, fixturePaints: [m.paint] });
  assert.deepEqual(result.raw[0], m.paint);
  assert.equal(result.raw[0].color.a, 0.30000001192092896);
  assert.equal(result.raw[0].opacity, 0.987654321);
  assert.equal(result.raw[0].boundVariables.color.id, 'VariableID:16447:59');
  assert.equal(typeof result.display[0].hex, 'string');
});
test('raw helper distinguishes mixed, missing, AUTO, explicit null and nonfinite values', async () => {
  const m = mock(); const result = await helpers('return out({ mixed:figma.mixed, absent:undefined, auto:{unit:"AUTO"}, nullable:null, n:NaN });', m.figma);
  assert.deepEqual(result.mixed, { $state: 'mixed' }); assert.deepEqual(result.absent, { $state: 'missing' });
  assert.deepEqual(result.auto, { unit: 'AUTO' }); assert.equal(result.nullable, null);
  assert.deepEqual(result.n, { $state: 'non-finite', value: 'NaN' });
});
test('text style units, AUTO and mixed survive; binding IDs are not replaced by names', async () => {
  const m = mock(), result = await run('text_styles_export', {}, m.figma), style = result.styles[0];
  assert.deepEqual(style.typography.fontName, { $state: 'mixed' });
  assert.deepEqual(style.typography.lineHeight, { unit: 'AUTO' });
  assert.deepEqual(style.typography.letterSpacing, { unit: 'PIXELS', value: -0.123456789 });
  assert.deepEqual(style.typography.fontWeight, { $state: 'missing' });
  assert.deepEqual(style.bindings.fontSize, alias('VariableID:1:1'));
});
test('page inventory retains fractional dimensions, per-corner radii, padding and zero constraints', async () => {
  const m = mock(), result = await run('page_inventory', { pageId: 'page:1' }, m.figma);
  const frame = result.frames.find(f => f.id === 'frame:1');
  assert.equal(frame.geometry.width, 402.123456789); assert.equal(frame.geometry.height, 100.987654321);
  assert.equal(frame.geometry.paddingTop, 8.123456789); assert.equal(frame.geometry.itemSpacing, 8.567891234);
  assert.equal(frame.geometry.minWidth, 0); assert.deepEqual(frame.geometry.maxWidth, { $state: 'missing' });
  assert.equal(frame.opacity, 0.987654321);
  assert.deepEqual(frame.geometry.cornerRadius, { $state: 'mixed' }); assert.equal(frame.geometry.topLeftRadius, 1.123456789);
});
test('component spec keeps raw effects/reactions, original text style IDs, and reports depth boundaries', async () => {
  const m = mock();
  const set = container('set:1', 'COMPONENT_SET', 'Fixture set', []);
  m.frame.type = 'COMPONENT'; m.frame.effects = [{ type: 'DROP_SHADOW', radius: 0.123456789 }];
  m.frame.reactions = [{ trigger: { type: 'ON_CLICK' }, actions: [{ transition: null }] }];
  set.children = [m.frame]; m.frame.parent = set; set.parent = m.page; m.nodes.set(set.id, set);
  const result = await run('component_set_spec', { ids: ['set:1'], depth: 0 }, m.figma);
  assert.equal(result.rows[0].geometry.width, 402.123456789);
  assert.deepEqual(result.rows[0].effects, m.frame.effects);
  assert.deepEqual(result.rows[0].reactions, m.frame.reactions);
  assert.deepEqual(result.rows[0].children[0].style, { $state: 'missing' });
  assert.deepEqual(result.rows[0].children[0].typography.letterSpacing, { unit:'PERCENT', value:-4.123456789 });
});
test('text-range-only binding is discovered with range provenance without collecting characters', async () => {
  const m = mock();
  m.variables.set('VariableID:5:1', { ...m.variables.get('VariableID:1:1'), id:'VariableID:5:1' });
  m.text.getStyledTextSegments = () => [{ start:2, end:4, characters:'private fixture text', fontSize:13.123456789,
    boundVariables:{ fontSize:alias('VariableID:5:1') }, fills:[] }];
  const result = await run('variables_export', { nodeIds:['frame:1'] }, m.figma);
  const v = result.vars.find(v => v.id === 'VariableID:5:1');
  assert.equal(v.enumerated, false);
  assert.deepEqual(v.provenance[0].textRange, { start:2, end:4 });
  assert.deepEqual(v.provenance[0].propertyPath, ['textSegments',0,'boundVariables','fontSize']);
  const segments = await helpers('return out({segments:await textSegments(figma.fixtureText)});', { ...m.figma, fixtureText:m.text });
  assert.equal(segments.segments[0].fontSize, 13.123456789);
  assert.equal('characters' in segments.segments[0], false);
});
test('unavailable range-binding API is explicit and prevents a false completeness claim', async () => {
  const m = mock(); delete m.text.getStyledTextSegments;
  const result = await run('variables_export', { nodeIds:['frame:1'] }, m.figma);
  assert.equal(result.complete, false);
  assert.equal(result.diagnostics.unresolvedScope[0].kind, 'text-segments');
});
test('missing styles and mixed paint data remain different states', async () => {
  const m = mock();
  const result = await helpers('return out({style:await styleName("absent-style"), noStyle:await styleName(""), paints:await pf(figma.mixed)});', m.figma);
  assert.equal(result.style.$state, 'unresolved');
  assert.equal(result.noStyle.$state, 'missing');
  assert.equal(result.paints.raw.$state, 'mixed');
});
test('standalone components beyond old 150 cap are paginated without dropping property keys', async () => {
  const m = mock(); const items = Array.from({ length: 151 }, (_, i) => container('c:' + i, 'COMPONENT', 'C', [], { componentPropertyDefinitions: { 'Text#1:1': { type:'TEXT', defaultValue:'A' } } }));
  m.page.children = items; items.forEach(c => c.parent = m.page);
  const rows = []; let offset = 0;
  do { const r = await run('component_sets_list', { pageId: 'page:1', offset, limit: 5 }, m.figma); assert.equal(r.error, undefined); rows.push(...r.entries); offset = r.next; } while (offset !== null);
  assert.equal(rows.length, 151); assert.equal(new Set(rows.map(r => r.id)).size, 151);
  assert.ok(rows[0].properties['Text#1:1']);
});
test('invalid scope never falls back to scanning entire file', async () => {
  const m = mock();
  await assert.rejects(run('variables_export', { nodeIds: ['document:1'] }, m.figma), /Document roots/);
  await assert.rejects(run('variables_export', { nodeIds: 'page:1' }, m.figma), /array/);
  const other = container('page:2', 'PAGE', 'Other', []); m.nodes.set(other.id, other);
  await assert.rejects(run('variables_export', { nodeIds: ['frame:1', 'page:2'] }, m.figma), /one extraction call per page/);
});
test('nested gradient/effect/component-definition bindings are discovered by ID and full path', async () => {
  const m = mock();
  m.frame.type = 'COMPONENT';
  m.frame.componentPropertyDefinitions = { 'Label#1:1': { type:'TEXT', boundVariables: { value:alias('VariableID:16447:43') } } };
  m.frame.effects = [{ type:'DROP_SHADOW', boundVariables:{ radius:alias('VariableID:16447:46') } }];
  m.frame.fills.push({ type:'GRADIENT_LINEAR', gradientStops:[{ position:0.123456789, color:{ r:0.123456789, g:0, b:1, a:0.456789123 }, boundVariables:{ color:alias('VariableID:16447:60') } }] });
  const result = await run('variables_export', { nodeIds:['frame:1'] }, m.figma);
  const origins = id => result.vars.find(v => v.id === id).provenance.map(p => p.propertyPath?.join('.'));
  assert.ok(origins('VariableID:16447:43').includes('componentPropertyDefinitions.Label#1:1.boundVariables.value'));
  assert.ok(origins('VariableID:16447:46').includes('effects.0.boundVariables.radius'));
  assert.ok(origins('VariableID:16447:60').includes('fills.1.gradientStops.0.boundVariables.color'));
});
test('nested instance counts and separate unresolved instances are not conflated', async () => {
  const m = mock();
  const main = { id:'main:1', name:'Main', type:'COMPONENT', parent:null };
  const inner = container('instance:2', 'INSTANCE', 'Inner', [], { getMainComponentAsync:async () => main });
  const outer = container('instance:1', 'INSTANCE', 'Outer', [inner], { getMainComponentAsync:async () => main });
  const unknownA = container('unknown:1', 'INSTANCE', 'Unknown', [], { getMainComponentAsync:async () => null });
  const unknownB = container('unknown:2', 'INSTANCE', 'Unknown', [], { getMainComponentAsync:async () => { throw Error('fixture'); } });
  m.frame.children = [outer,unknownA,unknownB]; m.frame.children.forEach(c => c.parent=m.frame);
  const result = await run('instance_usage', { pageId:'page:1' }, m.figma);
  assert.equal(result.total, 4); assert.equal(result.counts.length, 4);
  assert.equal(result.diagnostics.length, 2);
  assert.deepEqual(result.counts.filter(r => r.componentId === 'main:1').map(r=>r.nested).sort(), [false,true]);
});
test('oversize output returns a byte-counted error, never a truncated successful page', async () => {
  const m = mock(), result = await helpers('return out({message:"ی".repeat(10000)});', m.figma);
  assert.equal(result.error, 'OUTPUT_TOO_LARGE'); assert.ok(result.bytes > 20000);
  assert.equal('message' in result, false); assert.equal('next' in result, false);
});
test('remaining packed scripts execute only against mocks, including mock-only SVG export', async () => {
  const m = mock();
  assert.equal((await run('list_pages', {}, m.figma)).pages.length, 1);
  assert.equal((await run('design_lint', { rootId:'frame:1', examples:0 }, m.figma)).unstyledText.count, 1);
  assert.equal((await run('instance_usage', { pageId:'page:1' }, m.figma)).total, 0);
  const icon = { id:'icon:1', name:'Fixture icon', type:'COMPONENT', width:24.123456789, height:24, exportAsync:async () => '<svg>mock only</svg>' };
  const set = container('icons:1', 'COMPONENT_SET', 'Icons', [icon]); m.nodes.set(set.id, set);
  const result = await run('icons_export_svg', { setId:'icons:1' }, m.figma);
  assert.equal(result.icons[0].geometry.width, 24.123456789);
  assert.equal(result.icons[0].svg, '<svg>mock only</svg>');
});
test('Dart pack consumer still concatenates, substitutes params and executes against mock only', async () => {
  const dart = process.env.DART || 'D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe';
  const result = spawnSync(dart, [path.join(base, 'pack.dart'), 'variables_export', '{"limit":2}'], { encoding:'utf8' });
  assert.equal(result.status, 0, result.stderr);
  assert.ok(result.stdout.includes("SCHEMA_VERSION = '2.0.0'"));
  assert.ok(result.stdout.includes('const P = {"limit":2}'));
  assert.equal(result.stdout.includes('%PARAMS%'), false);
  const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
  const extracted = JSON.parse(await new AsyncFunction('figma', result.stdout)(mock().figma));
  assert.equal(extracted.total, 3);
  assert.equal(extracted.vars.length, 2);
  assert.equal(extracted.next, 2);
});
