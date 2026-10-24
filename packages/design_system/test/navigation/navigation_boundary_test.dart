import 'dart:ui' show SemanticsRole, Tristate;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

// flutter_test_config.dart loads the real bundled Outfit and Vazirmatn faces.
// D-031 has no finite badge-label limit. This is a wrapping stress sample,
// deliberately not described as a maximum supported value.
final stressBadge = List.filled(8, '1234567890').join();

List<AppNavigationDestination> items(
  Brightness theme,
  bool fa,
  String badges,
) => [
  for (final d in NavigationBarSpec.lookup(theme).referenceDestinations)
    AppNavigationDestination(
      id: d.id,
      icon: d.icon,
      label: fa
          ? {
              'home': 'خانه',
              'mission': 'مأموریت',
              'games': 'بازی‌ها',
              'leaderboard': 'جدول رتبه‌بندی',
              'shop': 'فروشگاه',
            }[d.id]!
          : d.label,
      badge: badges == 'none' || d.badge == null
          ? null
          : AppNavigationBadge(
              label: badges == 'source' ? d.badge! : stressBadge,
              semanticLabel: badges == 'source' ? d.badge! : stressBadge,
            ),
    ),
];

Finder part(String id) => find.byKey(ValueKey('test.boundary.$id'));

Widget fixture({
  required double width,
  required double scale,
  required Brightness theme,
  required bool fa,
  required List<AppNavigationDestination> destinations,
  required String selected,
  required ValueChanged<String> onSelected,
}) => MaterialApp(
  theme: AppThemeFactory.build(brightness: theme),
  builder: (context, child) => Localizations.override(
    context: context,
    locale: Locale(fa ? 'fa' : 'en'),
    child: child!,
  ),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Directionality(
      textDirection: fa ? TextDirection.rtl : TextDirection.ltr,
      child: UiIdentityScope(
        routeName: 'navigation-boundary',
        instanceKey: 'fixture',
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: SizedBox(
            width: width,
            child: AppNavigationBar(
              elementId: 'test.boundary',
              destinations: destinations,
              selectedDestinationId: selected,
              onDestinationSelected: onSelected,
            ),
          ),
        ),
      ),
    ),
  ),
);

void inside(Rect outer, Rect inner) {
  const epsilon = 0.001;
  expect(inner.left, greaterThanOrEqualTo(outer.left - epsilon));
  expect(inner.top, greaterThanOrEqualTo(outer.top - epsilon));
  expect(inner.right, lessThanOrEqualTo(outer.right + epsilon));
  expect(inner.bottom, lessThanOrEqualTo(outer.bottom + epsilon));
}

void disjoint(Rect a, Rect b) {
  final overlap = a.intersect(b);
  expect(
    overlap.width <= 0.001 || overlap.height <= 0.001,
    isTrue,
    reason: '$a must not overlap $b',
  );
}

// Check horizontal text extents and complete wrapped line height, not just the
// surrounding frame. Tight selection boxes use font ascent/descent rather than
// ink bounds, so they are not a reliable badge clipping measurement.
void textFits(WidgetTester t, Finder frame, Rect paintBounds, {Rect? avoid}) {
  final paragraphFinder = find.descendant(
    of: frame,
    matching: find.byType(RichText),
  );
  final paragraph = t.renderObject<RenderParagraph>(paragraphFinder);
  expect(paragraph.didExceedMaxLines, isFalse);
  final text = paragraph.text.toPlainText();
  final bounds = t.getRect(frame);
  inside(paintBounds, t.getRect(paragraphFinder));
  final painter = TextPainter(
    text: paragraph.text,
    textDirection: paragraph.textDirection,
    textScaler: paragraph.textScaler,
  )..layout(maxWidth: paragraph.size.width);
  expect(painter.height, lessThanOrEqualTo(paragraph.size.height + 0.001));
  painter.dispose();
  // A wrapped trailing space has a selection box past the line edge, but
  // paints no glyph. Measure the non-whitespace runs rather than that space.
  for (final box in [
    for (final run in RegExp(r'\S+').allMatches(text))
      ...paragraph.getBoxesForSelection(
        TextSelection(baseOffset: run.start, extentOffset: run.end),
      ),
  ]) {
    final rect = box.toRect().shift(paragraph.localToGlobal(Offset.zero));
    if (avoid != null) inside(paintBounds, rect);
    expect(rect.left, greaterThanOrEqualTo(bounds.left - 0.001), reason: text);
    expect(rect.right, lessThanOrEqualTo(bounds.right + 0.001), reason: text);
    if (avoid != null) disjoint(rect, avoid);
  }
  final widget = t.widget<RichText>(paragraphFinder);
  expect(widget.maxLines, isNull);
  expect(widget.softWrap, isTrue);
  expect(widget.overflow, isNot(TextOverflow.ellipsis));
}

void main() {
  test('minimum derives from five 48 dp cells and 12 dp source padding', () {
    expect(NavigationSourceSpec.engineering['destinationCount'], 5);
    expect(NavigationSourceSpec.engineeringMetric('minimumHitWidth'), 48);
    for (final theme in Brightness.values) {
      final spec = NavigationBarSpec.lookup(theme);
      expect(spec.padding('body').horizontal, 12);
      expect(NavigationLayout.minimumWidth(spec), 5 * 48 + 12);
    }
  });

  testWidgets('degenerate host and badge constraints never become negative', (
    t,
  ) async {
    final previousHandler = FlutterError.onError;
    final reports = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      if (details.exceptionAsString().startsWith(
        'Navigator Bar host contract violation:',
      )) {
        reports.add(details);
      } else {
        previousHandler!(details);
      }
    };
    try {
      for (final width in [0.0, 12.0, 20.0, 100.0]) {
        await t.pumpWidget(
          fixture(
            width: width,
            scale: 1,
            theme: Brightness.dark,
            fa: false,
            destinations: items(Brightness.dark, false, 'source'),
            selected: 'home',
            onSelected: (_) {},
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        expect(find.byType(ErrorWidget), findsNothing);
        expect(find.byType(AssetAppIcon), findsNWidgets(5));
        expect(t.getSize(part('content')).width, width);
      }
      expect(reports.length, kReleaseMode ? 0 : 4);
    } finally {
      FlutterError.onError = previousHandler;
    }
  });

  testWidgets(
    'diagnostic is deferred, deduplicated across rebuilds and width revisits',
    (t) async {
      final reports = <FlutterErrorDetails>[];
      final previousHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().startsWith(
          'Navigator Bar host contract violation:',
        )) {
          // A diagnostic cannot substitute an ErrorWidget for navigation.
          expect(part('content'), findsOneWidget);
          reports.add(details);
        } else {
          previousHandler!(details);
        }
      };
      try {
        final destinations = items(Brightness.dark, false, 'source');
        for (final (width, count) in [
          (251.0, 1),
          (251.0, 1),
          (200.0, 2),
          (252.0, 2),
          (402.0, 2),
          (251.0, 2),
          (200.0, 2),
        ]) {
          await t.pumpWidget(
            fixture(
              width: width,
              scale: 1,
              theme: Brightness.dark,
              fa: false,
              destinations: destinations,
              selected: 'home',
              onSelected: (_) {},
            ),
          );
          await t.pumpAndSettle();
          expect(reports.length, kReleaseMode ? 0 : count);
          expect(t.takeException(), isNull);
          expect(find.byType(ErrorWidget), findsNothing);
          final identity = t
              .widgetList<ElementIdentity>(find.byType(ElementIdentity))
              .singleWhere((w) => w.componentId == 'navigation.bar');
          final resolved = (identity.resolved['bar'] as Map)['value'] as Map;
          expect((resolved['layout'] as Map)['itemWidth'], (width - 12) / 5);
        }
        expect(
          reports.map((r) => r.exceptionAsString()),
          kReleaseMode
              ? isEmpty
              : [
                  contains('received width 251.0'),
                  contains('received width 200.0'),
                ],
        );
      } finally {
        FlutterError.onError = previousHandler;
      }
    },
  );

  for (final width in [252.0, 251.0, 200.0, 402.0]) {
    for (final fa in [false, true]) {
      for (final scale in [1.0, 1.3]) {
        for (final theme in Brightness.values) {
          for (final badges in ['none', 'source', 'stress']) {
            testWidgets(
              '$width ${fa ? "fa RTL" : "en LTR"} $scale ${theme.name} $badges: all selections',
              (t) async {
                t.view.physicalSize = const Size(1200, 1600);
                t.view.devicePixelRatio = 1;
                addTearDown(t.view.resetPhysicalSize);
                addTearDown(t.view.resetDevicePixelRatio);
                final semantics = t.ensureSemantics();
                final diagnostics = <FlutterErrorDetails>[];
                final previousHandler = FlutterError.onError;
                FlutterError.onError = (details) {
                  if (details.exception is FlutterError &&
                      details.exceptionAsString().startsWith(
                        'Navigator Bar host contract violation:',
                      )) {
                    diagnostics.add(details);
                  } else {
                    previousHandler!(details);
                  }
                };
                try {
                  final destinations = items(theme, fa, badges);
                  Map<String, Rect>? previousGeometry;
                  for (final selected in destinations) {
                    final events = <String>[];
                    await t.pumpWidget(
                      fixture(
                        width: width,
                        scale: scale,
                        theme: theme,
                        fa: fa,
                        destinations: destinations,
                        selected: selected.id,
                        onSelected: events.add,
                      ),
                    );
                    await t.pumpAndSettle();
                    expect(
                      diagnostics.length,
                      !kReleaseMode && width < 252 ? 1 : 0,
                    );
                    if (diagnostics.isNotEmpty) {
                      expect(
                        diagnostics.single.exceptionAsString(),
                        contains('received width $width'),
                      );
                      expect(
                        diagnostics.single.exceptionAsString(),
                        contains('minimum width is 252'),
                      );
                    }
                    expect(t.takeException(), isNull);
                    final content = t.getRect(part('content'));
                    expect(content.width, width);
                    expect(find.byType(Scrollable), findsNothing);
                    expect(find.byType(AssetAppIcon), findsNWidgets(5));
                    final geometry = <String, Rect>{};
                    final hits = <Rect>[];
                    for (final d in destinations) {
                      final hit = t.getRect(part('${d.id}.hit'));
                      final indicator = t.getRect(part('${d.id}.indicator'));
                      final icon = t.getRect(part('${d.id}.icon'));
                      final label = t.getRect(part('${d.id}.label'));
                      expect(hit.width, closeTo((width - 12) / 5, 0.001));
                      expect(hit.width < 48, width < 252);
                      expect(hit.height, greaterThanOrEqualTo(48));
                      inside(content, hit);
                      inside(hit, indicator);
                      inside(indicator, icon);
                      inside(hit, label);
                      disjoint(label, indicator);
                      expect(icon.width, closeTo(24, 0.001));
                      expect(icon.height, closeTo(24, 0.001));
                      expect(
                        indicator.width,
                        closeTo(hit.width.clamp(0, 64), 0.001),
                      );
                      expect(
                        icon.center.dx,
                        closeTo(indicator.center.dx, 0.001),
                      );
                      expect(
                        icon.center.dy,
                        closeTo(indicator.center.dy, 0.001),
                      );
                      textFits(t, part('${d.id}.label'), hit, avoid: indicator);
                      for (final earlier in hits) {
                        disjoint(hit, earlier);
                        disjoint(label, earlier);
                        disjoint(indicator, earlier);
                      }
                      hits.add(hit);
                      geometry.addAll({
                        '${d.id}.hit': hit,
                        '${d.id}.indicator': indicator,
                        '${d.id}.icon': icon,
                        '${d.id}.label': label,
                      });
                      if (d.badge != null) {
                        final badge = t.getRect(part('${d.id}.badge'));
                        final pill = t.getRect(part('${d.id}.badge.pill'));
                        inside(indicator, badge);
                        inside(badge, pill);
                        inside(content, badge);
                        expect(badge.top, indicator.top);
                        // Source badges occupy the icon's end corner; growing
                        // badges move inward without escaping their own cell.
                        final offset = (indicator.width / 2).clamp(
                          0.0,
                          indicator.width - badge.width,
                        );
                        expect(
                          fa
                              ? indicator.right - badge.right
                              : badge.left - indicator.left,
                          closeTo(offset, 0.001),
                        );
                        textFits(t, part('${d.id}.badge.pill'), badge);
                        geometry['${d.id}.badge'] = badge;
                      } else {
                        expect(part('${d.id}.badge'), findsNothing);
                      }
                      final node = t.getSemantics(
                        find.bySemanticsLabel(d.label),
                      );
                      final data = node.getSemanticsData();
                      expect(data.label, d.label);
                      expect(data.value, d.badge?.semanticLabel ?? '');
                      expect(data.role, SemanticsRole.tab);
                      expect(
                        data.flagsCollection.isSelected,
                        d.id == selected.id
                            ? Tristate.isTrue
                            : Tristate.isFalse,
                      );
                      // Probe the four corners of every full-item hit region,
                      // including space outside the visible icon and label.
                      for (final point in [
                        hit.topLeft + const Offset(1, 1),
                        hit.topRight + const Offset(-1, 1),
                        hit.bottomLeft + const Offset(1, -1),
                        hit.bottomRight + const Offset(-1, -1),
                      ]) {
                        await t.tapAt(point);
                        await t.pumpAndSettle();
                        expect(events.removeLast(), d.id);
                        expect(events, isEmpty);
                      }
                    }
                    expect(hits.first.left < hits.last.left, !fa);
                    if (previousGeometry != null) {
                      expect(
                        geometry,
                        previousGeometry,
                        reason: 'Selection must preserve every item/label/icon/badge rect',
                      );
                    }
                    previousGeometry = geometry;
                    expect(t.takeException(), isNull);
                  }
                } finally {
                  FlutterError.onError = previousHandler;
                  semantics.dispose();
                }
              },
            );
          }
        }
      }
    }
  }
}
