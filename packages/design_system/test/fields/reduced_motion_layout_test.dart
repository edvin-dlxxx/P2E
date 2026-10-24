import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'field size transitions survive OS changes: ${brightness.name}',
      (tester) async {
        final media = ValueNotifier(const MediaQueryData());
        final text = TextEditingController(text: 'retained');
        final password = TextEditingController(text: 'private');
        addTearDown(media.dispose);
        addTearDown(text.dispose);
        addTearDown(password.dispose);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppThemeFactory.build(brightness: brightness),
            home: ValueListenableBuilder<MediaQueryData>(
              valueListenable: media,
              builder: (context, data, _) => MediaQuery(
                data: data,
                child: UiIdentityScope(
                  routeName: 'field-regression',
                  instanceKey: 'stable',
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: SizedBox(
                        width: 402,
                        child: Column(
                          children: [
                            AppTextField(
                              elementId: 'regression.text',
                              label: 'Field label برچسب',
                              options: FieldInputOptions(
                                controller: text,
                                supportingText: 'Supporting message متن راهنما',
                              ),
                            ),
                            AppPasswordField(
                              elementId: 'regression.password',
                              label: 'Password رمز عبور',
                              showPasswordLabel: 'Show',
                              hidePasswordLabel: 'Hide',
                              options: FieldInputOptions(
                                controller: password,
                                supportingText: 'Supporting message متن راهنما',
                              ),
                            ),
                          ],
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
        final editors = tester
            .stateList<EditableTextState>(find.byType(EditableText))
            .toList();
        for (final reduced in [true, false, true]) {
          for (final scale in [3.0, 1.0, 1.3, 2.0, 3.0]) {
            for (final keyboard in [true, false]) {
              media.value = MediaQueryData(
                textScaler: TextScaler.linear(scale),
                viewInsets: EdgeInsets.only(bottom: keyboard ? 300 : 0),
                disableAnimations: reduced,
                boldText: true,
              );
              await tester.pumpAndSettle();
              expect(
                tester.takeException(),
                isNull,
                reason: 'reduced=$reduced scale=$scale keyboard=$keyboard',
              );
              expect(
                tester
                    .stateList<EditableTextState>(find.byType(EditableText))
                    .toList(),
                orderedEquals(editors),
              );
              expect(text.text, 'retained');
              expect(password.text, 'private');
            }
          }
        }
      },
    );
  }
}
