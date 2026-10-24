import '../theme/bundled_typography.dart';
import '../theme/skin_theme.dart';
import 'generated/skin_roles.g.dart';

import 'package:flutter/material.dart';

import '../icons/app_icon.dart';
import '../icons/icon_registry.dart';
import '../theme/button_theme_tokens.dart';
import 'generated/badge_data.g.dart';

enum BadgeSize { small, medium, large }

enum BadgeAppearance { filled, tonal, outlined, text, disabled }

enum BadgeIconMode { none, fill, outline }

/// Typed immutable source registry; appearance is independent of icon style.
class BadgeSpec {
  const BadgeSpec(this.data, {this.skin});
  final SkinDefinition? skin;
  BadgeSpec withSkin(SkinDefinition value) => BadgeSpec(data, skin: value);
  final Map<String, dynamic> data;
  String get identityKey =>
      '${brightness.name}.${size.name}.${appearance.name}';
  static final all = List<BadgeSpec>.unmodifiable([
    for (final row in badgeSourceData['rows'] as List)
      BadgeSpec(row as Map<String, dynamic>),
  ]);
  static final _byVariant = {
    for (final s in all) (s.size, s.appearance, s.brightness): s,
  };
  static final _variables = {
    for (final v in badgeSourceData['foundations']['variables'] as List)
      v['id']: v,
  };
  static BadgeSpec lookup(
    BadgeSize size,
    BadgeAppearance appearance,
    Brightness brightness,
  ) =>
      _byVariant[(size, appearance, brightness)] ??
      (throw StateError('Missing Badge source combination'));
  BadgeSize get size => BadgeSize.values.byName(data['size'] as String);
  BadgeAppearance get appearance =>
      BadgeAppearance.values.byName(data['appearance'] as String);
  Brightness get brightness =>
      Brightness.values.byName(data['brightness'] as String);
  String get id => data['id'] as String;
  String get setId => data['setId'] as String;
  String get setName => data['setName'] as String;
  String get rawName => data['rawName'] as String;
  String get fileKey => data['fileKey'] as String;
  Map<String, dynamic> get body => data['body'] as Map<String, dynamic>;
  Map<String, dynamic> get labelFrame =>
      data['labelFrame'] as Map<String, dynamic>;
  Map<String, dynamic> get text => data['text'] as Map<String, dynamic>;
  Map<String, dynamic> get slot => data['iconSlot'] as Map<String, dynamic>;
  String get referenceLabel => text['characters'] as String;
  Size get sourceSize => Size(metric(body, 'width'), metric(body, 'height'));
  double get gap => metric(body, 'itemSpacing');
  double get opacity => metric(body, 'opacity');
  double get radius => metric(body, 'cornerRadius');
  double get iconWidth => metric(slot, 'width');
  double get iconHeight => metric(slot, 'height');
  double metric(Map node, String key) => (node[key] as num).toDouble();
  EdgeInsetsDirectional get padding => EdgeInsetsDirectional.fromSTEB(
    metric(body, 'paddingLeft'),
    metric(body, 'paddingTop'),
    metric(body, 'paddingRight'),
    metric(body, 'paddingBottom'),
  );
  Color? paint(Map node, String key) {
    final visible = (node[key] as List? ?? []).where(
      (p) => p['visible'] != false,
    );
    if (visible.isEmpty) return null;
    if (visible.length != 1 || visible.single['type'] != 'SOLID') {
      throw StateError('Unsupported Badge paint $id/$key');
    }
    final p = visible.single as Map,
        binding = p['boundVariables']?['color']?['id'];
    final c = binding == null
        ? p['color'] as Map
        : (_variables[binding]['valuesByMode'] as Map).values.single as Map;
    final source = Color.from(
      red: (c['r'] as num).toDouble(),
      green: (c['g'] as num).toDouble(),
      blue: (c['b'] as num).toDouble(),
      alpha:
          (c['a'] as num? ?? 1).toDouble() * (p['opacity'] as num).toDouble(),
    );
    return skinPaint(
      skin,
      brightness,
      source,
      role: binding == null ? null : _variables[binding]['name'] as String,
      opacity: (p['opacity'] as num? ?? 1).toDouble(),
    );
  }

  BorderSide border(Map node) {
    final color = paint(node, 'strokes');
    if (color == null) return BorderSide.none;
    return BorderSide(
      color: color,
      width: metric(node, 'strokeWeight'),
      strokeAlign: switch (node['strokeAlign']) {
        'INSIDE' => BorderSide.strokeAlignInside,
        'CENTER' => BorderSide.strokeAlignCenter,
        'OUTSIDE' => BorderSide.strokeAlignOutside,
        _ => throw StateError('Unsupported Badge stroke alignment'),
      },
    );
  }

  TextStyle textStyle({bool persian = false}) {
    final font = metric(text, 'fontSize'),
        line = text['lineHeight'] as Map,
        spacing = text['letterSpacing'] as Map;
    return TextStyle(
      fontFamily: BundledTypography.family(persian: persian),
      fontSize: font,
      fontWeight:
          FontWeight.values[(metric(text, 'fontWeight').toInt() ~/ 100) - 1],
      height: (line['value'] as num).toDouble() / font,
      letterSpacing:
          (spacing['value'] as num).toDouble() *
          (spacing['unit'] == 'PERCENT' ? font / 100 : 1),
      color: paint(text, 'fills'),
    );
  }

  Color? get sourceForegroundColor => paint(text, 'fills');

  /// ENGINEERING(D-029): the source Light disabled label color equals its
  /// background fill (On Surface/Disabled on Surface Container/Highest,
  /// both #d4d4d4). Remap this component/state only to the readable token;
  /// raw source paints stay surfaced in the Inspector evidence.
  bool get readabilityOverride =>
      brightness == Brightness.light && appearance == BadgeAppearance.disabled;

  Color? get effectiveForegroundColor => readabilityOverride
      ? (skin?.valuesFor(brightness).color('On Surface/Emphasis') ??
            ButtonThemeTokens.forBrightness(Brightness.light)
                .color('On Surface/Emphasis'))
      : sourceForegroundColor;

  TextStyle labelStyle({bool persian = false}) =>
      textStyle(persian: persian).copyWith(color: effectiveForegroundColor);

  Color? effectiveIconColor(BadgeIconMode mode) =>
      readabilityOverride && mode != BadgeIconMode.none
      ? (skin?.valuesFor(brightness).color('On Surface/Emphasis') ??
            ButtonThemeTokens.forBrightness(Brightness.light)
                .color('On Surface/Emphasis'))
      : iconColor(mode);

  Map<String, Object?>? engineeringOverride(BadgeIconMode iconMode) =>
      readabilityOverride
      ? {
          'decision': 'D-029',
          'token': 'On Surface/Emphasis',
          'sourceForeground': sourceForegroundColor?.toARGB32(),
          'sourceIconColor': iconColor(iconMode)?.toARGB32(),
          'effectiveForeground': effectiveForegroundColor?.toARGB32(),
          'effectiveIconColor': effectiveIconColor(iconMode)?.toARGB32(),
          'background': paint(body, 'fills')?.toARGB32(),
          'componentOpacity': opacity,
          'reason': 'Source Light disabled foreground has insufficient separation from its fill',
        }
      : null;

  Map<String, dynamic>? artwork(BadgeIconMode mode) =>
      mode == BadgeIconMode.none
      ? null
      : data['icons'][mode.name] as Map<String, dynamic>?;
  IconDefinition icon(BadgeIconMode mode) =>
      AppIconRegistry.byKey(artwork(mode)!['logicalKey'] as String);
  Color? iconColor(BadgeIconMode mode) => mode == BadgeIconMode.none
      ? null
      : paint({'fills': artwork(mode)!['paint']}, 'fills');
  Map<String, Object?> resolved({
    required BadgeIconMode iconMode,
    bool persian = false,
  }) {
    final font = textStyle(persian: persian),
        stroke = border(body),
        labelStroke = border(labelFrame);
    return {
      'background': paint(body, 'fills')?.toARGB32(),
      'foreground': effectiveForegroundColor?.toARGB32(),
      'opacity': opacity,
      'border': {
        'color': stroke.color.toARGB32(),
        'width': stroke.width,
        'alignment': body['strokeAlign'],
      },
      'labelFrameBorder': {
        'color': labelStroke.color.toARGB32(),
        'width': labelStroke.width,
        'alignment': labelFrame['strokeAlign'],
        'includedInLayout': true,
      },
      'radius': radius,
      'padding': {
        'start': padding.start,
        'top': padding.top,
        'end': padding.end,
        'bottom': padding.bottom,
      },
      'gap': iconMode == BadgeIconMode.none ? 0 : gap,
      'icon': artwork(iconMode),
      'iconColor': effectiveIconColor(iconMode)?.toARGB32(),
      'engineeringOverride': engineeringOverride(iconMode),
      'fontFamily': font.fontFamily,
      'fontSize': font.fontSize,
      'fontWeight': font.fontWeight?.value,
      'lineHeight': font.height! * font.fontSize!,
      'letterSpacing': font.letterSpacing,
      'textStyleId': text['textStyleId'],
      'presentational': true,
      'motion': 'none (no source reactions)',
    };
  }
}
