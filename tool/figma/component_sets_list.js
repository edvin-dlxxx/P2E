// P = {pageId, offset?:0, limit?:100}. Both sets and standalone components are paginated.
const P = %PARAMS%;
const root = await loadPage(P.pageId);
const entries = [];
for (const set of root.findAllWithCriteria({ types: ['COMPONENT_SET'] })) {
  entries.push({ kind: 'set', id: set.id, name: set.name,
    variantCount: children(set).length, properties: raw(set.componentPropertyDefinitions) });
}
for (const component of root.findAllWithCriteria({ types: ['COMPONENT'] })) {
  if (component.parent?.type === 'COMPONENT_SET') continue;
  entries.push({ kind: 'component', id: component.id, name: component.name,
    geometry: geometry(component), properties: raw(component.componentPropertyDefinitions) });
}
entries.sort(byId);
const pg = page(entries, P, 100);
return out({ pageId: root.id, page: root.name, total: pg.total, offset: pg.offset, next: pg.next, entries: pg.slice });
