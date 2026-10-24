import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  final root = File.fromUri(Platform.script).parent.parent;
  final translations = <String, Map<String, String>>{};
  for (final locale in ['en', 'fa']) {
    final arb = jsonDecode(
      File('${root.path}/l10n/tool_$locale.arb').readAsStringSync(),
    ) as Map;
    translations[locale] = {
      for (final e in arb.entries)
        if (!e.key.toString().startsWith('@'))
          e.key as String: e.value as String,
    };
  }
  for (final key in translations['en']!.keys.where(
    (key) => key.startsWith('sample'),
  )) {
    if (!translations['fa']!.containsKey(key)) {
      throw StateError('Missing fixture translation: $key');
    }
  }
  final source =
      '// GENERATED from l10n/tool_en.arb and tool_fa.arb. Do not edit.\n'
      'const toolCopyData = ${jsonEncode(translations).replaceAll(r'$', r'\$')};\n';
  final temporary = Directory.systemTemp.createTempSync('p2e-tool-copy-');
  final file = File('${temporary.path}/copy.dart');
  try {
    file.writeAsStringSync(source);
    final format = Process.runSync(Platform.resolvedExecutable, [
      'format',
      file.path,
    ]);
    if (format.exitCode != 0) throw StateError('Copy formatting failed');
    final output = file.readAsStringSync();
    final target = File('${root.path}/lib/src/host/generated/tool_copy.g.dart');
    if (arguments.contains('--check')) {
      if (!target.existsSync() ||
          target.readAsStringSync().replaceAll('\r\n', '\n') !=
              output.replaceAll('\r\n', '\n')) {
        throw StateError('Tool copy is stale');
      }
      stdout.writeln('Tool ARB copy verified.');
    } else {
      target.parent.createSync(recursive: true);
      target.writeAsStringSync(output);
    }
  } finally {
    if (file.existsSync()) file.deleteSync();
    temporary.deleteSync();
  }
}
