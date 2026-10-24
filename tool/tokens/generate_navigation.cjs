// Read-only snapshot -> typed shared Navigator Bar spec. No network.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto');
const {execFileSync}=require('node:child_process');
const root=path.resolve(__dirname,'../..'),snap='docs/snapshots/2026-10-21_development-navigation',check=process.argv.includes('--check');
const read=p=>JSON.parse(fs.readFileSync(path.join(root,p),'utf8'));
const inv=read(`${snap}/evidence/inventory.json`),foundations=read(`${snap}/evidence/foundations.json`),consumers=read(`${snap}/evidence/consumers.json`);
const library=read('docs/snapshots/2026-10-20_development-icons/icons.json');
if(!inv.complete||inv.pages.length!==3||inv.pages.at(-1).next!==null||!foundations.complete||foundations.unresolved.length||!consumers.complete||consumers.rows.length!==4||consumers.next!==null)throw Error('Incomplete navigation evidence');
for(let i=0;i<inv.pages.length;i++)if(inv.pages[i].offset!==i||inv.pages[i].total!==3||inv.pages[i].next!==(i===2?null:i+1))throw Error('Missing inventory page');
if(inv.sets[0].variants.length!==2||inv.sets.slice(1).flatMap(s=>s.variants).length!==4)throw Error('Source count changed');
const walk=n=>[n,...(n.children||[]).flatMap(walk)];
const node=id=>{const e=read(`${snap}/evidence/node-${id.replace(':','-')}.json`);if(!e.complete||e.root.id!==id)throw Error('Incomplete '+id);return e.root;};
const strip=n=>Object.fromEntries(Object.entries(n).filter(([k])=>k!=='children'));
function artwork(inst){const v=library.versions.find(v=>v.nodeId===inst.mainComponent?.id);if(!v)throw Error('Unknown master '+inst.id);const paintNodes=walk(inst).filter(n=>n.fills?.some(p=>p.visible!==false));if(paintNodes.length!==1)throw Error('Unexpected paint layers');return {...v,instanceId:inst.id,paintNode:strip(paintNodes[0]),geometry:strip(inst)};}
function item(n,set){
 const indicator=n.children[0],labelFrame=n.children[1],icon=indicator.children[0],badge=indicator.children[1],pill=badge.children[0],badgeLabelFrame=pill.children[0];
 const parts={body:n,indicator,labelFrame,label:labelFrame.children[0],icon,badge,pill,badgeLabelFrame,badgeLabel:badgeLabelFrame.children[0]};
 return {id:n.id,rawName:n.name,setId:set.id,setName:set.name,fileKey:inv.pages[0].fileKey,brightness:set.name.endsWith('Light')?'light':'dark',
  state:(n.variantProperties?.State||n.mainComponent?.name.split('=')[1])==='Active'?'active':'inactive',sourceProperties:n.componentProperties||n.variantProperties,
  master:n.mainComponent||null,parts:Object.fromEntries(Object.entries(parts).map(([k,v])=>[k,strip(v)])),artwork:artwork(icon),
  reactions:walk(n).flatMap(c=>(c.reactions||[]).map(r=>({nodeId:c.id,...r})))};
}
const items=inv.sets.slice(1).flatMap(s=>s.variants.map(v=>item(node(v.id),s)));
const bars=inv.sets[0].variants.map(v=>{const n=node(v.id);if(n.children.length!==5)throw Error('Expected five destinations');
 return {id:n.id,rawName:n.name,setId:inv.sets[0].id,setName:inv.sets[0].name,fileKey:inv.pages[0].fileKey,brightness:v.props.Theme.toLowerCase(),body:strip(n),sourceProperties:v.props,
  destinations:n.children.map(c=>{const child=node(c.id),set=inv.sets.find(s=>s.id===child.mainComponent?.setId);if(!set)throw Error('Unknown item set');return item(child,set);})};});
const roles={'icon.home':'home','icon.target_check':'mission','icon.stadia_controller':'games','icon.leaderboard':'leaderboard','icon.store':'shop'};
const pairs={};
for(const b of bars)for(const d of b.destinations){const k=d.artwork.logicalKey;if(!roles[k])throw Error('Unexpected destination concept '+k);
 if(!pairs[k])pairs[k]=Object.fromEntries(['fill','outline'].map(style=>{const a=library.versions.find(v=>v.logicalKey===k&&v.style===style);if(!a)throw Error('Missing real style '+k+'/'+style);
  const f=path.join(root,'packages/design_system',a.assetPath);if(!fs.existsSync(f)||!fs.statSync(f).size||crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex')!==a.sha256)throw Error('SVG mismatch '+f);return [style,a];}));
 d.technicalId=roles[k];d.label=d.parts.label.characters;
 const template=items.find(i=>i.brightness===b.brightness&&i.state===d.state);
 for(const role of ['indicator','label'])if(JSON.stringify(d.parts[role].fills)!==JSON.stringify(template.parts[role].fills))throw Error('Instance color override needs explicit resolver '+d.id+'/'+role);
 if(JSON.stringify(d.artwork.paintNode.fills)!==JSON.stringify(template.artwork.paintNode.fills))throw Error('Instance tint override needs explicit resolver '+d.id);
}
const data={bars,items,pairs,foundations,engineering:read('design/engineering/navigation.json')};
function output(p,s){const f=path.join(root,p);if(check){if(!fs.existsSync(f)||fs.readFileSync(f,'utf8')!==s)throw Error('Stale '+p);}else{fs.mkdirSync(path.dirname(f),{recursive:true});fs.writeFileSync(f,s);}}
output(`${snap}/navigation.json`,JSON.stringify(data,null,2)+'\n');
output(`${snap}/manifest.json`,JSON.stringify({status:'DEVELOPMENT',sourceAccess:'read-only MCP',fileKey:inv.pages[0].fileKey,page:inv.pages[0].page,versionId:null,designerApproval:null,counts:{bars:bars.length,nestedItemVariants:items.length},pagination:inv.pages.map(p=>({offset:p.offset,total:p.total,next:p.next})),evidenceHashes:Object.fromEntries(fs.readdirSync(path.join(root,snap,'evidence')).sort().map(f=>[f,crypto.createHash('sha256').update(fs.readFileSync(path.join(root,snap,'evidence',f))).digest('hex')]))},null,2)+'\n');
const temp=path.join(root,'build/navigation-generation/navigation_data.g.dart');fs.mkdirSync(path.dirname(temp),{recursive:true});fs.writeFileSync(temp,`// GENERATED by tool/tokens/generate_navigation.cjs. Do not edit.\nconst navigationSourceData = <String,dynamic>${JSON.stringify(data).replace(/\$/g,'\\$')};\n`);
execFileSync(process.env.DART||'D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe',['format',temp]);output('packages/design_system/lib/src/tokens/generated/navigation_data.g.dart',fs.readFileSync(temp,'utf8'));
console.log(`${check?'Verified':'Generated'} 2 source bars, 4 nested item states, 5 exact icon pairs.`);
