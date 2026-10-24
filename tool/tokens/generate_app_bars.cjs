// Scoped read-only evidence -> shared App Bar registry. No network or Figma writes.
const fs = require('node:fs'), path = require('node:path'), crypto = require('node:crypto');
const {execFileSync} = require('node:child_process');
const root = path.resolve(__dirname, '../..');
const snapshot = 'docs/snapshots/2026-10-20_development-app-bars';
const check = process.argv.includes('--check');
const read = p => JSON.parse(fs.readFileSync(path.join(root, p), 'utf8'));
const walk = n => [n, ...(n.children || []).flatMap(walk)];
const inventory = read(`${snapshot}/evidence/inventory.json`);
const foundations = read(`${snapshot}/evidence/foundations.json`);
const consumers = read(`${snapshot}/evidence/consumers.json`);
const backgrounds = read(`${snapshot}/evidence/backgrounds.json`);
const icons = read('docs/snapshots/2026-10-20_development-icons/icons.json');
if (!inventory.complete || inventory.next !== null || inventory.total !== inventory.variants.length || inventory.total !== 5 || new Set(inventory.variants.map(v=>v.id)).size!==5 || !foundations.complete || foundations.missing.length || !consumers.complete || consumers.next!==null || consumers.consumers.length!==4 || !backgrounds.complete || backgrounds.roots.length!==4) throw Error('Incomplete App Bar evidence');
const masters = {'18422:11366':'crown','18422:12234':'currency','14559:951':'addCoins','18422:12323':'help','18517:6375':'back','18517:6410':'downloads','18517:6460':'bookmark'};
const rows = inventory.variants.map(v => {
  const evidence = read(`${snapshot}/evidence/variant-${v.id.replace(':','-')}.json`);
  if (!evidence.complete || evidence.root.id !== v.id) throw Error('Incomplete variant '+v.id);
  const n = evidence.root, all = walk(n), parts = {body:n}, artwork = {};
  const category = v.props.Therme.startsWith('Home') ? 'home' : v.props.Therme.startsWith('Back') ? 'back' : 'downloadableGame';
  const one = (name, from=all) => {const a=from.filter(x=>x.name===name);if(a.length!==1)throw Error(`Ambiguous ${v.id}/${name}`);return a[0];};
  parts.spacer = one('Empty Space');
  if (category !== 'back') {parts.avatarAction=one('Trailing Avatar');parts.avatar=one('Avatar');parts.avatarText=parts.avatar.children[0];}
  if (category === 'home') {
    for (const [role,name] of Object.entries({wallet:'Wallet',points:'Points',coins:'Coins',pointsAmount:'Points Amount',coinsAmount:'Coins Amount'})) parts[role]=one(name);
    parts.pointsValue=parts.pointsAmount.children[0];parts.pointsUnit=parts.pointsAmount.children[1];parts.coinsValue=parts.coinsAmount.children[0];
    parts.pointsIcon=parts.points.children[0];parts.coinsIcon=parts.coins.children[0];parts.addSurface=parts.coins.children[2];
  }
  if (category !== 'home') parts.backSurface=n.children[0].children[0];
  if (category === 'downloadableGame') {parts.overlay=one('Badge');parts.dot=parts.overlay.children[0];}
  for (const inst of all.filter(x=>x.type==='INSTANCE')) {
    const role=masters[inst.mainComponent?.id];if(!role)throw Error('Unexpected master '+inst.mainComponent?.id);
    const entry=icons.versions.find(x=>x.nodeId===inst.mainComponent.id);if(!entry)throw Error('Unknown local icon');
    const file=path.join(root,'packages/design_system',entry.assetPath);
    if(!fs.existsSync(file)||!fs.statSync(file).size)throw Error('Missing artwork '+file);
    const hash=crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');if(hash!==entry.sha256)throw Error('Changed original SVG');
    const paints=walk(inst).filter(x=>x.fills?.some(p=>p.visible!==false));if(paints.length!==1)throw Error('Unsupported icon paints');
    artwork[role]={...entry,instanceId:inst.id,rawName:inst.mainComponent.name,paintNode:paints[0],geometry:{width:inst.width,height:inst.height}};
    parts[role+'Artwork']=inst;
    if(['back','help','downloads','bookmark'].includes(role))parts[role+'Action']=n.children.find(c=>walk(c).some(x=>x.id===inst.id));
  }
  // Preserve the tree as evidence; normalized roles are references to actual nodes.
  const flat=Object.fromEntries(all.map(x=>[x.id,Object.fromEntries(Object.entries(x).filter(([k])=>k!=='children'))]));
  return {id:v.id,rawName:v.name,sourceAxis:v.props,category,brightness:v.props.Therme.endsWith('Light')?'light':'dark',fileKey:inventory.fileKey,setId:inventory.id,setName:inventory.name,parts:Object.fromEntries(Object.entries(parts).map(([k,x])=>[k,flat[x.id]])),artwork,reactions:all.flatMap(x=>(x.reactions||[]).map(r=>({nodeId:x.id,...r})))};
});
const data={rows,foundations,backgrounds,engineering:read('design/engineering/app_bar.json')};
function output(p,s){const f=path.join(root,p);if(check){if(!fs.existsSync(f)||fs.readFileSync(f,'utf8')!==s)throw Error('Stale '+p);}else{fs.mkdirSync(path.dirname(f),{recursive:true});fs.writeFileSync(f,s);}}
output(`${snapshot}/app_bars.json`,JSON.stringify(data,null,2)+'\n');
output(`${snapshot}/manifest.json`,JSON.stringify({status:'DEVELOPMENT',sourceAccess:'read-only MCP',fileKey:inventory.fileKey,page:inventory.page,versionId:null,designerApproval:null,counts:{sets:1,sourceVariants:rows.length,categories:3},pagination:{total:inventory.total,next:inventory.next,complete:inventory.complete},evidenceHashes:Object.fromEntries(fs.readdirSync(path.join(root,snapshot,'evidence')).sort().map(f=>[f,crypto.createHash('sha256').update(fs.readFileSync(path.join(root,snapshot,'evidence',f))).digest('hex')]))},null,2)+'\n');
const temp=path.join(root,'build/app-bar-generation/app_bar_data.g.dart');fs.mkdirSync(path.dirname(temp),{recursive:true});
fs.writeFileSync(temp,`// GENERATED by tool/tokens/generate_app_bars.cjs. Do not edit.\nconst appBarSourceData = <String,dynamic>${JSON.stringify(data).replace(/\$/g,'\\$')};\n`);
execFileSync(process.env.DART||'D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe',['format',temp]);
output('packages/design_system/lib/src/tokens/generated/app_bar_data.g.dart',fs.readFileSync(temp,'utf8'));
console.log(`${check?'Verified':'Generated'} 5 source App Bar variants, 3 categories; exact local SVG hashes verified.`);
