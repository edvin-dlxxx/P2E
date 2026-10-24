import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system_viewer/main.dart';
import 'package:p2e_design_system_viewer/board/button_sample.dart';
import 'package:p2e_design_system_viewer/fields/field_browser.dart';
import 'package:p2e_design_system_viewer/viewer_shell.dart';

void main() {
  testWidgets('selected control motion does not rebuild the catalog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const DevelopmentViewer(initialLocale: Locale('en')),
    );
    await tester.pumpAndSettle();
    final sample = tester.widget<ButtonSample>(find.byType(ButtonSample).first);
    sample.onSelect();
    await tester.pumpAndSettle();
    final button = tester.widget<AppButton>(
      find.descendant(
        of: find.byType(ButtonSample).first,
        matching: find.byType(AppButton),
      ),
    );
    final counts = <String, int>{};
    final previous = debugOnRebuildDirtyWidget;
    addTearDown(() => debugOnRebuildDirtyWidget = previous);
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      final w = element.widget;
      if (w is ViewerShell ||
          w is FieldBrowser ||
          (w is ButtonSample && w.sampleId != sample.sampleId)) {
        final key = w.runtimeType.toString();
        counts[key] = (counts[key] ?? 0) + 1;
      }
    };
    for (var i = 0; i < 3; i++) {
      button.statesController!.update(WidgetState.pressed, true);
      for (var f = 0; f < 8; f++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      button.statesController!.update(WidgetState.pressed, false);
      for (var f = 0; f < 16; f++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }
    debugOnRebuildDirtyWidget = previous;
    final buttonCounts = Map<String, int>.of(counts);
    expect(
      buttonCounts,
      isEmpty,
      reason: 'Press/release must not rebuild the shell or other buttons',
    );
    await tester.tap(find.byKey(const ValueKey('section-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppTextField));
    await tester.pumpAndSettle();
    final focus = tester
        .widget<TextField>(find.byType(TextField, skipOffstage: false))
        .focusNode!;
    counts.clear();
    debugOnRebuildDirtyWidget = (element, builtOnce) {
      final w = element.widget;
      if (w is ViewerShell || w is FieldBrowser) {
        final key = w.runtimeType.toString();
        counts[key] = (counts[key] ?? 0) + 1;
      }
    };
    for (var i = 0; i < 3; i++) {
      focus.unfocus();
      for (var f = 0; f < 16; f++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      focus.requestFocus();
      for (var f = 0; f < 16; f++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
    }
    debugOnRebuildDirtyWidget = previous;
    expect(
      counts,
      isEmpty,
      reason: 'Focus motion must not rebuild the shell or reference catalog',
    );
    Directory('build').createSync(recursive: true);
    File('build/motion-work.json').writeAsStringSync(
      jsonEncode({'button': buttonCounts, 'textField': counts}),
    );
    expect(tester.takeException(), isNull);
  });
}
