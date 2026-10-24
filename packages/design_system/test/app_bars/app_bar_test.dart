import 'dart:io';
import 'dart:ui' show ImageByteFormat, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

const locator = UiRuntimeLocator(routeName: 'test', routeInstanceId: 'app-bar');
AppBarAction action(String label, [VoidCallback? callback]) =>
    AppBarAction(label: label, onPressed: callback);
HomeAppBar home({
  VoidCallback? callback,
  String points = '5,325',
  String coins = '150',
  CompactAppBarWallet? compact,
}) => HomeAppBar(
  avatar: const AppBarAvatar(text: 'A'),
  profile: action('Profile', callback),
  help: action('Help', callback),
  addCoins: action('Add coins', callback),
  wallet: AppBarWallet(
    points: points,
    unit: 'pts',
    coins: coins,
    pointsSemanticLabel: '$points points',
    coinsSemanticLabel: '$coins coins',
    compact: compact,
  ),
);
DownloadableGameAppBar game({bool dot = true, VoidCallback? callback}) =>
    DownloadableGameAppBar(
      avatar: const AppBarAvatar(text: 'A'),
      back: action('Back', callback),
      downloads: action('Downloads', callback),
      bookmark: action('Bookmark', callback),
      profile: action('Profile', callback),
      showNotification: dot,
      notificationLabel: 'Downloads, new activity',
    );
AppBarContent content(AppBarConfiguration config) => AppBarContent(
  elementId: 'test.bar',
  runtimeLocator: locator,
  configuration: config,
);
Future<void> mount(
  WidgetTester tester,
  AppBarConfiguration config, {
  Brightness brightness = Brightness.dark,
  double width = 402,
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
  bool reduced = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
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
              child: SizedBox(width: width, child: content(config)),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Finder key(String value) => find.byKey(ValueKey('test.bar.$value'));

void main() {
  test('five complete sources, three categories, exact original artwork', () {
    expect(AppBarSpec.all.length, 5);
    expect(AppBarSpec.lookup(AppBarCategory.back, Brightness.light), isNull);
    expect(
      AppBarSpec.all.map((s) => s.category).toSet(),
      AppBarCategory.values.toSet(),
    );
    final masterRoles = {
      'crown': '18422:11366',
      'currency': '18422:12234',
      'addCoins': '14559:951',
      'help': '18422:12323',
      'back': '18517:6375',
      'downloads': '18517:6410',
      'bookmark': '18517:6460',
    };
    for (final s in AppBarSpec.all) {
      expect(s.sourceSize, const Size(402, 64));
      expect(s.color('body'), isNull);
      expect(s.part('spacer')['layoutGrow'], 1);
      expect(s.data['reactions'], isEmpty);
      for (final role in (s.data['artwork'] as Map).keys) {
        final a = s.icon(role).artwork(s.iconStyle(role));
        expect(a.nodeId, masterRoles[role]);
        expect(File(a.assetPath).lengthSync(), greaterThan(0));
        expect(s.iconColor(role), isNotNull);
      }
      expect(
        (s.resolved()['typography'] as Map)['avatarText']?['sourceStyleId'],
        anyOf(equals(''), isNull),
      );
    }
  });
  for (final s in AppBarSpec.all) {
    testWidgets('${s.rawName} source geometry and dynamic display', (
      tester,
    ) async {
      final config = s.category == AppBarCategory.home
          ? home()
          : s.category == AppBarCategory.downloadableGame
          ? game()
          : BackAppBar(back: action('Back'), help: action('Help'));
      await mount(tester, config, brightness: s.brightness);
      expect(tester.getSize(key('content')), const Size(402, 64));
      final roles = config.actions.keys;
      final rects = [
        for (final role in roles) tester.getRect(key('$role.hit')),
      ];
      for (final r in rects) {
        expect(r.size, const Size(48, 48));
      }
      for (var i = 0; i < rects.length; i++) {
        for (var j = i + 1; j < rects.length; j++) {
          expect(rects[i].overlaps(rects[j]), isFalse);
        }
      }
      if (config is HomeAppBar) {
        expect(tester.getSize(key('wallet')), const Size(212, 48));
        expect(tester.getSize(key('points.pill')), const Size(104, 32));
        expect(tester.getSize(key('coins.pill')), const Size(104, 32));
        expect(tester.getRect(key('profile.hit')).left, 16);
        expect(tester.getRect(key('wallet')).left, 126);
        expect(tester.getRect(key('help.hit')).left, 338);
        expect(tester.getSize(key('avatar.surface')), const Size(32, 32));
      }
      if (config is DownloadableGameAppBar) {
        expect(tester.getSize(key('notification')), const Size(6, 6));
        expect(
          tester.getRect(key('notification')).topLeft -
              tester.getRect(key('downloads.hit')).topLeft,
          const Offset(33, 9),
        );
        expect(tester.getSize(key('back.surface')), const Size(32, 32));
      }
      final root = tester
          .widgetList<ElementIdentity>(find.byType(ElementIdentity))
          .first;
      expect(root.variantId, s.id);
      expect(find.byType(AppButton), findsNothing);
      expect(find.byType(AppBadge), findsNothing);
      for (final icon in tester.widgetList<AssetAppIcon>(
        find.byType(AssetAppIcon),
      )) {
        expect(tester.getSize(find.byWidget(icon)), Size.square(icon.size!));
      }
    });
  }
  testWidgets('widths, long values, compact, RTL and scales preserve actions', (
    tester,
  ) async {
    for (final width in [280.0, 320.0, 360.0, 402.0, 900.0]) {
      for (final direction in TextDirection.values) {
        for (final scale in [1.0, 1.3]) {
          await mount(
            tester,
            home(
              points: '۱۲۳٬۴۵۶٬۷۸۹',
              coins: '987,654,321',
              callback: () {},
              compact: const CompactAppBarWallet(
                points: '123M',
                coins: '987M',
                showUnit: false,
              ),
            ),
            width: width,
            scale: scale,
            direction: direction,
          );
          expect(tester.getSize(key('content')).height, 64);
          expect(find.byType(TextButton), findsNWidgets(3));
          final semantics = tester.ensureSemantics();
          expect(find.bySemanticsLabel('۱۲۳٬۴۵۶٬۷۸۹ points'), findsOneWidget);
          semantics.dispose();
          final root = tester
              .widgetList<ElementIdentity>(find.byType(ElementIdentity))
              .first;
          final scrolls =
              ((root.resolved['appBar'] as Map)['value']
                      as Map)['layout']['horizontalScroll']
                  as bool;
          expect(
            find.byType(Scrollbar),
            scrolls ? findsOneWidget : findsNothing,
          );
        }
      }
    }
    await mount(tester, home(points: '9', coins: '2'), width: 900);
    expect(find.text('9'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(tester.getSize(key('wallet')).width, lessThan(212));
    expect(find.byType(Scrollbar), findsNothing);
  });
  testWidgets(
    'dot ignores pointer input; callbacks once, semantics and keyboard',
    (tester) async {
      int calls = 0;
      await mount(tester, game(callback: () => calls++));
      final semantics = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Downloads, new activity'), findsOneWidget);
      await tester.tapAt(tester.getCenter(key('notification')));
      await tester.pumpAndSettle();
      expect(calls, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls, 2);
      semantics.dispose();
      await mount(tester, game(dot: false));
      expect(key('notification'), findsNothing);
      await tester.tap(key('downloads.hit'));
      expect(calls, 2);
      final disabled = tester.ensureSemantics();
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Downloads'))
            .getSemanticsData()
            .flagsCollection
            .isEnabled,
        Tristate.isFalse,
      );
      disabled.dispose();
    },
  );
  testWidgets('source tints differ per instance and back mirrors only once', (
    tester,
  ) async {
    await mount(
      tester,
      game(),
      brightness: Brightness.light,
      direction: TextDirection.rtl,
    );
    final back = tester.widget<AssetAppIcon>(key('back.artwork'));
    final helpSpec = AppBarSpec.lookup(AppBarCategory.home, Brightness.light)!;
    expect(back.definition.mirrorInRtl, isTrue);
    expect(
      back.color,
      AppBarSpec.lookup(
        AppBarCategory.downloadableGame,
        Brightness.light,
      )!.iconColor('back'),
    );
    expect(back.color, isNot(helpSpec.iconColor('help')));
    expect(
      tester.getRect(key('back.hit')).right,
      tester.getRect(key('content')).right - 16,
    );
    for (final icon in tester.widgetList<AssetAppIcon>(
      find.byType(AssetAppIcon),
    )) {
      if (icon.logicalKey != 'icon.arrow_left') {
        expect(icon.definition.mirrorInRtl, isFalse);
      }
    }
  });
  for (final inset in [0.0, 24.0, 55.0]) {
    testWidgets('Scaffold safe area exactly once: $inset', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.build(brightness: Brightness.dark),
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(top: inset)),
            child: Scaffold(
              appBar: AppBarScaffoldAdapter(
                content: content(
                  BackAppBar(back: action('Back'), help: action('Help')),
                ),
              ),
              body: const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(AppBarScaffoldAdapter)).height,
        64 + inset,
      );
      expect(tester.getSize(key('content')).height, 64);
      expect(tester.getTopLeft(key('content')).dy, inset);
      expect(find.byType(AppBar), findsNothing);
    });
  }
  testWidgets('action motion, focus and reduced motion stay local', (
    tester,
  ) async {
    int calls = 0;
    await mount(tester, home(callback: () => calls++));
    Finder transform(String role) => find.descendant(
      of: key('$role.hit'),
      matching: find.byKey(const ValueKey('app-button-press-transform')),
    );
    final before = tester.getRect(key('help.hit'));
    final gesture = await tester.startGesture(
      tester.getCenter(key('help.hit')),
    );
    await tester.pump(const Duration(milliseconds: 110));
    await tester.pump(const Duration(milliseconds: 40));
    expect(
      tester.widget<Transform>(transform('help')).transform.storage[0],
      lessThan(1),
    );
    expect(
      tester.widget<Transform>(transform('profile')).transform.storage[0],
      1,
    );
    expect(tester.getRect(key('help.hit')), before);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(calls, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    final buttons = tester.widgetList<TextButton>(find.byType(TextButton));
    final focused = buttons.firstWhere(
      (b) => b.statesController!.value.contains(WidgetState.focused),
    );
    expect(focused.style!.side!.resolve({WidgetState.focused})!.width, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(calls, 2);
    await mount(tester, home(callback: () => calls++), reduced: true);
    final reduced = await tester.startGesture(
      tester.getCenter(key('help.hit')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(tester.widget<Transform>(transform('help')).transform.storage[0], 1);
    await reduced.cancel();
    await tester.pumpAndSettle();
    expect(calls, 2);
  });
  testWidgets('diagnostic source matrix with real fonts; no golden baseline', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: RepaintBoundary(
          key: boundary,
          child: Column(
            children: [
              for (final s in AppBarSpec.all)
                Theme(
                  data: AppThemeFactory.build(brightness: s.brightness),
                  child: ColoredBox(
                    color: s.previewBackground!,
                    child: content(
                      s.category == AppBarCategory.home
                          ? home()
                          : s.category == AppBarCategory.downloadableGame
                          ? game()
                          : BackAppBar(
                              back: action('Back'),
                              help: action('Help'),
                            ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ImageByteFormat.png);
      final output = File('../../build/app-bar-validation/source-variants.png');
      output.parent.createSync(recursive: true);
      output.writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
    });
  });
}
