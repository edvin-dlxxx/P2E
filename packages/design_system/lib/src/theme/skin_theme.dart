import 'package:flutter/material.dart';

import '../tokens/generated/product_skin.g.dart';
import '../tokens/generated/skin_roles.g.dart';

/// Independent skin axis; source geometry, typography and identity stay intact.
class SkinTheme extends ThemeExtension<SkinTheme> {
  const SkinTheme(this.definition);
  final SkinDefinition definition;
  static SkinDefinition of(BuildContext context) =>
      Theme.of(context).extension<SkinTheme>()?.definition ?? productSkin;
  @override
  SkinTheme copyWith({SkinDefinition? definition}) =>
      SkinTheme(definition ?? this.definition);
  @override
  SkinTheme lerp(covariant SkinTheme? other, double t) =>
      t < .5 ? this : other ?? this;
}

/// Keep original source floats untouched for product. For alternate skins,
/// resolve by the bound raw role, never by matching a hex value. Unbound source
/// paints use the existing Outline/Variant role as an explicit diagnostic paint.
Color skinPaint(
  SkinDefinition? skin,
  Brightness brightness,
  Color source, {
  String? role,
  double opacity = 1,
}) {
  if (skin == null || identical(skin, productSkin)) return source;
  final color = skin.valuesFor(brightness).color(role ?? 'Outline/Variant');
  return color.withValues(alpha: color.a * opacity);
}
