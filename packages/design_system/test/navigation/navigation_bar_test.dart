import 'dart:io';
import 'dart:ui' show ImageByteFormat, Tristate, SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

const locator = UiRuntimeLocator(
  routeName: 'navigation-test',
  routeInstanceId: 'test',
);
List<AppNavigationDestination> destinations({
  Brightness brightness = Brightness.dark,
  String? badge,
  String? longLabel,
  bool persian = false,
}) => [
  for (final d in NavigationBarSpec.lookup(brightness).referenceDestinations)
    AppNavigationDestination(
      id: d.id,
      label:
          longLabel ??
          (persian
              ? {
                  'home': 'خانه',
                  'mission': 'مأموریت',
                  'games': 'بازی‌ها',
                  'leaderboard': 'جدول رتبه‌بندی',
                  'shop': 'فروشگاه',
                }[d.id]!
              : d.label),
      icon: d.icon,
      badge: (d.id == 'mission' || d.id == 'shop')
          ? AppNavigationBadge(
              label: badge ?? d.badge!,
              semanticLabel: '${d.id} notifications',
            )
          : null,
    ),
];
AppNavigationBar bar(
  List<AppNavigationDestination> items, {
  String selected = 'home',
  ValueChanged<String>? onSelected,
}) => AppNavigationBar(
  elementId: 'test.nav',
  runtimeLocator: locator,
  destinations: items,
  selectedDestinationId: selected,
  onDestinationSelected: onSelected,
);
Finder key(String value) => find.byKey(ValueKey('test.nav.$value'));
Future<void> mount(
  WidgetTester t,
  Widget child, {
  Brightness brightness = Brightness.dark,
  TextDirection direction = TextDirection.ltr,
  double width = 402,
  double scale = 1,
  bool reduced = false,
  Locale locale = const Locale('en'),
}) async {
  t.view.physicalSize = const Size(1200, 1600);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(
      builder: (context, child) => Localizations.override(
        context: context,
        locale: locale,
        child: child!,
      ),
      theme: AppThemeFactory.build(brightness: brightness),
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(
            textScaler: TextScaler.linear(scale),
            disableAnimations: reduced,
          ),
          child: Directionality(
            textDirection: direction,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(width: width, child: child),
            ),
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
  expect(t.takeException(), isNull);
}

void main() {
  test('two bars, four item states, exact paired original artwork and unlinked typography', () {
    expect(NavigationBarSpec.all.length, 2);
    expect(NavigationItemSpec.all.length, 4);
    const outlineIds = [
      '18422:10890',
      '18422:11271',
      '18422:11301',
      '18422:11268',
      '18422:11365',
    ];
    for (final s in NavigationBarSpec.all) {
      expect(s.sourceSize, const Size(402, 68));
      expect(s.padding('body').horizontal, 12);
      final rows = s.referenceDestinations;
      expect(rows.length, 5);
      for (var i = 0; i < rows.length; i++) {
        final icon = AppIconRegistry.definition(rows[i].icon);
        expect(icon.mirrorInRtl, isFalse);
        expect(icon.artwork(AppIconStyle.outline).nodeId, outlineIds[i]);
        for (final style in AppIconStyle.values) {
          expect(
            File(icon.artwork(style).assetPath).lengthSync(),
            greaterThan(0),
          );
        }
      }
      expect(NavigationLayout.minimumWidth(s), 252);
    }
    for (final s in NavigationItemSpec.all) {
      expect(s.part('label')['textStyleId'], '');
      expect(s.part('badgeLabel')['textStyleId'], '');
      expect(s.data['reactions'], isEmpty);
      expect(s.metric('label', 'fontSize'), 12);
      expect(s.metric('badgeLabel', 'fontSize'), 10);
    }
  });
  test('invalid counts, IDs and selection fail beyond assertions', () {
    final d = destinations();
    expect(() => bar(d.take(4).toList()), throwsArgumentError);
    expect(
      () => bar([d.first, ...d.skip(1).take(3), d.first]),
      throwsArgumentError,
    );
    expect(() => bar(d, selected: 'absent'), throwsArgumentError);
    expect(
      () => AppNavigationBadge(label: '', semanticLabel: 'badge'),
      throwsArgumentError,
    );
    expect(
      () => AppNavigationDestination(
        id: '',
        label: 'Label',
        icon: AppIconId.home,
      ),
      throwsArgumentError,
    );
    expect(
      NavigationLayout.resolve(
        spec: NavigationBarSpec.all.first,
        destinations: d,
        width: 251,
        scaler: TextScaler.noScaling,
      ).itemWidth,
      (251 - 12) / 5,
    );
  });
  for (final s in NavigationBarSpec.all) {
    testWidgets(
      '${s.rawName} exact source geometry, tints, badge anchor and full hit cells',
      (t) async {
        await mount(
          t,
          bar(destinations(brightness: s.brightness)),
          brightness: s.brightness,
        );
        expect(t.getSize(key('content')), const Size(402, 68));
        final origin = t.getTopLeft(key('content'));
        for (var i = 0; i < 5; i++) {
          final d = s.referenceDestinations[i],
              spec = NavigationItemSpec.lookup(
                s.brightness,
                i == 0
                    ? AppNavigationItemState.active
                    : AppNavigationItemState.inactive,
              );
          expect(t.getSize(key('${d.id}.hit')), const Size(78, 68));
          expect(
            t.getRect(key('${d.id}.hit')).topLeft,
            origin + Offset(6 + 78.0 * i, 0),
          );
          expect(t.getSize(key('${d.id}.indicator')), const Size(64, 32));
          expect(t.getSize(key('${d.id}.icon')), const Size(24, 24));
          final icon = t.widget<AssetAppIcon>(key('${d.id}.icon'));
          expect(icon.color, spec.iconTint);
          expect(icon.style, spec.iconStyle);
          if (d.badge != null) {
            expect(t.getSize(key('${d.id}.badge')), const Size(16, 16));
            expect(t.getSize(key('${d.id}.badge.pill')), const Size(16, 14));
            expect(
              t.getTopLeft(key('${d.id}.badge')) -
                  t.getTopLeft(key('${d.id}.indicator')),
              const Offset(32, 0),
            );
          }
        }
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(AppBadge), findsNothing);
      },
    );
    for (final state in AppNavigationItemState.values) {
      testWidgets('${s.brightness.name}/${state.name} standalone source item', (
        t,
      ) async {
        final d = AppNavigationDestination(
          id: 'home',
          label: 'Home',
          icon: AppIconId.home,
          badge: AppNavigationBadge(label: '2', semanticLabel: 'two updates'),
        );
        await mount(
          t,
          AppNavigationItem(
            elementId: 'test.nav.home',
            runtimeLocator: locator,
            destination: d,
            state: state,
            onPressed: () {},
          ),
          width: 80,
          brightness: s.brightness,
        );
        expect(t.getSize(key('home.hit')), const Size(80, 68));
        expect(
          t
              .widgetList<ElementIdentity>(find.byType(ElementIdentity))
              .first
              .variantId,
          NavigationItemSpec.lookup(s.brightness, state).id,
        );
      });
    }
  }
  testWidgets(
    'all selected destinations use Fill and preserve controlled selection/reselection',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final d in destinations()) {
          await mount(
            t,
            bar(destinations(), selected: d.id),
            brightness: brightness,
          );
          for (final icon in t.widgetList<AssetAppIcon>(
            find.byType(AssetAppIcon),
          )) {
            expect(
              icon.style,
              icon.id == d.icon ? AppIconStyle.fill : AppIconStyle.outline,
            );
          }
        }
      }
      final events = <String>[];
      await mount(t, bar(destinations(), onSelected: events.add));
      await t.tapAt(t.getCenter(key('mission.badge')));
      await t.pumpAndSettle();
      expect(events, ['mission']);
      expect(t.widget<AssetAppIcon>(key('home.icon')).style, AppIconStyle.fill);
      await t.tap(key('home.hit'));
      await t.pumpAndSettle();
      expect(events, ['mission', 'home']);
      final reordered = destinations().reversed.toList();
      await mount(
        t,
        bar(reordered, selected: 'mission'),
        brightness: Brightness.light,
        direction: TextDirection.rtl,
      );
      final identity = t
          .widgetList<ElementIdentity>(find.byType(ElementIdentity))
          .firstWhere((i) => i.elementId == 'test.nav.mission');
      expect(identity.variants['state'], 'active');
      expect(identity.variantId, '18422:11462');
    },
  );
  testWidgets(
    'responsive English/Persian, long labels and badges, RTL and scales',
    (t) async {
      for (final width in [280.0, 320.0, 360.0, 402.0, 900.0]) {
        for (final scale in [1.0, 1.3]) {
          for (final rtl in [false, true]) {
            final items = destinations(
              persian: rtl,
              badge: '123456789012345678901234567890',
              longLabel: rtl
                  ? 'عنوان طولانی مقصد آزمایشی'
                  : 'Long destination label',
            );
            await mount(
              t,
              bar(items),
              width: width,
              scale: scale,
              direction: rtl ? TextDirection.rtl : TextDirection.ltr,
              locale: Locale(rtl ? 'fa' : 'en'),
            );
            final rects = [
              for (final d in items) t.getRect(key('${d.id}.hit')),
            ];
            for (var i = 0; i < rects.length; i++) {
              expect(rects[i].width, greaterThanOrEqualTo(48));
              for (var j = i + 1; j < rects.length; j++) {
                final intersection = rects[i].intersect(rects[j]);
                expect(
                  intersection.width <= 0.001 || intersection.height <= 0.001,
                  isTrue,
                  reason:
                      'No hit overlap beyond subpixel rounding: ${rects[i]} / ${rects[j]}',
                );
              }
              final badge = key('${items[i].id}.badge.pill');
              if (badge.evaluate().isNotEmpty) {
                expect(
                  t.getRect(badge).left,
                  greaterThanOrEqualTo(rects[i].left),
                );
                expect(
                  t.getRect(badge).right,
                  lessThanOrEqualTo(rects[i].right),
                );
              }
            }
            expect(t.getSize(key('content')).height, greaterThan(68));
            expect(find.byType(Scrollable), findsNothing);
            expect(find.byType(AssetAppIcon), findsNWidgets(5));
            if (rtl) {
              expect(rects.first.left, greaterThan(rects.last.left));
            }
          }
        }
      }
      await mount(t, bar(destinations(badge: '0')));
      expect(find.text('0'), findsNWidgets(2));
    },
  );
  testWidgets(
    'one indexed tab semantic per destination; focus, keyboard and callbacks',
    (t) async {
      final events = <String>[];
      await mount(t, bar(destinations(), onSelected: events.add));
      final sem = t.ensureSemantics();
      for (final d in destinations()) {
        final node = t.getSemantics(find.bySemanticsLabel(d.label));
        expect(node.getSemanticsData().role, SemanticsRole.tab);
        expect(
          node.getSemanticsData().flagsCollection.isSelected,
          d.id == 'home' ? Tristate.isTrue : Tristate.isFalse,
        );
      }
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      final button = t
          .widgetList<TextButton>(find.byType(TextButton))
          .firstWhere(
            (b) => b.statesController!.value.contains(WidgetState.focused),
          );
      expect(button.style!.side!.resolve({WidgetState.focused})!.width, 2);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(events, ['home']);
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      await t.pumpAndSettle();
      expect(events, ['home', 'home']);
      sem.dispose();
    },
  );
  testWidgets(
    'press is local, reduced motion immediate, interrupted selection keeps endpoints',
    (t) async {
      String selected = 'home';
      Widget controlled() => StatefulBuilder(
        builder: (context, update) => bar(
          destinations(),
          selected: selected,
          onSelected: (id) => update(() => selected = id),
        ),
      );
      await mount(t, controlled());
      Finder transform(String id) => find.descendant(
        of: key('$id.hit'),
        matching: find.byKey(const ValueKey('app-button-press-transform')),
      );
      final bounds = t.getRect(key('mission.hit'));
      final gesture = await t.startGesture(bounds.center);
      await t.pump(const Duration(milliseconds: 110));
      await t.pump(ButtonMotion.pressDuration);
      expect(
        t.widget<Transform>(transform('mission')).transform.entry(0, 0),
        lessThan(1),
      );
      expect(t.widget<Transform>(transform('home')).transform.entry(0, 0), 1);
      expect(t.getRect(key('mission.hit')), bounds);
      await gesture.up();
      await t.pump(const Duration(milliseconds: 30));
      await t.tap(key('games.hit'));
      await t.pumpAndSettle();
      expect(selected, 'games');
      expect(t.getSize(key('content')), const Size(402, 68));
      expect(
        t.widget<AssetAppIcon>(key('games.icon')).style,
        AppIconStyle.fill,
      );
      final indicator = t.widget<AnimatedContainer>(key('games.indicator'));
      expect(
        (indicator.decoration! as BoxDecoration).color,
        NavigationItemSpec.lookup(
          Brightness.dark,
          AppNavigationItemState.active,
        ).color('indicator'),
      );
      await mount(t, bar(destinations(), onSelected: (_) {}), reduced: true);
      expect(
        t.widget<AnimatedContainer>(key('home.indicator')).duration,
        Duration.zero,
      );
      final reduced = await t.startGesture(t.getCenter(key('mission.hit')));
      await t.pump(const Duration(milliseconds: 200));
      expect(
        t.widget<Transform>(transform('mission')).transform.entry(0, 0),
        1,
      );
      await reduced.cancel();
    },
  );
  for (final inset in [0.0, 24.0, 34.0]) {
    testWidgets('bottom inset $inset is counted once with source background', (
      t,
    ) async {
      await t.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.build(brightness: Brightness.dark),
          home: MediaQuery(
            data: MediaQueryData(
              padding: EdgeInsets.only(bottom: inset),
              viewPadding: EdgeInsets.only(bottom: inset),
            ),
            child: Scaffold(
              bottomNavigationBar: AppNavigationBarHost(
                bar: bar(destinations()),
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(t.getSize(key('content')).height, 68);
      expect(t.getSize(find.byType(AppNavigationBarHost)).height, 68 + inset);
      expect(find.byType(SafeArea), findsOneWidget);
    });
  }
  testWidgets('diagnostic exact source endpoints; no golden baseline', (
    t,
  ) async {
    t.view.physicalSize = const Size(402, 136);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    await t.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: boundary,
          child: Column(
            children: [
              for (final s in NavigationBarSpec.all)
                Theme(
                  data: AppThemeFactory.build(brightness: s.brightness),
                  child: bar(destinations(brightness: s.brightness)),
                ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    await t.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ImageByteFormat.png);
      final file = File('../../build/navigation-validation/source-bars.png');
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(data!.buffer.asUint8List());
      image.dispose();
    });
  });
}
