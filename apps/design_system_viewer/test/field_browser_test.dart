import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system_viewer/fields/field_browser.dart';
import 'package:p2e_design_system_viewer/inspection/inspection_record.dart';
import 'package:p2e_design_system_viewer/l10n/generated/viewer_localizations.dart';

void main() {
  for (final family in FieldFamily.values) {
    testWidgets(
      '${family.name} filters and source counts are scoped to its tab',
      (tester) async {
        tester.view.physicalSize = const Size(1600, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: ViewerLocalizations.localizationsDelegates,
            supportedLocales: ViewerLocalizations.supportedLocales,
            home: UiIdentityScope(
              routeName: 'test.viewer',
              child: Scaffold(
                body: FieldBrowser(
                  family: family,
                  selected: null,
                  onInspect: (_) {},
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l = ViewerLocalizations.of(
          tester.element(find.byType(FieldBrowser)),
        );
        final count = FieldSpec.all.where((s) => s.family == family).length;
        expect(find.text(l.fieldCoverage(count)), findsOneWidget);
        final derived =
            family == FieldFamily.password || family == FieldFamily.otp;
        expect(
          find.text(l.fieldVisibleCount(derived ? count * 2 : count)),
          findsOneWidget,
        );
        final stateControl = tester.widget<DropdownButton<String>>(
          find.descendant(
            of: find.byKey(const ValueKey('fields-state-all')),
            matching: find.byType(DropdownButton<String>),
          ),
        );
        final states = stateControl.items!.map((i) => i.value).toSet();
        expect(states.contains('Edit'), family == FieldFamily.otp);
        expect(states.contains('Error'), family != FieldFamily.radio);
        expect(
          find.byKey(const ValueKey('fields-visibility-all')),
          family == FieldFamily.password ? findsOneWidget : findsNothing,
        );
        expect(
          find.byKey(const ValueKey('fields-support-icon')),
          family == FieldFamily.textField || family == FieldFamily.password
              ? findsOneWidget
              : findsNothing,
        );
        expect(
          find.byKey(const ValueKey('fields-deselect')),
          family == FieldFamily.radio ? findsOneWidget : findsNothing,
        );
        final state = family == FieldFamily.radio
            ? 'Selected Hover'
            : family == FieldFamily.otp
            ? 'Edit'
            : 'Written';
        await tester.tap(find.byKey(const ValueKey('fields-state-all')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(state).last);
        await tester.pumpAndSettle();
        expect(
          find.text(
            l.fieldVisibleCount(
              family == FieldFamily.otp
                  ? 2
                  : family == FieldFamily.password
                  ? 4
                  : 2,
            ),
          ),
          findsOneWidget,
        );
        if (family == FieldFamily.password) {
          await tester.tap(find.byKey(const ValueKey('fields-visibility-all')));
          await tester.pumpAndSettle();
          await tester.tap(find.text(l.fieldShown).last);
          await tester.pumpAndSettle();
          expect(find.text(l.fieldVisibleCount(2)), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final language in ['en', 'fa']) {
    testWidgets(
      '$language fields source count, filtering, editing and safe Inspector',
      (tester) async {
        tester.view.physicalSize = const Size(1600, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        InspectionRecord? record;
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            supportedLocales: ViewerLocalizations.supportedLocales,
            localizationsDelegates: ViewerLocalizations.localizationsDelegates,
            theme: AppThemeFactory.build(brightness: Brightness.dark),
            home: UiIdentityScope(
              routeName: 'test.viewer',
              child: Scaffold(
                body: FieldBrowser(
                  family: FieldFamily.password,
                  selected: 'live.password',
                  onInspect: (v) => record = v,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(AppFieldSurface), findsNWidgets(21));
        final count = tester
            .widget<Text>(find.byKey(const ValueKey('fields-source-count')))
            .data;
        final native = find.descendant(
          of: find.byType(AppPasswordField),
          matching: find.byType(TextField),
        );
        await tester.ensureVisible(find.byType(AppPasswordField));
        await tester.tap(find.byType(AppPasswordField));
        await tester.pumpAndSettle();
        await tester.enterText(native, 'Private-password-123');
        await tester.pumpAndSettle();
        expect(record!.sampleId, 'live.password');
        final metadata = {
          for (final e in record!.groups.entries)
            e.key.name: [
              for (final f in e.value)
                {'id': f.id.name, 'value': f.value.toString()},
            ],
        };
        expect(jsonEncode(metadata), isNot(contains('Private-password-123')));
        final editable = tester.widget<TextField>(native).controller;
        final filter = find.byKey(const ValueKey('fields-coverage-all'));
        await tester.ensureVisible(filter);
        await tester.tap(filter);
        await tester.pumpAndSettle();
        final l = ViewerLocalizations.of(
          tester.element(find.byType(FieldBrowser)),
        );
        await tester.tap(find.text(l.fieldDerived).last);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('fields-source-count')))
              .data,
          count,
        );
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('fields-visible-count')))
              .data,
          l.fieldVisibleCount(10),
        );
        expect(tester.widget<TextField>(native).controller, same(editable));
        expect(editable!.text, 'Private-password-123');
      },
    );
  }
}
