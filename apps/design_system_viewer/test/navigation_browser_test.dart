import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system_viewer/main.dart';
import 'package:p2e_design_system_viewer/navigation/navigation_browser.dart';
import 'package:p2e_design_system_viewer/inspection/component_inspector.dart';
import 'package:p2e_design_system_viewer/inspection/inspection_record.dart';
import 'package:p2e_design_system_viewer/l10n/generated/viewer_localizations.dart';

Future<void> choose(WidgetTester t, String control, String value) async {
  final f = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('nav-$control-'),
  );
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
  await t.tap(find.text(value).last);
  await t.pumpAndSettle();
}

AppNavigationBar live(WidgetTester t) => t.widget<AppNavigationBar>(
  find.descendant(
    of: find.byKey(const ValueKey('navigation.live')),
    matching: find.byType(AppNavigationBar),
  ),
);
void main() {
  for (final language in ['en', 'fa']) {
    testWidgets(
      '$language navigation source counts, controlled live state, host measurements and inspector',
      (t) async {
        t.view.physicalSize = const Size(2400, 1800);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        await t.pumpWidget(DevelopmentViewer(initialLocale: Locale(language)));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const ValueKey('section-8')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const ValueKey('components-navigation')));
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        final l = ViewerLocalizations.of(
          t.element(find.byType(NavigationBrowser)),
        );
        expect(find.byType(AppNavigationBar), findsNWidgets(3));
        expect(find.byType(AppNavigationItem), findsNWidgets(4));
        expect(find.text(l.navCount(2, 4)), findsOneWidget);
        expect(
          t.getRect(find.byKey(const ValueKey('physical-left-inspector'))).left,
          0,
        );
        const source = 'navigation.source.dark';
        final mission = find.byKey(const ValueKey('$source.mission.hit'));
        await t.ensureVisible(mission);
        await t.tap(mission);
        await t.pumpAndSettle();
        expect(live(t).selectedDestinationId, 'home');
        final sourceRecord = t
            .widget<ComponentInspector>(find.byType(ComponentInspector))
            .record!;
        expect(sourceRecord.sampleId, source);
        final identities =
            sourceRecord.groups[InspectionGroup.identity]!
                    .firstWhere(
                      (f) => f.id == InspectionFieldId.runtimeIdentity,
                    )
                    .value
                as Map;
        expect(
          identities.keys,
          containsAll([source, '$source.home', '$source.mission']),
        );
        await choose(t, 'selected', l.navGames);
        expect(live(t).selectedDestinationId, 'games');
        final shop = find.byKey(const ValueKey('navigation.live.shop.hit'));
        await t.ensureVisible(shop);
        await t.tap(shop);
        await t.pumpAndSettle();
        expect(live(t).selectedDestinationId, 'shop');
        expect(
          t
              .widget<ComponentInspector>(find.byType(ComponentInspector))
              .record!
              .sampleId,
          'navigation.live',
        );
        await choose(t, 'inset', '34');
        await choose(t, 'width', '252');
        expect(
          t
              .getSize(find.byKey(const ValueKey('navigation.live.content')))
              .width,
          252,
        );
        expect(
          t
              .getSize(find.byKey(const ValueKey('navigation.live.home.hit')))
              .width,
          48,
        );
        final widthControl = t.widget<DropdownButton<String>>(
          find.descendant(
            of: find.byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith('nav-width-'),
            ),
            matching: find.byType(DropdownButton<String>),
          ),
        );
        expect(
          widthControl.items!.map((item) => double.parse(item.value!)),
          everyElement(greaterThanOrEqualTo(252)),
        );
        expect(t.takeException(), isNull);
        await choose(t, 'width', '320');
        await choose(t, 'scale', '1.3');
        await choose(t, 'direction', l.rtl);
        final label = find.byKey(const ValueKey('nav-label-home'));
        await t.ensureVisible(label);
        await t.enterText(label, 'Custom Home');
        await t.pumpAndSettle();
        final badge = find.byKey(const ValueKey('nav-badge-mission'));
        await t.ensureVisible(badge);
        await t.enterText(badge, '0');
        await t.pumpAndSettle();
        expect(
          live(t).destinations
              .firstWhere((d) => d.id == 'mission')
              .badge!
              .label,
          '0',
        );
        expect(live(t).destinations.first.label, 'Custom Home');
        await choose(t, 'theme', l.light);
        expect(find.byType(AppNavigationBar), findsNWidgets(2));
        expect(find.byType(AppNavigationItem), findsNWidgets(2));
        expect(find.text(l.navCount(1, 2)), findsOneWidget);
        expect(live(t).selectedDestinationId, 'shop');
        final inspect = find.byKey(const ValueKey('inspect-navigation.live'));
        await t.ensureVisible(inspect);
        await t.tap(inspect);
        await t.pumpAndSettle();
        final record = t
            .widget<ComponentInspector>(find.byType(ComponentInspector))
            .record!;
        final config =
            record.groups[InspectionGroup.configuration]!
                    .firstWhere((f) => f.id == InspectionFieldId.label)
                    .value
                as Map;
        expect(config['selectedDestinationId'], 'shop');
        final constraints =
            record.groups[InspectionGroup.geometry]!
                    .firstWhere((f) => f.id == InspectionFieldId.constraints)
                    .value
                as Map;
        final bounds =
            record.groups[InspectionGroup.geometry]!
                    .firstWhere((f) => f.id == InspectionFieldId.content)
                    .value
                as Map;
        expect(constraints['bottomInset'], 34);
        expect(bounds.keys, contains('navigation.live.content'));
        final measured = t.getSize(
          find.byKey(const ValueKey('navigation.live.content')),
        );
        expect(
          constraints['totalHostHeight'],
          closeTo(measured.height + 34, 0.001),
        );
        final actualIds =
            record.groups[InspectionGroup.identity]!
                    .firstWhere(
                      (f) => f.id == InspectionFieldId.runtimeIdentity,
                    )
                    .value
                as Map;
        expect(
          (actualIds['navigation.live.shop']
              as Map)['identity']['designRef']['nodeId'],
          '18422:11462',
        );
        await t.ensureVisible(find.byKey(const ValueKey('language-control')));
        await t.tap(find.byKey(const ValueKey('language-control')));
        await t.pumpAndSettle();
        await t.tap(find.text(language == 'en' ? l.persian : l.english).last);
        await t.pumpAndSettle();
        expect(live(t).selectedDestinationId, 'shop');
        expect(live(t).destinations.first.label, 'Custom Home');
        expect(
          live(t).destinations
              .firstWhere((d) => d.id == 'mission')
              .badge!
              .label,
          '0',
        );
        await t.tap(find.byKey(const ValueKey('components-app-bar')));
        await t.pumpAndSettle();
        expect(find.byType(AppNavigationBar), findsNothing);
        expect(find.byType(AppBarContent), findsNWidgets(5));
        expect(
          t.widget<ComponentInspector>(find.byType(ComponentInspector)).record,
          isNull,
        );
        expect(t.takeException(), isNull);
      },
    );
  }
}
