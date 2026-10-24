import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/app/bootstrap.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  testWidgets('existing neutral root wrapper preserves exact frame media', (
    tester,
  ) async {
    await tester.pumpWidget(
      Center(
        child: SizedBox(
          width: 402,
          height: 874,
          child: composeApp(
            config: const AppConfig(environment: AppEnvironment.dev),
            rootWrapper: (root) => MediaQuery(
              data: const MediaQueryData(
                size: Size(402, 874),
                padding: EdgeInsets.fromLTRB(0, 24, 0, 24),
                textScaler: TextScaler.linear(2),
                platformBrightness: Brightness.dark,
              ),
              child: root,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(PageScaffold));
    expect(MediaQuery.sizeOf(context), const Size(402, 874));
    expect(
      MediaQuery.paddingOf(context),
      const EdgeInsets.fromLTRB(0, 24, 0, 24),
    );
    expect(MediaQuery.textScalerOf(context).scale(10), 20);
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
