const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {execFileSync}=require('node:child_process');
const root=path.resolve(__dirname,'../..');
const snapshot='docs/snapshots/2026-10-20_development-text-fields';
const check=process.argv.includes('--check');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p)));
const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const output=(p,data)=>{const file=path.join(root,p),bytes=Buffer.from(data);if(check){if(!fs.existsSync(file)||!fs.readFileSync(file).equals(bytes))throw Error('Stale: '+p);}else{fs.mkdirSync(path.dirname(file),{recursive:true});fs.writeFileSync(file,bytes);}};
const inventory=read(`${snapshot}/evidence/page-inventory.json`);
const foundations=read(`${snapshot}/evidence/foundations.json`);
const icons=read('docs/snapshots/2026-10-20_development-icons/icons.json');
const flatten=(n)=>[n,...(n.children||[]).flatMap(flatten)];
const rows=[];
function compact(n){if(!n)return null;return Object.fromEntries(['id','name','type','width','height','paddingLeft','paddingRight','paddingTop','paddingBottom','itemSpacing','cornerRadius','strokeWeight','fills','strokes','effects','fontName','fontSize','fontWeight','lineHeight','letterSpacing','textStyleId','characters','visible','boundVariables'].filter(k=>k in n).map(k=>[k,n[k]]));}
for(const set of inventory.sets)for(const v of set.variants){
  const tree=read(`${snapshot}/evidence/variant-${v.id.replace(':','-')}.json`);
  if(!tree.complete||tree.root.id!==v.id)throw Error('Incomplete variant '+v.id);
  const n=tree.root,all=flatten(n),find=name=>all.find(n=>n.name===name),firstText=node=>node&&flatten(node).find(n=>n.type==='TEXT');
  const family=set.name.startsWith('Base Password')?'password':set.name.startsWith('Base Text')?'textField':set.name.startsWith('Radio')?'radio':'otp';
  const state=v.props.State;
  const body=n.children[0],support=find('Supporting Text'),label=find('Label');
  const textNodes=all.filter(n=>n.type==='TEXT');
  const input=firstText(find('Input Text'))||firstText(find('Input Password'));
  const visibleIcons=all.filter(n=>n.type==='INSTANCE'&&n.mainComponent&&icons.versions.some(v=>v.nodeId===n.mainComponent.id)).map(n=>{
    const art=icons.versions.find(v=>v.nodeId===n.mainComponent.id);
    const artNodes=flatten(n);return {nodeId:n.id,visible:n.visible,logicalKey:art.logicalKey,style:art.style,sourceNodeId:art.nodeId,width:n.width,height:n.height,paint:artNodes.find(c=>(c.fills||[]).some(p=>p.type==='SOLID'))?.fills??[]};
  });
  const parts={body:compact(body),labelFrame:compact(label),label:compact(firstText(find('Label Text'))||firstText(find('Adjacent Label Text'))),indicator:compact(firstText(find('Required'))),input:compact(input),support:compact(support),supportText:compact(support&&flatten(support).find(n=>n.type==='TEXT')),radioOuter:family==='radio'?compact(body):null,radioInner:compact(find('Selected Icon')||find('Unselected Icon')),action:compact(find('Trailing Icon')),caret:compact(all.find(n=>n.name==='Caret Point'&&n.strokes?.length)),otpText:family==='otp'?compact(textNodes[0]):null};
  rows.push({id:n.id,rawName:n.name,fileKey:inventory.fileKey,setId:set.id,setName:set.name,family,state,brightness:set.name.includes('Light')?'light':'dark',width:n.width,height:n.height,gap:n.itemSpacing,parts,icons:visibleIcons,reactions:all.flatMap(n=>(n.reactions||[]).map(r=>({nodeId:n.id,...r})))});
}
rows.sort((a,b)=>a.id.localeCompare(b.id));
if(rows.length!==inventory.sets.reduce((n,s)=>n+s.variants.length,0)||new Set(rows.map(r=>r.id)).size!==rows.length)throw Error('Coverage mismatch');
const consumers=['18664-13700','18653-13552'].map(id=>read(`${snapshot}/evidence/consumer-${id}.json`));
for(const c of consumers)if(!c.complete)throw Error('Incomplete consumer');
const consumer=consumers[0].root,divider=consumer.children.find(n=>n.name==='Divider');
const hover=rows.filter(r=>r.family==='radio').flatMap(r=>r.reactions).find(r=>r.trigger?.type==='ON_HOVER');
const motion=read('design/engineering/field_motion.json');
const sourceMotion={hoverMs:Math.round(hover.actions[0].transition.duration*1000),raw:hover.actions[0].transition,origin:'source-extracted',clickTransition:'No explicit transition on inspected click reactions; not a claim about every Figma animation API.'};
const data={rows,variables:foundations.variables,collections:foundations.collections,textStyles:foundations.styles,
  otpComposition:{width:consumer.width,height:consumer.height,gap:consumer.itemSpacing,padding:[consumer.paddingLeft,consumer.paddingTop,consumer.paddingRight,consumer.paddingBottom],alignment:consumer.primaryAxisAlignItems,cellCount:consumer.children.filter(n=>n.type==='INSTANCE').length,dividerAfter:1,divider:compact(divider),dividerLine:compact(divider.children[0]),sourceIds:consumers.map(c=>c.root.id)},sourceMotion};
output(`${snapshot}/fields.json`,JSON.stringify(data,null,2)+'\n');
const files=fs.readdirSync(path.join(root,snapshot,'evidence')).sort();
output(`${snapshot}/manifest.json`,JSON.stringify({status:'DEVELOPMENT',fileKey:inventory.fileKey,page:inventory.page,versionId:null,designerApproval:null,sourceAccess:'read-only MCP',counts:{sets:inventory.sets.length,variants:rows.length,byFamily:Object.fromEntries(['textField','password','otp','radio'].map(f=>[f,rows.filter(r=>r.family===f).length]))},themeGaps:['password/light','otp/light'],evidenceHashes:Object.fromEntries(files.map(f=>[f,hash(fs.readFileSync(path.join(root,snapshot,'evidence',f)))]))},null,2)+'\n');
const value=x=>JSON.stringify(x).replace(/\$/g,'\\$');
// D-026: map actual paired TextField roles, rather than equal variable names.
const lightBindings={};
for(const dark of rows.filter(r=>r.family==='textField'&&r.brightness==='dark')){
 const light=rows.find(r=>r.family==='textField'&&r.brightness==='light'&&r.state===dark.state);
 for(const [role,part]of Object.entries(dark.parts)){
  if(!part||!light.parts[role])continue;
  for(const key of ['fills','strokes']){
   const from=part[key]?.[0]?.boundVariables?.color?.id;
   const to=light.parts[role][key]?.[0]?.boundVariables?.color?.id;
   if(!from||!to)continue;
   const bindings=(lightBindings[role]??={})[key]??={};
   if(bindings[from]&&bindings[from]!==to)throw Error('Ambiguous Light role '+role+'/'+key+'/'+from);
   bindings[from]=to;
  }
 }
}
let dart=`// GENERATED by tool/tokens/generate_fields.cjs. Do not edit.\nconst fieldSourceData = <String,dynamic>${value(data)};\nconst fieldEngineeringData = <String,dynamic>${value(motion)};\nconst fieldLightBindingsData = <String,dynamic>${value(lightBindings)};\n`;
const temp=path.join(root,'build/field-generation/field_data.g.dart');fs.mkdirSync(path.dirname(temp),{recursive:true});fs.writeFileSync(temp,dart);execFileSync(process.env.DART||'D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe',['format',temp]);dart=fs.readFileSync(temp,'utf8');
output('packages/design_system/lib/src/tokens/generated/field_data.g.dart',dart);
console.log(`${check?'Verified':'Generated'} ${rows.length} source variants / ${inventory.sets.length} sets; complete descendants, variables, typography and OTP consumers.`);
