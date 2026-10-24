import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system_viewer/main.dart';

void main() {
  testWidgets('Windows minimum client viewport fits scale1 chrome', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(640, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final language in ['fa', 'en']) {
      await tester.pumpWidget(
        DevelopmentViewer(
          key: ValueKey(language),
          initialLocale: Locale(language),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
