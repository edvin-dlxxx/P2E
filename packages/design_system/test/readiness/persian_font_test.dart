import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';

import '../support/readiness_sheet.dart';

void checkChain(TextStyle style, String reason) {
  final chain = [
    if (style.fontFamily != null) style.fontFamily!,
    ...?style.fontFamilyFallback,
  ];
  expect(chain, contains(BundledTypography.persianFamily), reason: reason);
  for (final family in chain) {
    expect(
      family.split(BundledTypography.packagePrefix).length - 1,
      lessThanOrEqualTo(1),
      reason: '$reason: $family',
    );
  }
}

Iterable<TextStyle> themeStyles(TextTheme theme) => [
  theme.displayLarge!,
  theme.displayMedium!,
  theme.displaySmall!,
  theme.headlineLarge!,
  theme.headlineMedium!,
  theme.headlineSmall!,
  theme.titleLarge!,
  theme.titleMedium!,
  theme.titleSmall!,
  theme.bodyLarge!,
  theme.bodyMedium!,
  theme.bodySmall!,
  theme.labelLarge!,
  theme.labelMedium!,
  theme.labelSmall!,
];

Future<List<int>> raster(
  WidgetTester tester,
  TextStyle style,
  String sample,
  TextScaler scaler,
) async {
  final painter = TextPainter(
    text: TextSpan(
      text: sample,
      style: style.copyWith(color: const Color(0xff000000)),
    ),
    textDirection: TextDirection.rtl,
    textScaler: scaler,
  )..layout();
  final baseline = painter.computeLineMetrics().first.baseline;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawColor(const Color(0xffffffff), BlendMode.src);
  // Align baselines so differing primary-font ascent does not mask glyph shape.
  painter.paint(canvas, Offset(8, 100 - baseline));
  painter.dispose();
  final picture = recorder.endRecording();
  final bytes = await tester.runAsync(() async {
    final image = await picture.toImage(1000, 180);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    image.dispose();
    return bytes;
  });
  picture.dispose();
  return bytes!;
}

void main() {
  test(
    'normalization repairs package merge without changing visual attributes',
    () {
      const source = TextStyle(
        fontFamily: 'Outfit',
        package: 'p2e_design_system',
        fontFamilyFallback: ['packages/p2e_design_system/Vazirmatn'],
        fontSize: 17,
        fontWeight: FontWeight.w500,
        height: 1.25,
        letterSpacing: -.3,
        wordSpacing: .2,
        color: Color(0xff123456),
        fontVariations: [ui.FontVariation('wght', 500)],
      );
      final resolved = BundledTypography.resolve(source);
      checkChain(resolved, 'merged package style');
      expect(resolved.fontFamily, source.fontFamily);
      expect(resolved.fontSize, source.fontSize);
      expect(resolved.fontWeight, source.fontWeight);
      expect(resolved.height, source.height);
      expect(resolved.letterSpacing, source.letterSpacing);
      expect(resolved.wordSpacing, source.wordSpacing);
      expect(resolved.color, source.color);
      expect(resolved.fontVariations, isEmpty); // D-060: static Outfit faces.
      checkChain(
        const TextStyle(
          fontFamily: 'Roboto',
          fontFamilyFallback: BundledTypography.persianFallback,
        ).merge(resolved),
        'post-merge heading',
      );
    },
  );
  for (final brightness in Brightness.values) {
    for (final skin in [productSkin, testSkin]) {
      test('all exported Persian style paths $brightness ${skin.id}', () {
        final theme = AppThemeFactory.build(brightness: brightness, skin: skin);
        final styles = <String, TextStyle>{
          for (final t in TypographyTokens.byName.entries)
            'token/${t.key}': t.value.style,
          for (final t
              in theme.extension<ButtonThemeTokens>()!.textStyles.entries)
            'extension/${t.key}': t.value,
          for (final (i, s) in themeStyles(theme.textTheme).indexed)
            'theme/$i': s,
          for (final (i, s) in themeStyles(theme.primaryTextTheme).indexed)
            'primaryTheme/$i': s,
          for (final s in ButtonSpec.all.where(
            (s) => s.brightness == brightness && s.hasText,
          ))
            'button/${s.id}': s.textStyle!,
          for (final s in BadgeSpec.all.where(
            (s) => s.brightness == brightness,
          ))
            'badge/${s.id}': s.withSkin(skin).labelStyle(persian: true),
          for (final s in AppBarSpec.all.where(
            (s) => s.brightness == brightness,
          ))
            for (final entry in (s.data['parts'] as Map).entries.where(
              (e) => e.value['fontSize'] != null,
            ))
              'appBar/${s.id}/${entry.key}': s
                  .withSkin(skin)
                  .textStyle(entry.key, persian: true),
          for (final s in NavigationItemSpec.all.where(
            (s) => s.brightness == brightness,
          ))
            for (final role in ['label', 'badgeLabel'])
              'navigation/${s.id}/$role': s
                  .withSkin(skin)
                  .textStyle(role, persian: true),
          for (final source in FieldSpec.all)
            if (source.brightness == brightness ||
                source.family == FieldFamily.password ||
                source.family == FieldFamily.otp)
              for (final entry in (source.data['parts'] as Map).entries.where(
                (e) => e.value is Map && e.value['fontSize'] != null,
              ))
                'field/${source.basisId}/${entry.key}': FieldSpec(
                  source.data,
                  brightness,
                  derived: source.brightness != brightness,
                ).withSkin(skin).textStyle(entry.key, persian: true),
        };
        for (final entry in styles.entries) {
          checkChain(entry.value, entry.key);
        }
      });
      testWidgets(
        'bundled Persian glyphs in every text family $brightness ${skin.id}',
        (tester) async {
          addTearDown(tester.view.reset);
          for (final family in families.where((f) => f != 'AppIcon')) {
            await pumpSheet(
              tester,
              family: family,
              language: 'fa',
              brightness: brightness,
              includeDerived: true,
              theme: AppThemeFactory.build(brightness: brightness, skin: skin),
            );
            for (final editable in tester.widgetList<EditableText>(
              find.byType(EditableText),
            )) {
              checkChain(editable.style, '$family/native editable');
            }
            final paragraphs = tester
                .renderObjectList<RenderParagraph>(find.byType(RichText))
                .where(
                  (p) =>
                      RegExp(r'[\u0600-\u06ff]').hasMatch(p.text.toPlainText()),
                )
                .toList();
            expect(paragraphs, isNotEmpty, reason: family);
            for (final paragraph in paragraphs) {
              checkChain(
                (paragraph.text as TextSpan).style!,
                '$family/${paragraph.text.toPlainText()}',
              );
            }
            final paragraph = paragraphs.first;
            final actual = (paragraph.text as TextSpan).style!;
            final reference = actual.copyWith(
              fontFamily: BundledTypography.persianFamily,
              fontFamilyFallback: const [],
            );
            for (final sample in ['پژوهش', '۱۲۳۴۵۶۷۸۹۰']) {
              final actualPainter = TextPainter(
                text: TextSpan(text: sample, style: actual),
                textDirection: TextDirection.rtl,
                textScaler: paragraph.textScaler,
              )..layout();
              final referencePainter = TextPainter(
                text: TextSpan(text: sample, style: reference),
                textDirection: TextDirection.rtl,
                textScaler: paragraph.textScaler,
              )..layout();
              expect(
                actualPainter.width,
                closeTo(referencePainter.width, .001),
                reason: '$family/$sample bundled advances',
              );
              actualPainter.dispose();
              referencePainter.dispose();
              final pixels = await raster(
                tester,
                actual,
                sample,
                paragraph.textScaler,
              );
              expect(
                pixels,
                orderedEquals(
                  await raster(tester, reference, sample, paragraph.textScaler),
                ),
                reason: '$family/$sample bundled glyph raster',
              );
              expect(
                pixels,
                isNot(
                  orderedEquals(
                    await raster(
                      tester,
                      reference,
                      '□□□□□',
                      paragraph.textScaler,
                    ),
                  ),
                ),
                reason: '$family must not render box glyphs',
              );
            }
          }
        },
      );
    }
  }
}
