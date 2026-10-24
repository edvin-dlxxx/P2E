import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_dev_inspector/inspector.dart';
import 'package:p2e_product_host/main.dart';

void main() {
  testWidgets(
    'real width and coarse grid sweep, OS fa/en x 1/2',
    (tester) async {
      tester.view.physicalSize = const Size(1800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final device = SimulatedDevice();
      addTearDown(device.dispose);
      await tester.pumpWidget(
        ProductInspectionHost(fixtures: true, device: device),
      );
      await tester.pumpAndSettle();
      while (tester.takeException() != null) {}
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      final saved = device.settings.toJson();
      Future<void> frame() async {
        await tester.pump(const Duration(milliseconds: 16));
        while (tester.takeException() != null) {}
      }

      final reports = <String, Object?>{};
      state.sweep.addListener(() {
        if (state.sweep.completed % 200 == 0) {
          stdout.writeln('sweep samples: ${state.sweep.completed}');
        }
      });
      for (final (name, plan) in [
        (
          'width',
          const SweepPlan(
            widthStep: 4,
            scales: [1, 2],
            locales: [
              [Locale('fa', 'IR')],
              [Locale('en', 'US')],
            ],
          ),
        ),
        (
          'coarseGrid',
          const SweepPlan(
            axis: SweepAxis.grid,
            widthStep: 200,
            heightStep: 220,
            scales: [1, 2],
            locales: [
              [Locale('fa', 'IR')],
              [Locale('en', 'US')],
            ],
          ),
        ),
      ]) {
        state.problems.clear();
        await state.sweep.run(plan, frame);
        reports[name] = jsonDecode(state.sweep.exportJson());
        expect(device.settings.toJson(), saved);
      }
      final output = Directory('../../../../build/inspector-v1.1')
        ..createSync(recursive: true);
      File(
        '${output.path}/product_host-sweep.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(reports));
      expect(find.byType(ProductInspectionHost), findsOneWidget);
    },
    skip: Platform.environment['RUN_REAL_SWEEP'] != '1',
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
