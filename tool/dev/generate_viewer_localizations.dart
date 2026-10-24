import 'dart:convert';
import 'dart:io';

/// Regenerates with Flutter; --check generates to an isolated ignored project.
Future<void> main(List<String> args) async {
  const viewer = 'apps/design_system_viewer';
  final check = args.contains('--check');
  final config = jsonDecode(
    File('$viewer/.dart_tool/package_config.json').readAsStringSync(),
  ) as Map;
  final sdk = config['flutterRoot'] as String;
  final flutterRoot = Directory.fromUri(Uri.parse(sdk)).path;
  final dart =
      '$flutterRoot/bin/cache/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}';
  String cwd = Directory(viewer).absolute.path;
  if (check) {
    final temporary = Directory('build/viewer-shell/l10n-check')
      ..createSync(recursive: true);
    Directory('${temporary.path}/arb').createSync(recursive: true);
    Directory('${temporary.path}/lib').createSync(recursive: true);
    File('$viewer/pubspec.yaml').copySync('${temporary.path}/pubspec.yaml');
    for (final file in Directory(
      '$viewer/l10n/viewer',
    ).listSync().whereType<File>()) {
      file.copySync('${temporary.path}/arb/${file.uri.pathSegments.last}');
    }
    File('${temporary.path}/l10n.yaml').writeAsStringSync(
      File('$viewer/l10n.yaml')
          .readAsStringSync()
          .replaceFirst('arb-dir: l10n/viewer', 'arb-dir: arb')
          .replaceFirst(
            'output-dir: lib/l10n/generated',
            'output-dir: generated',
          ),
    );
    cwd = temporary.absolute.path;
  }
  final result = await Process.run(dart, [
    '$flutterRoot/bin/cache/flutter_tools.snapshot',
    'gen-l10n',
  ], workingDirectory: cwd);
  if (result.exitCode != 0) {
    throw StateError('${result.stdout}\n${result.stderr}');
  }
  if (check) {
    final generated = Directory('$cwd/generated').listSync().whereType<File>();
    var count = 0;
    for (final file in generated) {
      final target = File(
        '$viewer/lib/l10n/generated/${file.uri.pathSegments.last}',
      );
      if (!target.existsSync() ||
          target.readAsStringSync() != file.readAsStringSync()) {
        throw StateError('Stale localization output: ${target.path}');
      }
      count++;
    }
    if (count != 3) {
      throw StateError('Expected base, English and Persian generated classes');
    }
    stdout.writeln(
      'Verified $count Flutter localization files without modifying source outputs.',
    );
  }
}
