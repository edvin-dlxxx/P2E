import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_architecture.dart';

void main() {
  late Directory root;
  setUp(() => root = Directory.systemTemp.createTempSync('p2e-architecture-'));
  tearDown(() => root.deleteSync(recursive: true));
  void write(String name, String body) {
    final file = File('${root.path}/$name');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(body);
  }

  test(
    'every forbidden layer direction fails for relative and package imports',
    () {
      const forbidden = {
        'core': ['ui', 'shared', 'features', 'app'],
        'ui': ['core', 'shared', 'features', 'app'],
        'shared': ['features', 'app'],
        'features': ['app'],
      };
      for (final source in forbidden.entries) {
        for (final destination in source.value) {
          final from = source.key == 'features' ? 'features/entry' : source.key;
          final to = destination == 'features'
              ? 'features/missions/public'
              : destination;
          for (final uri in [
            '${source.key == 'features' ? '../../' : '../'}$to/model.dart',
            'package:mygame_p2e/$to/model.dart',
          ]) {
            final path = 'lib/$from/layer_probe.dart';
            write(path, "import '$uri';");
            expect(
              checkArchitecture(root).join('\n'),
              contains('forbidden layer'),
              reason: '${source.key} -> $destination ($uri)',
            );
            File('${root.path}/$path').deleteSync();
          }
        }
      }
    },
  );

  test('every banned feature widget and its named constructor is rejected', () {
    for (final widget in [
      'ElevatedButton',
      'FilledButton',
      'OutlinedButton',
      'TextButton',
      'IconButton',
      'TextField',
      'TextFormField',
      'Card',
      'Chip',
      'InputChip',
      'FilterChip',
      'ChoiceChip',
      'ActionChip',
      'Switch',
      'SwitchListTile',
      'Checkbox',
      'Radio',
      'AlertDialog',
      'showDialog',
      'showModalBottomSheet',
      'SnackBar',
      'AppBar',
    ]) {
      for (final constructor in [widget, '$widget.adaptive']) {
        write(
          'lib/features/entry/banned.dart',
          'final value = $constructor();',
        );
        expect(
          checkArchitecture(root).join('\n'),
          contains('banned feature widget'),
          reason: constructor,
        );
      }
    }
  });

  final violations = <String, (String, String)>{
    'product cannot import inspection entrypoint': (
      'lib/app/bad.dart',
      "import 'package:p2e_design_system/inspection.dart';",
    ),
    'product cannot import testing entrypoint': (
      'lib/app/bad.dart',
      "import 'package:p2e_design_system/testing.dart';",
    ),
    'core cannot reach shared': (
      'lib/core/bad.dart',
      "import '../shared/session.dart';",
    ),
    'core cannot reach DS': (
      'lib/core/bad.dart',
      "import 'package:p2e_design_system/design_system.dart';",
    ),
    'ui cannot reach core': ('lib/ui/bad.dart', "import '../core/model.dart';"),
    'shared cannot reach app': (
      'lib/shared/bad.dart',
      "import '../app/app.dart';",
    ),
    'shared cannot reach feature': (
      'lib/shared/bad.dart',
      "import '../features/entry/entry.dart';",
    ),
    'feature cannot reach app': (
      'lib/features/entry/bad.dart',
      "import '../../app/app.dart';",
    ),
    'cross-feature src': (
      'lib/features/home/bad.dart',
      "import '../missions/src/private.dart';",
    ),
    'unapproved feature edge': (
      'lib/features/entry/bad.dart',
      "import '../wallet/wallet.dart';",
    ),
    'home has no incoming feature edge': (
      'lib/features/games/bad.dart',
      "import '../home/home.dart';",
    ),
    'domain is pure Dart': (
      'lib/features/entry/src/domain/bad.dart',
      "import 'package:flutter/widgets.dart';",
    ),
    'data cannot reach presentation': (
      'lib/features/entry/src/data/bad.dart',
      "import '../presentation/view.dart';",
    ),
    'presentation uses data through providers': (
      'lib/features/entry/src/presentation/bad.dart',
      "import '../data/repository.dart';",
    ),
    'SDK is data-only': (
      'lib/app/bad.dart',
      "import 'package:api_sdk/client.dart';",
    ),
    'dart io forbidden in shared': ('lib/shared/bad.dart', "import 'dart:io';"),
    'platform inspection forbidden': (
      'lib/features/entry/bad.dart',
      'final p = Platform.isAndroid;',
    ),
    'feature widget ban': (
      'lib/features/entry/bad.dart',
      'Widget build() => TextField();',
    ),
    'raw feature visuals': (
      'lib/features/entry/bad.dart',
      'final c = Color(0xff000000);',
    ),
    'DS public barrel only': (
      'lib/app/bad.dart',
      "import 'package:p2e_design_system/other.dart';",
    ),
    'DS cannot depend on Riverpod': (
      'packages/design_system/lib/bad.dart',
      "import 'package:flutter_riverpod/flutter_riverpod.dart';",
    ),
    'runtime tool reference': (
      'lib/app/bad.dart',
      "import '../../dev_tools/host.dart';",
    ),
    'viewer tool reference': (
      'apps/design_system_viewer/test/bad.dart',
      "import '../../../dev_tools/helper.dart';",
    ),
    'package tool reference': (
      'packages/design_system/pubspec.yaml',
      'dependency: ../../dev_tools/',
    ),
    'CI tool reference': (
      '.github/workflows/build.yml',
      'run: dart dev_tools/check.dart',
    ),
    'workspace tool reference': (
      'project.code-workspace',
      '{"path":"dev_tools/"}',
    ),
  };
  for (final entry in violations.entries) {
    test('rejects ${entry.key}', () {
      write(entry.value.$1, entry.value.$2);
      expect(checkArchitecture(root), isNotEmpty);
    });
  }
  for (final uri in [
    'package:mygame_p2e/core/errors/app_failure.dart',
    '../../../../core/errors/app_failure.dart',
  ]) {
    test('D-055 domain shared result import passes: $uri', () {
      write(
        'lib/core/errors/app_failure.dart',
        "import 'dart:core'; import 'dart:async'; class AppFailure {}",
      );
      write('lib/features/auth/src/domain/repositories.dart', "import '$uri';");
      expect(checkArchitecture(root), isEmpty);
    });
  }
  for (final uri in [
    'package:flutter/widgets.dart',
    'package:flutter_riverpod/flutter_riverpod.dart',
    'package:mygame_p2e/core/diagnostics/app_logger.dart',
    'package:mygame_p2e/core/errors/app_failure_extra.dart',
    'package:mygame_p2e/core/errors/nested/app_failure.dart',
    'package:mygame_p2e/shared/session/session.dart',
    '../data/repository.dart',
    '../presentation/controller.dart',
  ]) {
    test('D-055 retains other domain boundary: $uri', () {
      write('lib/features/auth/src/domain/repositories.dart', "import '$uri';");
      expect(
        checkArchitecture(root).join('\\n'),
        contains('domain must be pure Dart'),
      );
    });
  }
  for (final uri in [
    'dart:io',
    'dart:ui',
    'dart:convert',
    'package:flutter/widgets.dart',
    'package:riverpod/riverpod.dart',
    '../diagnostics/app_logger.dart',
  ]) {
    test('D-055 rejects impure shared contract fixture: $uri', () {
      final source = File('lib/core/errors/app_failure.dart')
          .readAsStringSync();
      write('lib/core/errors/app_failure.dart', "import '$uri';\\n$source");
      write(
        'lib/features/auth/src/domain/repositories.dart',
        "import 'package:mygame_p2e/core/errors/app_failure.dart';",
      );
      expect(
        checkArchitecture(root).join('\\n'),
        contains('D-055 permits only'),
      );
    });
  }
  test('D-055 shared contract cannot be part of another library', () {
    write('lib/core/errors/app_failure.dart', 'part of unsafe_library;');
    expect(
      checkArchitecture(root).join('\\n'),
      contains('standalone pure library'),
    );
  });

  test('approved feature/public and foundation edges remain legal', () {
    write('lib/features/home/home.dart', "import '../missions/missions.dart';");
    write(
      'lib/features/missions/missions.dart',
      "export 'src/domain/model.dart';",
    );
    write('lib/features/missions/src/domain/model.dart', "import 'dart:math';");
    write('lib/core/files.dart', "import 'dart:io';");
    write('lib/app/platform/native.dart', "import 'dart:io';");
    expect(checkArchitecture(root), isEmpty);
  });

  test('dev boundary permits main_dev and dev imports', () {
    write('lib/main.dart', "import 'app.dart';");
    write('lib/main_dev.dart', "import 'dev/view.dart';");
    write('lib/dev/view.dart', "import 'helper.dart';");
    expect(checkArchitecture(root), isEmpty);
  });
  test(
    'transitive exports into dev and string/icon violations are reported',
    () {
      write('lib/main.dart', "export 'app/leak.dart';");
      write('lib/app/leak.dart', "export '../dev/view.dart';");
      write('lib/dev/view.dart', '');
      write(
        'lib/ui/bad.dart',
        "Text('Product string'); Semantics(label: 'bad'); Icons.add;",
      );
      write('lib/ui/generated/bad.g.dart', 'const bad = 1;');
      write(
        'pubspec.yaml',
        'dependencies:\n  google_fonts: any\n  cupertino_icons: any\n',
      );
      final issues = checkArchitecture(root).join('\n');
      expect(issues, contains('release graph reaches lib/dev'));
      expect(issues, contains('dev import/export'));
      expect(issues, contains('hard-coded Text/Semantics'));
      expect(issues, contains('GENERATED header'));
      expect(issues, contains('prohibited Icons'));
      expect(issues, contains('google_fonts'));
      expect(issues, contains('cupertino_icons'));
    },
  );
  test(
    'cross-package imports and dependencies cannot bypass the boundaries',
    () {
      write(
        'lib/main.dart',
        "import 'package:p2e_design_system/design_system.dart';",
      );
      write(
        'packages/design_system/lib/design_system.dart',
        "export 'src/button.dart';",
      );
      write(
        'packages/design_system/lib/src/button.dart',
        "import 'package:p2e_design_system_viewer/viewer.dart';",
      );
      write('apps/design_system_viewer/lib/viewer.dart', '');
      write(
        'apps/design_system_viewer/lib/main.dart',
        "import 'package:p2e_design_system/src/button.dart';",
      );
      write(
        'packages/design_system/pubspec.yaml',
        'name: p2e_design_system\ndependencies:\n  mygame_p2e: any\n',
      );
      final issues = checkArchitecture(root).join('\n');
      expect(issues, contains('Design System reaches app'));
      expect(issues, contains('consumer imports package src'));
      expect(issues, contains('Design System depends on an app'));
      expect(
        issues,
        contains('release graph reaches apps/design_system_viewer'),
      );
    },
  );
}
