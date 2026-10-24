// Packs a read-only Figma script for the `use_figma` MCP tool.
//
//   dart run tool/figma/pack.dart <script> '<json params>' [--out <file>]
//   dart run tool/figma/pack.dart page_inventory '{"pageId":"16458:11"}'
//
// Output = helpers.js + <script>.js with %PARAMS% replaced. Pass it as `code`, together with the
// file key from docs/agents/figma-map.md and a short `description`.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln(
      'usage: dart run tool/figma/pack.dart <script> \'<json params>\' [--out <file>]',
    );
    exit(2);
  }
  final dir = File.fromUri(Platform.script).parent.path;
  final name = args[0].endsWith('.js') ? args[0] : '${args[0]}.js';
  final script = File('$dir/$name');
  if (!script.existsSync() || name == 'helpers.js') {
    stderr.writeln('Unknown script: $name');
    exit(2);
  }
  final Object? params;
  try {
    params = jsonDecode(args[1]);
  } on FormatException catch (e) {
    stderr.writeln('Params must be JSON: ${e.message}');
    exit(2);
  }
  if (params is! Map) {
    stderr.writeln('Params must be a JSON object.');
    exit(2);
  }
  final source = script.readAsStringSync();
  if (!source.contains('%PARAMS%')) {
    stderr.writeln('$name has no %PARAMS% placeholder.');
    exit(2);
  }
  final code =
      '${File('$dir/helpers.js').readAsStringSync()}\n${source.replaceAll('%PARAMS%', jsonEncode(params))}';
  final outIndex = args.indexOf('--out');
  if (outIndex >= 0 && outIndex + 1 < args.length) {
    File(args[outIndex + 1]).writeAsStringSync(code);
    stdout.writeln('wrote ${args[outIndex + 1]} (${code.length} chars)');
  } else {
    stdout.write(code);
  }
}
