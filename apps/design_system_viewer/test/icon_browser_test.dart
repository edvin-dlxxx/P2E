import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system_viewer/icons/icon_browser.dart';
import 'package:p2e_design_system_viewer/inspection/component_inspector.dart';
import 'package:p2e_design_system_viewer/inspection/inspection_record.dart';
import 'package:p2e_design_system_viewer/inspection/viewer_selection_frame.dart';
import 'package:p2e_design_system_viewer/l10n/generated/viewer_localizations.dart';

import 'viewer_shell_test.dart' show open, choose;

Future<void> iconControl(
  WidgetTester tester,
  String control,
  String label,
) async {
  final finder = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('icons-$control-'),
  );
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
}

void main() {
  for (final language in ['en', 'fa']) {
    testWidgets(
      '$language Icons search, styles, tint, physical-left selection and inspector',
      (tester) async {
        await open(tester, language: language);
        await tester.tap(find.byKey(const ValueKey('section-6')));
        await tester.pumpAndSettle();
        final l = ViewerLocalizations.of(
          tester.element(find.byType(IconBrowser)),
        );
        expect(
          find.text(
            l.iconLibraryCounts(
              AppIconRegistry.all.length,
              AppIconRegistry.all.fold<int>(0, (n, i) => n + i.styles.length),
            ),
          ),
          findsOneWidget,
        );
        expect(
          Directionality.of(tester.element(find.byType(IconBrowser))),
          language == 'fa' ? TextDirection.rtl : TextDirection.ltr,
        );
        expect(
          tester
              .getRect(find.byKey(const ValueKey('physical-left-inspector')))
              .left,
          0,
        );
        for (final query in ['icon.crown', 'Crown', l.iconLabel('crown')]) {
          await tester.enterText(
            find.byKey(const ValueKey('icons-search')),
            query,
          );
          await tester.pumpAndSettle();
          expect(find.text(l.iconLibraryCounts(1, 2)), findsOneWidget);
        }
        final card = find.byKey(const ValueKey('icon-card-icon.crown:fill'));
        await tester.tap(card);
        await tester.pumpAndSettle();
        expect(tester.widget<ViewerSelectionFrame>(card).selected, isTrue);
        expect(
          find.descendant(
            of: find.byType(AssetAppIcon).first,
            matching: find.byType(ViewerSelectionFrame),
          ),
          findsNothing,
        );
        InspectionRecord current() => tester
            .widget<ComponentInspector>(find.byType(ComponentInspector))
            .record!;
        Object? field(InspectionFieldId id) => current().groups.values
            .expand((g) => g)
            .singleWhere((f) => f.id == id)
            .value;
        expect(field(InspectionFieldId.logicalKey), 'icon.crown');
        expect(
          field(InspectionFieldId.variantId),
          AppIconRegistry.definition(AppIconId.crown)
              .artwork(AppIconStyle.fill)
              .nodeId,
        );
        expect(
          field(InspectionFieldId.assetHash),
          AppIconRegistry.definition(AppIconId.crown)
              .artwork(AppIconStyle.fill)
              .sha256,
        );
        expect(field(InspectionFieldId.renderStatus), l.iconRendered);
        await iconControl(tester, 'style', l.fillIcon);
        expect(find.text(l.iconLibraryCounts(1, 1)), findsOneWidget);
        await iconControl(tester, 'size', '64');
        await iconControl(tester, 'theme', l.light);
        await iconControl(tester, 'tint', l.themeTint);
        expect(tester.widget<AssetAppIcon>(find.byType(AssetAppIcon)).size, 64);
        expect(
          tester.widget<AssetAppIcon>(find.byType(AssetAppIcon)).color,
          ButtonThemeTokens.forBrightness(Brightness.light)
              .color('On Surface/Emphasis'),
        );
        expect(field(InspectionFieldId.previewSize), const Size(64, 64));
        await iconControl(tester, 'style', l.outlineIcon);
        expect(
          tester
              .widget<ComponentInspector>(find.byType(ComponentInspector))
              .record,
          isNull,
        );
        await tester.enterText(
          find.byKey(const ValueKey('icons-search')),
          'does-not-exist',
        );
        await tester.pumpAndSettle();
        expect(find.text(l.emptyState), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('icons-reset')));
        await tester.pumpAndSettle();
        expect(find.text(l.iconLibraryCounts(104, 208)), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Buttons source glyph links, icon-only none and 90 base identities',
    (tester) async {
      await open(tester);
      final context = tester.element(find.byType(AppButton).first),
          l = ViewerLocalizations.of(context);
      final icon = ButtonSpec.all.firstWhere(
        (s) =>
            s.family == AppButtonFamily.icon &&
            s.size == AppButtonSize.small &&
            s.brightness == Brightness.dark &&
            s.type == AppButtonType.filled,
      );
      final finder = find.byKey(ValueKey('button-${icon.id}'));
      AssetAppIcon artwork() => tester.widget<AssetAppIcon>(
        find.descendant(of: finder, matching: find.byType(AssetAppIcon)),
      );
      expect(artwork().id, AppIconId.crown);
      expect(artwork().style, AppIconStyle.fill);
      await choose(tester, 'icon', l.outlineIcon);
      expect(artwork().id, AppIconId.editSquare);
      expect(artwork().style, AppIconStyle.outline);
      expect(find.byType(AppButton), findsNWidgets(90));
      await choose(tester, 'icon', l.none);
      expect(finder, findsNothing);
      expect(find.byKey(const ValueKey('app-button-icon-slot')), findsNothing);
      expect(find.byKey(const ValueKey('app-button-icon-gap')), findsNothing);
      expect(find.text(l.sourceCount(90)), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
