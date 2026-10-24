import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
}

void main() {
  test('D-029 preserves source paints and changes only Light disabled effective foreground/icons', () {
    for (final s in ButtonSpec.all) {
      final tokens = ButtonThemeTokens.forBrightness(s.brightness),
          r = s.resolve(ButtonThemeTokens.forBrightness(s.brightness));
      final affected =
          s.brightness == Brightness.light && s.type == AppButtonType.disabled;
      expect(r.readabilityOverride, affected);
      if (affected) {
        final parent = tokens.color('Surface/Base');
        final fill = Color.alphaBlend(
          r.background!.withValues(alpha: r.background!.a * s.opacity),
          parent,
        );
        final label = Color.alphaBlend(
          Color.alphaBlend(
            r.foreground,
            r.background!,
          ).withValues(alpha: s.opacity),
          parent,
        );
        final icon = Color.alphaBlend(
          Color.alphaBlend(
            r.iconColor,
            r.background!,
          ).withValues(alpha: s.opacity),
          parent,
        );
        expect(contrast(label, fill), greaterThan(4.5));
        expect(contrast(icon, fill), greaterThan(4.5));
        expect(contrast(r.sourceForeground, fill), lessThan(1.5));
        expect(r.foreground, tokens.color('On Surface/Emphasis'));
        expect(r.foreground.a, 1);
        expect(r.engineeringOverride!['decision'], 'D-029');
      } else {
        expect(r.foreground, r.sourceForeground);
        expect(r.iconColor, r.sourceIconColor);
        expect(r.engineeringOverride, isNull);
      }
    }
  });
  testWidgets(
    'every disabled Light size/family stays inactive with and without icons',
    (tester) async {
      var taps = 0;
      for (final family in AppButtonFamily.values) {
        for (final size in AppButtonSize.values) {
          for (final mode in ButtonIconMode.values) {
            if (family == AppButtonFamily.icon && mode == ButtonIconMode.none) {
              continue;
            }
            await tester.pumpWidget(
              MaterialApp(
                theme: AppThemeFactory.build(brightness: Brightness.light),
                home: Scaffold(
                  body: SizedBox(
                    width: 330,
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: AppButton(
                        elementId: 'test.disabled',
                        runtimeLocator: const UiRuntimeLocator(
                          routeName: 'test',
                          routeInstanceId: 'test',
                        ),
                        label: 'Disabled',
                        family: family,
                        size: size,
                        type: AppButtonType.disabled,
                        iconMode: mode,
                        icon: mode == ButtonIconMode.none
                            ? null
                            : const AssetAppIcon(AppIconId.editSquare),
                        onPressed: () => taps++,
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.widget<TextButton>(find.byType(TextButton)).onPressed,
              isNull,
            );
            await tester.tap(find.byType(AppButton));
            await tester.pumpAndSettle();
            expect(taps, 0);
            final transform = tester.widget<Transform>(
              find.byKey(const ValueKey('app-button-press-transform')),
            );
            expect(transform.transform.getMaxScaleOnAxis(), 1);
            expect(
              find.byKey(const ValueKey('app-button-icon-slot')),
              mode == ButtonIconMode.none ? findsNothing : findsOneWidget,
            );
            expect(tester.takeException(), isNull);
          }
        }
      }
    },
  );
}
