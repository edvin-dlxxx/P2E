import '../theme/bundled_typography.dart';
import '../theme/skin_theme.dart';
import 'generated/skin_roles.g.dart';

import 'package:flutter/material.dart';

import '../icons/app_icon.dart';
import 'button_motion.dart';
import 'generated/navigation_data.g.dart';

enum AppNavigationItemState { inactive, active }

abstract class NavigationSourceSpec {
  const NavigationSourceSpec(this.data, {this.skin});
  final SkinDefinition? skin;
  final Map<String, dynamic> data;
  String get id => data['id'];
  String get rawName => data['rawName'];
  String get setId => data['setId'];
  String get setName => data['setName'];
  String get fileKey => data['fileKey'];
  Brightness get brightness => Brightness.values.byName(data['brightness']);
  Map<String, dynamic> part(String role) => data['parts'][role];
  double metric(String role, String key) => (part(role)[key] as num).toDouble();
  Size get sourceSize =>
      Size(metric('body', 'width'), metric('body', 'height'));
  static Map<String, dynamic> get engineering =>
      navigationSourceData['engineering'];
  static double engineeringMetric(String key) =>
      (engineering[key] as num).toDouble();
  static final _variables = {
    for (final v in navigationSourceData['foundations']['variables'] as List)
      v['id']: v,
  };
  Color? paint(Map node) {
    final paints = (node['fills'] as List? ?? []).where(
      (p) => p['visible'] != false,
    );
    if (paints.isEmpty) return null;
    if (paints.length != 1 || paints.single['type'] != 'SOLID') {
      throw StateError('Unsupported navigation paint');
    }
    final p = paints.single as Map,
        binding = p['boundVariables']?['color']?['id'];
    final c = binding == null
        ? p['color'] as Map
        : (_variables[binding]['valuesByMode'] as Map).values.single as Map;
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
      role: binding == null ? null : _variables[binding]['name'] as String,
      opacity: (p['opacity'] as num? ?? 1).toDouble(),
    );
  }

  Color? color(String role) => paint(part(role));
  EdgeInsetsDirectional padding(String role) => EdgeInsetsDirectional.fromSTEB(
    metric(role, 'paddingLeft'),
    metric(role, 'paddingTop'),
    metric(role, 'paddingRight'),
    metric(role, 'paddingBottom'),
  );
  Map<String, Object?> resolved() => {
    'id': id,
    'rawName': rawName,
    'setId': setId,
    'setName': setName,
    'fileKey': fileKey,
    'sourceSize': sourceSize.toString(),
    'sourceProperties': data['sourceProperties'],
    'parts': {
      for (final role in (data['parts'] as Map? ?? {'body': data['body']}).keys)
        role: {...part(role), 'resolvedFill': color(role)?.toARGB32()},
    },
    'sourceReactions': data['reactions'] ?? part('body')['reactions'],
    'engineering': engineering,
    'motion': {
      'origin': 'engineering D-021 / D-031, not Figma',
      'pressScale': ButtonMotion.pressedScale,
      'pressMs': ButtonMotion.pressDuration.inMilliseconds,
      'releaseAndSelectionMs': ButtonMotion.releaseDuration.inMilliseconds,
      'curve': ButtonMotion.curve.toString(),
      'reduced': 'immediate',
    },
    'unresolved': [
      'named design version / approval',
      'official label and badge text style IDs',
      'Persian typography R-003',
    ],
  };
}

class NavigationBarSpec extends NavigationSourceSpec {
  const NavigationBarSpec(super.data, {super.skin});
  NavigationBarSpec withSkin(SkinDefinition value) =>
      NavigationBarSpec(data, skin: value);
  static final all = List<NavigationBarSpec>.unmodifiable([
    for (final r in navigationSourceData['bars'] as List) NavigationBarSpec(r),
  ]);
  static NavigationBarSpec lookup(Brightness brightness) =>
      all.firstWhere((s) => s.brightness == brightness);
  @override
  Map<String, dynamic> part(String role) => data['body'];
  List<NavigationReferenceDestination> get referenceDestinations => [
    for (final d in data['destinations'] as List)
      NavigationReferenceDestination(d),
  ];
  String get referenceSelectedId =>
      referenceDestinations.firstWhere((d) => d.active).id;
}

class NavigationReferenceDestination {
  const NavigationReferenceDestination(this.data);
  final Map<String, dynamic> data;
  String get id => data['technicalId'];
  String get label => data['label'];
  String get sourceInstanceId => data['id'];
  bool get active => data['state'] == 'active';
  AppIconId get icon => AppIconRegistry.byKey(data['artwork']['logicalKey']).id;
  String? get badge => data['parts']['badge']['visible'] == false
      ? null
      : data['parts']['badgeLabel']['characters'];
}

class NavigationItemSpec extends NavigationSourceSpec {
  const NavigationItemSpec(super.data, {super.skin});
  NavigationItemSpec withSkin(SkinDefinition value) =>
      NavigationItemSpec(data, skin: value);
  static final all = List<NavigationItemSpec>.unmodifiable([
    for (final r in navigationSourceData['items'] as List)
      NavigationItemSpec(r),
  ]);
  static NavigationItemSpec lookup(
    Brightness brightness,
    AppNavigationItemState state,
  ) => all.firstWhere((s) => s.brightness == brightness && s.state == state);
  AppNavigationItemState get state =>
      AppNavigationItemState.values.byName(data['state']);
  AppIconStyle get iconStyle => state == AppNavigationItemState.active
      ? AppIconStyle.fill
      : AppIconStyle.outline;
  Color get iconTint => paint(data['artwork']['paintNode'])!;
  double get badgeInlineAllowance =>
      (metric('pill', 'width') - metric('badgeLabel', 'width')) / 2;
  TextStyle textStyle(String role, {bool persian = false}) {
    final n = part(role),
        font = metric(role, 'fontSize'),
        spacing = n['letterSpacing'] as Map;
    return TextStyle(
      inherit: false,
      decoration: TextDecoration.none,
      fontFamily: BundledTypography.family(persian: persian),
      fontSize: font,
      fontWeight:
          FontWeight.values[(n['fontWeight'] as num).toInt() ~/ 100 - 1],
      height: (n['lineHeight']['value'] as num).toDouble() / font,
      letterSpacing:
          (spacing['value'] as num).toDouble() *
          (spacing['unit'] == 'PERCENT' ? font / 100 : 1),
      color: color(role),
    );
  }

  Map<String, Object?> typography({bool persian = false}) => {
    for (final role in ['label', 'badgeLabel'])
      role: {
        'family': textStyle(role, persian: persian).fontFamily,
        'fontSize': metric(role, 'fontSize'),
        'weight': part(role)['fontWeight'],
        'lineHeight': part(role)['lineHeight'],
        'letterSpacing': part(role)['letterSpacing'],
        'sourceStyleId': part(role)['textStyleId'],
        'status': 'source-unlinked / provisional',
        'scriptStatus': persian ? 'provisional R-003' : 'source',
      },
  };
}
