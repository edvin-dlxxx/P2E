import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';
import 'package:p2e_design_system_viewer/board/button_sample.dart';

import 'viewer_shell_test.dart' as shell;

void main() {
  testWidgets('loading toggle and independent product/test skin control', (
    tester,
  ) async {
    await shell.open(tester);
    final l = shell.strings(tester);
    await shell.choose(tester, 'skin', l.testSkin);
    final context = tester.element(find.byType(AppButton).first);
    expect(SkinTheme.of(context), same(testSkin));
    final toggle = find.byKey(const ValueKey('loading-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      tester
          .widgetList<AppButton>(find.byType(AppButton))
          .every((b) => b.loading),
      isTrue,
    );
    expect(
      tester
          .widgetList<ButtonSample>(find.byType(ButtonSample))
          .every((s) => s.settings.loading),
      isTrue,
    );
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await shell.choose(tester, 'skin', l.productSkin);
    expect(
      SkinTheme.of(tester.element(find.byType(AppButton).first)),
      same(productSkin),
    );
    expect(tester.takeException(), isNull);
  });
}
