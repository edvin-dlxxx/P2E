import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system_viewer/main.dart';
import 'package:p2e_design_system_viewer/app_bars/app_bar_browser.dart';
import 'package:p2e_design_system_viewer/inspection/component_inspector.dart';
import 'package:p2e_design_system_viewer/inspection/inspection_record.dart';
import 'package:p2e_design_system_viewer/l10n/generated/viewer_localizations.dart';

Future<void> choose(WidgetTester t, String control, String value) async {
  final f = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('app-bar-$control-'),
  );
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
  await t.tap(find.text(value).last);
  await t.pumpAndSettle();
}

void main() {
  for (final language in ['en', 'fa']) {
    testWidgets(
      '$language App Bar catalog, source counts, selection, actions, inspector and filters',
      (t) async {
        t.view.physicalSize = const Size(2400, 1800);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        await t.pumpWidget(DevelopmentViewer(initialLocale: Locale(language)));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const ValueKey('section-8')));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byType(AppBarContent), findsNWidgets(5));
        final l = ViewerLocalizations.of(t.element(find.byType(AppBarBrowser)));
        expect(find.text(l.appBarCount(5)), findsOneWidget);
        expect(
          t.getRect(find.byKey(const ValueKey('physical-left-inspector'))).left,
          0,
        );
        final help = find.byKey(
          const ValueKey('viewer.app-bar.dark.home.help.hit'),
        );
        await t.ensureVisible(help);
        await t.tap(help);
        await t.pumpAndSettle();
        expect(find.textContaining('${l.appBarHelp}: 1'), findsOneWidget);
        final inspector = t.widget<ComponentInspector>(
          find.byType(ComponentInspector),
        );
        expect(inspector.record?.sampleId, '18422:12446');
        final identity =
            inspector.record!.groups[InspectionGroup.identity]!
                    .firstWhere(
                      (f) => f.id == InspectionFieldId.runtimeIdentity,
                    )
                    .value
                as Map;
        expect(
          identity.keys,
          containsAll([
            'viewer.app-bar.dark.home',
            'viewer.app-bar.dark.home.profile',
            'viewer.app-bar.dark.home.help',
          ]),
        );
        final geometry =
            inspector.record!.groups[InspectionGroup.geometry]!
                    .firstWhere((f) => f.id == InspectionFieldId.visual)
                    .value
                as Map;
        expect(geometry.keys, contains('viewer.app-bar.dark.home.help.hit'));
        await choose(t, 'mode', l.appBarLocalized);
        await choose(t, 'direction', l.rtl);
        await choose(t, 'scale', '1.3');
        await choose(t, 'width', '320');
        final long = find.byKey(const ValueKey('app-bar-long'));
        await t.ensureVisible(long);
        await t.tap(long);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        await choose(t, 'category', l.appBarGame);
        expect(find.byType(AppBarContent), findsNWidgets(2));
        expect(
          t.widget<ComponentInspector>(find.byType(ComponentInspector)).record,
          isNull,
        );
        await choose(t, 'theme', l.light);
        expect(find.byType(AppBarContent), findsOneWidget);
        final dot = find.byKey(const ValueKey('app-bar-notification'));
        await t.ensureVisible(dot);
        await t.tap(dot);
        await t.pumpAndSettle();
        expect(
          find.byKey(
            const ValueKey(
              'viewer.app-bar.light.downloadable-game.notification',
            ),
          ),
          findsNothing,
        );
        await choose(t, 'category', l.appBarBack);
        expect(find.byType(AppBarContent), findsNothing);
        expect(find.text(l.appBarCount(0)), findsOneWidget);
        expect(find.text(l.appBarMissing), findsOneWidget);
        expect(t.takeException(), isNull);
      },
    );
  }
}
