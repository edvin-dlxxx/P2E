import 'dart:convert';
import 'dart:io';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  final records = <Map<String, Object?>>[];
  tearDownAll(() {
    final file = File('../../build/readiness/six-digit-wallet.json');
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(records));
  });
  for (final persian in [false, true]) {
    for (final brightness in Brightness.values) {
      testWidgets(
        'full six-digit wallet ${persian ? 'fa' : 'en'} $brightness',
        (tester) async {
          final points = persian ? '۱۲۳٬۴۵۶' : '123,456';
          final coins = persian ? '۶۵۴٬۳۲۱' : '654,321';
          final pointUnit = persian ? 'امتیاز' : 'points';
          final coinUnit = persian ? 'سکه' : 'coins';
          final semantics = tester.ensureSemantics();
          final config = HomeAppBar(
            avatar: const AppBarAvatar(text: 'CM'),
            profile: AppBarAction(label: 'Profile', onPressed: () {}),
            help: AppBarAction(label: 'Help', onPressed: () {}),
            addCoins: AppBarAction(label: 'Add', onPressed: () {}),
            wallet: AppBarWallet(
              points: points,
              unit: pointUnit,
              coins: '$coins $coinUnit',
              pointsSemanticLabel: '$points $pointUnit',
              coinsSemanticLabel: '$coins $coinUnit',
            ),
          );
          await tester.pumpWidget(
            MaterialApp(
              locale: Locale(persian ? 'fa' : 'en'),
              supportedLocales: const [Locale('fa'), Locale('en')],
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              theme: AppThemeFactory.build(brightness: brightness),
              home: MediaQuery(
                data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                child: Directionality(
                  textDirection: persian
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: UiIdentityScope(
                    routeName: 'chrome-test',
                    child: Scaffold(
                      body: SizedBox(
                        width: 402,
                        child: AppBarContent(
                          elementId: 'test.bar',
                          configuration: config,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final layout = AppBarLayout.resolve(
            spec: AppBarSpec.lookup(AppBarCategory.home, brightness)!,
            configuration: config,
            width: 402,
            scaler: const TextScaler.linear(chromeTextScaleCap),
            persian: persian,
          );
          records.add({
            'locale': persian ? 'fa' : 'en',
            'brightness': brightness.name,
            'requestedScale': 2,
            'effectiveScale': chromeTextScaleCap,
            ...layout.toJson(),
          });
          for (final label in ['$points $pointUnit', '$coins $coinUnit']) {
            expect(find.bySemanticsLabel(label), findsOneWidget);
          }
          expect(find.text(points), findsOneWidget);
          expect(find.text('$coins $coinUnit'), findsOneWidget);
          for (final paragraph in tester.renderObjectList<RenderParagraph>(
            find.byType(RichText),
          )) {
            expect(
              paragraph.textScaler.scale(10) / 10,
              lessThanOrEqualTo(chromeTextScaleCap),
            );
            expect(paragraph.didExceedMaxLines, isFalse);
            final painter = TextPainter(
              text: paragraph.text,
              textDirection: paragraph.textDirection,
              textScaler: paragraph.textScaler,
            )..layout(maxWidth: paragraph.size.width);
            expect(
              painter.height,
              lessThanOrEqualTo(paragraph.size.height + .5),
            );
            painter.dispose();
          }
          expect(tester.takeException(), isNull);
          semantics.dispose();
        },
      );
    }
  }
}
