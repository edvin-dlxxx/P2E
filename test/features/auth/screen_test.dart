import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import '../../support/auth_harness.dart';

void main() {
  for (final locale in ['en', 'fa']) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        for (final width in [320.0, 402.0, 744.0, 1024.0]) {
          for (final state in ['idle', 'focused', 'phone', 'email']) {
            for (final keyboard in [false, true]) {
              testWidgets(
                '$locale $brightness scale$scale width$width $state keyboard$keyboard',
                (tester) async {
                  addTearDown(tester.view.reset);
                  await pumpAuth(
                    tester,
                    width: width,
                    locale: locale,
                    brightness: brightness,
                    scale: scale,
                    keyboard: keyboard,
                    focused: state != 'idle',
                    raw: switch (state) {
                      'phone' => '۰۹۱۲۳۴۵۶۷۸۹',
                      'email' => 'User12@EXAMPLE.COM',
                      _ => '',
                    },
                  );
                  expect(tester.takeException(), isNull);
                  final field = tester.widget<AppTextField>(
                    find.byType(AppTextField),
                  );
                  expect(field.options.textDirection, TextDirection.ltr);
                  expect(field.options.textAlign, TextAlign.left);
                  expect(field.options.autocorrect, false);
                  expect(field.options.enableSuggestions, false);
                  expect(field.options.identifierPrivacy, true);
                  expect(
                    find.byType(HeroBanner),
                    keyboard ? findsNothing : findsOneWidget,
                  );
                  expect(
                    find.byType(AppToggle),
                    keyboard ? findsNothing : findsOneWidget,
                  );
                  expect(
                    find.byWidgetPredicate(
                      (w) =>
                          w is ElementIdentity &&
                          w.elementId == 'auth.entry.reward',
                    ),
                    findsOneWidget,
                  );
                  for (final element in find.byType(RichText).evaluate()) {
                    final render = element.renderObject;
                    if (render is RenderParagraph) {
                      expect(render.didExceedMaxLines, false);
                    }
                  }
                  await tester.pumpWidget(const SizedBox.shrink());
                  await tester.pumpAndSettle();
                },
              );
            }
          }
        }
      }
    }
  }
  testWidgets(
    'submit routes through flow provider and Back preserves input/remember',
    (tester) async {
      addTearDown(tester.view.reset);
      await pumpAuth(tester, raw: 'user@example.com', focused: true);
      await tester.ensureVisible(find.byType(AppToggle));
      await tester.tap(find.byType(AppToggle));
      await tester.ensureVisible(find.byKey(const ValueKey('auth.continue')));
      await tester.tap(find.byKey(const ValueKey('auth.continue')));
      await tester.pumpAndSettle();
      expect(find.text('Password — screen coming next'), findsOneWidget);
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      expect(tester.widget<AppToggle>(find.byType(AppToggle)).value, true);
      expect(
        tester
            .widget<AppTextField>(find.byType(AppTextField))
            .options
            .controller!
            .text,
        'user@example.com',
      );
    },
  );
}
