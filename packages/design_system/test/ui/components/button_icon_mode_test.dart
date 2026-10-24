import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

const locator = UiRuntimeLocator(
  routeName: 'test',
  routeInstanceId: 'icon-mode',
);

void main() {
  for (final brightness in Brightness.values) {
    for (final direction in TextDirection.values) {
      for (final scale in [1.0, 1.3]) {
        testWidgets(
          'no-icon geometry ${brightness.name}/${direction.name}/$scale',
          (tester) async {
            for (final family in [AppButtonFamily.hug, AppButtonFamily.fill]) {
              for (final size in AppButtonSize.values) {
                for (final type in AppButtonType.values) {
                  for (final label in [
                    'Go',
                    'Continue With Email Address — a long label',
                  ]) {
                    await tester.pumpWidget(
                      MaterialApp(
                        theme: AppThemeFactory.build(brightness: brightness),
                        home: Directionality(
                          textDirection: direction,
                          child: MediaQuery(
                            data: MediaQueryData(
                              textScaler: TextScaler.linear(scale),
                            ),
                            child: Scaffold(
                              body: Align(
                                alignment: AlignmentDirectional.topStart,
                                child: SizedBox(
                                  width: 180,
                                  child: Align(
                                    child: AppButton(
                                      key: ValueKey(
                                        '$family-$size-$type-$label',
                                      ),
                                      elementId: 'test.no-icon',
                                      runtimeLocator: locator,
                                      label: label,
                                      onPressed: type == AppButtonType.disabled
                                          ? null
                                          : () {},
                                      family: family,
                                      size: size,
                                      type: type,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                    await tester.pumpAndSettle();
                    expect(tester.takeException(), isNull);
                    expect(
                      find.byKey(const ValueKey('app-button-icon-slot')),
                      findsNothing,
                    );
                    expect(
                      find.byKey(const ValueKey('app-button-icon-gap')),
                      findsNothing,
                    );
                    expect(find.byType(AssetAppIcon), findsNothing);
                    final button = find.byType(AppButton);
                    final surface = find.descendant(
                      of: button,
                      matching: find.byType(Material),
                    );
                    final labelBox = tester.getRect(find.text(label));
                    final visual = tester.getRect(surface);
                    expect(labelBox.center.dx, closeTo(visual.center.dx, 0.01));
                    expect(labelBox.center.dy, closeTo(visual.center.dy, 0.01));
                    final spec = ButtonSpec.lookup(
                      family: family,
                      size: size,
                      type: type,
                      brightness: brightness,
                    );
                    if (family == AppButtonFamily.fill) {
                      expect(visual.width, 180);
                    } else {
                      expect(
                        visual.width,
                        closeTo(labelBox.width + spec.padding.horizontal, 0.01),
                      );
                      if (label == 'Go') {
                        expect(visual.width, lessThan(spec.width));
                      }
                    }
                    expect(
                      visual.height,
                      greaterThanOrEqualTo(
                        spec.minimumHeightFor(ButtonIconMode.none),
                      ),
                    );
                  }
                }
              }
            }
          },
        );
      }
    }
  }
  for (final mode in [ButtonIconMode.fill, ButtonIconMode.outline]) {
    testWidgets(
      '${mode.name} uses real artwork, its slot, gap and source icon paint',
      (tester) async {
        for (final brightness in Brightness.values) {
          final theme = AppThemeFactory.build(brightness: brightness);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: AppButton(
                  elementId: 'test.real-icon',
                  runtimeLocator: locator,
                  label: 'Edit',
                  onPressed: () {},
                  iconMode: mode,
                  icon: const AssetAppIcon(AppIconId.editSquare),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            find.byKey(const ValueKey('app-button-icon-slot')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('app-button-icon-gap')),
            findsOneWidget,
          );
          final icon = tester.widget<AssetAppIcon>(find.byType(AssetAppIcon));
          expect(icon.style.name, mode.name);
          expect(icon.sourceNodeId, isNotEmpty);
          final spec = ButtonSpec.lookup(
            family: AppButtonFamily.hug,
            size: AppButtonSize.medium,
            type: AppButtonType.filled,
            brightness: brightness,
          );
          final paint = spec
              .resolve(theme.extension<ButtonThemeTokens>()!, iconMode: mode)
              .iconColor;
          expect(
            IconTheme.of(tester.element(find.byType(AssetAppIcon))).color,
            paint,
          );
        }
      },
    );
  }
  testWidgets('disabled remapping and callback/identity remain intact', (
    tester,
  ) async {
    var taps = 0;
    for (final enabled in [true, false]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.build(brightness: Brightness.dark),
          home: Scaffold(
            body: AppButton(
              elementId: 'test.identity',
              runtimeLocator: locator,
              label: 'Private label',
              onPressed: enabled ? () => taps++ : null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final identity = tester.widget<ElementIdentity>(
        find.byType(ElementIdentity),
      );
      expect(identity.variants['type'], enabled ? 'filled' : 'disabled');
      expect(identity.variants['iconMode'], 'none');
      expect(identity.declared['iconId'], {'value': null, 'origin': 'usage'});
      expect(
        identity.descriptor().toString(),
        isNot(contains('Private label')),
      );
      await tester.tap(find.byType(TextButton));
      expect(taps, 1);
    }
  });
  test('icon-only and missing artwork cannot silently become text-only', () {
    expect(
      () => AppButton(
        elementId: 'test.x',
        runtimeLocator: locator,
        label: 'Icon',
        onPressed: () {},
        family: AppButtonFamily.icon,
      ),
      throwsAssertionError,
    );
    expect(
      () => AppButton(
        elementId: 'test.x',
        runtimeLocator: locator,
        label: 'Edit',
        onPressed: () {},
        iconMode: ButtonIconMode.fill,
      ),
      throwsAssertionError,
    );
  });
}
