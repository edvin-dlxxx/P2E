// P = {offset?:0, limit?:80}
const P = %PARAMS%;
const styles = (await figma.getLocalTextStylesAsync()).slice().sort(byId);
const pg = page(styles, P, 80);
return out({ total: pg.total, offset: pg.offset, next: pg.next, styles: pg.slice.map(style => ({
  id: style.id, name: style.name, typography: typography(style), bindings: raw(style.boundVariables),
})) });
