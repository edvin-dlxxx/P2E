import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_dev_inspector/inspector.dart';

Widget app(FrameSettings s, GlobalKey key, {bool loading = false}) =>
    MediaQuery(
      data: s.media,
      child: SizedBox.expand(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemeFactory.build(brightness: Brightness.dark),
          home: UiIdentityScope(
            routeName: 'probe',
            instanceKey: 'one',
            child: Center(
              child: AppButton(
                elementId: 'probe.button',
                label: 'Continue',
                loading: loading,
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
    );
void main() {
  test(
    'scriptable device presets, limits, orientation, keyboard and classes',
    () {
      final d = SimulatedDevice();
      for (final (w, c) in [
        (599.0, 'compact'),
        (600.0, 'medium'),
        (839.0, 'medium'),
        (840.0, 'expanded'),
      ]) {
        d.resize(w, 800);
        expect(d.settings.sizeClass, c);
      }
      for (final p in SimulatedDevice.presets) {
        d.preset(p);
        expect(d.settings.size, p);
      }
      d.apply(
        d.settings.copyWith(
          size: const Size(402, 874),
          insets: const EdgeInsets.fromLTRB(1, 2, 3, 4),
          keyboard: true,
          keyboardHeight: 300,
          scale: 3,
        ),
      );
      d.rotate();
      expect(d.settings.size, const Size(874, 402));
      expect(d.settings.insets, const EdgeInsets.fromLTRB(4, 1, 2, 3));
      expect(d.settings.media.viewInsets.bottom, 300);
      expect(d.settings.media.textScaler.scale(10), 30);
      expect(
        FrameSettings.fromJson(d.settings.toJson()).toJson(),
        d.settings.toJson(),
      );
      d.resize(1, 9999);
      expect(d.settings.size, const Size(200, 1400));
      d.dispose();
    },
  );
  testWidgets(
    'numeric dimensions, nudges, handles, zoom picking and Fit window',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(InspectorHost(appBuilder: app));
      await tester.pumpAndSettle();
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      Future<void> submit(String key, String value) async {
        await tester.enterText(find.byKey(ValueKey(key)), value);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      await submit('frame-width', '500');
      await submit('frame-height', '900');
      expect(tester.getSize(find.byKey(state.appKey)), const Size(500, 900));
      await tester.tap(find.byKey(const ValueKey('frame-width')));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
      expect(state.settings.size.width, 501);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.pumpAndSettle();
      expect(state.settings.size.width, 491);
      // At 100% drag distances equal logical distances; all three independent handles.
      state.device.actualSize = true;
      state.update(state.settings.copyWith(size: const Size(402, 600)));
      await tester.pumpAndSettle();
      for (final (id, delta) in [
        ('resize-width', const Offset(20, 0)),
        ('resize-height', const Offset(0, 20)),
        ('resize-both', const Offset(20, 20)),
      ]) {
        final before = state.settings.size;
        await tester.drag(find.byKey(ValueKey(id)), delta);
        await tester.pumpAndSettle();
        expect(
          state.settings.size,
          Size(before.width + delta.dx, before.height + delta.dy),
        );
      }
      state.device.actualSize = false;
      for (final z in [.5, .75]) {
        state.device.zoomOverride = z;
        state.update(state.settings.copyWith(size: const Size(402, 874)));
        await tester.pumpAndSettle();
        state.session.setSelecting(true);
        await tester.pump();
        state.session.scan();
        final node = state.session.tree.firstWhere(
          (n) => n.identity.elementId == 'probe.button',
        );
        final root =
            state.appKey.currentContext!.findRenderObject() as RenderBox;
        await tester.tapAt(root.localToGlobal(node.bounds.center));
        await tester.pump();
        expect(state.session.selected?.identity.elementId, 'probe.button');
        expect(tester.getSize(find.byKey(state.appKey)), const Size(402, 874));
      }
      state.device.zoomOverride = null;
      state.device.setMode(FrameMode.fitWindow);
      await tester.pumpAndSettle();
      final before = state.settings.size;
      tester.view.physicalSize = const Size(1800, 1500);
      await tester.pumpAndSettle();
      expect(state.settings.size.width, greaterThan(before.width));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Problems forwards errors and sweep finds exact width and height ranges',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var appCallbacks = 0;
      await tester.pumpWidget(
        InspectorHost(
          appBuilder: (s, key) {
            final identity = ElementIdentity(
              elementId: 'probe.overflow',
              componentId: 'probe.overflow',
              structureRef: 'probe.overflow',
              runtimeLocator: const UiRuntimeLocator(
                routeName: 'probe',
                routeInstanceId: 'one',
              ),
              fileKey: '',
              variantId: null,
              componentSetId: null,
              rawSetName: '',
              rawVariantName: '',
              resolved: const {},
              declared: const {},
              variants: const {},
              child: GestureDetector(
                onTap: () => appCallbacks++,
                child: LayoutBuilder(
                  builder: (context, c) => Column(
                    children: [
                      SizedBox(
                        height: 400,
                        child: Row(children: [const SizedBox(width: 300)]),
                      ),
                    ],
                  ),
                ),
              ),
            );
            return MediaQuery(
              data: s.media,
              child: SizedBox.expand(
                key: key,
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: identity,
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      final saved = state.settings;
      Future<void> frame() async {
        await tester.pump();
        while (tester.takeException() != null) {}
        await tester.pump();
        while (tester.takeException() != null) {}
      }

      await state.sweep.run(
        const SweepPlan(minWidth: 295, maxWidth: 305, widthStep: 1),
        frame,
      );
      expect(
        state.sweep.ranges.any(
          (r) => r['firstWidth'] == 295 && r['lastWidth'] == 299,
        ),
        isTrue,
      );
      expect(state.settings.toJson(), saved.toJson());
      state.update(state.settings.copyWith(size: const Size(500, 874)));
      final saved2 = state.settings;
      await state.sweep.run(
        const SweepPlan(
          axis: SweepAxis.height,
          minHeight: 395,
          maxHeight: 405,
          heightStep: 1,
        ),
        frame,
      );
      expect(
        state.sweep.ranges.any(
          (r) => r['firstHeight'] == 395 && r['lastHeight'] == 399,
        ),
        isTrue,
      );
      expect(state.settings.toJson(), saved2.toJson());
      expect(appCallbacks, 0);
      expect(state.problems.collectorFailures, 0);
      expect(
        state.sweep.ranges.every((r) => r['elementId'] == 'probe.overflow'),
        isTrue,
      );
      expect(
        state.problems.problems.every((p) => p.kind == 'overflow'),
        isTrue,
      );
    },
  );
  testWidgets(
    'one-time missing loading label diagnostic retains a recoverable owner',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        InspectorHost(appBuilder: (s, key) => app(s, key, loading: true)),
      );
      await tester.pump(const Duration(milliseconds: 20));
      final reported = tester.takeException();
      expect(reported.toString(), contains('loadingSemanticsLabel is missing'));
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      expect(state.problems.problems.single.kind, 'loading-label-missing');
      expect(state.problems.problems.single.elementId, 'probe.button');
      state.update(state.settings.copyWith(size: const Size(410, 874)));
      await tester.pump(const Duration(milliseconds: 20));
      expect(tester.takeException(), isNull);
      expect(
        state.problems.problems
            .where((p) => p.kind == 'loading-label-missing')
            .length,
        1,
      );
      expect(state.problems.collectorFailures, 0);
    },
  );
}
