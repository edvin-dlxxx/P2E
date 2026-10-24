import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import '../support/readiness_sheet.dart';

void main() {
  testWidgets('product skin pixel preservation', (tester) async {
    addTearDown(tester.view.reset);
    const record = bool.fromEnvironment('RECORD_PRODUCT_BEFORE');
    for (final brightness in Brightness.values) {
      final old = ThemeData(
        brightness: brightness,
        fontFamilyFallback: const ['packages/p2e_design_system/Vazirmatn'],
        extensions: [ButtonThemeTokens.forBrightness(brightness)],
      );
      final current = AppThemeFactory.build(brightness: brightness);
      expect(current.colorScheme, old.colorScheme);
      expect(current.textTheme, old.textTheme);
      expect(current.scaffoldBackgroundColor, old.scaffoldBackgroundColor);
      expect(
        current.extension<ButtonThemeTokens>()!.colors,
        old.extension<ButtonThemeTokens>()!.colors,
      );
      expect(
        current.extension<ButtonThemeTokens>()!.textStyles,
        old.extension<ButtonThemeTokens>()!.textStyles,
      );
      expect(current.copyWith(extensions: old.extensions.values), old);
      for (final family in families) {
        if (!record && !const bool.fromEnvironment('RUN_PIXEL_GUARD')) continue;
        await pumpSheet(
          tester,
          family: family,
          language: 'en',
          brightness: brightness,
        );
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(sheetKey),
        );
        final bytes = await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final data = (await image.toByteData(format: ui.ImageByteFormat.png))!
              .buffer
              .asUint8List();
          image.dispose();
          return data;
        });
        final file = File(
          '../../build/readiness/product-before/${family}_${brightness.name}.png',
        );
        if (record) {
          file.parent.createSync(recursive: true);
          file.writeAsBytesSync(bytes!);
        } else {
          expect(
            bytes,
            orderedEquals(file.readAsBytesSync()),
            reason:
                'STOP: product skin pixels changed: $family/${brightness.name}',
          );
        }
      }
    }
  });
}
