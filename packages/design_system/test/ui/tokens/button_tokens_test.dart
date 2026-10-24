import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

const snapshot = '../../docs/snapshots/2026-10-19_development-buttons';
Map<String, dynamic> read(String name) =>
    jsonDecode(File('$snapshot/$name').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  final source = read('variables.json');
  final variables = (source['vars'] as List).cast<Map<String, dynamic>>();
  final collections = {
    for (final c
        in (source['collections'] as List).cast<Map<String, dynamic>>())
      c['id']: c,
  };
  final styles = (read('text_styles.json')['styles'] as List)
      .cast<Map<String, dynamic>>();

  test('generated catalog contains every scoped variable exactly once', () {
    expect(
      ColorTokens.allById.keys,
      unorderedEquals(variables.map((v) => v['id'])),
    );
    final generated = File('lib/src/tokens/generated/button_tokens.g.dart')
        .readAsStringSync();
    expect(generated, contains('GENERATED – do not edit'));
    for (final v in variables) {
      final token = ColorTokens.allById[v['id']]!;
      expect(token.id, v['id']);
      expect(token.name, v['name']);
      expect(token.collectionId, v['collectionId']);
      expect(token.collectionName, collections[v['collectionId']]!['name']);
      expect(generated, contains('Figma: ${v['name']} | ${v['id']}'));
    }
  });

  for (final v in variables) {
    for (final entry in (v['valuesByMode'] as Map<String, dynamic>).entries) {
      test('${v['id']} mode ${entry.key} preserves exact RGBA', () {
        final token = ColorTokens.allById[v['id']]!;
        final actual = token.valuesByMode[entry.key]!;
        final value = entry.value as Map<String, dynamic>;
        expect(actual.r, value['r']);
        expect(actual.g, value['g']);
        expect(actual.b, value['b']);
        expect(actual.a, value['a']);
        expect(
          token.valuesByMode.keys,
          unorderedEquals((v['valuesByMode'] as Map).keys),
        );
        expect(
          token.defaultModeId,
          collections[v['collectionId']]!['defaultModeId'],
        );
      });
    }
  }

  test(
    'every style retains source metrics/units/tags and converted TextStyle',
    () {
      expect(
        TypographyTokens.byId.keys,
        unorderedEquals(styles.map((s) => s['id'])),
      );
      expect(
        TypographyTokens.byName.keys,
        unorderedEquals(styles.map((s) => s['name'])),
      );
      for (final source in styles) {
        final token = TypographyTokens.byId[source['id']]!;
        final raw = source['typography'] as Map<String, dynamic>;
        final font = raw['fontName'] as Map<String, dynamic>;
        final size = (raw['fontSize'] as num).toDouble();
        expect(token.name, source['name']);
        expect(token.rawTypography, raw);
        expect(identical(TypographyTokens.byName[token.name], token), isTrue);
        final actual = token.style;
        expect(actual.fontSize, size);
        expect(
          actual.fontFamily,
          'packages/p2e_design_system/${font['family']}',
        );
        final weight = (font['variationSettings'] as Map)['wght'] as num;
        expect(actual.fontWeight!.value, weight);
        expect({
          for (final f in actual.fontVariations!) f.axis: f.value,
        }, isEmpty); // D-060: weight selects a real static face.
        final line = raw['lineHeight'] as Map;
        expect(actual.height, switch (line['unit']) {
          'PIXELS' => (line['value'] as num) / size,
          'PERCENT' => (line['value'] as num) / 100,
          'AUTO' => null,
          _ => throw StateError('Unsupported fixture unit'),
        });
        final spacing = raw['letterSpacing'] as Map;
        expect(actual.letterSpacing, switch (spacing['unit']) {
          'PERCENT' => size * ((spacing['value'] as num) / 100),
          'PIXELS' => spacing['value'],
          _ => throw StateError('Unsupported fixture unit'),
        });
      }
    },
  );

  test(
    'light/dark availability matches source; absent twins are not invented',
    () {
      final expected = <Brightness, Set<String>>{};
      for (final brightness in Brightness.values) {
        final modeName = brightness == Brightness.light
            ? 'Light Mode'
            : 'Dark Mode';
        expected[brightness] = variables
            .where((v) {
              final name = collections[v['collectionId']]!['name'] as String;
              return name == 'Base Color' || name.contains(modeName);
            })
            .map((v) => v['name'] as String)
            .toSet();
        final sourceTokens = brightness == Brightness.light
            ? ColorTokens.light
            : ColorTokens.dark;
        expect(sourceTokens.keys, unorderedEquals(expected[brightness]!));
        final theme = AppThemeFactory.build(brightness: brightness);
        final extension = theme.extension<ButtonThemeTokens>()!;
        expect(theme.brightness, brightness);
        expect(extension.colors.keys, unorderedEquals(sourceTokens.keys));
        for (final entry in sourceTokens.entries) {
          expect(extension.color(entry.key), entry.value.value);
        }
        expect(extension.textStyles, {
          for (final s in TypographyTokens.byName.entries) s.key: s.value.style,
        });
      }
      final report = jsonDecode(
        File('../../docs/design-system/buttons-token-report.json')
            .readAsStringSync(),
      ) as Map;
      expect(
        report['parity']['lightOnly'],
        unorderedEquals(
          expected[Brightness.light]!.difference(expected[Brightness.dark]!),
        ),
      );
      expect(
        report['parity']['darkOnly'],
        unorderedEquals(
          expected[Brightness.dark]!.difference(expected[Brightness.light]!),
        ),
      );
      expect(ColorTokens.light.length, ColorTokens.dark.length);
    },
  );

  test('unbound report preserves evidence and declares missing examples', () {
    final report = jsonDecode(
      File('../../docs/design-system/buttons-token-report.json')
          .readAsStringSync(),
    ) as Map;
    final lint = read('lint.json')['unboundPaint'] as Map;
    final paints = report['unboundPaints'] as Map;
    expect(paints['reportedCount'], lint['count']);
    final observed = paints['observed'] as List;
    expect(observed.length, (lint['examples'] as List).length);
    expect(paints['unrecordedCount'], (lint['count'] as int) - observed.length);
    for (final example in lint['examples'] as List) {
      final actual = observed.singleWhere((p) => p['nodeId'] == example['id']);
      expect(actual['rawPaint'], example['paint']);
      expect(actual['componentSet']['id'], example['id']);
      for (final suggestion in actual['suggestedMappingsOnly'] as List) {
        expect(ColorTokens.allById.containsKey(suggestion['id']), isTrue);
      }
    }
  });

  test('hidden report includes every explicitly hidden Snapshot child', () {
    final report = jsonDecode(
      File('../../docs/design-system/buttons-token-report.json')
          .readAsStringSync(),
    ) as Map;
    final manifest = read('manifest.json');
    final hiddenIds = <String>[];
    for (final name in manifest['artifacts']['components'] as List) {
      for (final variant in read(name as String)['variants'] as List) {
        for (final child in variant['children'] as List) {
          if (child['visible'] == false) hiddenIds.add(child['id'] as String);
        }
      }
    }
    expect(
      (report['hiddenNodes'] as List).map((n) => n['nodeId']),
      unorderedEquals(hiddenIds),
    );
  });

  test('extension copy/interpolation preserves endpoints and explicit availability', () {
    final light = ButtonThemeTokens.forBrightness(Brightness.light);
    final dark = ButtonThemeTokens.forBrightness(Brightness.dark);
    expect(light.copyWith().colors, light.colors);
    expect(light.copyWith(colors: dark.colors).colors, dark.colors);
    expect(light.lerp(dark, 0).colors, light.colors);
    expect(light.lerp(dark, 1).colors, dark.colors);
    expect(light.lerp(null, 0.5), same(light));
    final midpoint = light.lerp(dark, 0.5);
    expect(midpoint.colors.keys, unorderedEquals(dark.colors.keys));
    for (final key in light.colors.keys.toSet().intersection(
      dark.colors.keys.toSet(),
    )) {
      expect(
        midpoint.color(key),
        Color.lerp(light.color(key), dark.color(key), 0.5),
      );
    }
    for (final key in light.colors.keys.toSet().difference(
      dark.colors.keys.toSet(),
    )) {
      expect(() => dark.color(key), throwsStateError);
    }
  });
}
