import 'package:flutter/painting.dart';

/// D-048: resolve bundled family names once, without changing source metrics.
/// Outfit remains the Latin primary; existing Persian-aware resolvers keep
/// Vazirmatn primary. All other Persian runs/digits use the bundled fallback.
abstract final class BundledTypography {
  static const packagePrefix = 'packages/p2e_design_system/';
  static const outfitFamily = '${packagePrefix}Outfit';
  static const persianFamily = '${packagePrefix}Vazirmatn';
  static const persianFallback = [persianFamily];

  static String family({bool persian = false}) =>
      persian ? persianFamily : outfitFamily;

  static String _canonical(String name) {
    while (name.startsWith('$packagePrefix$packagePrefix')) {
      name = name.substring(packagePrefix.length);
    }
    return name;
  }

  /// Reconstruct rather than copyWith: Flutter retains the private `package`
  /// in copyWith, which would prefix an already-qualified fallback again.
  static TextStyle resolve(TextStyle style) => TextStyle(
    inherit: style.inherit,
    color: style.color,
    backgroundColor: style.backgroundColor,
    fontFamily: style.fontFamily == null ? null : _canonical(style.fontFamily!),
    fontFamilyFallback: {
      ...?style.fontFamilyFallback?.map(_canonical),
      persianFamily,
    }.toList(growable: false),
    fontSize: style.fontSize,
    fontWeight: style.fontWeight,
    fontStyle: style.fontStyle,
    letterSpacing: style.letterSpacing,
    wordSpacing: style.wordSpacing,
    textBaseline: style.textBaseline,
    height: style.height,
    leadingDistribution: style.leadingDistribution,
    locale: style.locale,
    foreground: style.foreground,
    background: style.background,
    shadows: style.shadows,
    fontFeatures: style.fontFeatures,
    // D-059: Outfit has real static faces. No variable-axis/faux-weight request.
    fontVariations: style.fontFamily?.endsWith('Outfit') == true
        ? style.fontVariations?.where((v) => v.axis != 'wght').toList()
        : style.fontVariations,
    decoration: style.decoration,
    decorationColor: style.decorationColor,
    decorationStyle: style.decorationStyle,
    decorationThickness: style.decorationThickness,
    debugLabel: style.debugLabel,
    overflow: style.overflow,
  );
}
