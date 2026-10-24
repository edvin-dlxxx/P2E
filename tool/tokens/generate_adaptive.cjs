const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
const values = JSON.parse(fs.readFileSync(path.join(root, 'design/engineering/adaptive.json'), 'utf8'));
const target = path.join(root, 'packages/design_system/lib/src/tokens/generated/adaptive_tokens.g.dart');
const output = '// GENERATED from design/engineering/adaptive.json. Do not edit.\n' +
  '// Architecture section 16; provisional Entry content cap (D-039).\n' +
  'abstract final class AdaptiveTokens {\n' +
  Object.entries(values).map(([key, value]) => `  static const double ${key} = ${value};\n`).join('') + '}\n';
if (process.argv.includes('--check')) {
  if (!fs.existsSync(target) || fs.readFileSync(target, 'utf8').replace(/\r\n/g, '\n') !== output) {
    console.error('Adaptive tokens are stale'); process.exit(1);
  }
} else { fs.writeFileSync(target, output); }
