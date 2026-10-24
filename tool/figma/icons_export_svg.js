// P = {setId, offset?:0, limit?:8}. This script is not run by local tests against Figma.
const P = %PARAMS%;
const set = await figma.getNodeByIdAsync(P.setId);
if (!set || !('children' in set)) throw new Error('Unresolved icon set: ' + P.setId);
const pg = page(children(set).slice().sort(byId), P, 8);
const icons = [];
for (const component of pg.slice) {
  const svg = await component.exportAsync({ format: 'SVG_STRING' });
  icons.push({ id: component.id, name: component.name, geometry: geometry(component), svg });
}
return out({ setId: set.id, set: set.name, total: pg.total, offset: pg.offset, next: pg.next, icons });
