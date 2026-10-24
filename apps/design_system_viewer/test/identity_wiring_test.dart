import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system_viewer/fields/field_browser.dart';
import 'package:p2e_design_system_viewer/badges/badge_browser.dart';
import 'package:p2e_design_system_viewer/board/button_sample.dart';
import 'package:p2e_design_system_viewer/board/preview_settings.dart';
import 'package:p2e_design_system_viewer/inspection/inspection_record.dart';
import 'package:p2e_design_system_viewer/navigation/navigation_browser.dart';
import 'package:p2e_design_system_viewer/l10n/generated/viewer_localizations.dart';

import 'package:p2e_design_system/testing.dart';

void main() {
  testWidgets('Badge publication reads mounted metadata on same-size changes', (
    t,
  ) async {
    InspectionRecord? report;
    final spec = BadgeSpec.all.first;
    Future<void> mount(BadgeIconMode mode) async {
      await t.pumpWidget(
        MaterialApp(
          localizationsDelegates: ViewerLocalizations.localizationsDelegates,
          supportedLocales: ViewerLocalizations.supportedLocales,
          theme: AppThemeFactory.build(brightness: spec.brightness),
          home: UiIdentityScope(
            routeName: 'test.badges',
            child: Scaffold(
              body: BadgeSample(
                spec: spec,
                label: 'Synthetic badge',
                sourceReference: false,
                iconMode: mode,
                scale: 1,
                direction: TextDirection.ltr,
                selected: true,
                onInspect: (r) => report = r,
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    await mount(BadgeIconMode.fill);
    final before = t.getSize(find.byType(AppBadge));
    await mount(BadgeIconMode.outline);
    final payload =
        report!.groups[InspectionGroup.identity]!
                .singleWhere((f) => f.id == InspectionFieldId.runtimeIdentity)
                .value
            as Map;
    expect((payload['declared']['iconMode'] as Map)['value'], 'outline');
    expect(t.getSize(find.byType(AppBadge)), before);
  });
  testWidgets(
    'Button source identity never publishes the previous same-size variant',
    (t) async {
      final reports = <InspectionRecord>[];
      final filled = ButtonSpec.lookup(
        family: AppButtonFamily.hug,
        size: AppButtonSize.medium,
        type: AppButtonType.filled,
        brightness: Brightness.dark,
      );
      final tonal = ButtonSpec.lookup(
        family: AppButtonFamily.hug,
        size: AppButtonSize.medium,
        type: AppButtonType.tonal,
        brightness: Brightness.dark,
      );
      Future<void> mount(ButtonSpec spec) async {
        await t.pumpWidget(
          MaterialApp(
            localizationsDelegates: ViewerLocalizations.localizationsDelegates,
            supportedLocales: ViewerLocalizations.supportedLocales,
            theme: AppThemeFactory.build(brightness: Brightness.dark),
            home: UiIdentityScope(
              routeName: 'test.buttons',
              child: Scaffold(
                body: ButtonSample(
                  key: const ValueKey('same-sample'),
                  spec: spec,
                  settings: const PreviewSettings(
                    iconMode: ButtonIconMode.fill,
                    scale: 1,
                    direction: TextDirection.ltr,
                    reference: false,
                    longLabel: false,
                    fillWidth: 402,
                    measurements: false,
                    revision: 0,
                  ),
                  selected: true,
                  onSelect: () {},
                  onObserve: reports.add,
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
      }

      await mount(filled);
      final before = t.getSize(find.byType(AppButton));
      reports.clear();
      await mount(tonal);
      expect(reports, isNotEmpty);
      for (final report in reports) {
        final payload =
            report.groups[InspectionGroup.identity]!
                    .singleWhere(
                      (f) => f.id == InspectionFieldId.runtimeIdentity,
                    )
                    .value
                as Map;
        expect(payload['designRef']['nodeId'], tonal.id);
      }
      expect(t.getSize(find.byType(AppButton)), before);
    },
  );
  testWidgets(
    'all 50 reference cards and fixed child slots have mounted identities',
    (t) async {
      t.view.physicalSize = const Size(1800, 4000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      var total = 0;
      for (final family in FieldFamily.values) {
        await t.pumpWidget(
          MaterialApp(
            localizationsDelegates: ViewerLocalizations.localizationsDelegates,
            supportedLocales: ViewerLocalizations.supportedLocales,
            home: Scaffold(
              body: UiIdentityScope(
                routeName: 'viewer.fields',
                child: FieldBrowser(
                  key: ValueKey(family),
                  family: family,
                  selected: null,
                  onInspect: (_) {},
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final all = mountedIdentities(t.binding.rootElement!);
        expectUniqueIdentities(t.binding.rootElement!);
        final refs = all
            .where((w) => w.elementId.startsWith('reference.field.'))
            .toList();
        total += refs.length;
        expect(refs.length, switch (family) {
          FieldFamily.textField => 10,
          FieldFamily.password => 20,
          FieldFamily.otp => 12,
          FieldFamily.radio => 8,
        });
        if (family == FieldFamily.password) {
          expect(
            all
                .where((w) => w.runtimeLocator?.slotPath == 'visibilityAction')
                .length,
            1,
          );
        }
        if (family == FieldFamily.otp) {
          final cells = all
              .where(
                (w) =>
                    w.runtimeLocator?.slotPath?.startsWith('cells.cell') ??
                    false,
              )
              .toList();
          expect(cells.length, 6);
          expect(
            cells.map((w) => w.runtimeLocator!.slotPath).toSet().length,
            6,
          );
          expect(cells.every((w) => w.elementId == 'live.otp'), isTrue);
        }
      }
      expect(total, 50);
    },
  );
  testWidgets(
    'two real screen instances never share effective occurrence keys',
    (t) async {
      t.view.physicalSize = const Size(2400, 4000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          localizationsDelegates: ViewerLocalizations.localizationsDelegates,
          supportedLocales: ViewerLocalizations.supportedLocales,
          home: Scaffold(
            body: Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Expanded(
                    child: UiIdentityScope(
                      routeName: 'viewer.navigation',
                      child: NavigationBrowser(
                        selected: null,
                        onInspect: (_) {},
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expectUniqueIdentities(t.binding.rootElement!);
      expect(mountedIdentities(t.binding.rootElement!).length, 44);
    },
  );
}
