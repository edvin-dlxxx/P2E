import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import '../support/readiness_catalog.dart';
import '../support/readiness_sheet.dart';

void startOf(Rect icon, Rect label, bool rtl, String reason) {
  expect(
    icon.center.dx,
    rtl ? greaterThan(label.center.dx) : lessThan(label.center.dx),
    reason: reason,
  );
}

void main() {
  for (final language in ['en', 'fa']) {
    final rtl = language == 'fa';
    final label = rtl ? 'ادامه' : 'Continue';
    testWidgets('Button start placement and loose cell widths $language', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      await pumpSheet(
        tester,
        family: 'Button',
        language: language,
        brightness: Brightness.dark,
      );
      final covered = <(AppButtonSize, AppButtonFamily)>{};
      for (final button in tester.widgetList<AppButton>(
        find.byType(AppButton),
      )) {
        final root = find.byWidget(button);
        final width = tester.getSize(root).width;
        expect(
          width,
          button.family == AppButtonFamily.fill ? equals(402) : lessThan(402),
          reason: '${button.family}/${button.size}',
        );
        if (button.iconMode == ButtonIconMode.none) continue;
        covered.add((button.size, button.family));
        final icon = tester.getRect(
          find.descendant(
            of: root,
            matching: find.byKey(const ValueKey('app-button-icon-slot')),
          ),
        );
        if (button.family == AppButtonFamily.icon) {
          expect(icon.center.dx, closeTo(tester.getRect(root).center.dx, .01));
        } else {
          final text = tester.getRect(
            find.descendant(of: root, matching: find.text(label)),
          );
          startOf(
            icon,
            text,
            rtl,
            '${button.size}/${button.family}/${button.type}/${button.iconMode}/loading=${button.loading}',
          );
        }
      }
      expect(covered.length, 9);
    });
    testWidgets('other icon/text families and badge anchoring $language', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      await pumpSheet(
        tester,
        family: 'Badge',
        language: language,
        brightness: Brightness.dark,
      );
      for (final badge in tester.widgetList<AppBadge>(find.byType(AppBadge))) {
        final root = find.byWidget(badge);
        expect(tester.getSize(root).width, lessThan(402));
        if (badge.iconMode == BadgeIconMode.none) continue;
        startOf(
          tester.getRect(
            find.descendant(
              of: root,
              matching: find.byKey(const ValueKey('badge-icon-slot')),
            ),
          ),
          tester.getRect(
            find.descendant(of: root, matching: find.text(badge.label)),
          ),
          rtl,
          'Badge',
        );
      }
      await pumpSheet(
        tester,
        family: 'TextField',
        language: language,
        brightness: Brightness.dark,
      );
      for (final support
          in find.byKey(const ValueKey('field-supporting')).evaluate()) {
        final root = find.byWidget(support.widget);
        final icon = find.descendant(
          of: root,
          matching: find.byType(AssetAppIcon),
        );
        if (icon.evaluate().isEmpty) continue;
        startOf(
          tester.getRect(icon.first),
          tester.getRect(
            find.descendant(of: root, matching: find.text(label)).first,
          ),
          rtl,
          'Field helper',
        );
      }
      await pumpSheet(
        tester,
        family: 'AppBar',
        language: language,
        brightness: Brightness.dark,
      );
      for (final (icon, value) in [('crown', '150'), ('currency', '25')]) {
        startOf(
          tester.getRect(find.byKey(ValueKey('audit.app-bar.$icon.artwork'))),
          tester.getRect(find.text(fixtureDigits(value, language))),
          rtl,
          'App Bar $icon',
        );
      }
      await pumpSheet(
        tester,
        family: 'Radio',
        language: language,
        brightness: Brightness.dark,
      );
      for (final radio in tester.widgetList<AppRadioPresentation>(
        find.byType(AppRadioPresentation),
      )) {
        final root = find.byWidget(radio);
        startOf(
          tester.getRect(
            find
                .descendant(
                  of: root,
                  matching: find.byType(TweenAnimationBuilder<Decoration?>),
                )
                .first,
          ),
          tester.getRect(
            find.descendant(of: root, matching: find.text(label)).first,
          ),
          rtl,
          'Radio',
        );
      }
      await pumpSheet(
        tester,
        family: 'Navigator',
        language: language,
        brightness: Brightness.dark,
      );
      for (final item in ['mission', 'shop']) {
        final icons = find.byKey(ValueKey('audit.navigation.$item.icon'));
        final badges = find.byKey(
          ValueKey('audit.navigation.$item.badge.pill'),
        );
        for (var i = 0; i < icons.evaluate().length; i++) {
          final dx =
              tester.getRect(badges.at(i)).center.dx -
              tester.getRect(icons.at(i)).center.dx;
          expect(
            dx,
            rtl ? lessThan(0) : greaterThan(0),
            reason: 'Navigator mirrored badge anchor',
          );
        }
      }
      await pumpSheet(
        tester,
        family: 'OTP',
        language: language,
        brightness: Brightness.dark,
      );
      for (final cell in find.byType(AppOtpCell).evaluate()) {
        expect(tester.getSize(find.byWidget(cell.widget)).width, lessThan(402));
      }
      await pumpSheet(
        tester,
        family: 'AppIcon',
        language: language,
        brightness: Brightness.dark,
      );
      for (final icon in find.byType(AssetAppIcon).evaluate()) {
        expect(
          tester.getSize(find.byWidget(icon.widget)).width,
          lessThanOrEqualTo(100),
        );
      }
    });
  }
  testWidgets('all fa fixture digits are Persian; DS text stays caller-owned', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    for (final family in families) {
      await pumpSheet(
        tester,
        family: family,
        language: 'fa',
        brightness: Brightness.dark,
      );
      for (final paragraph in tester.renderObjectList<RenderParagraph>(
        find.byType(RichText),
      )) {
        if (sheetCases(
          family,
          'fa',
          Brightness.dark,
        ).any((e) => e.key == paragraph.text.toPlainText())) {
          continue;
        }
        expect(
          RegExp('[0-9]').hasMatch(paragraph.text.toPlainText()),
          isFalse,
          reason: '$family: ${paragraph.text.toPlainText()}',
        );
      }
      for (final input in tester.widgetList<EditableText>(
        find.byType(EditableText),
      )) {
        expect(
          RegExp('[0-9]').hasMatch(input.controller.text),
          isFalse,
          reason: family,
        );
      }
    }
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.build(brightness: Brightness.dark),
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: UiIdentityScope(
            routeName: 'passthrough',
            child: Center(
              child: AppBadge(elementId: 'test.badge', label: '123'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('123'), findsOneWidget);
    expect(find.text('۱۲۳'), findsNothing);
  });
  testWidgets(
    'avatar paint is clipped to its circle through chrome scale cap',
    (tester) async {
      addTearDown(tester.view.reset);
      for (final language in ['en', 'fa']) {
        for (final scale in [1.0, 1.3, 2.0]) {
          await pumpSheet(
            tester,
            family: 'AppBar',
            language: language,
            brightness: Brightness.dark,
            scale: scale,
          );
          for (final clip in tester.widgetList<ClipOval>(
            find.byType(ClipOval),
          )) {
            expect(clip.clipBehavior, isNot(Clip.none));
            expect(clip.child, isA<FittedBox>());
          }
          for (final paragraph in tester.renderObjectList<RenderParagraph>(
            find.descendant(
              of: find.byType(ClipOval),
              matching: find.byType(RichText),
            ),
          )) {
            expect(
              paragraph.text.toPlainText().characters.length,
              inInclusiveRange(1, 2),
            );
            expect(
              paragraph.textScaler.scale(10) / 10,
              lessThanOrEqualTo(chromeTextScaleCap),
            );
          }
        }
      }
      // A deliberately oversized text slot must not paint beyond the clip.
      Future<(List<int>, Rect)> capture(bool content) async {
        tester.view.physicalSize = const Size(402, 80);
        tester.view.devicePixelRatio = 1;
        final action = AppBarAction(label: 'Action', onPressed: () {});
        await tester.pumpWidget(
          MaterialApp(
            theme: AppThemeFactory.build(brightness: Brightness.dark),
            home: Scaffold(
              body: UiIdentityScope(
                routeName: 'clip-proof',
                child: RepaintBoundary(
                  key: const ValueKey('clip-proof'),
                  child: AppBarContent(
                    elementId: 'test.bar',
                    configuration: HomeAppBar(
                      avatar: AppBarAvatar(
                        content: content
                            ? Transform.scale(
                                scale: 4,
                                child: const Text(
                                  'H',
                                  style: TextStyle(
                                    fontFamily:
                                        'packages/p2e_design_system/Outfit',
                                    fontSize: 20,
                                    color: Color(0xff00ff00),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      wallet: const AppBarWallet(
                        points: '1',
                        unit: 'point',
                        coins: '1',
                        pointsSemanticLabel: '1 point',
                        coinsSemanticLabel: '1 coin',
                      ),
                      profile: action,
                      help: action,
                      addCoins: action,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('clip-proof')),
        );
        final rect = tester.getRect(find.byType(ClipOval));
        final data = await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!.buffer.asUint8List();
          image.dispose();
          return bytes;
        });
        return (data!, rect);
      }

      final (blank, rect) = await capture(false);
      final (painted, _) = await capture(true);
      var insideChanged = false;
      for (var i = 0; i < blank.length; i += 4) {
        final point = Offset((i ~/ 4 % 402) + .5, (i ~/ 4 ~/ 402) + .5);
        final outside = (point - rect.center).distance > rect.width / 2 + 1;
        if (outside) {
          expect(painted.sublist(i, i + 4), blank.sublist(i, i + 4));
        } else if (List.generate(
          4,
          (channel) => painted[i + channel] != blank[i + channel],
        ).any((changed) => changed)) {
          insideChanged = true;
        }
      }
      expect(insideChanged, isTrue);
    },
  );
}
