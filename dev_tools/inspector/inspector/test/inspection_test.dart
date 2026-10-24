import 'dart:convert';
import 'dart:io';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/inspection.dart';
import 'package:p2e_dev_inspector/inspector.dart';

Widget sample(
  GlobalKey key,
  Widget child, {
  double scale = 1,
  SkinDefinition? skin,
}) => MaterialApp(
  theme: AppThemeFactory.build(
    brightness: Brightness.dark,
    skin: skin ?? productSkin,
  ),
  home: MediaQuery(
    data: MediaQueryData(
      textScaler: TextScaler.linear(scale),
      disableAnimations: true,
    ),
    child: SizedBox.expand(
      key: key,
      child: UiIdentityScope(
        routeName: 'probe',
        instanceKey: 'one',
        child: Scaffold(body: child),
      ),
    ),
  ),
);

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final manifest =
        jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
    for (final row in manifest) {
      final family = row['family'] as String;
      if (!family.endsWith('Outfit') && !family.endsWith('Vazirmatn')) {
        continue;
      }
      final loader = FontLoader(
        family.startsWith('packages/')
            ? family
            : 'packages/p2e_design_system/$family',
      );
      for (final face in row['fonts'] as List) {
        loader.addFont(rootBundle.load(face['asset'] as String));
      }
      await loader.load();
    }
  });

  test('comparison uses tolerance and explicit non-comparability', () {
    Map<String, Object?> metric(Object? measured, {String? reason}) =>
        compareMetric(
          source: 12,
          resolved: 12,
          measured: measured,
          reason: reason,
        );
    expect(metric(12.4)['status'], 'match');
    expect(metric(14)['status'], 'differs');
    expect(metric(null)['status'], 'unavailable');
    for (final reason in [
      'text differs',
      'width differs',
      'scale ≠1.0',
      'skin ≠product',
    ]) {
      expect(metric(12, reason: reason)['status'], 'not comparable');
      expect(metric(12, reason: reason)['reason'], reason);
    }
    expect(
      compareMetric(
        source: null,
        resolved: 10,
        measured: null,
        engineering: true,
      )['status'],
      'engineering-defined',
    );
  });

  testWidgets(
    'rendered padding deviation is detected without altering source',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        sample(
          key,
          Center(
            child: AppBadge(elementId: 'probe.badge', label: 'Badge'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final session = InspectionSession(key);
      addTearDown(session.dispose);
      session.scan();
      final node = session.tree.single;
      Map comparison() =>
          (node.capture()['resolved'] as Map)['inspectionComparison']['value']
              as Map;
      expect(comparison()['padding']['status'], 'match');
      RenderPadding? padding;
      void read(Element e) {
        if (e is RenderObjectElement && e.renderObject is RenderPadding) {
          padding ??= e.renderObject as RenderPadding;
        }
        e.visitChildren(read);
      }

      read(node.element);
      expect(padding, isNotNull);
      padding!.padding = const EdgeInsetsDirectional.all(35);
      await tester.pump();
      expect(comparison()['padding']['status'], 'differs');
    },
  );

  testWidgets('disabled and loading controls remain geometrically selectable', (
    tester,
  ) async {
    var calls = 0;
    final key = GlobalKey();
    await tester.pumpWidget(
      sample(
        key,
        Column(
          children: [
            AppButton(
              elementId: 'probe.disabled',
              label: 'Disabled',
              type: AppButtonType.disabled,
              onPressed: null,
            ),
            AppButton(
              elementId: 'probe.busy',
              label: 'Busy',
              onPressed: () => calls++,
              loading: true,
              loadingSemanticsLabel: 'Loading',
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final session = InspectionSession(key);
    addTearDown(session.dispose);
    session.scan();
    final nodes = List.of(session.tree);
    for (final n in nodes) {
      session.pick(n.clipBounds.center);
      expect(session.selected!.key, n.key);
    }
    expect(calls, 0);
  });

  testWidgets(
    'transformed and clipped identities cannot be picked outside paint clip',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        sample(
          key,
          Align(
            alignment: AlignmentDirectional.topStart,
            child: SizedBox(
              width: 60,
              height: 60,
              child: ClipRect(
                child: OverflowBox(
                  maxWidth: 200,
                  alignment: AlignmentDirectional.topStart,
                  child: Transform.translate(
                    offset: const Offset(20, 0),
                    child: AppButton(
                      elementId: 'probe.clipped',
                      label: 'Clipped',
                      onPressed: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final session = InspectionSession(key);
      addTearDown(session.dispose);
      session.scan();
      final node = session.tree.single;
      expect(node.bounds.right, greaterThan(node.clipBounds.right));
      session.pick(node.clipBounds.center);
      expect(session.selected!.key, node.key);
      session.pick(
        Offset(node.clipBounds.right + 5, node.clipBounds.center.dy),
      );
      expect(session.candidates, isEmpty);
    },
  );

  testWidgets('all component families export safe descriptor/registry data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(402, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(sample(key, const InspectionFixtures()));
    await tester.pumpAndSettle();
    final session = InspectionSession(key);
    addTearDown(session.dispose);
    session.scan();
    final families = session.tree.map((n) => n.identity.componentId).toSet();
    for (final id in [
      'button.base',
      'badge.base',
      'text-field.general',
      'text-field.password',
      'text-field.otp-group',
      'text-field.otp',
      'radio.base',
      'app-bar.container',
      'layout.page-scaffold',
    ]) {
      expect(families, contains(id));
    }
    expect(families.any((v) => v.startsWith('navigation.')), isTrue);
    final snapshots = <Map<String, Object?>>[];
    for (final node in session.tree) {
      final s = node.capture();
      snapshots.add(s);
      expect((s['identity'] as Map)['elementId'], node.identity.elementId);
      expect(
        (s['identity'] as Map)['runtimeLocator'],
        node.identity.runtimeLocator!.toJson(),
      );
      expect(jsonEncode(s), isNot(contains('inputValue')));
      final source = sourceFor(node.identity);
      if (source != null) {
        expect(
          (s['resolved'] as Map)['inspectionSource']['value'],
          safeData(source.data),
        );
      }
    }
    final out = File('../../../build/inspector-v1.1/snapshots.json');
    out.parent.createSync(recursive: true);
    out.writeAsStringSync(jsonEncode(snapshots));
    // Artwork intentionally has no independent identity (D-023); its owner is pickable.
    final icon = find.byWidgetPredicate((w) => w is AssetAppIcon).last;
    session.pick(tester.getCenter(icon));
    expect(session.selected, isNotNull);
    expect(session.rawType, isNotNull);
    expect(session.notice, contains('Nearest identity owner'));
  });

  testWidgets('Password and OTP typed values and lengths never leave core', (
    tester,
  ) async {
    final password = TextEditingController(text: 'PRIVATE_password_123456789');
    final otp = TextEditingController(text: '874291');
    addTearDown(password.dispose);
    addTearDown(otp.dispose);
    final key = GlobalKey();
    await tester.pumpWidget(
      sample(
        key,
        Column(
          children: [
            AppPasswordField(
              elementId: 'probe.password',
              label: 'Password',
              showPasswordLabel: 'Show',
              hidePasswordLabel: 'Hide',
              options: FieldInputOptions(controller: password),
            ),
            AppOtpField(elementId: 'probe.otp', label: 'Code', controller: otp),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    final session = InspectionSession(key);
    addTearDown(session.dispose);
    session.scan();
    for (final n in session.tree) {
      final exported = exportSnapshot(n.capture());
      for (final secret in [
        'PRIVATE_password_123456789',
        '874291',
        'codeLength',
        'hasContent',
        'complete',
        'inputValue',
      ]) {
        expect(exported, isNot(contains(secret)));
      }
    }
  });

  testWidgets(
    'deepest slots, overlapping owners, offstage and clipped geometry',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        sample(
          key,
          Column(
            children: [
              AppPasswordField(
                elementId: 'probe.password',
                label: 'Password',
                options: FieldInputOptions(
                  controller: TextEditingController(text: 'synthetic'),
                ),
                showPasswordLabel: 'Show',
                hidePasswordLabel: 'Hide',
              ),
              const AppOtpField(elementId: 'probe.otp', label: 'Code'),
              FadeTransition(
                opacity: const AlwaysStoppedAnimation(0),
                child: AppButton(
                  elementId: 'probe.transparent',
                  label: 'Invisible',
                  onPressed: () {},
                ),
              ),
              Offstage(
                child: AppButton(
                  elementId: 'probe.hidden',
                  label: 'Hidden',
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      final session = InspectionSession(key);
      addTearDown(session.dispose);
      session.scan();
      final slot = session.tree.firstWhere(
        (n) => n.identity.runtimeLocator?.slotPath == 'visibilityAction',
      );
      session.pick(slot.clipBounds.center);
      expect(session.selected!.key, slot.key);
      expect(session.candidates.length, greaterThan(1));
      expect(slot.owner!.identity.elementId, 'probe.password');
      final cell = session.tree.firstWhere(
        (n) => n.identity.runtimeLocator?.slotPath == 'cells.cell1',
      );
      session.pick(cell.clipBounds.center);
      expect(session.selected!.key, cell.key);
      expect(
        session.tree
            .firstWhere((n) => n.identity.elementId == 'probe.hidden')
            .visible,
        isFalse,
      );
      expect(
        session.tree
            .firstWhere((n) => n.identity.elementId == 'probe.transparent')
            .visible,
        isFalse,
      );
      expect(
        session.candidates.any((n) => n.identity.elementId == 'probe.hidden'),
        isFalse,
      );
    },
  );

  testWidgets(
    'selection overlay blocks callbacks, hover, press and focus; Esc exits',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var calls = 0;
      await tester.pumpWidget(
        InspectorHost(
          appBuilder: (settings, key) => sample(
            key,
            AppButton(
              key: const ValueKey('sample'),
              elementId: 'probe.button',
              label: 'Go',
              onPressed: () => calls++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final host = tester.state<InspectorHostState>(find.byType(InspectorHost));
      await tester.tap(find.byKey(const ValueKey('sample')));
      await tester.pumpAndSettle();
      expect(calls, 1);
      host.session.setSelecting(true);
      await tester.pumpAndSettle();
      final focus = FocusManager.instance.primaryFocus;
      final controller = tester
          .widget<TextButton>(
            find.descendant(
              of: find.byKey(const ValueKey('sample')),
              matching: find.byType(TextButton),
            ),
          )
          .statesController!;
      final previousStates = Set<WidgetState>.of(controller.value);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(
        tester.getCenter(find.byKey(const ValueKey('sample'))),
      );
      await tester.pumpAndSettle();
      expect(controller.value, previousStates);
      await mouse.down(tester.getCenter(find.byKey(const ValueKey('sample'))));
      await tester.pump();
      expect(controller.value, previousStates);
      await mouse.up();
      await mouse.removePointer();

      await tester.tap(
        find.byKey(const ValueKey('sample')),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(FocusManager.instance.primaryFocus, focus);
      expect(host.session.selected!.identity.elementId, 'probe.button');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(host.session.selecting, isFalse);
      await tester.tap(find.byKey(const ValueKey('sample')));
      await tester.pumpAndSettle();
      expect(calls, 2);
    },
  );

  testWidgets(
    'live loading/dispose/remount uses effective key, idle frames never scan',
    (tester) async {
      final key = GlobalKey();
      final state = ValueNotifier(0);
      addTearDown(state.dispose);
      await tester.pumpWidget(
        sample(
          key,
          ValueListenableBuilder<int>(
            valueListenable: state,
            builder: (context, value, _) => value == 2
                ? const SizedBox()
                : UiIdentityScope(
                    key: ValueKey(value == 4 ? 'other' : 'same'),
                    routeName: 'route',
                    instanceKey: value == 4 ? 'two' : 'one',
                    child: AppButton(
                      elementId: 'probe.live',
                      label: 'Go',
                      onPressed: () {},
                      loading: value == 1,
                      loadingSemanticsLabel: 'Loading',
                    ),
                  ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final session = InspectionSession(key);
      addTearDown(session.dispose);
      session.watchBuilds();
      session.scan();
      session.choose(session.tree.single);
      state.value = 1;
      await tester.pumpAndSettle();
      expect(
        (session.snapshot!['declared'] as Map)['loading']['value'],
        isTrue,
        reason:
            'signals=${session.buildSignals}, refreshes=${session.refreshes}, scans=${session.traversals} actualWidget=${(session.tree.single.element.widget as ElementIdentity).declared["loading"]}',
      );
      final stale = session.selected!;
      state.value = 2;
      await tester.pumpAndSettle();
      expect(session.disposedSelection, isTrue);
      session.choose(stale);
      expect(session.disposedSelection, isTrue);
      state.value = 3;
      await tester.pumpAndSettle();
      expect(session.disposedSelection, isFalse);
      state.value = 4;
      await tester.pumpAndSettle();
      expect(session.disposedSelection, isTrue);
      final count = session.traversals;
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(session.traversals, count);
    },
  );

  testWidgets('scale and skin comparison gates are explicit', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      sample(
        key,
        AppBadge(elementId: 'probe.badge', label: 'Badge'),
        scale: 2,
        skin: testSkin,
      ),
    );
    await tester.pumpAndSettle();
    final session = InspectionSession(key);
    addTearDown(session.dispose);
    session.scan();
    final snapshot = session.tree.single.capture(requestedScale: 2);
    final data =
        (snapshot['resolved'] as Map)['inspectionComparison']['value'] as Map;
    expect(data['padding']['status'], 'not comparable');
    expect(data['padding']['reason'], contains('scale ≠1.0'));
    expect(data['padding']['reason'], contains('skin ≠product'));
    await tester.pumpWidget(sample(key, const InspectionFixtures(), scale: 2));
    await tester.pumpAndSettle();
    session.scan();
    for (final component in ['app-bar.container', 'navigation.bar']) {
      final node = session.tree.firstWhere(
        (n) => n.identity.componentId == component,
      );
      final configuration =
          (node.capture()['resolved']
                  as Map)['inspectionConfiguration']['value']
              as Map;
      expect(configuration['requestedScale'], 2, reason: component);
      expect(configuration['effectiveScale'], 1.3, reason: component);
    }
  });
  testWidgets(
    'Light Password exposes only its Dark basis and never claims a dedicated source',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.build(brightness: Brightness.light),
          home: UiIdentityScope(
            routeName: 'light-probe',
            child: Scaffold(
              body: SizedBox(
                key: key,
                child: const AppPasswordField(
                  elementId: 'probe.password',
                  label: 'Password',
                  showPasswordLabel: 'Show',
                  hidePasswordLabel: 'Hide',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final session = InspectionSession(key);
      addTearDown(session.dispose);
      session.scan();
      final node = session.tree.firstWhere(
        (n) => n.identity.runtimeLocator?.slotPath == null,
      );
      expect(sourceFor(node.identity)!.basisOnly, isTrue);
      final snapshot = node.capture();
      expect(snapshot['identity'] as Map, isNot(contains('designRef')));
      final resolved = snapshot['resolved'] as Map;
      expect(
        resolved['inspectionConfiguration']['value']['provenance'],
        contains('derived'),
      );
      expect(
        resolved['inspectionComparison']['value']['height']['status'],
        'not comparable',
      );
      expect(
        resolved['inspectionComparison']['value']['height']['reason'],
        contains('basis source only'),
      );
      final file = File('../../../build/inspector-v1.1/snapshots.json');
      final snapshots = jsonDecode(file.readAsStringSync()) as List;
      snapshots.add(snapshot);
      file.writeAsStringSync(jsonEncode(snapshots));
    },
  );
}
