// Read-only. P = {setId, offset?:0, limit?:16}. No document mutation or export.
const P = %PARAMS%;
const set = await figma.getNodeByIdAsync(P.setId);
let page = set;
while (page && page.type !== 'PAGE') page = page.parent;
await figma.setCurrentPageAsync(page);
const all = set.children.filter(n => n.type === 'COMPONENT').sort((a,b) => a.id.localeCompare(b.id));
const offset = P.offset || 0, limit = P.limit || 16;
function paints(n, list = []) {
  for (const property of ['fills','strokes']) {
    if (property in n && Array.isArray(n[property])) {
      for (const paint of n[property]) list.push({nodeId:n.id,property,paint});
    }
  }
  if ('boundVariables' in n && Object.keys(n.boundVariables || {}).length) list.push({nodeId:n.id,boundVariables:n.boundVariables});
  if ('children' in n) for (const c of n.children) paints(c,list);
  return list;
}
return {schemaVersion:'icons-1.0',setId:set.id,setName:set.name,total:all.length,offset,next:offset+limit<all.length?offset+limit:null,componentPropertyDefinitions:set.componentPropertyDefinitions,icons:all.slice(offset,offset+limit).map(n=>({id:n.id,key:n.key,name:n.name,width:n.width,height:n.height,variantProperties:n.variantProperties,componentPropertyDefinitionsRef:set.id,description:n.description,documentationLinks:n.documentationLinks,paints:paints(n)}))};
