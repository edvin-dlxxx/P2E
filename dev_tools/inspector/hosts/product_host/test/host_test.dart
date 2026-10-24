import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/app/bootstrap.dart';
import 'package:flutter/rendering.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:p2e_dev_inspector/inspector.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_product_host/main.dart';
import 'package:mygame_p2e/features/auth/auth_data.dart';
import 'package:mygame_p2e/features/auth/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('identifier privacy and Dev scenario preserve editing state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProductInspectionHost());
    await tester.pumpAndSettle();
    final field = tester.widget<AppTextField>(find.byType(AppTextField));
    field.options.focusNode!.requestFocus();
    await tester.pumpAndSettle();
    const raw = 'private.person123@example.com';
    await tester.enterText(
      find.descendant(
        of: find.byType(AppTextField),
        matching: find.byType(EditableText),
      ),
      raw,
    );
    await tester.pumpAndSettle();
    tester
        .widget<DropdownButton<FakeAuthScenario>>(
          find.byType(DropdownButton<FakeAuthScenario>),
        )
        .onChanged!(FakeAuthScenario.offline);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<AppTextField>(find.byType(AppTextField))
          .options
          .controller!
          .text,
      raw,
    );
    final host = tester.state<InspectorHostState>(find.byType(InspectorHost));
    final scope = ProviderScope.containerOf(
      tester.element(find.byType(AppTextField)),
    );
    expect(scope.read(fakeAuthScenarioProvider), FakeAuthScenario.offline);
    expect(scope.read(authEntryControllerProvider).raw, raw);
    expect(scope.read(authEntryControllerProvider).identifier, isA<Email>());
    host.update(
      host.settings.copyWith(
        size: const Size(360, 800),
        scale: 2,
        keyboard: true,
        disableAnimations: true,
      ),
    );
    await tester.pumpAndSettle();
    expect(scope.read(authEntryControllerProvider).raw, raw);
    expect(scope.read(authEntryControllerProvider).identifier, isA<Email>());
    host.session.scan();
    final node = host.session.tree.firstWhere(
      (n) => n.identity.elementId == 'auth.entry.identifier',
    );
    final json = exportSnapshot(node.capture());
    expect(json, contains('••••'));
    expect(json, isNot(contains(raw)));
    expect(json.toLowerCase(), isNot(contains('hascontent')));
    expect(json.toLowerCase(), isNot(contains('inputvalue')));
    expect(node.identity.declared['privacy'], 'identifier');
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'real product frame and environment stay stable when panel changes',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const ProductInspectionHost());
      await tester.pumpAndSettle();
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      expect(tester.getSize(find.byKey(state.appKey)), const Size(402, 874));
      final texts = find.descendant(
        of: find.byKey(state.appKey),
        matching: find.byType(Text),
      );
      final context = tester.element(texts.first);
      expect(MediaQuery.sizeOf(context), const Size(402, 874));
      expect(
        MediaQuery.paddingOf(tester.element(find.byType(PageScaffold))),
        const EdgeInsets.fromLTRB(0, 24, 0, 24),
      );
      final textSize = tester.getSize(texts.first);
      final plainLabel = tester.widget<Text>(texts.first).data;
      await tester.tap(find.byKey(const ValueKey('toggle-panel')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(state.appKey)), const Size(402, 874));
      expect(tester.getSize(texts.first), textSize);
      state.update(
        state.settings.copyWith(
          size: const Size(360, 800),
          locale: const Locale('en'),
          scale: 2,
          brightness: Brightness.light,
          testSkin: true,
          insets: const EdgeInsets.fromLTRB(5, 10, 7, 20),
        ),
      );
      await tester.pumpAndSettle();
      final next = tester.element(texts.first);
      expect(MediaQuery.sizeOf(next), const Size(360, 800));
      expect(MediaQuery.textScalerOf(next).scale(10), 20);
      expect(
        MediaQuery.paddingOf(tester.element(find.byType(PageScaffold))),
        const EdgeInsets.fromLTRB(5, 10, 7, 20),
      );
      expect(Theme.of(next).brightness, Brightness.light);
      expect(Directionality.of(next), TextDirection.rtl);
      expect(tester.widget<Text>(texts.first).data, plainLabel);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Select off real product geometry and semantics equal plain same-frame app',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1300);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(const ProductInspectionHost());
      await tester.pumpAndSettle();
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      final text = find
          .descendant(of: find.byKey(state.appKey), matching: find.byType(Text))
          .first;
      final size = tester.getSize(text);
      final value = tester.widget<Text>(text).data;
      final appSemantics = tester.getSemantics(text).getSemanticsData();
      final settings = state.settings;
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.pumpWidget(
        Center(
          child: SizedBox(
            width: 402,
            height: 874,
            child: composeApp(
              config: const AppConfig(environment: AppEnvironment.dev),
              rootWrapper: (root) =>
                  MediaQuery(data: settings.media, child: root),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final plain = find.text(value!);
      expect(tester.getSize(plain), size);
      final plainSemantics = tester.getSemantics(plain).getSemanticsData();
      expect(plainSemantics.label, appSemantics.label);
      expect(plainSemantics.flagsCollection, appSemantics.flagsCollection);
      semantics.dispose();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'OS inputs preserve fa policy and reach app without app locale overrides',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final device = SimulatedDevice();
      addTearDown(device.dispose);
      await tester.pumpWidget(ProductInspectionHost(device: device));
      await tester.pumpAndSettle();
      for (final locale in [
        const Locale('en', 'US'),
        const Locale('de', 'DE'),
      ]) {
        device.apply(
          device.settings.copyWith(
            locales: [locale],
            scale: 3,
            brightness: Brightness.light,
            keyboard: true,
            keyboardHeight: 300,
            disableAnimations: true,
            boldText: true,
            highContrast: true,
            platform: TargetPlatform.iOS,
          ),
        );
        await tester.pumpAndSettle();
        final c = tester.element(find.byType(PageScaffold));
        expect(Localizations.localeOf(c).languageCode, 'fa');
        expect(Directionality.of(c), TextDirection.rtl);
        expect(MediaQuery.textScalerOf(c).scale(16), 32);
        expect(MediaQuery.viewInsetsOf(c).bottom, 300);
        expect(MediaQuery.disableAnimationsOf(c), isTrue);
        expect(MediaQuery.boldTextOf(c), isTrue);
        expect(MediaQuery.highContrastOf(c), isTrue);
        expect(Theme.of(c).platform, TargetPlatform.iOS);
        expect(Theme.of(c).brightness, Brightness.light);
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('app-result'))).data,
          contains('effective in app: 2.0'),
        );
      }
      expect(
        tester
            .widgetList<MaterialApp>(find.byType(MaterialApp))
            .every((a) => !a.debugShowCheckedModeBanner),
        isTrue,
      );
      // Fixture chrome clamps itself independently from the device/content scale.
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await tester.pumpWidget(
        ProductInspectionHost(device: device, fixtures: true),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      state.session.scan();
      final bar = state.session.tree.firstWhere(
        (n) => n.identity.elementId == 'fixtures.bar',
      );
      final paragraphs = find.descendant(
        of: find.byWidget(bar.element.widget),
        matching: find.byType(RichText),
      );
      for (final e in paragraphs.evaluate()) {
        expect(
          (e.findRenderObject() as RenderParagraph).textScaler.scale(16),
          20.8,
        );
      }
      // Every isolated OS input and all combinations through the public API.
      for (var mask = 0; mask < 16; mask++) {
        device.apply(
          device.settings.copyWith(
            scale: mask & 1 != 0 ? 3 : 1,
            keyboard: mask & 2 != 0,
            boldText: mask & 4 != 0,
            disableAnimations: mask & 8 != 0,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'OS input mask $mask');
        for (final keyboard in [true, false]) {
          device.apply(device.settings.copyWith(keyboard: keyboard));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      }
      device.resize(251, 874);
      await tester.pumpAndSettle();
      Object? diagnostic;
      while ((diagnostic = tester.takeException()) != null) {
        expect(
          diagnostic.toString(),
          contains('Navigator Bar host contract violation'),
        );
      }
      expect(
        state.problems.problems.any((p) => p.kind == 'navigator-below-minimum'),
        isTrue,
      );
    },
  );
}
