import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import '../../support/auth_harness.dart';

void main() {
  final frames = jsonDecode(
    File('docs/snapshots/2026-10-23_auth-conformance/frames.json')
        .readAsStringSync(),
  ) as List;
  final results = <String, Object?>{};
  Map<String, double> rect(Rect r) => {
    'x': r.left,
    'y': r.top,
    'width': r.width,
    'height': r.height,
  };
  bool paints(Element element) {
    var visible = true;
    element.visitAncestorElements((ancestor) {
      final render = ancestor.renderObject;
      if (render is RenderOpacity && render.opacity == 0 ||
          render is RenderAnimatedOpacity && render.opacity.value == 0) {
        visible = false;
        return false;
      }
      return true;
    });
    return visible;
  }

  for (final name in ['idle', 'focusedEmpty', 'phone', 'email']) {
    testWidgets('402 source rects: $name', (tester) async {
      addTearDown(tester.view.reset);
      final frame = frames.singleWhere((f) => f['state'] == name) as Map;
      final nodes = frame['nodes'] as List;
      Map source(String nodeName) =>
          nodes.firstWhere(
                (n) => n['name'] == nodeName && n['visible'] == true,
              )['screenRect']
              as Map;
      await pumpAuth(
        tester,
        keyboard: name != 'idle',
        focused: name != 'idle',
        raw: switch (name) {
          'phone' => '+98 912 827 9503',
          'email' => 'me.ardeshir.rashidi@gmail.com',
          _ => '',
        },
      );
      final measurements = <String, Object?>{};
      void measure(
        String role,
        Rect actual,
        Map expected, {
        String? deviation,
      }) {
        final actualMap = rect(actual);
        final delta = {
          for (final key in actualMap.keys)
            key: actualMap[key]! - (expected[key] as num).toDouble(),
        };
        measurements[role] = {
          'source': expected,
          'actual': actualMap,
          'delta': delta,
          'documentedPolicy': ?deviation,
        };
      }

      final title = tester.getRect(find.byKey(const ValueKey('auth.title')));
      final subtitle = tester.getRect(
        find.byKey(const ValueKey('auth.subtitle')),
      );
      measure(
        'title',
        title,
        source('Title'),
        deviation: 'Text intrinsic width uses the bundled source font; report exact metric delta.',
      );
      measure('subtitle', subtitle, source('Subtitle'));
      for (final (actual, expected) in [
        (title, source('Title')),
        (subtitle, source('Subtitle')),
      ]) {
        expect(actual.left, closeTo((expected['x'] as num).toDouble(), .5));
        expect(actual.top, closeTo((expected['y'] as num).toDouble(), .5));
        expect(
          actual.height,
          closeTo((expected['height'] as num).toDouble(), .5),
        );
      }
      final reward = find.byWidgetPredicate(
        (w) => w is ElementIdentity && w.elementId == 'auth.entry.reward',
      );
      measure(
        'reward',
        tester.getRect(reward),
        source('Points'),
        deviation: 'Intrinsic source-font metrics; never force a text width.',
      );
      final field = tester.getRect(find.byType(AppTextField));
      final fieldSource = source('Base Text Field - Dark Mode');
      measure('field', field, fieldSource);
      for (final key in rect(field).keys) {
        expect(
          rect(field)[key],
          closeTo((fieldSource[key] as num).toDouble(), .5),
          reason: 'field $key',
        );
      }
      final button = tester.getRect(
        find.byKey(const ValueKey('auth.continue')),
      );
      measure(
        'cta',
        button,
        source('Medium Fill Button - Dark Mode'),
        deviation: 'D-059: fixed Figma frame46; keyboard bottom gap20.',
      );
      expect(button.width, name == 'idle' ? 360 : 362);
      expect(button.height, 46);
      if (name != 'idle') expect(874 - 331 - button.bottom, closeTo(20, .5));
      if (name == 'idle') {
        expect(
          tester.getRect(find.byType(LinkText)),
          const Rect.fromLTWH(25, 813, 352, 36),
        );
        expect(button.top, closeTo(576, .5));
        measure(
          'hero',
          tester.getRect(find.byType(HeroBanner)),
          source('Background'),
        );
        measure(
          'rememberVisual',
          tester.getRect(find.byType(AppRadioPresentation)),
          source('Radio Button - Dark Mode'),
          deviation: 'Visual remains36; independent hit target is48.',
        );
        measure(
          'divider',
          tester.getRect(find.byType(LabeledDivider)),
          source('Divider'),
          deviation:
              'D-059: fixed CTA frame restores source downstream positions.',
        );
        for (final brand in SocialAuthBrand.values) {
          final tile = find.byWidgetPredicate(
            (w) => w is SocialAuthTile && w.brand == brand,
          );
          measure(
            brand.name,
            tester.getRect(tile),
            source(switch (brand) {
              SocialAuthBrand.playStation => 'Play Station',
              SocialAuthBrand.xbox => 'Xbox',
              SocialAuthBrand.google => 'Google',
            }),
            deviation:
                'Source geometry; PlayStation spelling corrected by owner.',
          );
        }
        measure(
          'legal',
          tester.getRect(find.byType(LinkText)),
          source('Terms & Privacy'),
          deviation:
              'D-059: inline link exception; source14/18 two-line prose.',
        );
      }
      results[name] = {
        'frameNodeId': frame['nodeId'],
        'toleranceLogicalPx': .5,
        'measurements': measurements,
        'paragraphs': [
          for (final element in find.byType(RichText).evaluate())
            if (element.renderObject is RenderParagraph && paints(element))
              (() {
                final paragraph = element.renderObject! as RenderParagraph;
                final style = (paragraph.text as TextSpan).style!;
                final origin = paragraph.localToGlobal(Offset.zero);
                return {
                  'text': paragraph.text.toPlainText(),
                  'rect': rect(origin & paragraph.size),
                  'fontFamily': style.fontFamily,
                  'weight': style.fontWeight?.value,
                  'size': style.fontSize,
                  'height': style.height,
                  'letterSpacing': style.letterSpacing,
                  'color': style.color?.toARGB32().toRadixString(16),
                  'advance': paragraph.getMaxIntrinsicWidth(double.infinity),
                };
              })(),
        ],
        'editable': [
          for (final w in tester.widgetList<EditableText>(
            find.byType(EditableText),
          ))
            {
              'text': w.controller.text,
              'weight': w.style.fontWeight?.value,
              'color': w.style.color?.toARGB32().toRadixString(16),
              'size': w.style.fontSize,
              'caretRect': (() {
                final edit = tester.renderObject<RenderEditable>(
                  find
                      .byElementPredicate(
                        (e) =>
                            e is RenderObjectElement &&
                            e.renderObject is RenderEditable,
                      )
                      .first,
                );
                final offset = w.controller.selection.extentOffset < 0
                    ? w.controller.text.length
                    : w.controller.selection.extentOffset;
                return rect(
                  edit
                      .getLocalRectForCaret(TextPosition(offset: offset))
                      .shift(edit.localToGlobal(Offset.zero)),
                );
              })(),
              'rect': rect(
                tester.getRect(
                  find
                      .byElementPredicate(
                        (e) =>
                            e is RenderObjectElement &&
                            e.renderObject is RenderEditable,
                      )
                      .first,
                ),
              ),
              'advance': (TextPainter(
                text: TextSpan(text: w.controller.text, style: w.style),
                textDirection: TextDirection.ltr,
              )..layout()).maxIntrinsicWidth,
            },
        ],
        'icons': [
          for (final e
              in find.byWidgetPredicate((w) => w is AppIcon).evaluate())
            {
              'id': (e.widget as AppIcon).iconId,
              if (e.widget is AssetAppIcon)
                'color': (e.widget as AssetAppIcon).color
                    ?.toARGB32()
                    .toRadixString(16),
              'rect': rect(
                tester.getRect(find.byElementPredicate((x) => identical(x, e))),
              ),
            },
        ],
        'surfaces': [
          for (final e in find.byType(DecoratedBox).evaluate())
            if (e.widget is DecoratedBox &&
                (e.widget as DecoratedBox).decoration is BoxDecoration)
              {
                'rect': rect(
                  tester.getRect(
                    find.byElementPredicate((x) => identical(x, e)),
                  ),
                ),
                'color':
                    ((e.widget as DecoratedBox).decoration as BoxDecoration)
                        .color
                        ?.toARGB32()
                        .toRadixString(16),
              },
        ],
        'dividerLines': [
          for (final e
              in find
                  .descendant(
                    of: find.byType(LabeledDivider),
                    matching: find.byType(CustomPaint),
                  )
                  .evaluate())
            rect(
              tester.getRect(find.byElementPredicate((x) => identical(x, e))),
            ),
        ],
      };
      final output = Directory('build/auth-entry-preflight')
        ..createSync(recursive: true);
      File(
        '${output.path}/figma-conformance.json',
      ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(results));
      expect(tester.takeException(), isNull);
    });
  }
}
