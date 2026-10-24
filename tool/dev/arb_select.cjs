// Merge independent feature-owned branches without deleting other Inspector fields.
exports.mergeSelect=(source,branches,other)=>{
  const values=new Map([...source.matchAll(/([A-Za-z_]\w*)\{([^{}]*)\}/g)].map(m=>[m[1],m[2]]));
  values.delete('other');for(const [key,value]of Object.entries(branches))values.set(key,value);
  return '{field, select, '+[...values].map(([k,v])=>`${k}{${v}}`).join(' ')+` other{${other}}}`;
};
