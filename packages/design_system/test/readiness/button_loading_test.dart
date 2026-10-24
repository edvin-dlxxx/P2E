import 'package:flutter/material.dart';

import 'dart:ui' show Tristate, SemanticsAction;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

Future<void> mount(
  WidgetTester tester,
  Widget button,
  Brightness brightness,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemeFactory.build(brightness: brightness),
      home: UiIdentityScope(
        routeName: 'loading-test',
        instanceKey: 'stable',
        child: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                width: 360,
                child: Align(
                  alignment: AlignmentDirectional.topStart,
                  child: button,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('all90 variants keep visual and hit dimensions while loading', (
    tester,
  ) async {
    for (final spec in ButtonSpec.all) {
      AppButton button(bool loading) => AppButton(
        elementId: 'test.button',
        family: spec.family,
        size: spec.size,
        type: spec.type,
        label: 'Continue',
        loading: loading,
        loadingSemanticsLabel: 'Loading',
        onPressed: () {},
        iconMode: spec.family == AppButtonFamily.icon
            ? ButtonIconMode.fill
            : ButtonIconMode.none,
        icon: spec.family == AppButtonFamily.icon
            ? const AssetAppIcon(AppIconId.editSquare)
            : null,
      );
      await mount(tester, button(false), spec.brightness);
      final visual = tester.getRect(find.byType(TextButton));
      final hit = tester.getRect(find.byType(AppButton));
      final normalIdentity = tester
          .widget<ElementIdentity>(find.byType(ElementIdentity))
          .effectiveKey;
      await mount(tester, button(true), spec.brightness);
      expect(tester.getRect(find.byType(TextButton)), visual, reason: spec.id);
      expect(tester.getRect(find.byType(AppButton)), hit, reason: spec.id);
      final identity = tester.widget<ElementIdentity>(
        find.byType(ElementIdentity),
      );
      expect(identity.effectiveKey, normalIdentity);
      expect(identity.declared['loading'], isTrue);
      expect(identity.descriptor()['state'], containsPair('enabled', false));
      final progress = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progress.value, isNotNull, reason: 'Reduced motion must not tick');
      expect(tester.takeException(), isNull);
    }
  });
  testWidgets(
    'loading blocks pointer/keyboard/semantic activation and retains focus',
    (tester) async {
      var calls = 0;
      final states = WidgetStatesController();
      addTearDown(states.dispose);
      AppButton button(bool loading) => AppButton(
        elementId: 'test.button',
        label: 'Continue',
        loading: loading,
        loadingSemanticsLabel: 'Loading',
        statesController: states,
        onPressed: () => calls++,
      );
      final semantics = tester.ensureSemantics();
      await mount(tester, button(false), Brightness.dark);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      final focus = tester
          .widget<TextButton>(find.byType(TextButton))
          .focusNode!;
      expect(focus.hasFocus, isTrue);
      await mount(tester, button(true), Brightness.dark);
      expect(focus.hasFocus, isTrue);
      final node = tester.getSemantics(find.byType(AppButton));
      expect(node.getSemanticsData().label, 'Continue, Loading');
      expect(
        node.getSemanticsData().flagsCollection.isEnabled,
        Tristate.isFalse,
      );
      expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(
        node.getSemanticsData().flagsCollection.isFocused,
        Tristate.isTrue,
      );
      await tester.tap(find.byType(AppButton));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(calls, 0);
      states.update(WidgetState.pressed, true);
      states.update(WidgetState.hovered, true);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Transform>(
              find.byKey(const ValueKey('app-button-press-transform')),
            )
            .transform
            .getMaxScaleOnAxis(),
        1,
      );
      await mount(tester, button(false), Brightness.dark);
      expect(focus.hasFocus, isTrue);
      states.update(WidgetState.pressed, false);
      await tester.tap(find.byType(AppButton));
      expect(calls, 1);
      semantics.dispose();
    },
  );
  testWidgets('semantic focus survives loading ending in disabled state', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    AppButton button(bool loading) => AppButton(
      elementId: 'test.button',
      label: 'Continue',
      onPressed: null,
      loading: loading,
      loadingSemanticsLabel: 'Loading',
    );
    await mount(tester, button(true), Brightness.light);
    final node = tester.getSemantics(find.byType(AppButton));
    node.owner!.performAction(
      node.id,
      SemanticsAction.didGainAccessibilityFocus,
    );
    await tester.pumpAndSettle();
    final focus = tester.widget<TextButton>(find.byType(TextButton)).focusNode!;
    expect(focus.hasFocus, isTrue);
    await mount(tester, button(false), Brightness.light);
    expect(focus.hasFocus, isTrue);
    final data = tester.getSemantics(find.byType(AppButton)).getSemanticsData();
    expect(data.label, 'Continue');
    expect(data.flagsCollection.isEnabled, Tristate.isFalse);
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    focus.unfocus();
    await tester.pumpAndSettle();
    semantics.dispose();
    expect(tester.takeException(), isNull);
  });
  testWidgets('missing label reports once per instance and keeps rendering', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final errors = <FlutterErrorDetails>[];
    final original = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      for (var i = 0; i < 3; i++) {
        await mount(
          tester,
          const AppButton(
            elementId: 'test.button',
            label: 'Continue',
            onPressed: null,
            loading: true,
          ),
          Brightness.light,
        );
      }
      expect(errors, hasLength(1));
      expect(
        errors.single.exceptionAsString(),
        contains('loadingSemanticsLabel'),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final node = tester.getSemantics(find.byType(AppButton));
      expect(node.getSemanticsData().label, 'Continue');
    } finally {
      FlutterError.onError = original;
      semantics.dispose();
    }
  });
}
