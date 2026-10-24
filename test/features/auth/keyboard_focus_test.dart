import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/app/app.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:mygame_p2e/features/auth/auth.dart';
import 'package:p2e_design_system/design_system.dart';

import '../../support/auth_harness.dart';

void main() {
  for (final locale in ['en', 'fa']) {
    for (final brightness in Brightness.values) {
      for (final scale in [1.0, 2.0]) {
        for (final raw in ['', '09123456789', 'user@example.com']) {
          testWidgets(
            'keyboard retains editor $locale $brightness $scale $raw',
            (tester) async {
              addTearDown(tester.view.reset);
              tester.view.devicePixelRatio = 1;
              tester.view.physicalSize = const Size(402, 874);
              final inset = ValueNotifier<double>(0);
              addTearDown(inset.dispose);
              final repos = ImmediateRepositories();
              await tester.pumpWidget(
                ProviderScope(
                  overrides: [
                    appConfigProvider.overrideWithValue(
                      const AppConfig(environment: AppEnvironment.stage),
                    ),
                    appLocaleProvider.overrideWithValue(Locale(locale)),
                    welcomeOfferRepositoryProvider.overrideWith((_) => repos),
                    phoneSignInRepositoryProvider.overrideWith((_) => repos),
                    emailSignInRepositoryProvider.overrideWith((_) => repos),
                    socialSignInRepositoryProvider.overrideWith((_) => repos),
                  ],
                  child: ValueListenableBuilder<double>(
                    valueListenable: inset,
                    child: const P2EApp(),
                    builder: (context, bottom, child) => MediaQuery(
                      data: MediaQueryData(
                        size: const Size(402, 874),
                        padding: const EdgeInsets.only(top: 55),
                        viewPadding: const EdgeInsets.only(top: 55),
                        viewInsets: EdgeInsets.only(bottom: bottom),
                        platformBrightness: brightness,
                        textScaler: TextScaler.linear(scale),
                        disableAnimations: true,
                      ),
                      child: child!,
                    ),
                  ),
                ),
              );
              await tester.pumpAndSettle();
              tester
                  .widget<AppTextField>(find.byType(AppTextField))
                  .options
                  .focusNode!
                  .requestFocus();
              await tester.pumpAndSettle();
              final editor = find.byType(EditableText);
              await tester.showKeyboard(editor);
              await tester.enterText(editor, raw);
              await tester.pumpAndSettle();
              final original = tester.state<EditableTextState>(editor);
              final focus = original.widget.focusNode;
              final value = TextEditingValue(
                text: raw,
                selection: TextSelection.collapsed(offset: raw.length),
                composing: raw.isEmpty
                    ? TextRange.empty
                    : TextRange(start: 0, end: raw.length),
              );
              tester.testTextInput.updateEditingValue(value);
              await tester.pumpAndSettle();

              // Animate real insets on the same mounted screen, then repeat.
              for (final bottom in [
                1.0,
                100.0,
                331.0,
                200.0,
                0.0,
                331.0,
                0.0,
              ]) {
                tester.testTextInput.log.clear();
                inset.value = bottom;
                await tester.pumpAndSettle();
                expect(tester.state<EditableTextState>(editor), same(original));
                expect(focus.hasPrimaryFocus, isTrue);
                expect(tester.testTextInput.hasAnyClients, isTrue);
                expect(tester.testTextInput.isVisible, isTrue);
                expect(original.widget.controller.value, value);
                expect(
                  tester.testTextInput.log.map((call) => call.method),
                  isNot(contains('TextInput.hide')),
                );
                expect(
                  tester.testTextInput.log.map((call) => call.method),
                  isNot(contains('TextInput.clearClient')),
                );
                expect(
                  find.byType(HeroBanner),
                  bottom > 0 ? findsNothing : findsOneWidget,
                );
                expect(tester.takeException(), isNull);
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
