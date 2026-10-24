import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

const locator = UiRuntimeLocator(routeName: 'motion', routeInstanceId: 'test');
void main() {
  Future<void> mount(
    WidgetTester tester,
    VoidCallback? callback, {
    bool reduced = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.build(brightness: Brightness.light),
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: Scaffold(
            body: Center(
              child: AppButton(
                elementId: 'test.motion',
                runtimeLocator: locator,
                label: 'Press',
                onPressed: callback,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  double scale(WidgetTester tester) => tester
      .widget<Transform>(
        find.byKey(const ValueKey('app-button-press-transform')),
      )
      .transform
      .entry(0, 0);
  testWidgets(
    'press/release scales paint, keeps layout/hit bounds, invokes once',
    (tester) async {
      var calls = 0;
      await mount(tester, () => calls++);
      final outer = tester.getRect(find.byType(AppButton));
      final surface = find.descendant(
        of: find.byType(TextButton),
        matching: find.byType(Material),
      );
      final visual = tester.getSize(surface);
      final gesture = await tester.startGesture(outer.center);
      await tester.pump(const Duration(milliseconds: 110));
      await tester.pump(ButtonMotion.pressDuration);
      expect(scale(tester), closeTo(ButtonMotion.pressedScale, 0.0001));
      expect(tester.getRect(find.byType(AppButton)), outer);
      expect(tester.getSize(surface), visual);
      expect(
        tester
            .widget<Transform>(
              find.byKey(const ValueKey('app-button-press-transform')),
            )
            .transformHitTests,
        isFalse,
      );
      await gesture.up();
      await tester.pump();
      await tester.pump(ButtonMotion.releaseDuration);
      expect(scale(tester), 1);
      expect(calls, 1);
    },
  );
  testWidgets('cancel returns to rest without activation', (tester) async {
    var calls = 0;
    await mount(tester, () => calls++);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(TextButton)),
    );
    await tester.pump(const Duration(milliseconds: 110));
    await tester.pump(ButtonMotion.pressDuration);
    expect(scale(tester), lessThan(1));
    await gesture.cancel();
    await tester.pump();
    await tester.pump(ButtonMotion.releaseDuration);
    expect(scale(tester), 1);
    expect(calls, 0);
  });
  testWidgets('the original edge remains clickable while the paint is scaled', (
    tester,
  ) async {
    var calls = 0;
    await mount(tester, () => calls++);
    final bounds = tester.getRect(find.byType(AppButton));
    final point = Offset(bounds.left + 0.1, bounds.center.dy);
    final gesture = await tester.startGesture(point);
    await tester.pump(const Duration(milliseconds: 110));
    await tester.pump(ButtonMotion.pressDuration);
    expect(scale(tester), closeTo(ButtonMotion.pressedScale, 0.0001));
    final painted = tester.getRect(find.byType(TextButton));
    expect(painted.left, greaterThan(point.dx));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls, 1);
  });
  testWidgets('disabled never animates or activates', (tester) async {
    await mount(tester, null);
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(TextButton)),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(scale(tester), 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(scale(tester), 1);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
  });
  testWidgets(
    'reduced animation preserves callback without a scale transition',
    (tester) async {
      var calls = 0;
      await mount(tester, () => calls++, reduced: true);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(TextButton)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(scale(tester), 1);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(scale(tester), 1);
    },
  );
  testWidgets('keyboard activation uses the shared interaction once', (
    tester,
  ) async {
    var calls = 0;
    await mount(tester, () => calls++);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    await tester.pump(ButtonMotion.pressDuration);
    expect(calls, 1);
    expect(scale(tester), closeTo(ButtonMotion.pressedScale, 0.0001));
    await tester.pumpAndSettle();
    expect(scale(tester), 1);
  });
}
