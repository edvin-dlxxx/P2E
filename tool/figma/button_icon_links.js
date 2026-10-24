// Read-only master-instance links for explicitly scoped Button sets.
const P = %PARAMS%;
let pg = await figma.getNodeByIdAsync(P.setIds[0]);
while (pg.type !== 'PAGE') pg = pg.parent;
await figma.setCurrentPageAsync(pg);
const variants = [];
for (const id of P.setIds) {
  const set = await figma.getNodeByIdAsync(id);
  for (const variant of set.children.filter(n=>n.type==='COMPONENT')) {
    const icons = [];
    for (const n of variant.findAllWithCriteria({types:['INSTANCE']})) {
      const main = await n.getMainComponentAsync();
      if (main && ['14466:880','14466:925'].includes(main.parent.id)) {
        icons.push({instanceId:n.id,name:n.name,visible:n.visible,componentProperties:n.componentProperties,mainComponentId:main.id,mainComponentName:main.name,setId:main.parent.id,setName:main.parent.name});
      }
    }
    variants.push({id:variant.id,name:variant.name,setId:set.id,icons});
  }
}
return {variants};
