'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const workspace = path.resolve(__dirname, '../../..');
const source = path.join(workspace, 'docs/snapshots/2026-10-19_development-buttons-complete');
const assembler = path.join(workspace, 'tool/figma/assemble_buttons_snapshot.cjs');
const run = folder => spawnSync(process.execPath, [assembler, '--source=' + folder, '--check'], {
  cwd: workspace, encoding: 'utf8', windowsHide: true,
});
function fixture(t) {
  const parent = path.join(workspace, '.dart_tool/buttons-snapshot-test-fixtures');
  fs.mkdirSync(parent, { recursive: true });
  const folder = fs.mkdtempSync(path.join(parent, 'case-'));
  fs.cpSync(source, folder, { recursive: true });
  t.after(() => {
    const relative = path.relative(parent, path.resolve(folder));
    assert(relative && !relative.startsWith('..') && !path.isAbsolute(relative));
    fs.rmSync(folder, { recursive: true });
  });
  return folder;
}

test('real Buttons package has complete pages, references and unchanged raw/SVG bytes', () => {
  const result = run(source);
  assert.equal(result.status, 0, result.stderr);
  assert.match(result.stdout, /90 variants.*18 variables.*3 SVGs.*774 origins/);
});

test('raw text differing from its MCP wrapper is rejected', t => {
  const folder = fixture(t);
  const call = JSON.parse(fs.readFileSync(path.join(folder, 'calls.json')))[0];
  fs.appendFileSync(path.join(folder, 'raw', call.textFiles[0]), '\n');
  const result = run(folder);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Raw response text changed/);
});

test('missing origin page cannot be reported as complete', t => {
  const folder = fixture(t);
  const call = JSON.parse(fs.readFileSync(path.join(folder, 'calls.json')))
    .find(c => c.name === 'scoped_variable_provenance');
  const responsePath = path.join(folder, 'raw', call.response);
  const response = JSON.parse(fs.readFileSync(responsePath));
  const block = response.content.find(c => c.type === 'text');
  const envelope = JSON.parse(block.text);
  envelope.batches.shift();
  block.text = JSON.stringify(envelope);
  fs.writeFileSync(responsePath, JSON.stringify(response));
  fs.writeFileSync(path.join(folder, 'raw', call.textFiles[0]), block.text);
  const result = run(folder);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Missing\/overlapping page/);
});

test('exported SVG modification is rejected by reproducibility check', t => {
  const folder = fixture(t);
  fs.appendFileSync(path.join(folder, 'icons/fill/crown.svg'), '\n');
  const result = run(folder);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Stale artifact: icons\/fill\/crown.svg/);
});
