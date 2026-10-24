import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

const locator = UiRuntimeLocator(
  routeName: 'badge-test',
  routeInstanceId: 'test',
);
Future<void> mount(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.dark,
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
  double width = 400,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AppThemeFactory.build(brightness: brightness),
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Directionality(
            textDirection: direction,
            child: SizedBox(
              width: width,
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: child,
              ),
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
  test(
    'all 30 source variants and real style-specific master links reconcile',
    () {
      final source = jsonDecode(
        File(
          '../../docs/snapshots/2026-10-20_development-badges/evidence/inventory.json',
        ).readAsStringSync(),
      ) as Map;
      expect(
        BadgeSpec.all.map((s) => s.id),
        orderedEquals(
          (source['sets'] as List).expand(
            (s) => (s['variants'] as List).map((v) => v['id']),
          ),
        ),
      );
      for (final s in BadgeSpec.all) {
        for (final mode in [BadgeIconMode.fill, BadgeIconMode.outline]) {
          final art = s.artwork(mode)!;
          expect(s.icon(mode).key, art['logicalKey']);
          expect(
            s.icon(mode).artwork(AppIconStyle.values.byName(mode.name)).nodeId,
            art['nodeId'],
          );
          expect(s.iconColor(mode), isNotNull);
        }
      }
    },
  );
  testWidgets(
    'reference geometry uses actual fonts and preserves the nested label border exception',
    (tester) async {
      for (final s in BadgeSpec.all) {
        await mount(
          tester,
          AppBadge(
            elementId: 'test.badge',
            runtimeLocator: locator,
            label: s.referenceLabel,
            size: s.size,
            appearance: s.appearance,
            iconMode: BadgeIconMode.fill,
          ),
          brightness: s.brightness,
        );
        final actual = tester.getSize(find.byType(AppBadge));
        expect(actual.height, closeTo(s.sourceSize.height, 0.1), reason: s.id);
        expect(actual.width, closeTo(s.sourceSize.width, 1), reason: s.id);
        final identity = tester.widget<ElementIdentity>(
          find.byType(ElementIdentity),
        );
        expect(identity.variantId, s.id);
        expect(identity.variants['appearance'], s.appearance.name);
        expect(find.byType(TextButton), findsNothing);
      }
      final special = BadgeSpec.lookup(
        BadgeSize.large,
        BadgeAppearance.disabled,
        Brightness.light,
      );
      expect(special.sourceSize, const Size(84, 24));
      expect(special.border(special.labelFrame).width, 1);
      expect(
        BadgeSpec.lookup(
          BadgeSize.large,
          BadgeAppearance.filled,
          Brightness.light,
        ).border(
          BadgeSpec.lookup(
            BadgeSize.large,
            BadgeAppearance.filled,
            Brightness.light,
          ).labelFrame,
        ),
        BorderSide.none,
      );
    },
  );
  testWidgets(
    'no-icon removes its slot and gap and width follows actual label content',
    (tester) async {
      Widget badge(String label, BadgeIconMode mode) => AppBadge(
        elementId: 'test.badge',
        runtimeLocator: locator,
        label: label,
        size: BadgeSize.small,
        iconMode: mode,
      );
      await mount(tester, badge('A', BadgeIconMode.fill));
      final withIcon = tester.getSize(find.byType(AppBadge));
      await mount(tester, badge('A', BadgeIconMode.none));
      final without = tester.getSize(find.byType(AppBadge));
      expect(find.byKey(const ValueKey('badge-icon-slot')), findsNothing);
      expect(find.byKey(const ValueKey('badge-icon-gap')), findsNothing);
      expect(withIcon.width - without.width, 14);
      expect(without.width, lessThan(65));
      await mount(tester, badge('A longer label', BadgeIconMode.none));
      expect(
        tester.getSize(find.byType(AppBadge)).width,
        greaterThan(without.width),
      );
    },
  );
  testWidgets(
    'long bilingual labels wrap at 1.3 and semantics remain presentational',
    (tester) async {
      final handle = tester.ensureSemantics();
      for (final size in BadgeSize.values) {
        for (final brightness in Brightness.values) {
          for (final direction in TextDirection.values) {
            for (final scale in [1.0, 1.3]) {
              final label = direction == TextDirection.rtl
                  ? 'برچسب وضعیت طولانی برای آزمایش'
                  : 'A long status label that wraps';
              await mount(
                tester,
                AppBadge(
                  elementId: 'test.badge',
                  runtimeLocator: locator,
                  label: label,
                  size: size,
                  appearance: BadgeAppearance.disabled,
                  iconMode: BadgeIconMode.outline,
                ),
                brightness: brightness,
                direction: direction,
                scale: scale,
                width: 140,
              );
              expect(
                tester.getSize(find.byType(AppBadge)).width,
                lessThanOrEqualTo(140),
              );
              expect(
                tester
                    .getSemantics(find.text(label))
                    .getSemanticsData()
                    .flagsCollection
                    .isButton,
                isFalse,
              );
              expect(find.byType(GestureDetector), findsNothing);
            }
          }
        }
      }
      handle.dispose();
    },
  );
}
