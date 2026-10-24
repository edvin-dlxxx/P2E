import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  test('width-only size-class boundaries', () {
    expect(SizeClass.fromWidth(599), SizeClass.compact);
    expect(SizeClass.fromWidth(600), SizeClass.medium);
    expect(SizeClass.fromWidth(839), SizeClass.medium);
    expect(SizeClass.fromWidth(840), SizeClass.expanded);
  });
  for (final width in [390.0, 700.0, 1000.0]) {
    for (final brightness in Brightness.values) {
      for (final direction in TextDirection.values) {
        for (final scale in [1.0, 2.0]) {
          testWidgets(
            'page $width $brightness $direction scale=$scale safe-area and keyboard focus',
            (tester) async {
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = Size(width, 900);
              tester.view.padding = const FakeViewPadding(
                top: 24,
                bottom: 20,
                left: 12,
                right: 12,
              );
              tester.view.viewPadding = const FakeViewPadding(
                top: 24,
                bottom: 20,
                left: 12,
                right: 12,
              );
              addTearDown(tester.view.reset);
              final focus = FocusNode();
              addTearDown(focus.dispose);
              await tester.pumpWidget(
                MaterialApp(
                  theme: AppThemeFactory.build(brightness: brightness),
                  builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.linear(scale)),
                    child: Directionality(
                      textDirection: direction,
                      child: child!,
                    ),
                  ),
                  home: UiIdentityScope(
                    routeName: 'adaptive-test',
                    child: PageScaffold(
                      elementId: 'test.page',
                      child: Column(
                        children: [
                          Text(
                            direction == TextDirection.rtl
                                ? 'عنوان صفحه'
                                : 'Page title',
                            key: const ValueKey('title'),
                          ),
                          const SizedBox(height: 600),
                          AppTextField(
                            elementId: 'test.input',
                            label: direction == TextDirection.rtl
                                ? 'ایمیل'
                                : 'Email',
                            options: FieldInputOptions(focusNode: focus),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              final scroll = find.byType(SingleChildScrollView);
              final bounds = tester.getRect(scroll);
              expect(
                bounds.width,
                closeTo(width < 600 ? width - 24 : 600, .01),
              );
              expect(bounds.top, 24);
              final paragraphContext = tester.element(
                find.byKey(const ValueKey('title')),
              );
              expect(
                MediaQuery.textScalerOf(paragraphContext).scale(10),
                10 * scale,
              );
              focus.requestFocus();
              await tester.pumpAndSettle();
              tester.view.viewInsets = const FakeViewPadding(bottom: 320);
              tester.view.padding = const FakeViewPadding(
                top: 24,
                left: 12,
                right: 12,
              );
              await tester.pumpAndSettle();
              final field = tester.getRect(find.byType(EditableText));
              expect(focus.hasFocus, isTrue);
              expect(field.bottom, lessThanOrEqualTo(580));
              expect(field.top, greaterThanOrEqualTo(24));
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
