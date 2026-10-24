const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const path=require('node:path');
const crypto=require('node:crypto');
const root=path.resolve(__dirname,'../../..');
const dir=path.join(root,'docs/snapshots/2026-10-20_development-text-fields');
const read=name=>JSON.parse(fs.readFileSync(path.join(dir,name)));
test('all source variants are complete and immutable evidence hashes match',()=>{
 const m=read('manifest.json'),data=read('fields.json'),inventory=read('evidence/page-inventory.json');
 assert.equal(m.status,'DEVELOPMENT'); assert.equal(m.designerApproval,null);
 assert.equal(m.sourceAccess,'read-only MCP');
 assert.deepEqual(m.counts.byFamily,{textField:10,password:10,otp:6,radio:8});
 assert.equal(data.rows.length,inventory.sets.flatMap(s=>s.variants).length);
 for(const [name,expected] of Object.entries(m.evidenceHashes)){
   assert.equal(crypto.createHash('sha256').update(fs.readFileSync(path.join(dir,'evidence',name))).digest('hex'),expected,name);
 }
 for(const row of data.rows){
   const raw=read(`evidence/variant-${row.id.replace(':','-')}.json`);
   assert.equal(raw.complete,true); assert.equal(raw.root.id,row.id);
   assert.equal(raw.root.name,row.rawName);
   assert.ok(row.parts.body); assert.ok(row.setId);
 }
});
test('source motion, unusual OTP divider and theme gaps remain explicit',()=>{
 const d=read('fields.json'),m=read('manifest.json');
 assert.equal(d.sourceMotion.hoverMs,300);
 assert.equal(d.sourceMotion.origin,'source-extracted');
 assert.equal(d.otpComposition.cellCount,6);
 assert.equal(d.otpComposition.dividerAfter,1);
 assert.equal(d.otpComposition.width,362);
 assert.equal(d.otpComposition.divider.width,10);
 assert.deepEqual(m.themeGaps,['password/light','otp/light']);
 assert.ok(d.rows.filter(r=>r.family==='password'||r.family==='otp').every(r=>r.brightness==='dark'));
});
