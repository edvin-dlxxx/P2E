const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
const data = JSON.parse(fs.readFileSync(path.join(root, 'design/engineering/readiness.json'), 'utf8'));
const target = path.join(root, 'packages/design_system/lib/src/tokens/generated/readiness_tokens.g.dart');
const output = '// GENERATED from design/engineering/readiness.json. Do not edit.\n' +
  '// D-044 chrome/content scaling; D-045 provisional loading artwork metrics.\n' +
  Object.entries(data).map(([key, value]) => `const double ${key} = ${value};\n`).join('');
if (process.argv.includes('--check')) {
  if (!fs.existsSync(target) || fs.readFileSync(target, 'utf8').replace(/\r\n/g, '\n') !== output) {
    throw Error('Readiness tokens are stale');
  }
} else fs.writeFileSync(target, output);
