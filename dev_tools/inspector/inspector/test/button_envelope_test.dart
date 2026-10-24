import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_dev_inspector/inspector.dart';

void main() {
  for (final host in ['room', 'bounds', 'clip']) {
    testWidgets('Problems detects button envelope constraint: $host', (
      tester,
    ) async {
      final key = GlobalKey();
      final session = InspectionSession(key);
      final device = SimulatedDevice();
      final recorder = ProblemRecorder(session, device);
      addTearDown(recorder.dispose);
      addTearDown(session.dispose);
      addTearDown(device.dispose);
      Widget button = ButtonHitRegion(
        child: AppButton(
          elementId: 'probe.button',
          label: 'Continue',
          onPressed: () {},
        ),
      );
      if (host == 'bounds') button = SizedBox(height: 46, child: button);
      if (host == 'clip') button = ClipRect(child: button);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.build(brightness: Brightness.dark),
          home: UiIdentityScope(
            routeName: 'probe',
            child: SizedBox.expand(
              key: key,
              child: Scaffold(body: Center(child: button)),
            ),
          ),
        ),
      );
      recorder.sampleLayout();
      expect(
        recorder.problems.where(
          (p) => p.kind == 'button-hit-envelope-constrained',
        ),
        host == 'room' ? isEmpty : hasLength(1),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
