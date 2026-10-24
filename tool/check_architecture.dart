import 'dart:io';

/// Checks all three runtime trees and package dependency directions.
/// Parsing remains lexical; native runners, tools and tests are not runtime code.
List<String> checkArchitecture(Directory root) {
  final violations = <String>[];
  const ds = 'packages/design_system';
  const viewer = 'apps/design_system_viewer';
  const packages = {
    'mygame_p2e': '',
    'p2e_design_system': ds,
    'p2e_design_system_viewer': viewer,
  };
  final graph = <String, List<String>>{};
  // D-055: one exact shared domain contract, not a directory/pattern allowlist.
  const domainCoreContract = 'lib/core/errors/app_failure.dart';
  // Architecture sections 8/9. Edges are public APIs only, never feature src.
  const featureEdges = {
    'home:missions',
    'home:leaderboard',
    'games:missions',
    'game_session:checkout',
    'shop:checkout',
  };
  String? feature(String path) =>
      RegExp(r'^lib/features/([^/]+)/').firstMatch(path)?[1];
  String? layer(String path) => path.startsWith('$ds/lib/')
      ? 'ui'
      : RegExp(r'^lib/(core|ui|shared|features|app)/').firstMatch(path)?[1];
  const allowed = {
    'core': {'core'},
    'ui': {'ui'},
    'shared': {'shared', 'core', 'ui'},
    'features': {'features', 'shared', 'core', 'ui'},
    'app': {'app', 'features', 'shared', 'core', 'ui'},
  };
  bool referencesDevTools(String value) =>
      RegExp(r'\bdev_tools(?:[/\\]|[\s"\x27]|$)').hasMatch(value);
  String relative(File file) => file.absolute.path
      .substring(root.absolute.path.length + 1)
      .replaceAll('\\', '/');
  String uncomment(String source) => source
      .replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '')
      .replaceAll(RegExp(r'^\s*//.*$', multiLine: true), '');
  String? resolve(File file, String uri) {
    if (uri.startsWith('package:')) {
      final path = uri.substring(8);
      final slash = path.indexOf('/');
      if (slash < 0) return null;
      final package = packages[path.substring(0, slash)];
      if (package == null) return null;
      return '${package.isEmpty ? '' : '$package/'}lib/${path.substring(slash + 1)}';
    }
    if (uri.contains(':')) return null;
    final target = File.fromUri(file.absolute.uri.resolve(uri));
    if (!target.path.startsWith(
      '${root.absolute.path}${Platform.pathSeparator}',
    )) {
      return null;
    }
    return relative(target);
  }

  final iconPackages = RegExp(
    r'(?:cupertino_icons|material_symbols_icons|font_awesome_flutter|lucide_icons|iconsax|hugeicons|phosphor_flutter)',
  );
  for (final scope in packages.values) {
    final prefix = scope.isEmpty ? '' : '$scope/';
    final pubspec = File('${root.path}/${prefix}pubspec.yaml');
    if (pubspec.existsSync()) {
      final content = pubspec.readAsStringSync();
      if (referencesDevTools(content)) {
        violations.add('${prefix}pubspec.yaml: dev_tools reference');
      }
      for (final line in content.split('\n')) {
        if (RegExp(r'^\s*(?:google_fonts|' + iconPackages.pattern + r')\s*:')
            .hasMatch(line)) {
          violations.add(
            '${prefix}pubspec.yaml: prohibited font/icon package: ${line.trim()}',
          );
        }
      }
      if (scope == ds &&
          RegExp(
            r'^\s*(?:mygame_p2e|p2e_design_system_viewer)\s*:',
            multiLine: true,
          ).hasMatch(content)) {
        violations.add('$ds: Design System depends on an app');
      }
      if (scope.isEmpty &&
          RegExp(
            r'^\s*p2e_design_system_viewer\s*:',
            multiLine: true,
          ).hasMatch(content)) {
        violations.add('product depends on viewer');
      }
    }
    final lib = Directory('${root.path}/${prefix}lib');
    if (!lib.existsSync()) continue;
    for (final file in lib.listSync(recursive: true).whereType<File>()) {
      final path = relative(file), raw = file.readAsStringSync();
      if (referencesDevTools(raw)) violations.add('$path: dev_tools reference');
      final generated =
          path.contains('/generated/') ||
          path.endsWith('.g.dart') ||
          path.endsWith('.freezed.dart');
      if (generated &&
          !raw
              .substring(0, raw.length < 600 ? raw.length : 600)
              .contains(RegExp('GENERATED', caseSensitive: false))) {
        violations.add('$path: generated file lacks GENERATED header');
      }
      if (!path.endsWith('.dart')) continue;
      final code = uncomment(raw), targets = <String>[];
      if (path == domainCoreContract &&
          RegExp(r'\bpart\s+of\b').hasMatch(code)) {
        violations.add(
          '$path: D-055 contract must be a standalone pure library',
        );
      }
      for (final directive in RegExp(
        r'''\b(?:import|export|part(?!\s+of))\s+([^;]+);''',
      ).allMatches(code)) {
        for (final match in RegExp(
          r'''['"]([^'"]+)['"]''',
        ).allMatches(directive[1]!)) {
          final uri = match[1]!, target = resolve(file, uri);
          if (uri == 'dart:io' &&
              !path.startsWith('lib/core/') &&
              !path.startsWith('lib/app/platform/')) {
            violations.add('$path: dart:io outside core/app/platform');
          }
          if (scope == ds &&
              RegExp(
                r'^package:(?:flutter_riverpod|riverpod|riverpod_annotation)/',
              ).hasMatch(uri)) {
            violations.add('$path: Design System must be plain Flutter');
          }
          if (path == domainCoreContract &&
              uri != 'dart:core' &&
              uri != 'dart:async') {
            violations.add(
              '$path: D-055 permits only dart:core/dart:async directives: $uri',
            );
          }
          if (path.contains('/src/domain/') &&
              !(uri.startsWith('dart:') &&
                  uri != 'dart:io' &&
                  uri != 'dart:ui') &&
              target != domainCoreContract &&
              !(target != null &&
                  feature(path) == feature(target) &&
                  target.contains('/src/domain/'))) {
            violations.add('$path: domain must be pure Dart');
          }
          if (RegExp(r'^package:(?:api_sdk|backend_sdk)/').hasMatch(uri) &&
              !path.startsWith('lib/shared/backend/') &&
              !(feature(path) != null && path.contains('/src/data/'))) {
            violations.add('$path: backend SDK outside data boundary');
          }
          if (target != null) {
            targets.add(target);
            final from = layer(path), to = layer(target);
            if (from != null && to != null && !allowed[from]!.contains(to)) {
              violations.add('$path: forbidden layer $from -> $to: $uri');
            }
            final sourceFeature = feature(path),
                targetFeature = feature(target);
            if (targetFeature != null && targetFeature != sourceFeature) {
              if (target.contains('/src/')) {
                violations.add('$path: feature private src import: $uri');
              }
              if (sourceFeature != null &&
                  (targetFeature == 'home' ||
                      !featureEdges.contains(
                        '$sourceFeature:$targetFeature',
                      ))) {
                violations.add(
                  '$path: forbidden feature edge $sourceFeature -> $targetFeature',
                );
              }
            }
            if (sourceFeature != null &&
                path.contains('/src/data/') &&
                !(target.contains('lib/features/$sourceFeature/src/data/') ||
                    target.contains(
                      'lib/features/$sourceFeature/src/domain/',
                    ) ||
                    target.startsWith('lib/shared/backend/') ||
                    target.startsWith('lib/core/'))) {
              violations.add(
                '$path: data layer dependency outside domain/backend/core',
              );
            }
            if (sourceFeature != null &&
                path.contains('/src/presentation/') &&
                target.contains('/src/data/') &&
                !RegExp(r'(?:/providers/|/[^/]*providers?\.dart$)')
                    .hasMatch(target)) {
              violations.add(
                '$path: presentation may reach data only via providers',
              );
            }
            if (target.startsWith('lib/dev/') &&
                !path.startsWith('lib/dev/') &&
                path != 'lib/main_dev.dart') {
              violations.add(
                '$path: dev import/export/part outside main_dev: $uri',
              );
            }
            if (scope == ds &&
                (target.startsWith('lib/') || target.startsWith('$viewer/'))) {
              violations.add('$path: Design System reaches app: $target');
            }
            if (scope != ds &&
                target.startsWith('$ds/lib/') &&
                target != '$ds/lib/design_system.dart' &&
                !(scope == viewer && target == '$ds/lib/testing.dart')) {
              violations.add(
                '$path: consumer imports package src implementation: $uri',
              );
            }
            if (scope.isEmpty && target.startsWith('$viewer/')) {
              violations.add('$path: product imports viewer: $uri');
            }
          }
          if (uri.startsWith('package:') && iconPackages.hasMatch(uri)) {
            violations.add('$path: prohibited icon package $uri');
          }
          if (uri.contains('google_fonts')) {
            violations.add('$path: runtime font package $uri');
          }
        }
      }
      graph[path] = targets;
      if (!path.startsWith('lib/core/') &&
          !path.startsWith('lib/app/platform/') &&
          RegExp(r'\b(?:Platform\s*\.\s*is\w+|defaultTargetPlatform)\b')
              .hasMatch(code)) {
        violations.add('$path: platform branching outside core/app/platform');
      }
      if (path.startsWith('lib/features/')) {
        if (RegExp(
          r'\b(?:ElevatedButton|FilledButton|OutlinedButton|TextButton|IconButton|TextField|TextFormField|Card|\w*Chip|Switch|SwitchListTile|Checkbox|Radio|AlertDialog|showDialog|showModalBottomSheet|SnackBar|AppBar)\s*(?:<[^>]+>)?\s*(?:\.\w+\s*)?\(',
        ).hasMatch(code)) {
          violations.add('$path: banned feature widget');
        }
      }
      if (path.startsWith('lib/features/') ||
          path.startsWith('lib/shared/widgets/')) {
        if (RegExp(
          r'\b(?:Color\s*\(|Colors\s*\.|fontSize\s*:\s*\d|Radius\.circular\s*\(\s*\d)',
        ).hasMatch(code)) {
          violations.add('$path: raw feature/shared visual value');
        }
      }
      if (RegExp(r'\b(?:Icons|CupertinoIcons)\s*\.').hasMatch(code)) {
        violations.add('$path: prohibited Icons/CupertinoIcons member');
      }
      if (RegExp(r'\bGoogleFonts\s*\.').hasMatch(code) ||
          RegExp(
            r'''https?://[^'"\s]+\.(?:ttf|otf|woff2?)''',
            caseSensitive: false,
          ).hasMatch(code)) {
        violations.add('$path: possible runtime font download');
      }
      final productUi =
          path.startsWith('lib/ui/') ||
          path.startsWith('lib/app/') ||
          scope == ds;
      if (productUi && !generated) {
        if (RegExp(r'''\bText(?:\.rich)?\s*\(\s*(?:r)?['"]''').hasMatch(code) ||
            RegExp(
              r'''\bSemantics\s*\([^;]{0,500}?\b(?:label|hint|value)\s*:\s*(?:r)?['"]''',
            ).hasMatch(code)) {
          violations.add(
            '$path: hard-coded Text/Semantics string (best-effort lexical check)',
          );
        }
      }
    }
  }
  // Configuration/CI and non-runtime app/package files must also be detachable.
  for (final directory in [
    'config',
    '.github',
    '.vscode',
    'android',
    'ios',
    'assets',
    'apps',
    'packages',
  ]) {
    final folder = Directory('${root.path}/$directory');
    if (!folder.existsSync()) continue;
    for (final file in folder.listSync(recursive: true).whereType<File>()) {
      final path = relative(file);
      if (RegExp(r'/(?:build|\.dart_tool|ephemeral)/').hasMatch(path)) continue;
      if (!RegExp(
        r'\.(?:dart|yaml|yml|json|toml|xml|gradle|kts|kt|swift|plist|pbxproj)$',
      ).hasMatch(path)) {
        continue;
      }
      if (referencesDevTools(file.readAsStringSync())) {
        violations.add('$path: dev_tools reference');
      }
    }
  }
  for (final file in root.listSync().whereType<File>()) {
    if (RegExp(r'\.(?:yaml|yml|json|toml|code-workspace)$')
            .hasMatch(file.path) &&
        referencesDevTools(file.readAsStringSync())) {
      violations.add('${relative(file)}: dev_tools reference');
    }
  }
  final visited = <String>{};
  void visit(String path) {
    if (!visited.add(path)) return;
    if (path.startsWith('lib/dev/') || path.startsWith('$viewer/')) {
      violations.add('lib/main.dart release graph reaches $path');
    }
    for (final target in graph[path] ?? <String>[]) {
      visit(target);
    }
  }

  visit('lib/main.dart');
  return violations;
}

void main(List<String> args) {
  final violations = checkArchitecture(Directory.current);
  if (violations.isNotEmpty) {
    stderr.writeln(violations.join('\n'));
    exitCode = 1;
  } else {
    stdout.writeln(
      'Architecture checks passed: product, Design System and viewer runtime trees.',
    );
  }
}
