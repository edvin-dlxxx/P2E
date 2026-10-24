import 'dart:convert';
import 'dart:io';

const snapshotDefault = 'docs/snapshots/2026-10-19_development-buttons';
const generated = 'GENERATED – do not edit';

Map<String, dynamic> object(dynamic value) => value as Map<String, dynamic>;
List<Map<String, dynamic>> objects(dynamic value) =>
    (value as List).map(object).toList();
Map<String, dynamic> readJson(String path) =>
    object(jsonDecode(File(path).readAsStringSync()));

String quote(String value) => jsonEncode(value).replaceAll(r'$', r'\$');
String literal(dynamic value) {
  if (value is String) return quote(value);
  if (value is List) return '[${value.map(literal).join(',')}]';
  if (value is Map) {
    return '{${value.entries.map((e) => '${quote(e.key as String)}: ${literal(e.value)}').join(',')}}';
  }
  if (value == null || value is bool || value is num) return '$value';
  throw StateError('Unsupported source value: $value');
}

String number(dynamic value) {
  if (value is! num || !value.isFinite) {
    throw StateError('Missing/nonfinite metric: $value');
  }
  return value.toDouble().toString();
}

String identifier(String value) {
  final words =
      value.replaceAll('%', ' percent ').split(RegExp('[^a-zA-Z0-9]+'))
        ..removeWhere((w) => w.isEmpty);
  final result =
      words.first.toLowerCase() +
      words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1)).join();
  if (!RegExp(r'^[a-z][a-zA-Z0-9]*$').hasMatch(result)) {
    throw StateError('Invalid identifier: $value');
  }
  return result;
}

String themeOf(Map<String, dynamic> collection) {
  final name = collection['name'] as String;
  if (name.contains('Light Mode')) return 'light';
  if (name.contains('Dark Mode')) return 'dark';
  if (name == 'Base Color') return 'shared';
  throw StateError('Unmapped collection (no inferred theme): $name');
}

String colorLiteral(Map<String, dynamic> value) {
  for (final channel in ['a', 'r', 'g', 'b']) {
    final n = value[channel];
    if (n is! num || n < 0 || n > 1) {
      throw StateError('Invalid/missing COLOR channel: $channel');
    }
  }
  return 'Color.from(alpha: ${number(value['a'])}, '
      'red: ${number(value['r'])}, green: ${number(value['g'])}, '
      'blue: ${number(value['b'])})';
}

String? lineHeight(Map<String, dynamic> metric, dynamic fontSize) =>
    switch (metric['unit']) {
      'PIXELS' => '${number(metric['value'])} / ${number(fontSize)}',
      'PERCENT' => '${number(metric['value'])} / 100',
      'AUTO' => null,
      _ => throw StateError('Unsupported line-height unit: $metric'),
    };

String letterSpacing(Map<String, dynamic> metric, dynamic fontSize) =>
    switch (metric['unit']) {
      'PIXELS' => number(metric['value']),
      'PERCENT' => '${number(fontSize)} * (${number(metric['value'])} / 100)',
      _ => throw StateError('Unsupported letter-spacing unit: $metric'),
    };

Future<String> format(String source) async {
  final process = await Process.start(Platform.resolvedExecutable, [
    'format',
    '--output=show',
    '--summary=none',
  ]);
  final output = process.stdout.transform(utf8.decoder).join();
  final error = process.stderr.transform(utf8.decoder).join();
  process.stdin.write(source);
  await process.stdin.close();
  if (await process.exitCode != 0) throw StateError(await error);
  return output;
}

Future<void> main(List<String> args) async {
  final check = args.contains('--check');
  final sourceIndex = args.indexOf('--snapshot');
  final source = sourceIndex < 0 ? snapshotDefault : args[sourceIndex + 1];
  final manifest = readJson('$source/manifest.json');
  if (manifest['status'] != 'DEVELOPMENT' ||
      object(manifest['completeness'])['result'] != 'PASS') {
    throw StateError('A complete DEVELOPMENT Snapshot is required');
  }
  final variables = readJson('$source/variables.json');
  final vars = objects(variables['vars'])
    ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  final collections = {
    for (final c in objects(variables['collections'])) c['id']: c,
  };
  final byId = {for (final v in vars) v['id']: v};
  final symbol = <String, String>{};
  final themes = {'light': <String, String>{}, 'dark': <String, String>{}};
  final code = StringBuffer('''// $generated
// Source: $source (DEVELOPMENT; version lock unverified).
// Reproduce: dart run tool/tokens/generate_buttons.dart
import 'package:flutter/painting.dart';
import '../button_token_types.dart';

abstract final class ColorTokens {
''');
  Map<String, dynamic> resolve(String id, String mode, Set<String> trail) {
    if (!trail.add('$id@$mode')) throw StateError('Alias cycle: $trail');
    final v = byId[id];
    if (v == null) throw StateError('Unresolved Variable: $id');
    final value = object(object(v['valuesByMode'])[mode]);
    if (value['type'] == 'VARIABLE_ALIAS') {
      // Exact mode only: cross-collection mode correspondence is never guessed.
      return resolve(value['id'] as String, mode, trail);
    }
    return value;
  }

  final resolved = <String, Map<String, dynamic>>{};
  for (final v in vars) {
    if (v['resolvedType'] != 'COLOR' || v['status'] != 'available') {
      throw StateError('Unsupported/unavailable scoped variable: ${v['id']}');
    }
    final c = collections[v['collectionId']]!;
    final modes = objects(c['modes']);
    if (modes.length != 1) {
      throw StateError(
        'Theme mode selection needs explicit mapping: ${c['id']}',
      );
    }
    final group = themeOf(c);
    final id = v['id'] as String;
    final name = v['name'] as String;
    final field = identifier('$group $name');
    if (symbol.containsValue(field)) throw StateError('Name collision: $field');
    symbol[id] = field;
    code.writeln('/// Figma: $name | $id. Collection: ${c['name']}.');
    code.writeln('static const $field = FigmaColorToken(');
    code.writeln('id: ${quote(id)}, name: ${quote(name)},');
    code.writeln(
      'collectionId: ${quote(c['id'])}, collectionName: ${quote(c['name'])},',
    );
    code.writeln(
      'defaultModeId: ${quote(c['defaultModeId'])}, valuesByMode: {',
    );
    for (final mode in modes) {
      final modeId = mode['modeId'] as String;
      final value = resolve(id, modeId, {});
      resolved['$id@$modeId'] = value;
      code.writeln('${quote(modeId)}: ${colorLiteral(value)},');
    }
    code.writeln('});');
    for (final theme in themes.keys) {
      if (group == theme || group == 'shared') {
        if (themes[theme]!.containsKey(name)) {
          throw StateError('Role collision: $name');
        }
        themes[theme]![name] = field;
      }
    }
  }
  code.writeln('static const allById = <String, FigmaColorToken>{');
  for (final e in symbol.entries) {
    code.writeln('${quote(e.key)}: ${e.value},');
  }
  code.writeln('};');
  for (final theme in themes.keys) {
    code.writeln('static const $theme = <String, FigmaColorToken>{');
    final names = themes[theme]!.keys.toList()..sort();
    for (final name in names) {
      code.writeln('${quote(name)}: ${themes[theme]![name]},');
    }
    code.writeln('};');
  }
  code.writeln('}\nabstract final class TypographyTokens {');
  final styles = objects(readJson('$source/text_styles.json')['styles']);
  final styleSymbols = <String, String>{};
  for (final s in styles) {
    final t = object(s['typography']);
    final font = object(t['fontName']);
    final variations = object(font['variationSettings']);
    final weight = t['fontWeight'] is num
        ? t['fontWeight']
        : variations['wght'];
    if (weight is! num || weight % 100 != 0 || weight < 100 || weight > 900) {
      throw StateError('No exact Flutter weight from source: ${s['id']}');
    }
    if (t['textCase'] != 'ORIGINAL' || t['textDecoration'] != 'NONE') {
      throw StateError('Unsupported text transformation: ${s['id']}');
    }
    final field = identifier(s['name']);
    styleSymbols[s['id']] = field;
    code.writeln('/// Figma: ${s['name']} | ${s['id']}.');
    code.writeln('static const $field = FigmaTextToken(');
    code.writeln('id: ${quote(s['id'])}, name: ${quote(s['name'])},');
    code.writeln('rawTypography: ${literal(t)},');
    code.writeln(
      'style: TextStyle(fontFamily: ${quote(font['family'])}, package: "p2e_design_system",',
    );
    code.writeln(
      'fontSize: ${number(t['fontSize'])}, fontWeight: FontWeight.w${weight.toInt()},',
    );
    code.writeln(
      'fontVariations: [${variations.entries.map((e) => 'FontVariation(${quote(e.key)}, ${number(e.value)})').join(',')}],',
    );
    final height = lineHeight(object(t['lineHeight']), t['fontSize']);
    if (height != null) code.writeln('height: $height,');
    code.writeln(
      'letterSpacing: ${letterSpacing(object(t['letterSpacing']), t['fontSize'])},),);',
    );
  }
  code.writeln('static const byId = <String, FigmaTextToken>{');
  for (final e in styleSymbols.entries) {
    code.writeln('${quote(e.key)}: ${e.value},');
  }
  code.writeln('};\nstatic const byName = <String, FigmaTextToken>{');
  for (final s in styles) {
    code.writeln('${quote(s['name'])}: ${styleSymbols[s['id']]},');
  }
  code.writeln('};\n}');

  final lint = readJson('$source/lint.json');
  final components = [
    for (final path in object(manifest['artifacts'])['components'] as List)
      readJson('$source/$path'),
  ];
  final setById = {
    for (final c in components) object(c['set'])['id']: object(c['set']),
  };
  final unbound = <Map<String, dynamic>>[];
  for (final example in objects(object(lint['unboundPaint'])['examples'])) {
    final paint = object(example['paint']);
    final rgb = object(paint['color']);
    final matches = vars
        .where((v) {
          return object(v['valuesByMode']).keys.any((mode) {
            final value = resolved['${v['id']}@$mode']!;
            return paint['opacity'] == 1 &&
                ['r', 'g', 'b'].every((k) => value[k] == rgb[k]) &&
                value['a'] == (rgb['a'] ?? 1);
          });
        })
        .map((v) => {'id': v['id'], 'name': v['name']})
        .toList();
    unbound.add({
      'nodeId': example['id'],
      'componentSet': {
        'id': setById[example['id']]?['id'],
        'name': setById[example['id']]?['name'],
      },
      'field': example['field'],
      'rawPaint': paint,
      'suggestedMappingsOnly': matches,
    });
  }
  final hidden = <Map<String, dynamic>>[];
  for (final c in components) {
    for (final v in objects(c['variants'])) {
      for (final node in objects(v['children'])) {
        if (node['visible'] == false) {
          hidden.add({
            'componentSet': {
              'id': object(c['set'])['id'],
              'name': object(c['set'])['name'],
            },
            'variantId': v['id'],
            'variantName': v['name'],
            'nodeId': node['id'],
            'name': node['name'],
            'type': node['type'],
          });
        }
      }
    }
  }
  hidden.sort(
    (a, b) => (a['nodeId'] as String).compareTo(b['nodeId'] as String),
  );
  final lightOnly =
      themes['light']!.keys
          .where((k) => !themes['dark']!.containsKey(k))
          .toList()
        ..sort();
  final darkOnly =
      themes['dark']!.keys
          .where((k) => !themes['light']!.containsKey(k))
          .toList()
        ..sort();
  final report = {
    'generated': generated,
    'source': source,
    'sourceStatus': manifest['status'],
    'technicalVersionLock': manifest['technicalVersionLock'],
    'counts': {
      'variables': vars.length,
      'light': themes['light']!.length,
      'dark': themes['dark']!.length,
      'textStyles': styles.length,
    },
    'parity': {
      'lightOnly': lightOnly,
      'darkOnly': darkOnly,
      'substitutionApplied': false,
    },
    'unboundPaints': {
      'reportedCount': object(lint['unboundPaint'])['count'],
      'observed': unbound,
      'unrecordedCount':
          (object(lint['unboundPaint'])['count'] as int) - unbound.length,
      'gap': 'Snapshot lint examples are limited; remaining node IDs and colors are unavailable. No values inferred.',
    },
    'hiddenNodes': hidden,
    'hiddenSummary': {
      for (final name in hidden.map((n) => n['name'] as String).toSet())
        name: hidden.where((n) => n['name'] == name).length,
    },
    'limits': [
      'Only scoped COLOR variables exist; no spacing/radius/duration variables were invented.',
      'Outfit metrics are generated; font binaries are not present or installed by this generator.',
      'Material ColorScheme/TextTheme semantic mappings are not inferred.',
    ],
  };
  final markdown = StringBuffer('''# Button token source report

$generated

Source: $source (DEVELOPMENT, technical version lock unverified).

${vars.length} source COLOR variables; ${themes['light']!.length} active colors per Light theme and ${themes['dark']!.length} per Dark theme; ${styles.length} text styles shared by both.
No spacing, radius or motion variables were added.

## Source parity gaps

Light only: ${lightOnly.join(', ')}.
Dark only: ${darkOnly.join(', ')}.
No counterpart or semantic substitution was invented.

## Unbound paints

Lint reports ${object(lint['unboundPaint'])['count']} paints, but only ${unbound.length} detailed examples are present. The remaining node IDs and raw colors are unavailable in this Snapshot. This is a data gap, not a token mapping.

| Component set | Node | Field | Original color channels | Paint opacity | Suggested mapping only |
|---|---|---|---|---|---|
''');
  for (final item in unbound) {
    final paint = object(item['rawPaint']);
    markdown.writeln(
      '| ${object(item['componentSet'])['name']} | ${item['nodeId']} | ${item['field']} | ${jsonEncode(paint['color'])} | ${paint['opacity']} | ${(item['suggestedMappingsOnly'] as List).isEmpty ? 'None (no exact match)' : jsonEncode(item['suggestedMappingsOnly'])} |',
    );
  }
  markdown.writeln('''
## Hidden nodes

${hidden.length} hidden nodes. The JSON companion lists every node, set, variant and type. No tokens were generated for them.
''');
  for (final e in object(report['hiddenSummary']).entries) {
    markdown.writeln(
      '- ${e.key}: ${e.value}; hidden Outline instance alternatives in the optional icon anatomy.',
    );
  }
  markdown.writeln('''
## Limits

Outfit and Vazirmatn are bundled in packages/design_system/assets with licenses. Tests validate source values, metric conversion and real-font geometry; no rasterization/golden approval is claimed. ThemeData exposes the Button ThemeExtension; product UI and Material role mappings are not implemented.
''');
  final outputs = {
    'packages/design_system/lib/src/tokens/generated/button_tokens.g.dart':
        await format(code.toString()),
    'docs/design-system/buttons-token-report.json':
        '${const JsonEncoder.withIndent('  ').convert(report)}\n',
    'docs/design-system/buttons-token-report.md': markdown.toString(),
  };
  for (final entry in outputs.entries) {
    final file = File(entry.key);
    if (check) {
      if (!file.existsSync() || file.readAsStringSync() != entry.value) {
        throw StateError('Generated output is stale: ${entry.key}');
      }
    } else {
      if (file.existsSync() && !file.readAsStringSync().contains(generated)) {
        throw StateError('Refusing to overwrite unmanaged file: ${entry.key}');
      }
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
  }
  stdout.writeln(
    '${check ? 'Verified' : 'Generated'} ${outputs.length} files; ${vars.length} variables, ${styles.length} text styles.',
  );
}
