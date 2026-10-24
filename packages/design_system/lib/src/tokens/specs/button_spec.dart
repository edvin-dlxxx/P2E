import 'package:flutter/material.dart';

import '../../theme/button_theme_tokens.dart';
import '../generated/button_tokens.g.dart';
import 'generated/app_button_spec.g.dart';

enum AppButtonFamily { hug, fill, icon }

enum AppButtonSize { small, medium, large }

enum AppButtonType { filled, tonal, outlined, text, disabled }

/// D-056: accent is a provisional screen-instance color role, not a new source row.
enum AppButtonTone { source, accent }

/// Figma: none = Icon:false; fill/outline = Icon:true and one visible child.
enum ButtonIconMode { none, fill, outline }

/// Typed access to the generated source contract; no copied visual defaults.
class ButtonSpec {
  const ButtonSpec(this.data);
  final Map<String, dynamic> data;

  static List<ButtonSpec> get all => [
    for (final row in appButtonSpecData['variants'] as List)
      ButtonSpec(row as Map<String, dynamic>),
  ];

  static ButtonSpec lookup({
    required AppButtonFamily family,
    required AppButtonSize size,
    required AppButtonType type,
    required Brightness brightness,
  }) => all.singleWhere(
    (s) =>
        s.family == family &&
        s.size == size &&
        s.type == type &&
        s.brightness == brightness,
  );

  String get id => data['variantId'] as String;
  String get setId => data['componentSetId'] as String;
  String get rawName => data['rawName'] as String;
  String get setName => data['componentSetName'] as String;
  AppButtonFamily get family => AppButtonFamily.values.byName(data['family']);
  AppButtonSize get size => AppButtonSize.values.byName(data['size']);
  AppButtonType get type => AppButtonType.values.byName(data['type']);
  Brightness get brightness => Brightness.values.byName(data['mode']);
  Map get geometry => data['geometry'] as Map;
  double metric(String key) => (geometry[key] as num).toDouble();
  double get width => metric('width');
  double get height => metric('height');
  // D-059: fixed Figma frame wins over conflicting padding (E-011 resolved).
  double get minimumVisualHeight =>
      (data['runtimeGeometry']['minimumVisualHeight'] as num).toDouble();
  double minimumHeightFor(ButtonIconMode mode) {
    return height;
  }

  double get gap => metric('itemSpacing');
  double get opacity => (data['opacity'] as num).toDouble();
  double get iconWidth => (data['icon']['geometry']['width'] as num).toDouble();
  double get iconHeight =>
      (data['icon']['geometry']['height'] as num).toDouble();
  bool get hasText => data['text'] != null;
  bool get hasHeightConflict => data['heightPaddingConflict'] as bool;
  EdgeInsetsDirectional get padding => EdgeInsetsDirectional.only(
    start: metric('paddingLeft'),
    top: metric('paddingTop'),
    end: metric('paddingRight'),
    bottom: metric('paddingBottom'),
  );
  BorderRadiusDirectional get radius => BorderRadiusDirectional.only(
    topStart: Radius.circular(metric('topLeftRadius')),
    topEnd: Radius.circular(metric('topRightRadius')),
    bottomStart: Radius.circular(metric('bottomLeftRadius')),
    bottomEnd: Radius.circular(metric('bottomRightRadius')),
  );
  EdgeInsetsDirectional get visualPadding =>
      EdgeInsetsDirectional.only(start: padding.start, end: padding.end);
  TextStyle? get textStyle => hasText
      ? TypographyTokens.byId[data['text']['style']['id']]!.style
      : null;

  Color? paint(List paints, ButtonThemeTokens tokens) {
    final visible = paints.where((p) => p['visible'] != false);
    if (visible.isEmpty) return null;
    if (visible.length != 1) throw StateError('Multiple paint layers: $id');
    final p = visible.single as Map;
    if (p['type'] != 'SOLID') throw StateError('Unsupported paint: $id');
    final binding = p['boundVariables']?['color']?['id'];
    final Color value;
    if (binding != null) {
      final token = ColorTokens.allById[binding];
      if (token == null) throw StateError('Missing generated token: $binding');
      value = tokens.color(token.name);
    } else {
      // Owner-authorized unbound source paint; never promoted to a token.
      final c = p['color'] as Map;
      value = Color.from(
        alpha: (c['a'] as num? ?? 1).toDouble(),
        red: (c['r'] as num).toDouble(),
        green: (c['g'] as num).toDouble(),
        blue: (c['b'] as num).toDouble(),
      );
    }
    return value.withValues(alpha: value.a * (p['opacity'] as num).toDouble());
  }

  ResolvedButtonStyle resolve(
    ButtonThemeTokens tokens, {
    ButtonIconMode iconMode = ButtonIconMode.none,
    Color? backgroundColor,
    Color? foregroundColor,
    Color? borderColor,
  }) {
    final sourceForeground = paint(
      hasText
          ? data['text']['fills']['raw'] as List
          : data['iconPaints'] as List,
      tokens,
    );
    final sourceIconColor = paint(
      data[iconMode == ButtonIconMode.outline
              ? 'outlineIconPaints'
              : 'iconPaints']
          as List,
      tokens,
    );
    if (sourceForeground == null || sourceIconColor == null) {
      throw StateError('Unresolved foreground: $id');
    }
    // ENGINEERING(D-029): source Light disabled foreground is nearly its fill.
    // Remap this component/state only; preserve caller overrides and raw tokens.
    final readabilityOverride =
        brightness == Brightness.light &&
        type == AppButtonType.disabled &&
        foregroundColor == null;
    final foreground =
        foregroundColor ??
        (readabilityOverride
            ? tokens.color('On Surface/Emphasis')
            : sourceForeground);
    final iconColor =
        foregroundColor ??
        (readabilityOverride
            ? tokens.color('On Surface/Emphasis')
            : sourceIconColor);
    final stroke = paint(data['strokes'] as List, tokens);
    return ResolvedButtonStyle(
      spec: this,
      iconMode: iconMode,
      background: backgroundColor ?? paint(data['fills'] as List, tokens),
      foreground: foreground,
      iconColor: iconColor,
      sourceForeground: sourceForeground,
      sourceIconColor: sourceIconColor,
      readabilityOverride: readabilityOverride,
      border: stroke == null
          ? BorderSide.none
          : BorderSide(
              color: borderColor ?? stroke,
              width: metric('strokeWeight'),
              strokeAlign: switch (geometry['strokeAlign']) {
                'INSIDE' => BorderSide.strokeAlignInside,
                'CENTER' => BorderSide.strokeAlignCenter,
                'OUTSIDE' => BorderSide.strokeAlignOutside,
                _ => throw StateError('Unsupported border alignment: $id'),
              },
            ),
    );
  }
}

class ResolvedButtonStyle {
  const ResolvedButtonStyle({
    required this.spec,
    this.iconMode = ButtonIconMode.none,
    required this.background,
    required this.foreground,
    required this.iconColor,
    required this.border,
    required this.sourceForeground,
    required this.sourceIconColor,
    required this.readabilityOverride,
  });
  final ButtonSpec spec;
  final ButtonIconMode iconMode;
  final Color? background;
  final Color foreground;
  final Color iconColor;
  final BorderSide border;
  final Color sourceForeground, sourceIconColor;
  final bool readabilityOverride;
  Map<String, Object?>? get engineeringOverride => readabilityOverride
      ? {
          'decision': 'D-029',
          'token': 'On Surface/Emphasis',
          'sourceForeground': sourceForeground.toARGB32(),
          'sourceIconColor': sourceIconColor.toARGB32(),
          'effectiveForeground': foreground.toARGB32(),
          'effectiveIconColor': iconColor.toARGB32(),
          'background': background?.toARGB32(),
          'componentOpacity': spec.opacity,
          'reason': 'Light disabled source foreground has insufficient separation from its fill',
        }
      : null;

  ButtonStyle get material => ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(background),
    foregroundColor: WidgetStatePropertyAll(foreground),
    textStyle: WidgetStatePropertyAll(spec.textStyle),
    minimumSize: WidgetStatePropertyAll(
      Size(
        spec.family == AppButtonFamily.icon ? spec.width : 0,
        spec.minimumHeightFor(iconMode),
      ),
    ),
    maximumSize: const WidgetStatePropertyAll(Size.infinite),
    // Fixed source frames center the row; source vertical padding conflicts.
    padding: WidgetStatePropertyAll(spec.visualPadding),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: spec.radius),
    ),
    side: WidgetStatePropertyAll(border),
    // Empty effects/reactions in the source: no invented shadow/state motion.
    elevation: const WidgetStatePropertyAll(0),
    overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0)),
    shadowColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0)),
    surfaceTintColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0)),
    splashFactory: NoSplash.splashFactory,
    animationDuration: Duration.zero,
    visualDensity: VisualDensity.standard,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    alignment: AlignmentDirectional.center,
  );
}
