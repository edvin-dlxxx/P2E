import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  for (final gap in [2.0, 4.0, 10.0]) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'small adjacent targets choose nearest visual rect $direction gap=$gap',
        (tester) async {
          for (final disabled in [false, true]) {
            final counts = [0, 0];
            await tester.pumpWidget(
              MaterialApp(
                theme: AppThemeFactory.build(brightness: Brightness.dark),
                home: UiIdentityScope(
                  routeName: 'test.overlap',
                  child: Scaffold(
                    body: Center(
                      child: Directionality(
                        textDirection: direction,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: gap,
                          children: [
                            for (var i = 0; i < 2; i++)
                              AppButton(
                                key: ValueKey(i),
                                elementId: 'test.overlap.button$i',
                                family: AppButtonFamily.icon,
                                size: AppButtonSize.small,
                                icon: const AssetAppIcon(AppIconId.home),
                                iconMode: ButtonIconMode.fill,
                                label: 'Action $i',
                                onPressed: disabled && i == 1
                                    ? null
                                    : () => counts[i]++,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            final rects = [
              for (var i = 0; i < 2; i++)
                tester.getRect(find.byKey(ValueKey(i))),
            ];
            final left = rects[0].left < rects[1].left ? 0 : 1;
            final right = 1 - left;
            for (final (index, point) in [
              (
                left,
                Offset(rects[left].right + gap / 2 - .5, rects[left].center.dy),
              ),
              (
                right,
                Offset(
                  rects[right].left - gap / 2 + .5,
                  rects[right].center.dy,
                ),
              ),
            ]) {
              final before = List<int>.of(counts);
              await tester.tapAt(point);
              await tester.pumpAndSettle();
              expect(
                counts[index],
                before[index] + (disabled && index == 1 ? 0 : 1),
              );
              expect(counts[1 - index], before[1 - index]);
            }
            expect(tester.takeException(), isNull);
          }
        },
      );
    }
  }
}
