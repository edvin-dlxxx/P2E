import 'bundled_typography.dart';

import 'package:flutter/material.dart';

import '../tokens/generated/product_skin.g.dart';
import '../tokens/generated/skin_roles.g.dart';
import 'skin_theme.dart';
import 'button_theme_tokens.dart';

abstract final class AppThemeFactory {
  static final _themes = <(SkinDefinition, Brightness), ThemeData>{};
  static ThemeData build({
    required Brightness brightness,
    SkinDefinition skin = productSkin,
  }) => _themes.putIfAbsent((skin, brightness), () {
    final source = ButtonThemeTokens.forBrightness(brightness);
    final product = ThemeData(
      brightness: brightness,
      fontFamilyFallback: BundledTypography.persianFallback,
      extensions: [source, SkinTheme(skin)],
    );
    if (identical(skin, productSkin)) return product;
    final roles = skin.valuesFor(brightness);
    final foreground = roles.color('On Surface/Emphasis');
    final background = roles.color('Surface/Base');
    return product.copyWith(
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: roles.color('Primary/Teal'),
        onPrimary: foreground,
        secondary: roles.color('Primary/Pink'),
        onSecondary: foreground,
        error: roles.color('Actions/Error/On Surface'),
        onError: foreground,
        surface: background,
        onSurface: foreground,
        outline: roles.color('Outline/Base'),
      ),
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: background,
      dividerColor: roles.color('Outline/Variant'),
      textTheme: product.textTheme.apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),
      extensions: [
        SkinTheme(skin),
        source.copyWith(colors: roles.byName),
      ],
    );
  });
}
