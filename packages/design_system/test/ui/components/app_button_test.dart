import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

const source = '../../docs/snapshots/2026-10-19_development-buttons';
Map<String, dynamic> read(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

void main() {
  final manifest = read('$source/manifest.json');
  final sourceRows = <String, Map>{};
  for (final file in manifest['artifacts']['components'] as List) {
    for (final row in read('$source/$file')['variants'] as List) {
      sourceRows[row['id'] as String] = row as Map;
    }
  }
  final variableData = read('$source/variables.json');
  final vars = {for (final v in variableData['vars'] as List) v['id']: v};
  Color? expectedPaint(List paints) {
    final visible = paints.where((p) => p['visible'] != false);
    if (visible.isEmpty) return null;
    final p = visible.single as Map;
    final id = p['boundVariables']?['color']?['id'];
    final c = id == null
        ? p['color'] as Map
        : (vars[id]['valuesByMode'] as Map).values.single as Map;
    return Color.from(
      alpha:
          (c['a'] as num? ?? 1).toDouble() * (p['opacity'] as num).toDouble(),
      red: (c['r'] as num).toDouble(),
      green: (c['g'] as num).toDouble(),
      blue: (c['b'] as num).toDouble(),
    );
  }

  test('90-row generated contract matches Snapshot properties without substitutions', () {
    expect(ButtonSpec.all.map((s) => s.id), unorderedEquals(sourceRows.keys));
    expect(ButtonSpec.all.length, 90);
    for (final spec in ButtonSpec.all) {
      final row = sourceRows[spec.id]!;
      expect(spec.data['geometry'], row['geometry']);
      expect(spec.data['fills'], row['fills']['raw']);
      expect(spec.data['strokes'], row['strokes']['raw']);
      expect(spec.data['rawAxes'], row['variantProperties']);
      expect(spec.rawName, row['name']);
      expect(spec.setId, row['setId']);
      expect(spec.setName, row['setName']);
      final sourceText = (row['children'] as List)
          .where((n) => n['type'] == 'TEXT')
          .firstOrNull;
      expect(spec.data['text'], sourceText);
      final sourceIcon = (row['children'] as List).firstWhere(
        (n) => n['type'] == 'FRAME' && (n['name'] as String).startsWith('Icon'),
      );
      expect(spec.data['icon'], sourceIcon);
      final outline = (row['children'] as List).lastWhere(
        (n) => n['type'] == 'VECTOR' && (n['fills']['raw'] as List).isNotEmpty,
      );
      expect(spec.data['outlineIconPaints'], outline['fills']['raw']);
      final theme = ButtonThemeTokens.forBrightness(spec.brightness);
      expect(
        spec.resolve(theme, iconMode: ButtonIconMode.outline).sourceIconColor,
        expectedPaint(outline['fills']['raw'] as List),
      );
    }
  });

  for (final input in ButtonSpec.all) {
    for (final brightness in Brightness.values) {
      testWidgets(
        '${input.id} under ${brightness.name} resolves the source twin and exact style',
        (tester) async {
          final spec = ButtonSpec.lookup(
            family: input.family,
            size: input.size,
            type: input.type,
            brightness: brightness,
          );
          final raw = sourceRows[spec.id]!;
          final disabled = spec.type == AppButtonType.disabled;
          final direction = input.brightness == Brightness.light
              ? TextDirection.rtl
              : TextDirection.ltr;
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey('${input.id}.${brightness.name}'),
              theme: AppThemeFactory.build(brightness: brightness),
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: SizedBox(
                    width: 330,
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: AppButton(
                        elementId: 'test.button.control',
                        runtimeLocator: const UiRuntimeLocator(
                          routeName: 'test',
                          routeInstanceId: 'test-instance',
                        ),
                        label: 'Secret sample',
                        family: input.family,
                        iconMode: ButtonIconMode.fill,
                        icon: const AssetAppIcon(AppIconId.editSquare),
                        size: input.size,
                        type: input.type,
                        onPressed: disabled ? null : () {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final widget = tester.widget<TextButton>(find.byType(TextButton));
          final states = disabled ? {WidgetState.disabled} : <WidgetState>{};
          final actual = widget.style!;
          expect(
            actual.minimumSize!.resolve(states),
            Size(
              spec.family == AppButtonFamily.icon ? spec.width : 0,
              spec.minimumVisualHeight,
            ),
          );
          expect(actual.padding!.resolve(states), spec.visualPadding);
          expect(
            actual.backgroundColor!.resolve(states),
            expectedPaint(raw['fills']['raw'] as List),
          );
          final text = (raw['children'] as List)
              .where((n) => n['type'] == 'TEXT')
              .firstOrNull;
          final vector = (raw['children'] as List).firstWhere(
            (n) =>
                n['type'] == 'VECTOR' && (n['fills']['raw'] as List).isNotEmpty,
          );
          expect(
            actual.foregroundColor!.resolve(states),
            disabled && brightness == Brightness.light
                ? ButtonThemeTokens.forBrightness(brightness)
                      .color('On Surface/Emphasis')
                : expectedPaint(
                    text == null
                        ? vector['fills']['raw'] as List
                        : text['fills']['raw'] as List,
                  ),
          );
          expect(
            actual.textStyle!.resolve(states),
            text == null
                ? null
                : TypographyTokens.byId[text['style']['id']]!.style,
          );
          final border = actual.side!.resolve(states)!;
          final stroke = expectedPaint(raw['strokes']['raw'] as List);
          if (stroke == null) {
            expect(border, BorderSide.none);
          } else {
            expect(border.color, stroke);
            expect(border.width, raw['geometry']['strokeWeight']);
            expect(border.strokeAlign, BorderSide.strokeAlignInside);
          }
          final shape = actual.shape!.resolve(states) as RoundedRectangleBorder;
          expect(shape.borderRadius, spec.radius);
          expect(
            actual.padding!.resolve(states)!.resolve(direction),
            spec.visualPadding.resolve(direction),
          );
          final identity = tester.widget<ElementIdentity>(
            find.byType(ElementIdentity),
          );
          expect(identity.variantId, spec.id);
          expect(identity.componentSetId, spec.setId);
          expect(identity.rawVariantName, raw['name']);
          expect(identity.elementId, 'test.button.control');
          expect(identity.descriptor()['schemaVersion'], '1.1.0');
          expect(
            jsonEncode(identity.descriptor()),
            isNot(contains('Secret sample')),
          );
          expect(widget.onPressed == null, disabled);
          expect(
            tester.getSize(find.byType(TextButton)).height,
            greaterThanOrEqualTo(spec.height),
          );
          final surface = find.descendant(
            of: find.byType(TextButton),
            matching: find.byType(Material),
          );
          expect(tester.getSize(surface).height, spec.minimumVisualHeight);
          expect(
            tester.getSize(find.byType(TextButton)).height,
            greaterThanOrEqualTo(spec.height),
          );
          expect(
            tester.getSize(find.byType(TextButton)).width,
            greaterThanOrEqualTo(
              spec.family == AppButtonFamily.icon ? spec.width : 0,
            ),
          );
        },
      );
    }
  }

  testWidgets(
    'color parameters override defaults; callbacks and scale/RTL work',
    (tester) async {
      var taps = 0;
      final override = ColorTokens.sharedAlphaBlack.value;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.build(brightness: Brightness.light),
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: SizedBox(
                  width: 320,
                  child: AppButton(
                    elementId: 'test.scaled.control',
                    runtimeLocator: const UiRuntimeLocator(
                      routeName: 'test',
                      routeInstanceId: 'scale',
                    ),
                    label: 'متن بلند برای کنترل چیدمان راست به چپ',
                    onPressed: () => taps++,
                    backgroundColor: override,
                    foregroundColor: override,
                    type: AppButtonType.outlined,
                    borderColor: override,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final button = tester.widget<TextButton>(find.byType(TextButton));
      expect(button.style!.backgroundColor!.resolve({}), override);
      expect(button.style!.foregroundColor!.resolve({}), override);
      expect(button.style!.side!.resolve({})!.color, override);
      await tester.tap(find.byType(TextButton));
      expect(taps, 1);
    },
  );
}
