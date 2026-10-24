import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  for (final size in AppButtonSize.values) {
    testWidgets(
      '$size fixed visual frame has a layout-neutral48px hit envelope',
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: AppThemeFactory.build(brightness: Brightness.dark),
            home: UiIdentityScope(
              routeName: 'test.button',
              child: Scaffold(
                body: Center(
                  child: AppButton(
                    elementId: 'test.button.control',
                    size: size,
                    label: 'Go',
                    onPressed: () => taps++,
                  ),
                ),
              ),
            ),
          ),
        );
        final box = tester.getRect(find.byType(AppButton));
        final spec = ButtonSpec.lookup(
          family: AppButtonFamily.hug,
          size: size,
          type: AppButtonType.filled,
          brightness: Brightness.dark,
        );
        expect(box.height, spec.height);
        final hit = Rect.fromCenter(
          center: box.center,
          width: box.width < 48 ? 48 : box.width,
          height: box.height < 48 ? 48 : box.height,
        );
        for (final point in [
          Offset(hit.left + .1, hit.top + .1),
          Offset(hit.right - .1, hit.bottom - .1),
          hit.center,
        ]) {
          await tester.tapAt(point);
          await tester.pump();
        }
        expect(taps, 3);
        expect(tester.getRect(find.byType(AppButton)), box);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
