import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';

void main() {
  for (final configuration in [
    ('en', Brightness.light, 1.0, false),
    ('en', Brightness.dark, 1.0, false),
    ('fa', Brightness.light, 1.0, false),
    ('fa', Brightness.dark, 1.0, false),
    ('en', Brightness.light, 2.0, false),
    ('fa', Brightness.dark, 2.0, false),
    ('en', Brightness.light, 1.0, true),
  ]) {
    final (locale, brightness, scale, alternate) = configuration;
    final name =
        'auth-primitives-$locale-${brightness.name}-$scale-${alternate ? 'test' : 'product'}';
    testWidgets(
      name,
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(402, 1600);
        addTearDown(tester.view.reset);
        final fa = locale == 'fa';
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            supportedLocales: const [Locale('en'), Locale('fa')],
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            theme: AppThemeFactory.build(
              brightness: brightness,
              skin: alternate ? testSkin : productSkin,
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                disableAnimations: true,
              ),
              child: child!,
            ),
            home: Scaffold(
              body: UiIdentityScope(
                routeName: 'gallery.auth',
                child: RepaintBoundary(
                  key: const ValueKey('auth-fixture'),
                  child: AuthPrimitivesFixture(
                    label: fa ? 'ادامه' : 'Continue',
                    divider: fa ? 'یا ادامه با' : 'or continue with',
                    remember: fa
                        ? 'مرا برای دفعه بعد به خاطر بسپار.'
                        : 'Remember me for next time.',
                    terms: fa ? 'شرایط و قوانین' : 'Terms & Conditions',
                    privacy: fa ? 'سیاست حریم خصوصی' : 'Privacy Policy',
                    playStation: 'PlayStation',
                    xbox: 'Xbox',
                    google: 'Google',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => precacheImage(
            const AssetImage(
              'assets/images/auth/entry_illustration.png',
              package: 'p2e_design_system',
            ),
            tester.element(find.byType(HeroBanner)),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const ValueKey('auth-fixture')),
          matchesGoldenFile('baselines/windows/$name.png'),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
      tags: ['golden'],
      skip: !Platform.isWindows,
    );
  }
}
