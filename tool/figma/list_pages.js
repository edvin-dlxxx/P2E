// Lists pages. P = {}
const P = %PARAMS%;
return out({ file: figma.root.name, pages: figma.root.children.map((p) => ({ id: p.id, name: p.name })) });
