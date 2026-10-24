import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../../tokens/app_bar_spec.dart';
import 'app_bar_configuration.dart';

/// Pure text measurement and constraint policy, shared with Viewer diagnostics.
class AppBarLayout {
  const AppBarLayout({
    required this.minimumWidth,
    required this.canvasWidth,
    required this.walletWidth,
    required this.pointsWidth,
    required this.coinsWidth,
    required this.pillHeight,
    required this.points,
    required this.coins,
    required this.showUnit,
    required this.compact,
    required this.scrolls,
  });
  final double minimumWidth, canvasWidth, walletWidth, pointsWidth, coinsWidth;
  final double pillHeight;
  final String points, coins;
  final bool showUnit, compact, scrolls;

  static double textWidth(String value, TextStyle style, TextScaler scaler) {
    final p = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
    )..layout();
    final tracking =
        (style.letterSpacing ?? 0) *
        scaler.scale(style.fontSize!) /
        style.fontSize!;
    final width = (p.width - tracking).ceilToDouble();
    p.dispose();
    return math.max(0, width);
  }

  static AppBarLayout resolve({
    required AppBarSpec spec,
    required AppBarConfiguration configuration,
    required double width,
    required TextScaler scaler,
    bool persian = false,
  }) {
    final home = configuration is HomeAppBar ? configuration : null;
    String points = home?.wallet.points ?? '', coins = home?.wallet.coins ?? '';
    bool showUnit = home?.wallet.unit.isNotEmpty ?? false, compact = false;
    double pw = 0, cw = 0, ww = 0;
    void measure() {
      if (home == null) return;
      pw =
          spec.padding('points').horizontal +
          spec.metric('pointsIcon', 'width') +
          spec.metric('points', 'itemSpacing') +
          textWidth(
            points,
            spec.textStyle('pointsValue', persian: persian),
            scaler,
          ) +
          (showUnit
              ? spec.metric('pointsAmount', 'itemSpacing') +
                    textWidth(
                      home.wallet.unit,
                      spec.textStyle('pointsUnit', persian: persian),
                      scaler,
                    )
              : 0);
      cw =
          spec.padding('coins').horizontal +
          spec.metric('coinsIcon', 'width') +
          2 * spec.metric('coins', 'itemSpacing') +
          math.max(
            spec.metric('coinsAmount', 'width'),
            textWidth(
              coins,
              spec.textStyle('coinsValue', persian: persian),
              scaler,
            ),
          ) +
          spec.metric('addSurface', 'width');
      ww = pw + spec.metric('wallet', 'itemSpacing') + cw;
    }

    measure();
    final fixed =
        spec.horizontalPadding * 2 +
        spec.actionExtent * (configuration is DownloadableGameAppBar ? 4 : 2);
    if (home?.wallet.compact case final CompactAppBarWallet alternative
        when ww + fixed > width) {
      points = alternative.points;
      coins = alternative.coins;
      showUnit = alternative.showUnit && home!.wallet.unit.isNotEmpty;
      compact = true;
      measure();
    }
    final minimum = fixed + ww;
    final pillHeight = home == null
        ? 0.0
        : math.max(
            spec.metric('points', 'height'),
            scaler.scale(spec.metric('pointsValue', 'fontSize')) *
                    spec.textStyle('pointsValue').height! +
                spec.padding('points').vertical,
          );
    return AppBarLayout(
      minimumWidth: minimum,
      canvasWidth: math.max(width, minimum),
      walletWidth: ww,
      pointsWidth: pw,
      coinsWidth: cw,
      pillHeight: pillHeight,
      points: points,
      coins: coins,
      showUnit: showUnit,
      compact: compact,
      scrolls: minimum > width,
    );
  }

  Map<String, Object?> toJson() => {
    'pillHeight': pillHeight,
    'minimumWidth': minimumWidth,
    'canvasWidth': canvasWidth,
    'walletWidth': walletWidth,
    'pointsWidth': pointsWidth,
    'coinsWidth': coinsWidth,
    'displayedPoints': points,
    'displayedCoins': coins,
    'unitVisible': showUnit,
    'compact': compact,
    'horizontalScroll': scrolls,
  };
}
