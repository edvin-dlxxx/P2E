import 'dart:convert';
import 'dart:io';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

const locator = UiRuntimeLocator(
  routeName: 'test-fields',
  routeInstanceId: 'test',
);
const labels = FieldRequirementLabels(
  required: '(Required)',
  optional: '(Optional)',
);
Future<void> mount(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.dark,
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
  bool reduced = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemeFactory.build(brightness: brightness),
      home: MediaQuery(
        data: MediaQueryData(
          textScaler: TextScaler.linear(scale),
          disableAnimations: reduced,
        ),
        child: Directionality(
          textDirection: direction,
          child: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(width: 370, child: child),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  test('derived Light follows paired TextField anatomy and preserves source identity', () {
    for (final state in [
      FieldVisualState.defaultState,
      FieldVisualState.focused,
      FieldVisualState.written,
      FieldVisualState.success,
      FieldVisualState.error,
    ]) {
      final text = FieldSpec.lookup(
        FieldFamily.textField,
        state,
        Brightness.light,
      );
      for (final visible in [true, false]) {
        final password = FieldSpec.lookup(
          FieldFamily.password,
          state,
          Brightness.light,
          passwordVisible: visible,
        );
        expect(password.derived, isTrue);
        expect(password.sourceId, isNull);
        for (final role in [
          'body',
          'label',
          'indicator',
          'input',
          'support',
          'supportText',
        ]) {
          if (password.part(role) != null && text.part(role) != null) {
            expect(
              password.color(role),
              text.color(role),
              reason: '$state/$role',
            );
          }
        }
        expect(
          password.color('body', stroke: true),
          text.color('body', stroke: true),
        );
      }
    }
    final text = FieldSpec.lookup(
      FieldFamily.textField,
      FieldVisualState.written,
      Brightness.light,
    );
    final otp = FieldSpec.lookup(
      FieldFamily.otp,
      FieldVisualState.written,
      Brightness.light,
    );
    expect(otp.color('body'), text.color('body'));
    expect(otp.textStyle('otpText').color, text.textStyle('input').color);
    final success = FieldSpec.lookup(
      FieldFamily.otp,
      FieldVisualState.success,
      Brightness.light,
    );
    expect(
      success.iconPaint(success.icons.single),
      text.textStyle('input').color,
    );
    final radio = FieldSpec.lookup(
      FieldFamily.radio,
      FieldVisualState.selected,
      Brightness.light,
    );
    expect(radio.derived, isFalse);
    expect(radio.sourceId, isNotNull);
    expect(
      identical(
        text,
        FieldSpec.lookup(
          FieldFamily.textField,
          FieldVisualState.written,
          Brightness.light,
        ),
      ),
      isTrue,
    );
  });

  testWidgets(
    'reduced motion, interrupted transitions and runtime extensions',
    (tester) async {
      final c = TextEditingController();
      final focus = FocusNode();
      FieldRuntimeSnapshot? info;
      Widget field({
        bool enabled = true,
        bool readOnly = false,
        String? helper,
      }) => AppTextField(
        elementId: 'test.motion',
        runtimeLocator: locator,
        label: 'Input',
        options: FieldInputOptions(
          controller: c,
          focusNode: focus,
          enabled: enabled,
          readOnly: readOnly,
          supportingText: helper,
          onSnapshot: (s) => info = s,
        ),
      );
      await mount(tester, field(), reduced: true);
      expect(info!.motionReduced, isTrue);
      expect(
        tester
            .widgetList<AnimatedSize>(find.byType(AnimatedSize))
            .every((w) => w.duration == Duration.zero),
        isTrue,
      );
      await mount(tester, field(enabled: false));
      expect(info!.sourceCovered, isFalse);
      expect(info!.toJson()['variantId'], isNull);
      expect(
        tester
            .widget<TextField>(find.byType(TextField, skipOffstage: false))
            .enabled,
        isFalse,
      );
      await mount(tester, field(readOnly: true));
      expect(
        tester
            .widget<TextField>(find.byType(TextField, skipOffstage: false))
            .readOnly,
        isTrue,
      );
      expect(info!.toJson()['setId'], isNull);
      await mount(tester, field(helper: 'Helper'));
      focus.requestFocus();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 40));
      focus.unfocus();
      await tester.pump();
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(info!.state, FieldVisualState.focused);
      expect(c.text, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      focus.dispose();
    },
  );
  testWidgets(
    'every source and derived paint resolves and source geometry stays exact',
    (tester) async {
      for (final spec in FieldSpec.all) {
        Widget child;
        if (spec.family == FieldFamily.otp) {
          child = Align(
            alignment: AlignmentDirectional.topStart,
            child: AppOtpCell(
              spec: spec,
              value: 'P',
              visualKey: const ValueKey('visual'),
            ),
          );
        } else if (spec.family == FieldFamily.radio) {
          child = AppRadioPresentation(
            spec: spec,
            label: 'Label',
            visualKey: const ValueKey('visual'),
          );
        } else {
          child = AppFieldSurface(
            spec: spec,
            label: 'Label',
            input: const Text('Input'),
            visualKey: const ValueKey('visual'),
            supportingText: 'Helper',
            feedback: (spec.data['state'] as String).startsWith('Error')
                ? FieldFeedback.error('Error')
                : const FieldFeedback.neutral(),
          );
        }
        await mount(tester, child, brightness: spec.brightness);
        final actual = tester.getSize(find.byKey(const ValueKey('visual')));
        if (spec.family == FieldFamily.otp) {
          expect(actual, spec.sourceSize);
        } else if (spec.family != FieldFamily.radio) {
          expect(actual.width, 370);
          expect(actual.height, spec.number('body', 'height'));
        }
        expect(() => jsonEncode(spec.visualMetadata), returnsNormally);
        if (spec.family == FieldFamily.password ||
            spec.family == FieldFamily.otp) {
          final derived = FieldSpec(spec.data, Brightness.light, derived: true);
          expect(derived.sourceId, isNull);
          expect(() => jsonEncode(derived.visualMetadata), returnsNormally);
        }
      }
    },
  );
  test('source coverage and application-owned state/feedback contracts', () {
    final source = jsonDecode(
      File(
        '../../docs/snapshots/2026-10-20_development-text-fields/evidence/page-inventory.json',
      ).readAsStringSync(),
    ) as Map;
    expect(
      FieldSpec.all.length,
      (source['sets'] as List).fold<int>(
        0,
        (n, s) => n + (s['variants'] as List).length,
      ),
    );
    expect(
      FieldSpec.all.map((s) => s.sourceId).toSet().length,
      FieldSpec.all.length,
    );
    expect(() => FieldFeedback.error('  '), throwsArgumentError);
    expect(
      FieldFeedback.error('Caller error').supporting('helper', show: false),
      'Caller error',
    );
    expect(
      FieldStateMapper.input(focused: false, hasContent: true),
      FieldVisualState.written,
    );
    expect(
      FieldStateMapper.input(focused: true, hasContent: true),
      FieldVisualState.focused,
    );
    expect(
      FieldStateMapper.input(
        focused: true,
        hasContent: true,
        validation: FieldValidation.success,
      ),
      FieldVisualState.success,
    );
    expect(
      FieldStateMapper.input(
        focused: true,
        hasContent: false,
        validation: FieldValidation.error,
      ),
      FieldVisualState.error,
    );
    expect(
      FieldStateMapper.otp(
        active: true,
        populated: false,
        validation: FieldValidation.neutral,
      ),
      FieldVisualState.focused,
    );
    expect(
      FieldStateMapper.otp(
        active: true,
        populated: true,
        validation: FieldValidation.neutral,
      ),
      FieldVisualState.edit,
    );
    for (final family in FieldFamily.values) {
      final states = FieldSpec.all.where(
        (s) => s.family == family && s.brightness == Brightness.dark,
      );
      for (final s in states) {
        final light = FieldSpec.lookup(
          family,
          FieldSpec.names.entries
              .singleWhere(
                (e) =>
                    e.value ==
                    (s.data['state'] as String).split(' - Visibility')[0],
              )
              .key,
          Brightness.light,
          passwordVisible: (s.data['state'] as String).endsWith(' On'),
        );
        expect(
          light.derived,
          family == FieldFamily.password || family == FieldFamily.otp,
        );
        if (light.derived) {
          expect(light.sourceId, isNull);
          expect(light.setId, isNull);
        }
        light.visualMetadata;
      }
    }
  });
  testWidgets(
    'real editing retains controller, selection, focus and metadata privacy across theme rebuilds',
    (tester) async {
      final controller = TextEditingController(), focus = FocusNode();
      FieldRuntimeSnapshot? info;
      Widget field() => AppTextField(
        elementId: 'test.text',
        runtimeLocator: locator,
        label: 'Field',
        options: FieldInputOptions(
          controller: controller,
          focusNode: focus,
          onSnapshot: (v) => info = v,
        ),
      );
      await mount(tester, field());
      expect(tester.getSize(find.byType(AppTextField)).height, 60);
      await tester.tap(find.byType(AppTextField));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Synthetic entered text');
      await tester.pumpAndSettle();
      controller.selection = const TextSelection(
        baseOffset: 2,
        extentOffset: 8,
      );
      await tester.pump();
      final editable = tester.state(find.byType(EditableText));
      await mount(
        tester,
        field(),
        brightness: Brightness.light,
        direction: TextDirection.rtl,
      );
      expect(
        identical(editable, tester.state(find.byType(EditableText))),
        isTrue,
      );
      expect(
        controller.selection,
        const TextSelection(baseOffset: 2, extentOffset: 8),
      );
      expect(focus.hasFocus, isTrue);
      expect(info!.state, FieldVisualState.focused);
      expect(jsonEncode(info!.toJson()), isNot(contains(controller.text)));
      await tester.pumpWidget(const SizedBox());
      controller.text = 'Still externally owned';
      focus.requestFocus();
      controller.dispose();
      focus.dispose();
    },
  );
  testWidgets(
    'supporting content removes its row and gap; errors override hiding and long copy grows',
    (tester) async {
      Widget field({
        String? helper,
        bool show = true,
        FieldFeedback feedback = const FieldFeedback.neutral(),
      }) => AppTextField(
        elementId: 'test.helper',
        runtimeLocator: locator,
        label: 'Label',
        options: FieldInputOptions(
          supportingText: helper,
          showSupporting: show,
          feedback: feedback,
          requirementLabels: labels,
          requirement: FieldRequirement.required,
          showRequirement: true,
        ),
      );
      await mount(tester, field());
      final base = tester.getSize(find.byType(AppTextField)).height;
      expect(find.byKey(const ValueKey('field-supporting')), findsNothing);
      expect(find.text('(Required)'), findsOneWidget);
      expect(find.text('(Optional)'), findsNothing);
      await mount(tester, field(helper: 'Help'));
      expect(
        tester.getSize(find.byType(AppTextField)).height,
        greaterThan(base),
      );
      await mount(tester, field(helper: 'Help', show: false));
      expect(tester.getSize(find.byType(AppTextField)).height, base);
      await mount(
        tester,
        field(
          show: false,
          feedback: FieldFeedback.error('خطای نمونهٔ طولانی ' * 12),
        ),
        direction: TextDirection.rtl,
        scale: 1.3,
      );
      expect(find.byKey(const ValueKey('field-supporting')), findsOneWidget);
      expect(
        tester.getSize(find.byType(AppTextField)).height,
        greaterThan(106),
      );
    },
  );
  testWidgets(
    'all Password source state and visibility combinations use real artwork and safe toggling',
    (tester) async {
      final c = TextEditingController(), focus = FocusNode();
      FieldRuntimeSnapshot? info;
      for (final visible in [true, false]) {
        for (final state in [
          FieldVisualState.defaultState,
          FieldVisualState.focused,
          FieldVisualState.written,
          FieldVisualState.success,
          FieldVisualState.error,
        ]) {
          await tester.pumpWidget(const SizedBox());
          c.value = TextEditingValue(
            text:
                state == FieldVisualState.defaultState ||
                    state == FieldVisualState.focused
                ? ''
                : 'SyntheticP!',
          );
          final feedback = state == FieldVisualState.error
              ? FieldFeedback.error('Caller error')
              : state == FieldVisualState.success
              ? const FieldFeedback.success()
              : const FieldFeedback.neutral();
          await mount(
            tester,
            AppPasswordField(
              key: ValueKey('$visible-${state.name}'),
              elementId: 'test.pw',
              runtimeLocator: locator,
              label: 'Password',
              showPasswordLabel: 'Show password',
              hidePasswordLabel: 'Hide password',
              initiallyVisible: visible,
              options: FieldInputOptions(
                controller: c,
                focusNode: focus,
                feedback: feedback,
                onSnapshot: (s) => info = s,
              ),
            ),
          );
          if (state == FieldVisualState.focused) {
            focus.requestFocus();
            await tester.pumpAndSettle();
          }
          expect(info!.state, state);
          expect(info!.passwordVisible, visible);
          expect(
            info!.spec.data['state'],
            '${FieldSpec.names[state]} - Visibility ${visible ? 'On' : 'Off'}',
          );
          if (c.text.isNotEmpty) {
            focus.requestFocus();
            await tester.pumpAndSettle();
            c.selection = const TextSelection.collapsed(offset: 3);
            await tester.pump();
            final value = c.value;
            final action = find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.label ==
                      (visible ? 'Hide password' : 'Show password'),
            );
            await tester.tap(action);
            await tester.pumpAndSettle();
            expect(c.value, value);
            expect(focus.hasFocus, isTrue);
            expect(info!.passwordVisible, !visible);
            expect(jsonEncode(info!.toJson()), isNot(contains(c.text)));
          }
        }
      }
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      focus.dispose();
    },
  );
  testWidgets(
    'single native OTP input supports paste, replacement, character policy, completion and stable RTL order',
    (tester) async {
      final c = TextEditingController(), focus = FocusNode();
      var completed = 0;
      FieldRuntimeSnapshot? info;
      Widget field({
        FieldFeedback feedback = const FieldFeedback.neutral(),
        List<TextInputFormatter> formatters = const [],
      }) => AppOtpField(
        elementId: 'test.otp',
        runtimeLocator: locator,
        label: 'Code',
        controller: c,
        focusNode: focus,
        feedback: feedback,
        inputFormatters: formatters,
        onCompleted: (_) => completed++,
        onSnapshot: (s) => info = s,
      );
      await mount(tester, field(), direction: TextDirection.rtl);
      expect(find.byType(TextField), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'P۱۲٣AB7');
      await tester.pumpAndSettle();
      expect(c.text, 'P۱۲٣AB');
      expect(completed, 1);
      final first = tester.getRect(
            find.byKey(const ValueKey('test.otp.cell.0')),
          ),
          last = tester.getRect(find.byKey(const ValueKey('test.otp.cell.5')));
      expect(first.left, lessThan(last.left));
      await mount(tester, field(), direction: TextDirection.rtl);
      focus.unfocus();
      await tester.pumpAndSettle();
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(completed, 1);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'P۱۲٣A',
          selection: TextSelection.collapsed(offset: 5),
        ),
      );
      await tester.pumpAndSettle();
      expect(c.text, 'P۱۲٣A');
      expect(info!.complete, isFalse);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'Q۱۲٣AZ',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      await tester.pumpAndSettle();
      expect(c.text, 'Q۱۲٣AZ');
      expect(completed, 2);
      await mount(tester, field(feedback: const FieldFeedback.success()));
      expect(c.text, 'Q۱۲٣AZ');
      expect(find.byType(AssetAppIcon), findsNWidgets(6));
      expect(jsonEncode(info!.toJson()), isNot(contains(c.text)));
      await mount(tester, field(feedback: FieldFeedback.error('Group error')));
      expect(find.text('Group error'), findsOneWidget);
      await mount(
        tester,
        field(formatters: [FilteringTextInputFormatter.allow(RegExp('[A-Z]'))]),
      );
      await tester.enterText(find.byType(TextField), 'AbP۱۲Q');
      await tester.pumpAndSettle();
      expect(c.text, 'APQ');
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      focus.dispose();
    },
  );
  testWidgets(
    'Radio uses controlled mutual exclusion, hover, keyboard and exclusive semantics',
    (tester) async {
      int? value;
      final focus = FocusNode();
      FieldRuntimeSnapshot? info;
      Widget group() => StatefulBuilder(
        builder: (context, setState) => AppRadioGroup<int>(
          value: value,
          onChanged: (v) => setState(() => value = v),
          child: Column(
            children: [
              AppRadio<int>(
                elementId: 'radio.a',
                runtimeLocator: locator,
                value: 1,
                label: 'One',
                focusNode: focus,
                requirement: FieldRequirement.required,
                requirementLabels: labels,
                showRequirement: true,
                onSnapshot: (s) => info = s,
              ),
              const AppRadio<int>(
                elementId: 'radio.b',
                runtimeLocator: locator,
                value: 2,
                label: 'Two',
              ),
            ],
          ),
        ),
      );
      await mount(tester, group());
      expect(value, isNull);
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      expect(value, 1);
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      expect(value, 1);
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();
      expect(value, 2);
      focus.requestFocus();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(value, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(value, 2);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(500, 500));
      await mouse.moveTo(tester.getCenter(find.text('One')));
      await tester.pumpAndSettle();
      expect(info!.state, FieldVisualState.notSelectedHover);
      await mouse.removePointer();
      final semantics = tester.ensureSemantics();
      expect(
        tester
            .getSemantics(find.byType(AppRadio<int>).first)
            .getSemanticsData()
            .flagsCollection
            .isInMutuallyExclusiveGroup,
        isTrue,
      );
      semantics.dispose();
      await tester.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );
}
