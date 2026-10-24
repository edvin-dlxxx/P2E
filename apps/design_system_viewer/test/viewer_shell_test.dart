import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system_viewer/main.dart';
import 'package:p2e_design_system_viewer/board/button_board.dart';
import 'package:p2e_design_system_viewer/board/button_sample.dart';
import 'package:p2e_design_system_viewer/catalog/button_catalog.dart';
import 'package:p2e_design_system_viewer/inspection/inspection_record.dart';
import 'package:p2e_design_system_viewer/inspection/component_inspector.dart';
import 'package:p2e_design_system_viewer/inspection/viewer_selection_frame.dart';
import 'package:p2e_design_system_viewer/l10n/generated/viewer_localizations.dart';
import 'package:p2e_design_system_viewer/icons/icon_browser.dart';
import 'package:p2e_design_system_viewer/fields/field_browser.dart';
import 'package:p2e_design_system_viewer/badges/badge_browser.dart';
import 'package:p2e_design_system_viewer/app_bars/app_bar_browser.dart';

Future<void> open(
  WidgetTester tester, {
  String language = 'en',
  double width = 2400,
}) async {
  tester.view.physicalSize = Size(width, 1500);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(DevelopmentViewer(initialLocale: Locale(language)));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

ViewerLocalizations strings(WidgetTester tester) =>
    ViewerLocalizations.of(tester.element(find.byType(ButtonBoard)));
Future<void> choose(WidgetTester tester, String control, String value) async {
  final finder = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('control-$control-'),
  );
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  test(
    'ARB key parity and generated inspector field translations are complete',
    () async {
      final en = jsonDecode(
        File('l10n/viewer/viewer_en.arb').readAsStringSync(),
      ) as Map;
      final fa = jsonDecode(
        File('l10n/viewer/viewer_fa.arb').readAsStringSync(),
      ) as Map;
      expect(
        en.keys.where((k) => !k.startsWith('@')),
        unorderedEquals(fa.keys.where((k) => !k.startsWith('@'))),
      );
      for (final locale in [const Locale('en'), const Locale('fa')]) {
        final l = await ViewerLocalizations.delegate.load(locale);
        for (final id in InspectionFieldId.values) {
          expect(l.fieldLabel(id.name), isNot(l.unavailable));
        }
      }
    },
  );
  for (final language in ['en', 'fa']) {
    testWidgets(
      '$language shell, physical board order, 90 identities and inspector',
      (tester) async {
        await open(tester, language: language);
        final l = strings(tester);
        expect(find.byType(ButtonSample), findsNWidgets(90));
        final widgets = tester.widgetList<ButtonSample>(
          find.byType(ButtonSample),
        );
        expect(widgets.map((w) => w.spec.id).toSet().length, 90);
        expect(find.byType(AppButton), findsNWidgets(90));
        expect(find.text(l.sourceCount(90)), findsOneWidget);
        expect(
          tester
              .getRect(find.byKey(const ValueKey('physical-left-inspector')))
              .left,
          0,
        );
        expect(
          Directionality.of(tester.element(find.byType(ComponentInspector))),
          language == 'fa' ? TextDirection.rtl : TextDirection.ltr,
        );
        for (final size in AppButtonSize.values) {
          final boxes = [
            for (final family in ButtonCatalog.families)
              tester.getRect(
                find.byKey(ValueKey('band-${family.name}-${size.name}')),
              ),
          ];
          expect(boxes[0].left, lessThan(boxes[1].left));
          expect(boxes[1].left, lessThan(boxes[2].left));
          expect(boxes[0].top, boxes[1].top);
          expect(boxes[1].top, boxes[2].top);
        }
        for (final family in ButtonCatalog.families) {
          final dark = ButtonCatalog().variants.firstWhere(
            (s) =>
                s.family == family &&
                s.size == AppButtonSize.small &&
                s.brightness == Brightness.dark,
          );
          final light = ButtonCatalog().variants.firstWhere(
            (s) =>
                s.family == family &&
                s.size == AppButtonSize.small &&
                s.brightness == Brightness.light,
          );
          final d = tester.getRect(find.byKey(ValueKey('set-${dark.setId}'))),
              v = tester.getRect(find.byKey(ValueKey('set-${light.setId}')));
          if (family == AppButtonFamily.icon) {
            expect(d.top, lessThan(v.top));
          } else {
            expect(d.left, lessThan(v.left));
          }
        }
        for (final button in tester.widgetList<AppButton>(
          find.byType(AppButton),
        )) {
          final element = tester.element(find.byKey(button.key!));
          expect(
            Directionality.of(element),
            language == 'fa' ? TextDirection.rtl : TextDirection.ltr,
          );
          final spec = ButtonSpec.all.singleWhere(
            (s) => 'button-${s.id}' == (button.key! as ValueKey<String>).value,
          );
          expect(Theme.of(element).brightness, spec.brightness);
        }
        final spec = ButtonSpec.all.firstWhere(
          (s) =>
              s.family == AppButtonFamily.hug &&
              s.size == AppButtonSize.small &&
              s.brightness == Brightness.dark &&
              s.type == AppButtonType.disabled,
        );
        final button = find.byKey(ValueKey('button-${spec.id}'));
        await tester.ensureVisible(button);
        final gesture = await tester.startGesture(tester.getCenter(button));
        await tester.pump(const Duration(milliseconds: 100));
        final transform = find.descendant(
          of: button,
          matching: find.byKey(const ValueKey('app-button-press-transform')),
        );
        expect(tester.widget<Transform>(transform).transform.storage[0], 1);
        await gesture.up();
        await tester.pumpAndSettle();
        final frame = find.byKey(ValueKey('selection-${spec.id}'));
        expect(tester.widget<ViewerSelectionFrame>(frame).selected, isTrue);
        expect(
          find.descendant(
            of: button,
            matching: find.byType(ViewerSelectionFrame),
          ),
          findsNothing,
        );
        expect(
          tester
              .widget<AppButton>(find.byKey(ValueKey('button-${spec.id}')))
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<SelectableText>(
                find.byKey(const ValueKey('inspector-variantId')),
              )
              .data,
          spec.id,
        );
        final resolved = spec.resolve(
          ButtonThemeTokens.forBrightness(spec.brightness),
          iconMode: ButtonIconMode.fill,
        );
        expect(
          tester
              .widget<SelectableText>(
                find.byKey(const ValueKey('inspector-background')),
              )
              .data,
          ComponentInspector.format(resolved.background, l),
        );
        expect(
          tester
              .widget<SelectableText>(
                find.byKey(const ValueKey('inspector-enabled')),
              )
              .data,
          l.no,
        );
        final inspector = tester.widget<ComponentInspector>(
          find.byType(ComponentInspector),
        );
        final fields = inspector.record!.groups.values.expand((g) => g);
        Object? value(InspectionFieldId id) =>
            fields.singleWhere((f) => f.id == id).value;
        expect(value(InspectionFieldId.pressedScale), 1);
        expect(value(InspectionFieldId.pressDuration), 0);
        expect(value(InspectionFieldId.releaseDuration), 0);
        expect(value(InspectionFieldId.currentState), l.disabled);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'combined filters, counts, reset, empty state and selection clearing',
    (tester) async {
      await open(tester);
      final l = strings(tester);
      final selected = ButtonSpec.all.firstWhere(
        (s) =>
            s.brightness == Brightness.dark && s.type == AppButtonType.filled,
      );
      await tester.tap(find.byKey(ValueKey('inspect-${selected.id}')));
      await tester.pumpAndSettle();
      await choose(tester, 'theme', l.light);
      expect(find.text(l.sourceCount(45)), findsOneWidget);
      expect(find.text(l.selectSample), findsOneWidget);
      await choose(tester, 'family', l.hugFamily);
      expect(find.text(l.sourceCount(15)), findsOneWidget);
      await choose(tester, 'size', l.small);
      expect(find.text(l.sourceCount(5)), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('reset-filters')));
      await tester.pumpAndSettle();
      await choose(tester, 'family', l.hugFamily);
      expect(find.text(l.sourceCount(30)), findsOneWidget);
      final board = tester.getRect(find.byKey(const ValueKey('buttons-board'))),
          area = tester.getRect(find.byType(ButtonBoard));
      expect(board.center.dx, closeTo(area.center.dx, 0.01));
      await tester.enterText(
        find.byKey(const ValueKey('source-search')),
        'missing-source',
      );
      await tester.pumpAndSettle();
      expect(find.text(l.emptyState), findsOneWidget);
      expect(find.byType(ButtonSample), findsNothing);
      await tester.tap(find.byKey(const ValueKey('reset-filters')));
      await tester.pumpAndSettle();
      expect(find.byType(ButtonSample), findsNWidgets(90));
    },
  );
  testWidgets(
    'all nine tabs isolate field families and keep localized states',
    (tester) async {
      await open(tester);
      final en = strings(tester);
      for (var i = 1; i < 9; i++) {
        await tester.tap(find.byKey(ValueKey('section-$i')));
        await tester.pumpAndSettle();
        if (i >= 2 && i <= 5) {
          expect(find.byType(FieldBrowser), findsOneWidget);
          expect(
            tester.widget<FieldBrowser>(find.byType(FieldBrowser)).family,
            [
              FieldFamily.textField,
              FieldFamily.password,
              FieldFamily.otp,
              FieldFamily.radio,
            ][i - 2],
          );
          expect(
            find.byType(AppTextField),
            i == 2 ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(AppPasswordField),
            i == 3 ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(AppOtpField),
            i == 4 ? findsOneWidget : findsNothing,
          );
          expect(
            find.byType(AppRadio<int>),
            i == 5 ? findsNWidgets(2) : findsNothing,
          );
          expect(find.text(en.notAddedYet), findsNothing);
        } else if (i == 1) {
          expect(find.byType(BadgeBrowser), findsOneWidget);
          expect(find.byType(AppBadge), findsNWidgets(30));
          expect(find.text(en.notAddedYet), findsNothing);
        } else if (i == 6) {
          expect(find.byType(IconBrowser), findsOneWidget);
          expect(find.text(en.notAddedYet), findsNothing);
        } else if (i == 8) {
          expect(find.byType(AppBarBrowser), findsOneWidget);
          expect(find.byType(AppBarContent), findsNWidgets(5));
          expect(find.text(en.notAddedYet), findsNothing);
        } else {
          expect(find.text(en.notAddedYet), findsOneWidget);
        }
        expect(find.byType(AppButton), findsNothing);
      }
      await tester.tap(find.byKey(const ValueKey('section-0')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('language-control')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(en.persian).last);
      await tester.pumpAndSettle();
      expect(strings(tester).buttons, 'دکمه‌ها');
      expect(find.byType(ButtonSample), findsNWidgets(90));
      expect(
        tester
            .getRect(find.byKey(const ValueKey('physical-left-inspector')))
            .left,
        0,
      );
    },
  );
  testWidgets(
    'selection survives preview changes and keeps exact inspector data',
    (tester) async {
      await open(tester);
      final l = strings(tester);
      final spec = ButtonSpec.all.firstWhere(
        (s) =>
            s.family == AppButtonFamily.hug &&
            s.size == AppButtonSize.small &&
            s.brightness == Brightness.dark &&
            s.type == AppButtonType.disabled,
      );
      final inspect = find.byKey(ValueKey('inspect-${spec.id}'));
      await tester.ensureVisible(inspect);
      await tester.tap(inspect);
      await tester.pumpAndSettle();
      await choose(tester, 'icon', l.none);
      expect(
        tester
            .widget<SelectableText>(
              find.byKey(const ValueKey('inspector-variantId')),
            )
            .data,
        spec.id,
      );
      expect(
        tester
            .widget<SelectableText>(
              find.byKey(const ValueKey('inspector-iconMode')),
            )
            .data,
        l.none,
      );
      expect(
        tester
            .widget<SelectableText>(find.byKey(const ValueKey('inspector-gap')))
            .data,
        '0',
      );
      expect(
        tester
            .widget<SelectableText>(
              find.byKey(const ValueKey('inspector-outer')),
            )
            .data,
        isNot(l.unavailable),
      );
      expect(
        tester
            .widget<AppButton>(find.byKey(ValueKey('button-${spec.id}')))
            .onPressed,
        isNull,
      );
      await choose(tester, 'appearance', l.disabled);
      expect(find.text(l.sourceCount(18)), findsOneWidget);
      expect(
        tester
            .widget<SelectableText>(
              find.byKey(const ValueKey('inspector-variantId')),
            )
            .data,
        spec.id,
      );
      await tester.tap(find.byKey(const ValueKey('reset-filters')));
      await tester.pumpAndSettle();
      expect(find.byType(ButtonSample), findsNWidgets(90));
    },
  );
  testWidgets('none icon, bounded Fill and unstretched Hug use real fonts', (
    tester,
  ) async {
    await open(tester);
    final l = strings(tester);
    await choose(tester, 'icon', l.none);
    expect(find.byKey(const ValueKey('app-button-icon-slot')), findsNothing);
    expect(find.byKey(const ValueKey('app-button-icon-gap')), findsNothing);
    final catalog = ButtonCatalog();
    for (final family in [AppButtonFamily.fill, AppButtonFamily.hug]) {
      final spec = catalog.variants.firstWhere(
        (s) => s.family == family && s.size == AppButtonSize.small,
      );
      final button = find.byKey(ValueKey('button-${spec.id}'));
      final visual = tester.getRect(
        find.descendant(of: button, matching: find.byType(Material)),
      );
      final label = tester.getRect(
        find.descendant(of: button, matching: find.byType(Text)),
      );
      expect(label.center.dx, closeTo(visual.center.dx, 0.01));
      if (family == AppButtonFamily.fill) {
        expect(visual.width, spec.width);
      } else {
        expect(visual.width, lessThan(spec.width));
      }
    }
  });
  for (final language in ['en', 'fa']) {
    testWidgets('$language narrow inspector and long localized 1.3 preview', (
      tester,
    ) async {
      await open(tester, language: language, width: 520);
      final l = strings(tester);
      final first = ButtonCatalog().variants.firstWhere(
        (s) =>
            s.family == AppButtonFamily.fill &&
            s.size == AppButtonSize.small &&
            s.brightness == Brightness.dark,
      );
      expect(
        tester.getRect(find.byKey(ValueKey('set-${first.setId}'))).left,
        greaterThanOrEqualTo(0),
      );
      expect(
        find.byKey(const ValueKey('physical-left-inspector')),
        findsNothing,
      );
      await choose(tester, 'text', l.localizedText);
      await choose(tester, 'scale', '1.3');
      await tester.tap(find.text(l.shortLabel));
      await tester.pumpAndSettle();
      expect(find.text(l.longPreviewLabel), findsNWidgets(60));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('open-inspector')));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      expect(find.text(l.selectSample), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.byType(ComponentInspector))),
        language == 'fa' ? TextDirection.rtl : TextDirection.ltr,
      );
    });
  }
}
