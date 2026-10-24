import 'dart:io';

/// Compatibility entry point; the full source registry now owns Button artwork.
Future<void> main(List<String> args) async {
  final result = await Process.run('node', [
    'tool/tokens/generate_icons.cjs',
    ...args,
  ]);
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  exitCode = result.exitCode;
}
