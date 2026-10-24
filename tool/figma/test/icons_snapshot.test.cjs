const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const {execFileSync}=require('node:child_process');
const {hash,root,snapshot}=require('../assemble_icons_snapshot.cjs');

test('source inventory, original SVGs, manifest, renderer proof and runtime assets reconcile',()=>{
  const read=f=>JSON.parse(fs.readFileSync(path.join(root,snapshot,f)));
  const manifest=read('manifest.json'),{concepts,versions,buttonIcons}=read('icons.json');
  const source=read('evidence/page-inventory.json');
  assert.equal(versions.length,source.definitions);
  assert.equal(new Set(versions.map(v=>v.nodeId)).size,versions.length);
  assert.equal(new Set(concepts.map(c=>c.key)).size,concepts.length);
  assert.equal(manifest.counts.exported,versions.length);
  assert.equal(manifest.counts.renderable,versions.length);
  assert.equal(manifest.counts.failed,0);
  for(const [file,sha] of Object.entries(manifest.evidenceHashes))assert.equal(hash(fs.readFileSync(path.join(root,snapshot,'evidence',file))),sha);
  for(const v of versions) {
    const original=fs.readFileSync(path.join(root,snapshot,v.file));
    assert.equal(hash(original),v.sha256);
    assert.deepEqual(original,fs.readFileSync(path.join(root,'packages/design_system',v.assetPath)));
    assert.equal(v.renderStatus,'renderer-validated');
  }
  assert.equal(Object.keys(buttonIcons).length,90);
  const names=new Map();
  for(const v of versions) {
    const concept=concepts.find(c=>c.key===v.logicalKey);
    assert.ok(concept.styles.includes(v.style));
    assert.equal(v.variantProperties.Icon,concept.rawName);
    const key=v.style+'/'+v.iconId;
    assert.ok(!names.has(key),'Asset collision '+key);names.set(key,v.nodeId);
  }
});

test('snapshot and runtime generation are deterministic and read-only in check mode',()=>{
  for(const script of ['tool/figma/assemble_icons_snapshot.cjs','tool/tokens/generate_icons.cjs','tool/dev/generate_icon_strings.cjs']) {
    execFileSync(process.execPath,[script,'--check'],{cwd:root,stdio:'pipe'});
  }
});
