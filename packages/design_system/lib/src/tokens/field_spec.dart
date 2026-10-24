import '../theme/bundled_typography.dart';
import '../theme/skin_theme.dart';
import 'generated/skin_roles.g.dart';

import 'package:flutter/material.dart';

import '../components/fields/field_models.dart';
import '../icons/icon_registry.dart';
import 'generated/field_data.g.dart';

export '../components/fields/field_models.dart';

class FieldSpec {
  const FieldSpec(
    this.data,
    this.brightness, {
    this.derived = false,
    this.skin,
  });
  final Map<String, dynamic> data;
  String get identityKey =>
      '${family.name == 'textField' ? 'text-field' : family.name}.${brightness.name}.${(data['state'] as String).toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}';
  final Brightness brightness;
  final bool derived;
  final SkinDefinition? skin;
  FieldSpec withSkin(SkinDefinition value) =>
      FieldSpec(data, brightness, derived: derived, skin: value);
  static const names = <FieldVisualState, String>{
    FieldVisualState.defaultState: 'Default',
    FieldVisualState.focused: 'Focused',
    FieldVisualState.written: 'Written',
    FieldVisualState.edit: 'Edit',
    FieldVisualState.success: 'Success',
    FieldVisualState.error: 'Error',
    FieldVisualState.notSelected: 'Not Selected',
    FieldVisualState.notSelectedHover: 'Not Selected Hover',
    FieldVisualState.selected: 'Selected',
    FieldVisualState.selectedHover: 'Selected Hover',
  };
  static final List<FieldSpec> all = List.unmodifiable([
    for (final row in fieldSourceData['rows'] as List)
      FieldSpec(
        row as Map<String, dynamic>,
        Brightness.values.byName(row['brightness'] as String),
      ),
  ]);
  static final _variants = {
    for (final spec in all)
      (spec.family, spec.data['state'], spec.brightness): spec,
  };
  static final _derivedVariants =
      <(FieldFamily, String, Brightness), FieldSpec>{};
  static final _variables = {
    for (final v in fieldSourceData['variables'] as List)
      v['id'] as String: v as Map<String, dynamic>,
  };
  static final _collections = {
    for (final c in fieldSourceData['collections'] as List)
      c['id'] as String: c as Map<String, dynamic>,
  };
  static final _lightVariables = {
    for (final v in _variables.values)
      if ((_collections[v['collectionId']]!['name'] as String).contains(
        'Light Mode',
      ))
        v['name'] as String: v,
  };
  static FieldSpec lookup(
    FieldFamily family,
    FieldVisualState state,
    Brightness brightness, {
    bool passwordVisible = false,
  }) {
    final raw =
        '${names[state]}${family == FieldFamily.password ? ' - Visibility ${passwordVisible ? 'On' : 'Off'}' : ''}';
    final key = (family, raw, brightness);
    final direct = _variants[key];
    if (direct != null) return direct;
    final basis = _variants[(family, raw, Brightness.dark)];
    if (basis == null) {
      throw StateError('No field source state: $family/$raw');
    }
    return _derivedVariants.putIfAbsent(
      key,
      () => FieldSpec(basis.data, brightness, derived: true),
    );
  }

  FieldFamily get family => FieldFamily.values.byName(data['family'] as String);
  String get basisId => data['id'] as String;
  String? get sourceId => derived ? null : basisId;
  String? get setId => derived ? null : data['setId'] as String;
  String get rawName => data['rawName'] as String;
  Size get sourceSize => Size(
    (data['width'] as num).toDouble(),
    (data['height'] as num).toDouble(),
  );
  Map<String, dynamic>? part(String name) =>
      (data['parts'] as Map)[name] as Map<String, dynamic>?;
  double number(String partName, String key, {double fallback = 0}) =>
      (part(partName)?[key] as num?)?.toDouble() ?? fallback;
  EdgeInsetsDirectional padding(String name) => EdgeInsetsDirectional.fromSTEB(
    number(name, 'paddingLeft'),
    number(name, 'paddingTop'),
    number(name, 'paddingRight'),
    number(name, 'paddingBottom'),
  );
  Color? paint(Map<String, dynamic>? node, String key, {String? role}) {
    final paints = (node?[key] as List? ?? []).where(
      (p) => p['visible'] != false,
    );
    if (paints.isEmpty) return null;
    final p = paints.first as Map;
    if (p['type'] != 'SOLID') {
      throw StateError(
        'Unsupported field paint retained in source: ${p['type']}',
      );
    }
    var c = p['color'] as Map;
    final id = p['boundVariables']?['color']?['id'];
    String? skinRole;
    if (id != null) {
      var variable =
          _variables[id] ?? (throw StateError('Unknown field variable: $id'));
      if (derived) {
        role ??= (data['parts'] as Map).entries
            .where((entry) => identical(entry.value, node))
            .map((entry) => entry.key as String)
            .firstOrNull;
        if (role == 'otpText') role = 'input';
        final mapped = (fieldLightBindingsData[role] as Map?)?[key]?[id];
        if (mapped != null) variable = _variables[mapped]!;
        final collection = _collections[variable['collectionId']]!;
        if ((collection['name'] as String).contains('Dark Mode')) {
          variable =
              _lightVariables[variable['name']] ??
              (throw StateError(
                'Unresolved derived Light paint: ${variable['name']}',
              ));
        }
      }
      skinRole = variable['name'];
      c = (variable['valuesByMode'] as Map).values.single as Map;
    }
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
      role: skinRole,
      opacity: (p['opacity'] as num? ?? 1).toDouble(),
    );
  }

  Color? color(String name, {bool stroke = false}) =>
      paint(part(name), stroke ? 'strokes' : 'fills');
  TextStyle textStyle(String name, {bool persian = false}) {
    var node = part(name);
    node ??= lookup(
      family,
      FieldVisualState.written,
      brightness,
      passwordVisible: true,
    ).part(family == FieldFamily.otp ? 'otpText' : name);
    if (node == null) throw StateError('No text role $family/$name');
    final size = (node['fontSize'] as num).toDouble();
    final line = node['lineHeight'] as Map,
        spacing = node['letterSpacing'] as Map;
    return TextStyle(
      fontFamily: BundledTypography.family(persian: persian),
      fontSize: size,
      fontWeight:
          FontWeight.values[((node['fontWeight'] as num).toInt() ~/ 100) - 1],
      height: (line['value'] as num).toDouble() / size,
      letterSpacing:
          (spacing['value'] as num).toDouble() *
          (spacing['unit'] == 'PERCENT' ? size / 100 : 1),
      color: paint(node, 'fills', role: name),
    );
  }

  Map<String, Object?> typographyMetadata(String role, {bool persian = false}) {
    final style = textStyle(role, persian: persian);
    return {
      'fontFamily': style.fontFamily,
      'fontSize': style.fontSize,
      'fontWeight': style.fontWeight?.value,
      'lineHeight': style.height! * style.fontSize!,
      'letterSpacing': style.letterSpacing,
      'color': style.color?.toARGB32(),
    };
  }

  List<Map<String, dynamic>> get icons => [
    for (final i in data['icons'] as List) i as Map<String, dynamic>,
  ];
  IconDefinition icon(Map<String, dynamic> source) =>
      AppIconRegistry.byKey(source['logicalKey'] as String);
  Color? iconPaint(Map<String, dynamic> source) => paint(
    {'fills': source['paint']},
    'fills',
    role: family == FieldFamily.otp
        ? 'input'
        : (source['logicalKey'] as String).startsWith('icon.visibility')
        ? 'label'
        : 'supportText',
  );
  Map<String, Object?> get visualMetadata => {
    'background': color('body')?.toARGB32(),
    'borderColor': color('body', stroke: true)?.toARGB32(),
    'borderWidth': number('body', 'strokeWeight'),
    'radius': number('body', 'cornerRadius'),
    'padding': {
      'start': padding('body').start,
      'top': padding('body').top,
      'end': padding('body').end,
      'bottom': padding('body').bottom,
    },
    'sourceGap': data['gap'],
    'parts': {
      for (final entry in (data['parts'] as Map).entries)
        if (entry.value is Map)
          entry.key: {
            'basisNodeId': (entry.value as Map)['id'],
            for (final key in [
              'width',
              'height',
              'paddingLeft',
              'paddingRight',
              'paddingTop',
              'paddingBottom',
              'itemSpacing',
              'cornerRadius',
              'strokeWeight',
              'effects',
            ])
              if ((entry.value as Map).containsKey(key))
                key: (entry.value as Map)[key],
            'resolvedFill': paint(
              entry.value as Map<String, dynamic>,
              'fills',
            )?.toARGB32(),
            'resolvedStroke': paint(
              entry.value as Map<String, dynamic>,
              'strokes',
            )?.toARGB32(),
          },
    },
    'typography': {
      for (final entry in (data['parts'] as Map).entries)
        if (entry.value is Map && (entry.value as Map).containsKey('fontSize'))
          entry.key: {
            for (final key in [
              'fontName',
              'fontSize',
              'fontWeight',
              'lineHeight',
              'letterSpacing',
              'textStyleId',
            ])
              key: (entry.value as Map)[key],
          },
    },
    'icons': [
      for (final source in icons)
        {...source, 'resolvedColor': iconPaint(source)?.toARGB32()},
    ],
    'derived': derived,
  };
}

abstract final class FieldMotion {
  static Duration get label =>
      Duration(milliseconds: fieldEngineeringData['labelMs'] as int);
  static Duration get color =>
      Duration(milliseconds: fieldEngineeringData['colorMs'] as int);
  static Duration get support =>
      Duration(milliseconds: fieldEngineeringData['supportMs'] as int);
  static Duration get hover => Duration(
    milliseconds: (fieldSourceData['sourceMotion'] as Map)['hoverMs'] as int,
  );
  static const curve = Curves.easeOut;
  static double get tapExtent =>
      (fieldEngineeringData['minTapExtent'] as num).toDouble();
  static Map<String, dynamic> get metadata => {
    'engineering': fieldEngineeringData,
    'radioHover': fieldSourceData['sourceMotion'],
  };
  static Duration effective(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  static Map<String, dynamic> get otpComposition =>
      fieldSourceData['otpComposition'] as Map<String, dynamic>;
}
