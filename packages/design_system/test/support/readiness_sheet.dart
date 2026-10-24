import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import 'readiness_catalog.dart';

const sheetKey = ValueKey('readiness-sheet');
const families = [
  'Button',
  'Badge',
  'TextField',
  'Password',
  'OTP',
  'Radio',
  'AppIcon',
  'AppBar',
  'Navigator',
  'PageScaffold',
];
List<MapEntry<String, Widget>> sheetCases(
  String family,
  String language,
  Brightness brightness, {
  bool includeDerived = false,
}) => readinessCases(language, brightness).entries.where((e) {
  if (!includeDerived &&
      (family == 'Password' || family == 'OTP') &&
      brightness == Brightness.light) {
    return false;
  }
  return family == 'Navigator'
      ? e.key.startsWith('Navigation')
      : e.key.split('/').first == family;
}).toList();
Size sheetSize(String family, int count, {double width = 402}) {
  final columns = family == 'AppIcon'
      ? 8
      : family == 'PageScaffold'
      ? 1
      : 3;
  final cellWidth = family == 'AppIcon' ? 100.0 : width;
  final height = family == 'AppIcon'
      ? 120.0
      : family == 'PageScaffold'
      ? 700.0
      : 320.0;
  return Size(
    columns * cellWidth,
    (count / columns).ceil().clamp(1, 1000) * height,
  );
}

Future<void> pumpSheet(
  WidgetTester tester, {
  required String family,
  required String language,
  required Brightness brightness,
  double scale = 1,
  double width = 402,
  ThemeData? theme,
  bool includeDerived = false,
}) async {
  final entries = sheetCases(
    family,
    language,
    brightness,
    includeDerived: includeDerived,
  );
  final surface = sheetSize(family, entries.length, width: width);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = surface;
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: const [Locale('en'), Locale('fa')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: theme ?? AppThemeFactory.build(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(
          size: surface,
          devicePixelRatio: 1,
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: Directionality(
          textDirection: language == 'fa'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: RepaintBoundary(
            key: sheetKey,
            child: Builder(
              builder: (context) => ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: entries.isEmpty
                    ? const SizedBox.expand()
                    : Wrap(
                        children: [
                          for (final e in entries)
                            SizedBox(
                              width: family == 'AppIcon' ? 100 : width,
                              height: family == 'AppIcon'
                                  ? 120
                                  : family == 'PageScaffold'
                                  ? 700
                                  : 320,
                              child: UiIdentityScope(
                                key: ValueKey(e.key),
                                routeName: 'golden',
                                child: Scaffold(
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        e.key,
                                        key: ValueKey('caption.${e.key}'),
                                        textScaler: TextScaler.noScaling,
                                        style: const TextStyle(
                                          fontFamily: 'packages/p2e_design_system/Outfit',
                                          fontSize: 10,
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment:
                                              AlignmentDirectional.center,
                                          child:
                                              e.value is AppButton &&
                                                  (e.value as AppButton)
                                                          .family ==
                                                      AppButtonFamily.fill
                                              ? SizedBox(
                                                  width: width,
                                                  child: e.value,
                                                )
                                              : e.value,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
  );
  await tester.pumpAndSettle();
  expect(
    tester.takeException(),
    isNull,
    reason: '$family/$language/$brightness/$scale',
  );
}
