import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import '../../support/auth_harness.dart';

void main() {
  testWidgets('visibility correction waits until the user drag ends', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await pumpAuth(tester, width: 480, scale: 2);
    final state = tester.state<ScrollableState>(find.byType(Scrollable).first);
    expect(state.position.pixels, greaterThan(0));
    final gesture = await tester.startGesture(const Offset(10, 400));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump();
    expect(state.position.isScrollingNotifier.value, isTrue);
    expect(state.position.pixels, 0);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(state.position.pixels, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
  for (final brightness in Brightness.values) {
    for (final sample in [
      (480.0, 874.0, 'en', 2.0, false, ''),
      (540.0, 874.0, 'fa', 2.0, true, ''),
      (320.0, 660.0, 'fa', 1.0, false, ''),
      (402.0, 1020.0, 'fa', 2.0, false, ''),
      (520.0, 874.0, 'en', 2.0, true, '09123456789'),
      (400.0, 1200.0, 'fa', 2.0, true, '09123456789'),
      (520.0, 874.0, 'en', 2.0, true, 'user@example.com'),
    ]) {
      testWidgets('complete visible tap envelope $brightness $sample', (
        tester,
      ) async {
        addTearDown(tester.view.reset);
        final (width, height, locale, scale, focused, raw) = sample;
        await pumpAuth(
          tester,
          width: width,
          height: height,
          locale: locale,
          scale: scale,
          focused: focused,
          raw: raw,
          brightness: brightness,
        );
        final box = tester.renderObject<RenderBox>(find.byType(AppButton));
        final viewport = RenderAbstractViewport.maybeOf(box)! as RenderBox;
        final rect = MatrixUtils.transformRect(
          box.getTransformTo(viewport),
          box.semanticBounds,
        );
        expect(rect.top, greaterThanOrEqualTo(-.000001));
        expect(rect.bottom, lessThanOrEqualTo(viewport.size.height + .000001));
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'fully visible reference and fully offscreen target do not pull page',
    (tester) async {
      addTearDown(tester.view.reset);
      for (final height in [874.0, 480.0]) {
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await pumpAuth(tester, height: height);
        final state = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        expect(state.position.pixels, 0);
        expect(tester.takeException(), isNull);
      }
    },
  );
}
