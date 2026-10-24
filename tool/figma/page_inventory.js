// P = {pageId}; direct children remain in document order.
const P = %PARAMS%;
const root = await loadPage(P.pageId);
const frames = [];
for (const frame of children(root)) {
  const theme = {};
  if ('findAllWithCriteria' in frame) {
    for (const instance of frame.findAllWithCriteria({ types: ['INSTANCE'] })) {
      for (const [key, value] of Object.entries(instance.variantProperties || {})) if (/the?r?me/i.test(key)) {
        const name = key + '=' + value; theme[name] = (theme[name] || 0) + 1;
      }
    }
  }
  frames.push({ id: frame.id, name: frame.name, type: frame.type, geometry: geometry(frame),
    opacity: raw('opacity' in frame ? frame.opacity : undefined),
    background: await pf('fills' in frame ? frame.fills : undefined), bindings: await bvn(frame), theme });
}
return out({ pageId: root.id, page: root.name, count: frames.length, frames });
