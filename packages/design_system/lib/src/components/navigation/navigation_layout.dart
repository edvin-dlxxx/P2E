import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../tokens/navigation_spec.dart';
import 'navigation_destination.dart';

class NavigationBadgeLayout {
  const NavigationBadgeLayout({
    required this.width,
    required this.pillHeight,
    required this.wrapperHeight,
    required this.start,
  });
  final double width, pillHeight, wrapperHeight, start;
  Map<String, Object?> toJson() => {
    'width': width,
    'pillHeight': pillHeight,
    'wrapperHeight': wrapperHeight,
    'start': start,
  };
}

class NavigationLayout {
  const NavigationLayout({
    required this.itemWidth,
    required this.indicatorWidth,
    required this.indicatorHeight,
    required this.labelHeight,
    required this.contentHeight,
    required this.badges,
  });
  final double itemWidth,
      indicatorWidth,
      indicatorHeight,
      labelHeight,
      contentHeight;
  final Map<String, NavigationBadgeLayout> badges;
  static double minimumWidth(NavigationBarSpec spec) =>
      spec.padding('body').horizontal +
      NavigationSourceSpec.engineeringMetric('minimumHitWidth') *
          (NavigationSourceSpec.engineering['destinationCount'] as int);
  static Size measure(
    String text,
    TextStyle style,
    TextScaler scaler,
    double width,
  ) {
    final p = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout(maxWidth: math.max(0, width));
    final result = p.size;
    p.dispose();
    return result;
  }

  static NavigationLayout resolve({
    required NavigationBarSpec spec,
    required List<AppNavigationDestination> destinations,
    required double width,
    required TextScaler scaler,
    bool persian = false,
  }) {
    if (!width.isFinite) {
      throw ArgumentError(
        'Navigator Bar needs bounded width >= ${minimumWidth(spec)}; no scrolling or hidden destinations',
      );
    }
    // D-036: host misuse must not remove navigation in release builds.
    return _forItems(
      spec: NavigationItemSpec.lookup(
        spec.brightness,
        AppNavigationItemState.inactive,
      ),
      destinations: destinations,
      itemWidth:
          math.max(0, width - spec.padding('body').horizontal) /
          destinations.length,
      scaler: scaler,
      persian: persian,
    );
  }

  static NavigationLayout forItems({
    required NavigationItemSpec spec,
    required List<AppNavigationDestination> destinations,
    required double itemWidth,
    required TextScaler scaler,
    bool persian = false,
  }) {
    if (!itemWidth.isFinite ||
        itemWidth < NavigationSourceSpec.engineeringMetric('minimumHitWidth')) {
      throw ArgumentError('Navigation item needs at least 48 logical units');
    }
    return _forItems(
      spec: spec,
      destinations: destinations,
      itemWidth: itemWidth,
      scaler: scaler,
      persian: persian,
    );
  }

  static NavigationLayout _forItems({
    required NavigationItemSpec spec,
    required List<AppNavigationDestination> destinations,
    required double itemWidth,
    required TextScaler scaler,
    required bool persian,
  }) {
    final indicatorWidth = math.min(
      spec.metric('indicator', 'width'),
      itemWidth,
    );
    double labelHeight = spec.metric('labelFrame', 'height'),
        indicatorHeight = spec.metric('indicator', 'height');
    final badges = <String, NavigationBadgeLayout>{};
    for (final d in destinations) {
      labelHeight = math.max(
        labelHeight,
        measure(
          d.label,
          spec.textStyle('label', persian: persian),
          scaler,
          itemWidth,
        ).height.ceilToDouble(),
      );
      if (d.badge case final AppNavigationBadge badge) {
        final natural = measure(
          badge.label,
          spec.textStyle('badgeLabel', persian: persian),
          scaler,
          double.infinity,
        );
        final bw = math.min(
          indicatorWidth,
          math.max(
            spec.metric('pill', 'width'),
            natural.width.ceilToDouble() + 2 * spec.badgeInlineAllowance,
          ),
        );
        final text = measure(
          badge.label,
          spec.textStyle('badgeLabel', persian: persian),
          scaler,
          bw - 2 * spec.badgeInlineAllowance,
        );
        final bh = math.max(
          spec.metric('pill', 'height'),
          text.height.ceilToDouble() +
              spec.metric('pill', 'height') -
              spec.metric('badgeLabel', 'height'),
        );
        final wrapper =
            bh + spec.metric('badge', 'height') - spec.metric('pill', 'height');
        badges[d.id] = NavigationBadgeLayout(
          width: bw,
          pillHeight: bh,
          wrapperHeight: wrapper,
          start: math.min(indicatorWidth / 2, indicatorWidth - bw),
        );
        indicatorHeight = math.max(indicatorHeight, wrapper);
      }
    }
    return NavigationLayout(
      itemWidth: itemWidth,
      indicatorWidth: indicatorWidth,
      indicatorHeight: indicatorHeight,
      labelHeight: labelHeight,
      contentHeight:
          spec.padding('body').vertical +
          indicatorHeight +
          spec.metric('body', 'itemSpacing') +
          labelHeight,
      badges: Map.unmodifiable(badges),
    );
  }

  Map<String, Object?> toJson() => {
    'itemWidth': itemWidth,
    'indicatorWidth': indicatorWidth,
    'indicatorHeight': indicatorHeight,
    'labelHeight': labelHeight,
    'contentHeight': contentHeight,
    'badges': {for (final e in badges.entries) e.key: e.value.toJson()},
  };
}
