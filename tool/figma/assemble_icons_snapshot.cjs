// Local assembly only. Source evidence is collected by read-only MCP scripts.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const root = path.resolve(__dirname, '../..');
const snapshot = 'docs/snapshots/2026-10-20_development-icons';
const hash = data => crypto.createHash('sha256').update(data).digest('hex');
const json = data => JSON.stringify(data, null, 2) + '\n';
function output(file, content, check) {
  const target = path.join(root, file);
  if (check) {
    if (!fs.existsSync(target) || !fs.readFileSync(target).equals(Buffer.from(content))) throw Error('Stale/missing output: ' + file);
  } else {
    fs.mkdirSync(path.dirname(target), {recursive:true}); fs.writeFileSync(target, content);
  }
}
function assemble(check = false) {
  const dir = path.join(root, snapshot), evidence = path.join(dir, 'evidence');
  const files = fs.readdirSync(evidence).filter(x => x.endsWith('.json')).sort();
  const read = file => JSON.parse(fs.readFileSync(path.join(evidence, file)));
  const page = read('page-inventory.json');
  const mapping = JSON.parse(fs.readFileSync(path.join(root, 'design/icons/identity_mapping.json')));
  for(const property of ['id','dartId'])if(new Set(mapping.icons.map(i=>i[property])).size!==mapping.icons.length)throw Error('Stable identity collision: '+property);
  const versions = [], seen = new Set(), duplicates = [];
  for (const set of page.sets) {
    const style = set.name.toLowerCase();
    if (!['fill','outline'].includes(style)) throw Error('New style needs an explicit runtime enum: ' + set.name);
    const consume = prefix => {
      const pages = files.filter(f => f.startsWith(prefix + style + '-')).map(read).sort((a,b)=>a.offset-b.offset);
      let offset = 0; const items=[];
      for (let i=0;i<pages.length;i++) {
        const p=pages[i];
        if (p.offset!==offset || p.total!==set.count || p.setId!==set.id) throw Error('Pagination gap: '+prefix+style+' '+offset);
        items.push(...p.icons);offset+=p.icons.length;
        if (p.next !== (offset < p.total ? offset : null)) throw Error('Invalid next: '+prefix+style);
      }
      if(offset!==set.count)throw Error('Incomplete '+prefix+style);
      return items;
    };
    const inventory=consume('inventory-'), exports=consume('export-');
    const exported=new Map(exports.map(i=>[i.id,i]));
    if(exported.size!==exports.length)throw Error('Duplicate exported IDs');
    for(const source of inventory) {
      if(seen.has(source.id)){duplicates.push(source.id);continue;}seen.add(source.id);
      const svg=exported.get(source.id);
      if(!svg || svg.name!==source.name)throw Error('Missing/mismatched export: '+source.id);
      const matches=mapping.icons.filter(i=>i.sources[style]===source.id);
      if(matches.length!==1)throw Error('Unmapped/ambiguous source: '+source.id);
      const identity=matches[0];
      if(identity.rawName!==source.variantProperties.Icon)throw Error('Raw name changed: '+source.id);
      const file=`icons/${style}/${identity.id}.svg`;
      output(`${snapshot}/${file}`,svg.svg,check);
      const features=[...new Set([...svg.svg.matchAll(/<([a-zA-Z][\w:-]*)\b/g)].map(m=>m[1]))].sort();
      const colors=[...new Set([...svg.svg.matchAll(/(?:fill|stroke)="([^"]+)"/g)].map(m=>m[1]).filter(c=>c!=='none'))].sort();
      const complex=features.some(t=>['linearGradient','radialGradient','pattern','image','filter','foreignObject','text','use'].includes(t));
      versions.push({logicalKey:`icon.${identity.id}`,iconId:identity.id,dartId:identity.dartId,style,
        fileKey:page.fileKey,nodeId:source.id,rawName:source.name,setId:set.id,setName:set.name,
        width:source.width,height:source.height,viewBox:svg.svg.match(/viewBox="([^"]+)"/)?.[1]??null,
        variantProperties:source.variantProperties,componentPropertyDefinitionsRef:set.id,
        description:source.description,documentationLinks:source.documentationLinks,
        originalPaints:source.paints,originalColors:colors,features,monochrome:!complex&&colors.length===1,
        file,assetPath:`assets/icons/system/${style}/${identity.id}.svg`,sha256:hash(svg.svg),
        extractionStatus:'exported',renderStatus:'pending-validation',issue:null,derived:false});
    }
  }
  if(duplicates.length || versions.length!==page.definitions)throw Error('Definition reconciliation failed');
  versions.sort((a,b)=>a.logicalKey.localeCompare(b.logicalKey)||a.style.localeCompare(b.style));
  const validationFile=path.join(dir,'validation.json');
  const validation=fs.existsSync(validationFile)?JSON.parse(fs.readFileSync(validationFile)):null;
  if(validation)for(const v of versions) {
    const result=validation.versions[v.nodeId];
    if(!result || result.sha256!==v.sha256 || !result.rendered || !result.nonempty)throw Error('Missing/stale renderer validation: '+v.nodeId);
    v.renderStatus='renderer-validated';
  }
  const concepts=[...new Set(versions.map(v=>v.logicalKey))].sort().map(key=>{
    const rows=versions.filter(v=>v.logicalKey===key), identity=mapping.icons.find(i=>`icon.${i.id}`===key);
    return {key,id:identity.id,dartId:identity.dartId,rawName:identity.rawName,aliases:[identity.id],mirrorInRtl:identity.mirrorInRtl,
      styles:rows.map(r=>r.style),missingStyles:['fill','outline'].filter(s=>!rows.some(r=>r.style===s))};
  });
  if(concepts.length!==mapping.icons.length)throw Error('Unused identity mappings remain');
  const links=files.filter(f=>f.startsWith('button-links-')).flatMap(f=>read(f).variants);
  const buttonIcons={};
  for(const v of links) {
    if(buttonIcons[v.id])throw Error('Duplicate Button source ID');
    buttonIcons[v.id]={};
    for(const i of v.icons) {
      const artwork=versions.find(a=>a.nodeId===i.mainComponentId);
      if(!artwork)throw Error('Button artwork outside exported library');
      if(buttonIcons[v.id][artwork.style] && buttonIcons[v.id][artwork.style]!==artwork.logicalKey)throw Error('Ambiguous Button artwork');
      buttonIcons[v.id][artwork.style]=artwork.logicalKey;
    }
  }
  const evidenceHashes=Object.fromEntries(files.map(f=>[f,hash(fs.readFileSync(path.join(evidence,f)))]));
  const manifest={schemaVersion:'icons-1.0',status:'DEVELOPMENT',date:'2026-10-20',fileKey:page.fileKey,page:page.page,
    observedRootName:page.fileName,versionLabel:null,versionId:null,designerApproval:null,license:null,attribution:null,
    sourceAccess:'read-only MCP Plugin API',sets:page.sets,counts:{logicalIcons:concepts.length,artworkVersions:versions.length,
      fill:versions.filter(v=>v.style==='fill').length,outline:versions.filter(v=>v.style==='outline').length,other:0,
      exported:versions.length,renderable:validation?versions.length:null,failed:0,missingCounterparts:concepts.filter(c=>c.missingStyles.length).length},
    duplicateIds:duplicates,nameCollisions:[],ambiguousPairs:[],evidenceHashes,
    renderValidation:'See checked-in validation.json; never inferred from successful export.',
    provenance:'Original SVG_STRING bytes retained unchanged; runtime copies are byte-identical. No license/redistribution rights established.'};
  output(`${snapshot}/icons.json`,json({concepts,versions,buttonIcons}),check);
  output(`${snapshot}/manifest.json`,json(manifest),check);
  console.log(`${check?'Verified':'Assembled'} ${concepts.length} logical icons, ${versions.length} original SVG versions; ${manifest.counts.missingCounterparts} missing counterparts.`);
  return {concepts,versions,buttonIcons,manifest};
}
module.exports={assemble,output,json,root,snapshot,hash};
if(require.main===module)assemble(process.argv.includes('--check'));
