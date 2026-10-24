import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_dev_inspector/inspector.dart';
import 'package:p2e_product_host/main.dart';

void main() {
  testWidgets(
    'DS width sweep fa/en scales1/2/3 keyboard off/on reduced and bold',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final device = SimulatedDevice();
      addTearDown(device.dispose);
      device.apply(
        device.settings.copyWith(disableAnimations: true, boldText: true),
      );
      await tester.pumpWidget(
        ProductInspectionHost(fixtures: true, device: device),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      final saved = device.settings.toJson();
      final reports = <String, Object?>{};
      Future<void> frame() async {
        await tester.pump(const Duration(milliseconds: 16));
        Object? error;
        while ((error = tester.takeException()) != null) {
          expect(
            error.toString(),
            contains('Navigator Bar host contract violation'),
          );
        }
      }

      state.sweep.addListener(() {
        if (state.sweep.completed % 300 == 0) {
          stdout.writeln('samples: ${state.sweep.completed}');
        }
      });
      for (final keyboard in [false, true]) {
        device.apply(device.settings.copyWith(keyboard: keyboard));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final keyboardSettings = device.settings.toJson();
        state.problems.clear();
        await state.sweep.run(
          const SweepPlan(
            minWidth: 200,
            maxWidth: 1400,
            widthStep: 4,
            scales: [1, 2, 3],
            locales: [
              [Locale('fa', 'IR')],
              [Locale('en', 'US')],
            ],
          ),
          frame,
        );
        expect(state.sweep.completed, 1806);
        expect(device.settings.toJson(), keyboardSettings);
        expect(state.problems.collectorFailures, 0);
        final report =
            jsonDecode(state.sweep.exportJson()) as Map<String, dynamic>;
        for (final range in report['ranges'] as List) {
          expect(range['kind'], 'navigator-below-minimum');
        }
        reports[keyboard ? 'keyboardOn' : 'keyboardOff'] = report;
      }
      device.apply(FrameSettings.fromJson(saved));
      await tester.pumpAndSettle();
      expect(device.settings.toJson(), saved);
      expect(tester.takeException(), isNull);
      final dir = Directory('../../../../build/inspector-followup')
        ..createSync(recursive: true);
      File(
        '${dir.path}/ds-sweep.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(reports));
    },
    skip: Platform.environment['RUN_A11Y_SWEEP'] != '1',
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
