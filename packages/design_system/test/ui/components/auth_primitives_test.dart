import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';

Widget host(
  Widget child, {
  bool rtl = false,
  double scale = 1,
  SkinDefinition skin = productSkin,
  Brightness brightness = Brightness.dark,
}) => MaterialApp(
  theme: AppThemeFactory.build(brightness: brightness, skin: skin),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
    child: child!,
  ),
  home: Directionality(
    textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
    child: UiIdentityScope(
      routeName: 'test.auth',
      child: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  ),
);

void main() {
  test('brand artwork never fabricates Outline/Fill variants', () {
    for (final brand in SocialAuthBrand.values) {
      for (final style in AppIconStyle.values) {
        expect(
          () => BrandAppIcon(brand).withStyle(style),
          throwsUnsupportedError,
        );
      }
    }
  });
  testWidgets(
    'original brand boxes retain40/20 without overlapping destinations',
    (tester) async {
      await tester.pumpWidget(
        host(
          Row(
            children: [
              for (final brand in SocialAuthBrand.values)
                Expanded(
                  child: SocialAuthTile(
                    elementId: 'auth.brand.${brand.name.toLowerCase()}',
                    brand: brand,
                    label: brand.name,
                    onPressed: () {},
                  ),
                ),
            ],
          ),
        ),
      );
      final rects = <Rect>[];
      for (final brand in SocialAuthBrand.values) {
        final icon = find.byWidgetPredicate(
          (w) => w is BrandAppIcon && w.brand == brand,
        );
        final size = tester.getSize(icon);
        expect(size, Size.square(brand == SocialAuthBrand.google ? 20 : 40));
        rects.add(
          tester.getRect(
            find.byWidgetPredicate(
              (w) => w is SocialAuthTile && w.brand == brand,
            ),
          ),
        );
      }
      expect(rects[0].overlaps(rects[1]), false);
      expect(rects[1].overlaps(rects[2]), false);
    },
  );
  testWidgets(
    'long2x toast scrolls above keyboard and announces its full text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      const message = 'The service is unavailable. Please try again.';
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppThemeFactory.build(brightness: Brightness.dark),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(2),
              padding: const EdgeInsets.only(top: 55),
              viewInsets: const EdgeInsets.only(bottom: 300),
            ),
            child: child!,
          ),
          home: Scaffold(
            body: UiIdentityScope(
              routeName: 'test.toast',
              child: Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: AppToast(
                  elementId: 'auth.toast',
                  message: message,
                  onDismiss: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final scroll = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      expect(
        tester
            .getSemantics(find.bySemanticsLabel(message).first)
            .getSemanticsData()
            .flagsCollection
            .isLiveRegion,
        true,
      );
      expect(tester.takeException(), isNull);
      semantics.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
  testWidgets(
    'snapshot minor schema exposes loading independently of enabled',
    (tester) async {
      await tester.pumpWidget(
        host(
          AppButton(
            elementId: 'auth.busy',
            label: 'Continue',
            loading: true,
            loadingSemanticsLabel: 'Signing in',
            onPressed: () {},
          ),
        ),
      );
      final identity = tester.widget<ElementIdentity>(
        find
            .descendant(
              of: find.byType(AppButton),
              matching: find.byType(ElementIdentity),
            )
            .first,
      );
      final descriptor = identity.descriptor();
      expect(descriptor['schemaVersion'], '1.1.0');
      expect((descriptor['state'] as Map)['loading'], true);
      expect((descriptor['state'] as Map)['enabled'], false);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
  test('all new text tokens resolve bundled fonts exactly once', () {
    for (final style in AuthTextTokens.byName.values) {
      expect(style.fontFamily, BundledTypography.outfitFamily);
      expect(
        style.fontFamilyFallback,
        contains(BundledTypography.persianFamily),
      );
      expect(style.fontFamily, isNot(contains('p2e_design_system/packages/')));
    }
  });
  for (final skin in [productSkin, testSkin]) {
    for (final brightness in Brightness.values) {
      testWidgets('accent ${skin.id} $brightness preserves source geometry', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            Column(
              children: [
                AppButton(
                  elementId: 'auth.source',
                  label: 'Continue',
                  family: AppButtonFamily.fill,
                  onPressed: () {},
                ),
                AppButton(
                  elementId: 'auth.accent',
                  label: 'Continue',
                  family: AppButtonFamily.fill,
                  tone: AppButtonTone.accent,
                  onPressed: () {},
                ),
              ],
            ),
            skin: skin,
            brightness: brightness,
          ),
        );
        await tester.pumpAndSettle();
        final buttons = find.byType(AppButton);
        expect(tester.getSize(buttons.at(0)), tester.getSize(buttons.at(1)));
        final identity = find.descendant(
          of: buttons.at(1),
          matching: find.byType(ElementIdentity),
        );
        final metadata = tester.widget<ElementIdentity>(identity.first);
        expect((metadata.resolved['backgroundColor'] as Map)['value'], {
          'r': skin.valuesFor(brightness).actionAccent.r,
          'g': skin.valuesFor(brightness).actionAccent.g,
          'b': skin.valuesFor(brightness).actionAccent.b,
          'a': skin.valuesFor(brightness).actionAccent.a,
        });
      });
    }
  }
  for (final rtl in [false, true]) {
    testWidgets('checkbox target and keyboard activation rtl=$rtl', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var value = false;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => AppToggle(
              elementId: 'auth.remember',
              label: rtl ? 'به خاطر بسپار' : 'Remember',
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
          rtl: rtl,
        ),
      );
      expect(
        tester.getSize(find.byType(AppToggle)).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSemantics(find.byType(AppToggle)),
        matchesSemantics(
          label: rtl ? 'به خاطر بسپار' : 'Remember',
          hasCheckedState: true,
          isChecked: false,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasFocusAction: true,
          isFocusable: true,
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(value, true);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    });
  }
  testWidgets(
    'inline legal links retain separate semantics and keyboard focus',
    (tester) async {
      await tester.pumpWidget(
        host(
          LinkText(
            elementId: 'auth.legal',
            segments: [
              LinkTextSegment('Terms & Conditions', onTap: () {}),
              LinkTextSegment('Privacy Policy', onTap: () {}),
            ],
          ),
        ),
      );
      final targets = find.byType(TextButton);
      final a = tester.getRect(targets.at(0)),
          b = tester.getRect(targets.at(1));
      expect(a.height, 18);
      expect(b.height, 18);
      expect(a.overlaps(b), false);
    },
  );
  testWidgets('toast is a live region and cancels its timer on disposal', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var dismissed = false;
    await tester.pumpWidget(
      host(
        AppToast(
          elementId: 'auth.toast',
          message: 'Offline',
          onDismiss: () => dismissed = true,
        ),
      ),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Offline').first)
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      true,
    );
    await tester.pump(const Duration(seconds: 4));
    expect(dismissed, true);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
