import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/inspection.dart' show authEntrySpecData;

const inspectorBuildMarker = 'P2E_OPTIONAL_INSPECTOR_V1_20261022';
const metricTolerance = .5; // Existing Viewer SizeComparison convention.

/// Never inspect editable content or serialize widget diagnostic strings.
Object? safeData(Object? value, [List<String>? omissions]) {
  if (value is Map) {
    if (value.length > 250) {
      omissions?.add('Object truncated to schema limit250');
    }
    return <String, Object?>{
      for (final e in value.entries.take(250))
        if (!RegExp(
          'passwordvalue|otpvalue|inputvalue|rawinput|rawtext|secret|tokenvalue|accesstoken|authtoken|length|hascontent|hasvalue|complete',
          caseSensitive: false,
        ).hasMatch(e.key.toString()))
          e.key.toString(): safeData(e.value, omissions),
    };
  }
  if (value is List) {
    if (value.length > 20) omissions?.add('Array truncated to schema limit20');
    return value.take(20).map((v) => safeData(v, omissions)).toList();
  }
  if (value is String && value.length > 500) {
    omissions?.add('String truncated to schema limit500');
    return value.substring(0, 500);
  }
  if (value is num || value is bool || value is String || value == null) {
    return value;
  }
  return value.runtimeType.toString();
}

Map<String, Object?> rectData(Rect rect) => {
  'x': rect.left,
  'y': rect.top,
  'width': rect.width,
  'height': rect.height,
};

class SourceRecord {
  const SourceRecord(
    this.data,
    this.size, {
    this.text,
    this.padding,
    this.radius,
    this.artworkOnly = false,
    this.basisOnly = false,
  });
  final Map data;
  final Size size;
  final String? text;
  final EdgeInsetsDirectional? padding;
  final double? radius;
  final bool artworkOnly, basisOnly;
}

/// Uses precisely the public registries consumed by the independent Viewer.
SourceRecord? sourceFor(ElementIdentity identity) {
  final id = identity.variantId;
  final artwork = (identity.resolved['artwork'] as Map?)?['value'] as Map?;
  if (artwork?['logicalKey'] is String && artwork?['style'] is String) {
    final a = AppIconRegistry.byKey(artwork!['logicalKey'] as String)
        .artwork(AppIconStyle.values.byName(artwork['style'] as String));
    return SourceRecord(a.data, Size(a.width, a.height), artworkOnly: true);
  }
  if (id == null) {
    final field = (identity.resolved['field'] as Map?)?['value'] as Map?;
    for (final spec in FieldSpec.all) {
      if (spec.basisId == field?['basisVariantId']) {
        return SourceRecord(spec.data, spec.sourceSize, basisOnly: true);
      }
    }
    return null;
  }
  for (final s in ButtonSpec.all) {
    if (s.id == id) {
      return SourceRecord(
        s.data,
        Size(s.width, s.height),
        text: (s.data['text'] as Map?)?['characters'] as String?,
        padding: s.padding,
        radius: s.metric('topLeftRadius'),
      );
    }
  }
  for (final s in BadgeSpec.all) {
    if (s.id == id) {
      return SourceRecord(
        s.data,
        s.sourceSize,
        text: s.referenceLabel,
        padding: s.padding,
        radius: s.radius,
      );
    }
  }
  for (final s in FieldSpec.all) {
    if (s.sourceId == id) return SourceRecord(s.data, s.sourceSize);
  }
  for (final s in AppBarSpec.all) {
    if (s.id == id) return SourceRecord(s.data, s.sourceSize);
  }
  for (final s in [...NavigationBarSpec.all, ...NavigationItemSpec.all]) {
    if (s.id == id) return SourceRecord(s.data, s.sourceSize);
  }
  final auth = (authEntrySpecData['nodes'] as Map)[id] as Map?;
  if (auth != null) {
    final rect = auth['screenRect'] as Map;
    return SourceRecord(
      auth,
      Size(
        (rect['width'] as num).toDouble(),
        (rect['height'] as num).toDouble(),
      ),
    );
  }
  return null;
}

Map<String, Object?> compareMetric({
  required Object? source,
  required Object? resolved,
  required Object? measured,
  String? reason,
  bool engineering = false,
}) {
  bool equal(Object? a, Object? b) {
    if (a is num && b is num) return (a - b).abs() <= metricTolerance;
    if (a is List && b is List) {
      return a.length == b.length &&
          List.generate(a.length, (i) => i).every((i) => equal(a[i], b[i]));
    }
    return a == b;
  }

  return {
    'source': source,
    'resolved': resolved,
    'measured': measured,
    'status': reason != null
        ? 'not comparable'
        : engineering
        ? 'engineering-defined'
        : source == null || measured == null
        ? 'unavailable'
        : equal(source, measured)
        ? 'match'
        : 'differs',
    'reason': reason,
    'toleranceLogicalPx': metricTolerance,
  };
}

List<double> paddingData(EdgeInsets padding) => [
  padding.left,
  padding.top,
  padding.right,
  padding.bottom,
];

/// A mounted element is retained only for the current host session, not globally.
class InspectionNode {
  InspectionNode(
    this.element,
    this.owner,
    this.depth,
    this.bounds,
    this.clipBounds,
    this.visible,
    this.root,
  ) : identity = element.widget as ElementIdentity;
  final Element element;
  final InspectionNode? owner;
  final int depth;
  final Rect bounds, clipBounds;
  final bool visible;
  final RenderBox root;
  final ElementIdentity identity;
  String get key => identity.effectiveKey;

  Map<String, Object?> capture({double? requestedScale}) {
    final metadata = identity;
    final omissions = <String>[];
    final descriptor =
        safeData(metadata.descriptor(), omissions) as Map<String, Object?>;
    final render = element.findRenderObject();
    final source = sourceFor(metadata);
    final field = (metadata.resolved['field'] as Map?)?['value'] as Map?;
    final provenance = source?.basisOnly == true
        ? (field?['runtimeExtension'] != null ||
                  field?['enabled'] == false ||
                  field?['readOnly'] == true
              ? 'engineering-defined with source basis'
              : 'derived with source basis')
        : source?.artworkOnly == true
        ? 'engineering-defined preview with source-backed artwork'
        : source != null
        ? 'source-backed'
        : metadata.declared['engineeringDecision'] != null
        ? 'engineering-defined'
        : metadata.variantId != null
        ? 'source-backed; source role lookup unavailable'
        : field?['runtimeExtension'] != null ||
              metadata.componentId.startsWith('layout.')
        ? 'engineering-defined'
        : field?['basisVariantId'] != null
        ? 'derived'
        : 'source-unlinked';
    final context = element;
    final scale = MediaQuery.textScalerOf(context).scale(10) / 10;
    var inheritedRequest = scale;
    if (requestedScale == null) {
      element.visitAncestorElements((ancestor) {
        if (ancestor.widget is AppNavigationItem) {
          inheritedRequest = MediaQuery.textScalerOf(ancestor).scale(10) / 10;
        }
        if (ancestor.widget is AppBarContent ||
            ancestor.widget is AppNavigationBar) {
          inheritedRequest = MediaQuery.textScalerOf(ancestor).scale(10) / 10;
          return false;
        }
        return true;
      });
    }

    final skin = SkinTheme.of(context);
    final direction = Directionality.of(context);
    final sensitive =
        metadata.declared['privacy'] == 'identifier' ||
        metadata.componentId.contains('password') ||
        metadata.componentId.contains('otp');
    final paragraphs = <Map<String, Object?>>[];
    Map<String, Object?>? interaction;
    RenderPadding? padding;
    RenderDecoratedBox? decoration;
    Rect? hitRegion;
    bool? sameText;
    void read(Element current) {
      if (current != element && current.widget is ElementIdentity) return;
      if (current.widget case final ButtonStyleButton button) {
        final states = button.statesController?.value;
        if (states != null) {
          interaction ??= {
            'hovered': states.contains(WidgetState.hovered),
            'pressed': states.contains(WidgetState.pressed),
            'focused': states.contains(WidgetState.focused),
            'disabled': states.contains(WidgetState.disabled),
          };
        }
      }
      if (current is RenderObjectElement) {
        final r = current.renderObject;
        if (r is RenderPadding) padding ??= r;
        if (r is RenderDecoratedBox) decoration ??= r;
        if (r is RenderPointerListener && hitRegion == null && r.hasSize) {
          hitRegion = MatrixUtils.transformRect(
            r.getTransformTo(root),
            Offset.zero & r.size,
          );
        }
        if (r is RenderParagraph && !sensitive) {
          final style = r.text.style;
          // Compare public source text in memory; never retain rendered text.
          if (source?.text != null) {
            sameText = r.text.toPlainText() == source!.text;
          }
          paragraphs.add({
            'fontFamily': style?.fontFamily,
            'fontFamilyFallback': style?.fontFamilyFallback,
            'fontSize': style?.fontSize,
            'fontWeight': style?.fontWeight?.value,
            'letterSpacing': style?.letterSpacing,
            'paragraphHeightLogicalPx': r.size.height,
            'heightMultiplier': style?.height,
            'effectiveScale': style?.fontSize == null
                ? null
                : r.textScaler.scale(style!.fontSize!) / style.fontSize!,
            'fontResolution': 'configured bundled family chain; glyph selection is not exposed by Flutter',
          });
        }
      }
      current.visitChildren(read);
    }

    read(element);
    final box = render is RenderBox && render.hasSize ? render : null;
    final actualPadding = padding?.padding.resolve(direction);
    final sourcePadding = source?.padding?.resolve(direction);
    final shape = decoration?.decoration;
    final actualRadius = shape is BoxDecoration
        ? shape.borderRadius?.resolve(direction).topLeft.x
        : null;
    final effectiveScale = paragraphs.isEmpty
        ? scale
        : (paragraphs.first['effectiveScale'] as num?)?.toDouble() ?? scale;
    final reasons = <String>[
      if (source?.artworkOnly == true)
        'artwork source dimensions do not describe the preview owner',
      if (metadata.declared['loading'] == true)
        'loading visual has no source variant',
      if (source?.basisOnly == true) 'basis source only; no dedicated source for this derived/engineering owner',
      if (effectiveScale != 1) 'scale ≠1.0',
      if (skin.id != productSkin.id) 'skin ≠product',
      if (source == null)
        'unavailable source (derived/engineering/source-unlinked)',
      if (metadata.runtimeLocator?.slotPath == 'visibilityAction') 'owner source is available; independent visibility-action geometry is not mapped',
    ];
    final reason = reasons.isEmpty ? null : reasons.join('; ');
    final widthReason = [
      ...reasons,
      if (source != null &&
          (bounds.width - source.size.width).abs() > metricTolerance)
        'width differs from source reference',
      if (sameText != true) 'text/font equivalence unavailable or different',
    ].join('; ');
    final comparisons = {
      'width': compareMetric(
        source: source?.size.width,
        resolved: null,
        measured: bounds.width,
        reason: widthReason.isEmpty ? null : widthReason,
      ),
      'height': compareMetric(
        source: source?.size.height,
        resolved: source?.data['runtimeGeometry']?['minimumVisualHeight'],
        measured: bounds.height,
        reason: widthReason.isEmpty ? null : widthReason,
        engineering: source?.data['heightPaddingConflict'] == true,
      ),
      'padding': compareMetric(
        source: sourcePadding == null ? null : paddingData(sourcePadding),
        resolved: sourcePadding == null ? null : paddingData(sourcePadding),
        measured: actualPadding == null ? null : paddingData(actualPadding),
        reason: reason,
      ),
      'radius': compareMetric(
        source: source?.radius,
        resolved: null,
        measured: actualRadius,
        reason: reason,
      ),
      'gap': compareMetric(
        source:
            source?.data['geometry']?['itemSpacing'] ??
            source?.data['body']?['itemSpacing'] ??
            source?.data['gap'],
        resolved: null,
        measured: null,
        reason: reason,
      ),
      'typography': compareMetric(
        source: source?.data['text']?['typography'],
        resolved: paragraphs,
        measured: null,
        reason: sensitive ? 'Sensitive paragraphs are not collected' : 'Configured family chains/paragraph metrics are shown; glyph font and role equivalence unavailable',
      ),
      'icon': compareMetric(
        source: source?.artworkOnly == true
            ? source?.data
            : source?.data['icon'] ?? source?.data['iconSlot'],
        resolved: metadata.declared['iconId'],
        measured: null,
        reason: reason,
      ),
      'colors': compareMetric(
        source: null,
        resolved: {
          for (final e in (descriptor['resolved'] as Map).entries)
            if (e.key.toString().toLowerCase().contains('color'))
              e.key: e.value,
        },
        measured: null,
        reason: 'Resolved configuration only; no pixel sampling or visual equality claim',
      ),
      'motion': compareMetric(
        source: null,
        resolved: descriptor['declared'],
        measured: null,
        reason: 'Motion is not sampled; see source reactions and engineering metadata',
      ),
    };
    final actual = {
      'boundsInApp': rectData(bounds),
      'clippedBoundsInApp': rectData(clipBounds),
      'clipping': 'transformed bounds intersected with ancestor approximate paint clips',
      'visible': visible,
      'receivedConstraints': box?.constraints.toString(),
      'hitRegionInApp': hitRegion == null ? null : rectData(hitRegion!),
      'hitRegionOrigin': hitRegion == null
          ? 'unavailable'
          : 'RenderPointerListener bounds; not hit-tested',
      'typography': sensitive
          ? {
              if (metadata.declared['privacy'] == 'identifier')
                'displayMask': '••••',
              'status': 'unavailable: sensitive paragraphs are not collected (including counts)',
              'configured': safeData(field?['resolvedTypography']),
            }
          : paragraphs,
      'renderType': render.runtimeType.toString(),
      'interaction':
          interaction ?? {'status': 'unavailable; see descriptor state'},
    };
    final configuration = {
      'variants': metadata.variants,
      'effectiveKey': jsonDecode(metadata.effectiveKey),
      'effectiveKeyEncoding':
          'JSON array; jsonEncode recreates the descriptor effective key',
      'skin': skin.id,
      'brightness': Theme.of(context).brightness.name,
      'locale': Localizations.maybeLocaleOf(context)?.languageCode,
      'direction': direction.name,
      'requestedScale': requestedScale ?? inheritedRequest,
      'effectiveScale': effectiveScale,
      'chromeCap': chromeTextScaleCap,
      'mediaDevicePixelRatio': MediaQuery.devicePixelRatioOf(context),
      'provenance': provenance,
      'status': metadata.status,
      if ((descriptor['declared'] as Map)['loading'] case {'value': true})
        'loadingVisual':
            'engineering-defined; no loading axis in the base source variant',
      'ownerChain': [for (var p = owner; p != null; p = p.owner) p.key],
    };
    final resolved = descriptor['resolved'] as Map;
    resolved['inspectionSource'] = {
      'value': safeData(source?.data, omissions),
      'origin': source == null
          ? 'unknown'
          : source.artworkOnly
          ? 'icon-registry'
          : 'figma-reference',
    };
    resolved['inspectionConfiguration'] = {
      'value': safeData(configuration, omissions),
      'origin': 'runtime-resolver',
    };
    resolved['inspectionActual'] = {
      'value': safeData(actual, omissions),
      'origin': 'runtime-resolver',
    };
    resolved['inspectionComparison'] = {
      'value': safeData(comparisons, omissions),
      'origin': 'runtime-resolver',
    };
    descriptor['measured'] = {
      'widthLogicalPx': bounds.width,
      'heightLogicalPx': bounds.height,
      'leftGlobalLogicalPx': bounds.left,
      'topGlobalLogicalPx': bounds.top,
      'devicePixelRatio':
          View.maybeOf(context)?.devicePixelRatio ??
          MediaQuery.devicePixelRatioOf(context),
      'visible': visible,
    };
    final warnings = descriptor['warnings'] as List;
    for (final omission in omissions.toSet()) {
      warnings.add({
        'code': 'SCHEMA_BOUND',
        'severity': 'warning',
        'message': omission,
      });
    }
    return descriptor;
  }

  String? get figmaUrl {
    final artwork = (identity.resolved['artwork'] as Map?)?['value'] as Map?;
    final basis = sourceFor(identity);
    final node =
        identity.variantId ??
        (artwork?['nodeId'] as String?) ??
        (basis?.basisOnly == true ? basis?.data['id'] as String? : null);
    final file = identity.variantId == null
        ? ((artwork?['fileKey'] as String?) ??
              (basis?.data['fileKey'] as String?))
        : identity.fileKey;
    return node == null || file == null
        ? null
        : 'https://www.figma.com/design/$file?node-id=${node.replaceAll(':', '-')}';
  }
}

String exportSnapshot(Map<String, Object?> snapshot) =>
    const JsonEncoder.withIndent('  ').convert(safeData(snapshot));
