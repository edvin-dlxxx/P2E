import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import 'viewer_style.dart';

/// Viewer chrome ThemeData. Specimen boards build their own themed windows
/// (AppThemeFactory + ButtonThemeTokens); this theme only dresses the shell,
/// the rail, toolbars and the inspector with Design System token values.
abstract final class ViewerTheme {
  static ThemeData build({bool persian = false}) {
    final outline = ViewerStyle.hairline;
    final ink = ViewerStyle.ink;
    final dim = ViewerStyle.scrim(.64);
    final disabled = ViewerStyle.inkDisabled;
    final fieldFill = ViewerStyle.panel;
    final radius = Radius.circular(ViewerStyle.radiusField);
    final scheme = ColorScheme.dark(
      primary: ink,
      onPrimary: ViewerStyle.panel,
      surface: ViewerStyle.canvas,
      onSurface: ink,
      onSurfaceVariant: dim,
      outline: outline,
      outlineVariant: outline,
    );
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ViewerStyle.canvas,
      fontFamily: 'packages/p2e_design_system/Outfit',
      fontFamilyFallback: BundledTypography.persianFallback,
      extensions: [ButtonThemeTokens.forBrightness(Brightness.dark)],
      dividerColor: outline,
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: ink,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: dim,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: dim,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ViewerStyle.canvas,
        foregroundColor: ink,
        surfaceTintColor: ViewerStyle.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        isDense: true,
        hintStyle: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: disabled,
        ),
        labelStyle: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: dim,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: dim,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(radius),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(radius),
          borderSide: BorderSide(color: ViewerStyle.scrim(.45), width: 1.4),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(radius),
          borderSide: BorderSide(color: outline),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: fieldFill,
        selectedColor: ViewerStyle.highlight.withValues(alpha: .14),
        checkmarkColor: ink,
        labelStyle: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: ink,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: dim,
        ),
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(ViewerStyle.spaceS + 2),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: ViewerStyle.scrim(.85),
        inactiveTrackColor: outline,
        thumbColor: ink,
        overlayColor: ViewerStyle.scrim(.1),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ViewerStyle.highlight.withValues(alpha: .12),
        contentTextStyle: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: ink,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(radius)),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(
          fontFamily: persian ? BundledTypography.persianFamily : null,
          color: ink,
        ),
      ),
      iconTheme: IconThemeData(color: dim),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ink,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(radius)),
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: ViewerStyle.panel),
    );
  }
}
