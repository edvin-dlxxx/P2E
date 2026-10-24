import 'package:flutter/painting.dart';

import '../theme/bundled_typography.dart';

/// One Figma variable, retaining its original collection and mode identities.
class FigmaColorToken {
  const FigmaColorToken({
    required this.id,
    required this.name,
    required this.collectionId,
    required this.collectionName,
    required this.defaultModeId,
    required this.valuesByMode,
  });

  final String id;
  final String name;
  final String collectionId;
  final String collectionName;
  final String defaultModeId;
  final Map<String, Color> valuesByMode;

  Color get value => valuesByMode[defaultModeId]!;
}

/// Raw, unit-bearing typography and its separately converted Flutter style.
class FigmaTextToken {
  const FigmaTextToken({
    required this.id,
    required this.name,
    required this.rawTypography,
    required TextStyle style,
    // D-048: preserve the generated public `style:` argument while storing raw
    // source data privately; a private initializing formal would change that API.
    // ignore: prefer_initializing_formals
  }) : _style = style;

  final String id;
  final String name;
  final Map<String, Object?> rawTypography;
  final TextStyle _style;
  TextStyle get style => BundledTypography.resolve(_style);
}
