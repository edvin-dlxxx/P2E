import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';

import '../support/readiness_sheet.dart';

void main() {
  group('D-047 initial Windows references, pending review', () {
    const configurations = [
      ('fa', Brightness.light, 1.0, false),
      ('fa', Brightness.dark, 1.0, false),
      ('en', Brightness.light, 1.0, false),
      ('en', Brightness.dark, 1.0, false),
      ('fa', Brightness.dark, 2.0, false),
      ('en', Brightness.light, 2.0, false),
      ('en', Brightness.light, 1.0, true),
    ];
    for (final family in families) {
      for (final (language, brightness, scale, alternate) in configurations) {
        // No Light Password/OTP source exists; D-026 derived visuals are not
        // fabricated as Figma references. Back Light is omitted by the catalog.
        if ((family == 'Password' || family == 'OTP') &&
            brightness == Brightness.light) {
          continue;
        }
        for (final width
            in family == 'PageScaffold' ? [402.0, 700.0] : [402.0]) {
          final name =
              '${family.toLowerCase()}-$language-${brightness.name}-$scale-${alternate ? 'test' : 'product'}-${width.toInt()}';
          testWidgets(name, (tester) async {
            addTearDown(tester.view.reset);
            await pumpSheet(
              tester,
              family: family,
              language: language,
              brightness: brightness,
              scale: scale,
              width: width,
              theme: AppThemeFactory.build(
                brightness: brightness,
                skin: alternate ? testSkin : productSkin,
              ),
            );
            for (final entry in sheetCases(family, language, brightness)) {
              final caption = tester.widget<Text>(
                find.byKey(ValueKey('caption.${entry.key}')),
              );
              expect(caption.data, entry.key);
              expect(RegExp('[۰-۹]').hasMatch(caption.data!), isFalse);
            }
            if (Platform.environment['CAPTION_BOUNDS'] == '1') {
              final bounds = <List<double>>[];
              for (final e in sheetCases(family, language, brightness)) {
                final r = tester.getRect(
                  find.byKey(ValueKey('caption.${e.key}')),
                );
                bounds.add([r.left, r.top, r.right, r.bottom]);
              }
              final file = File('../../build/inspector-v1/captions/$name.json');
              file.parent.createSync(recursive: true);
              file.writeAsStringSync(jsonEncode(bounds));
            }
            await expectLater(
              find.byKey(sheetKey),
              matchesGoldenFile('baselines/windows/$name.png'),
            );
          }, tags: ['golden']);
        }
      }
    }
  });
}
