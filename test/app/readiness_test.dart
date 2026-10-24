import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/app/app.dart';
import 'package:mygame_p2e/app/bootstrap.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';

class NonlinearScaler extends TextScaler {
  const NonlinearScaler();
  @override
  double scale(double fontSize) => fontSize * (fontSize < 20 ? 1.8 : 2.4);
  @override
  double get textScaleFactor => 2.4;
}

void main() {
  testWidgets('D-044 retains nonlinear scaling and caps content at two', (
    tester,
  ) async {
    await tester.pumpWidget(
      composeApp(
        config: const AppConfig(environment: AppEnvironment.dev),
        rootWrapper: (root) => MediaQuery(
          data: const MediaQueryData(textScaler: NonlinearScaler()),
          child: root,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final scaler = MediaQuery.textScalerOf(
      tester.element(find.byType(Text).first),
    );
    expect(scaler.scale(18), closeTo(32.4, .0001));
    expect(scaler.scale(24), 48);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'D-046 neutral override selects skin independently of brightness',
    (tester) async {
      await tester.pumpWidget(
        composeApp(
          config: const AppConfig(environment: AppEnvironment.dev),
          providerOverrides: [appSkinProvider.overrideWithValue(testSkin)],
        ),
      );
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme!.extension<SkinTheme>()!.definition, same(testSkin));
      expect(app.darkTheme!.extension<SkinTheme>()!.definition, same(testSkin));
      expect(app.theme!.brightness, Brightness.light);
      expect(app.darkTheme!.brightness, Brightness.dark);
    },
  );
}
