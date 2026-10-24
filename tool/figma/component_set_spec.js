// P = {ids:[setId], depth?:2, offset?:0, limit?:10}
const P = %PARAMS%;
if (!Array.isArray(P.ids) || !P.ids.length || P.ids.some(id => typeof id !== 'string')) throw new Error('Explicit set ids are required');
const depth = P.depth === undefined ? 2 : P.depth;
if (!Number.isSafeInteger(depth) || depth < 0) throw new Error('depth must be a nonnegative safe integer');
const variants = [];
for (const id of [...new Set(P.ids)].sort(cmp)) {
  const set = await figma.getNodeByIdAsync(id);
  if (!set || set.type !== 'COMPONENT_SET') throw new Error('Unresolved component set: ' + id);
  for (const variant of children(set)) variants.push({ set, variant });
}
variants.sort((a, b) => cmp(a.set.id, b.set.id) || cmp(a.variant.id, b.variant.id));
const pg = page(variants, P, 10);
const rows = [];
for (const { set, variant } of pg.slice) {
  const kids = []; await walk(variant, depth, kids);
  rows.push({ setId: set.id, setName: set.name, id: variant.id, name: variant.name,
    geometry: geometry(variant), fills: await pf(variant.fills), strokes: await pf(variant.strokes),
    opacity: raw(variant.opacity), effects: raw(variant.effects), bindings: await bvn(variant),
    reactions: raw(variant.reactions), variantProperties: raw(variant.variantProperties), children: kids });
}
return out({ total: pg.total, offset: pg.offset, next: pg.next, depth, rows });
