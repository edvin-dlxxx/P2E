import '../theme/bundled_typography.dart';
import '../theme/skin_theme.dart';
import 'generated/skin_roles.g.dart';

import 'package:flutter/material.dart';

import '../icons/app_icon.dart';
import 'generated/app_bar_data.g.dart';
import 'button_motion.dart';

enum AppBarCategory { home, downloadableGame, back }

/// Generated source facts and a pure resolver. Theme is never a widget axis.
class AppBarSpec {
  const AppBarSpec(this.data, {this.skin});
  final SkinDefinition? skin;
  AppBarSpec withSkin(SkinDefinition value) => AppBarSpec(data, skin: value);
  final Map<String, dynamic> data;
  String get identityKey =>
      '${brightness.name}.${category.name == 'downloadableGame' ? 'downloadable-game' : category.name}';
  static final all = List<AppBarSpec>.unmodifiable([
    for (final row in appBarSourceData['rows'] as List)
      AppBarSpec(row as Map<String, dynamic>),
  ]);
  static final _byCategory = {
    for (final s in all) (s.category, s.brightness): s,
  };
  static final _variables = {
    for (final v in appBarSourceData['foundations']['variables'] as List)
      v['id']: v,
  };
  static final _styles = {
    for (final v in appBarSourceData['foundations']['styles'] as List)
      v['id']: v,
  };
  static AppBarSpec? lookup(AppBarCategory category, Brightness brightness) =>
      _byCategory[(category, brightness)];
  static Map<String, dynamic> get engineering =>
      appBarSourceData['engineering'] as Map<String, dynamic>;
  AppBarCategory get category => AppBarCategory.values.byName(data['category']);
  Brightness get brightness => Brightness.values.byName(data['brightness']);
  String get id => data['id'];
  String get fileKey => data['fileKey'];
  String get setId => data['setId'];
  String get setName => data['setName'];
  String get rawName => data['rawName'];
  Map<String, dynamic> part(String role) => data['parts'][role];
  double metric(String role, String key) => (part(role)[key] as num).toDouble();
  double get contentHeight => metric('body', 'height');
  double get actionExtent => metric('spacer', 'height');
  double get horizontalPadding => metric('body', 'paddingLeft');
  Size get sourceSize => Size(metric('body', 'width'), contentHeight);
  EdgeInsetsDirectional padding(String role) => EdgeInsetsDirectional.fromSTEB(
    metric(role, 'paddingLeft'),
    metric(role, 'paddingTop'),
    metric(role, 'paddingRight'),
    metric(role, 'paddingBottom'),
  );
  Color? paint(Map node) {
    final paints = (node['fills'] as List? ?? []).where(
      (p) => p['visible'] != false,
    );
    if (paints.isEmpty) return null;
    if (paints.length != 1 || paints.single['type'] != 'SOLID') {
      throw StateError('Unsupported App Bar paint');
    }
    final p = paints.single as Map;
    final variable = p['boundVariables']?['color']?['id'];
    final c = variable == null
        ? p['color'] as Map
        : (_variables[variable]['valuesByMode'] as Map).values.single as Map;
    final source = Color.from(
      red: (c['r'] as num).toDouble(),
      green: (c['g'] as num).toDouble(),
      blue: (c['b'] as num).toDouble(),
      alpha:
          (c['a'] as num? ?? 1).toDouble() *
          (p['opacity'] as num? ?? 1).toDouble(),
    );
    return skinPaint(
      skin,
      brightness,
      source,
      role: variable == null ? null : _variables[variable]['name'] as String,
      opacity: (p['opacity'] as num? ?? 1).toDouble(),
    );
  }

  Color? color(String role) => paint(part(role));
  Color? get previewBackground => paint(
    (appBarSourceData['backgrounds']['roots'] as List).firstWhere(
      (n) =>
          n['id'] ==
          (brightness == Brightness.dark ? '18437:9175' : '18422:11645'),
    ) as Map,
  );
  Map<String, dynamic> artwork(String role) => data['artwork'][role];
  IconDefinition icon(String role) =>
      AppIconRegistry.byKey(artwork(role)['logicalKey']);
  AppIconStyle iconStyle(String role) =>
      AppIconStyle.values.byName(artwork(role)['style']);
  Color? iconColor(String role) => paint(artwork(role)['paintNode']);
  double iconExtent(String role) =>
      (artwork(role)['geometry']['width'] as num).toDouble();
  TextStyle textStyle(String role, {bool persian = false}) {
    final n = part(role), font = metric(role, 'fontSize');
    final spacing = n['letterSpacing'] as Map, line = n['lineHeight'] as Map;
    return TextStyle(
      inherit: false,
      decoration: TextDecoration.none,
      fontFamily: BundledTypography.family(persian: persian),
      fontSize: font,
      fontWeight:
          FontWeight.values[(n['fontWeight'] as num).toInt() ~/ 100 - 1],
      height: (line['value'] as num).toDouble() / font,
      letterSpacing:
          (spacing['value'] as num).toDouble() *
          (spacing['unit'] == 'PERCENT' ? font / 100 : 1),
      color: color(role),
    );
  }

  Map<String, Object?> resolved({bool persian = false}) => {
    'sourceStatus': 'source-backed DEVELOPMENT',
    'sourceAxis': data['sourceAxis'],
    'parts': {
      for (final role in (data['parts'] as Map).keys)
        role: {...part(role), 'resolvedFill': color(role)?.toARGB32()},
    },
    'icons': {
      for (final role in (data['artwork'] as Map).keys)
        role: {
          ...artwork(role),
          'effectiveTint': iconColor(role)?.toARGB32(),
          'mirrorInRtl': icon(role).mirrorInRtl,
        },
    },
    'typography': {
      for (final role in [
        'avatarText',
        'pointsValue',
        'pointsUnit',
        'coinsValue',
      ])
        if ((data['parts'] as Map).containsKey(role))
          role: {
            'fontFamily': textStyle(role, persian: persian).fontFamily,
            'fontSize': metric(role, 'fontSize'),
            'fontWeight': part(role)['fontWeight'],
            'lineHeight': part(role)['lineHeight'],
            'letterSpacing': part(role)['letterSpacing'],
            'sourceStyleId': part(role)['textStyleId'],
            'sourceStyleName': _styles[part(role)['textStyleId']]?['name'],
            'status': part(role)['textStyleId'] == ''
                ? 'source-unlinked provisional component typography'
                : 'source-linked',
            'scriptStatus': persian ? 'provisional R-003' : 'source',
          },
    },
    'sourceReactions': data['reactions'],
    'motion': {
      'pressedScale': ButtonMotion.pressedScale,
      'pressMs': ButtonMotion.pressDuration.inMilliseconds,
      'releaseMs': ButtonMotion.releaseDuration.inMilliseconds,
      'curve': ButtonMotion.curve.toString(),
      'origin': 'engineering D-021 / D-030, not Figma',
      'reduced': 'immediate rest',
    },
    'engineering': engineering,
    'unresolved': [
      'Back Light source variant',
      'designer version/approval',
      'Figma interaction/focus/motion states',
      if (persian) 'Persian typography R-003',
    ],
  };
}
