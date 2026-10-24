import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';

import '../support/readiness_sheet.dart';

void main() {
  test('complete independent role sets', () {
    for (final brightness in Brightness.values) {
      final source = productSkin.valuesFor(brightness).byName;
      final target = testSkin.valuesFor(brightness).byName;
      expect(target.keys, unorderedEquals(source.keys));
      expect(target.length, 37);
      expect(target.keys, containsAll(['Action/Accent', 'Action/OnAccent']));
      for (final role in source.keys) {
        expect(target[role], isNot(source[role]), reason: role);
      }
      final theme = AppThemeFactory.build(
        brightness: brightness,
        skin: testSkin,
      );
      expect(theme.extension<SkinTheme>()!.definition, same(testSkin));
      expect(theme.extension<ButtonThemeTokens>()!.colors, target);
    }
  });
  for (final brightness in Brightness.values) {
    testWidgets('best-effort test skin pixel leak guard $brightness', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      final forbidden =
          productSkin
              .valuesFor(brightness)
              .byName
              .values
              .map((c) => c.toARGB32())
              .toSet()
            ..removeAll(
              testSkin
                  .valuesFor(brightness)
                  .byName
                  .values
                  .map((c) => c.toARGB32()),
            );
      for (final family in families) {
        await pumpSheet(
          tester,
          family: family,
          includeDerived: true,
          language: 'en',
          brightness: brightness,
          theme: AppThemeFactory.build(brightness: brightness, skin: testSkin),
        );
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(sheetKey),
        );
        final origin = boundary.localToGlobal(Offset.zero);
        final excluded = <Rect>[];
        // Original SVG artwork is source evidence, not a semantic skin role.
        // Multi-color artwork in controls is intentionally never force-tinted.
        for (final element in find.byType(AssetAppIcon).evaluate()) {
          final widget = element.widget as AssetAppIcon;
          if (family == 'AppIcon' || !widget.artwork.monochrome) {
            final box = element.renderObject as RenderBox;
            excluded.add((box.localToGlobal(Offset.zero) - origin) & box.size);
          }
        }
        final result = await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!.buffer.asUint8List();
          final width = image.width;
          image.dispose();
          return (bytes, width);
        });
        final (bytes, width) = result!;
        final leaks = <int, int>{};
        for (var i = 0; i < bytes.length; i += 4) {
          final point = Offset(
            (i ~/ 4 % width).toDouble(),
            (i ~/ 4 ~/ width).toDouble(),
          );
          if (excluded.any((r) => r.contains(point))) continue;
          final color =
              bytes[i + 3] << 24 |
              bytes[i] << 16 |
              bytes[i + 1] << 8 |
              bytes[i + 2];
          if (forbidden.contains(color)) {
            leaks.update(color, (v) => v + 1, ifAbsent: () => 1);
          }
        }
        expect(
          leaks,
          isEmpty,
          reason:
              '$family product-only exact colors: ${leaks.map((k, v) => MapEntry(k.toRadixString(16), v))}',
        );
      }
    });
  }
}
