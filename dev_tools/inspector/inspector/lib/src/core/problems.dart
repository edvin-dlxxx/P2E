import 'dart:convert';

import 'package:flutter/foundation.dart' show precisionErrorTolerance;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:p2e_design_system/design_system.dart';

import 'device.dart';
import 'selection.dart';

class InspectionProblem {
  InspectionProblem(
    this.kind,
    this.summary,
    this.ownerKey,
    this.elementId,
    this.device,
  );
  final String kind, summary;
  final String? ownerKey, elementId;
  final FrameSettings device;
  String get group => '$kind|${ownerKey ?? "unavailable"}';
  Map<String, Object?> toJson() => {
    'kind': kind,
    'summary': summary,
    'ownerKey': ownerKey == null ? null : jsonDecode(ownerKey!),
    'elementId': elementId,
    'device': device.toJson(),
  };
}

/// Chains the existing Flutter handler. Raw exception text, input and diagnostics
/// never enter the record; only allowlisted diagnostic kinds are exported.
class ProblemRecorder extends ChangeNotifier {
  ProblemRecorder(this.session, this.device);
  final InspectionSession session;
  final SimulatedDevice device;
  final List<InspectionProblem> problems = [];
  final List<InspectionProblem> events = [];
  int collectorFailures = 0;
  final _problemKeys = <String>{};
  void record(InspectionProblem p) {
    events.add(p);
    if (_problemKeys.add('${p.group}|${jsonEncode(p.device.toJson())}')) {
      problems.add(p);
    }
  }

  void Function(FlutterErrorDetails)? _previous, _handler;
  void attach() {
    _previous = FlutterError.onError;
    _handler = (details) {
      try {
        capture(details);
      } catch (_) {
        collectorFailures++;
      } finally {
        (_previous ?? FlutterError.presentError)(details);
      }
    };
    FlutterError.onError = _handler;
  }

  void capture(FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    final kind = message.contains('mutated in its own performLayout')
        ? 'layout-mutation'
        : message.contains('Navigator Bar host contract violation')
        ? 'navigator-below-minimum'
        : message.contains('loadingSemanticsLabel is missing')
        ? 'loading-label-missing'
        : message.contains('overflowed')
        ? 'overflow'
        : message.contains('RenderBox was not laid out')
        ? 'unlaid-render-box'
        : details.library == 'rendering library' ||
              details.context.toString().contains('layout') ||
              details.context.toString().contains('paint')
        ? 'layout-paint-error'
        : null;
    if (kind == null) return;
    Element? element;
    void inspect(DiagnosticsNode node) {
      final value = node is DiagnosticsProperty ? node.value : null;
      if (value is Element) element = value;
      if (value is DebugCreator) element = value.element;
      if (value is RenderObject && value.debugCreator is DebugCreator) {
        element = (value.debugCreator as DebugCreator).element;
      }
      for (final c in node.getProperties()) {
        if (c != node && c is DiagnosticsProperty) {
          final v = c.value;
          if (v is DebugCreator) element = v.element;
          if (v is Element) element = v;
        }
      }
    }

    for (final node
        in details.informationCollector?.call() ?? <DiagnosticsNode>[]) {
      inspect(node);
    }
    ElementIdentity? owner;
    if (element?.mounted ?? false) {
      if (element!.widget is ElementIdentity) {
        owner = element!.widget as ElementIdentity;
      }
      element!.visitAncestorElements((e) {
        if (e.widget is ElementIdentity) {
          owner = e.widget as ElementIdentity;
          return false;
        }
        return true;
      });
    }
    String? ownerKey = owner?.effectiveKey;
    String? ownerId = owner?.elementId;
    if (owner == null && kind == 'navigator-below-minimum') {
      void find(Element e) {
        final w = e.widget;
        if (w is ElementIdentity && w.componentId == 'navigation.bar') {
          final r = e.findRenderObject();
          if (r is RenderBox && r.hasSize && r.size.width < 252) {
            ownerKey = w.effectiveKey;
            ownerId = w.elementId;
          }
        }
        e.visitChildren(find);
      }

      (session.rootKey.currentContext as Element?)?.visitChildren(find);
    }
    if (ownerKey == null && kind == 'loading-label-missing') {
      final candidates = <ElementIdentity>[];
      void collect(Element e, bool offending) {
        final w = e.widget;
        if (w is AppButton) {
          offending =
              w.loading && (w.loadingSemanticsLabel?.trim().isEmpty ?? true);
        }
        if (offending &&
            w is ElementIdentity &&
            w.componentId == 'button.base') {
          candidates.add(w);
        }
        e.visitChildren((child) => collect(child, offending));
      }

      final root = session.rootKey.currentContext as Element?;
      if (root != null) collect(root, false);
      // Multiple identical diagnostics carry no emitter locator: never guess.
      if (candidates.length == 1) {
        ownerKey = candidates.single.effectiveKey;
        ownerId = candidates.single.elementId;
      }
    }
    final p = InspectionProblem(
      kind,
      switch (kind) {
        'navigator-below-minimum' =>
          'Host width below 252; degraded targets are non-compliant.',
        'loading-label-missing' =>
          'Loading accessibility label missing; fallback used.',
        'overflow' =>
          'Render object overflow; console retains details and stripes.',
        'unlaid-render-box' => 'RenderBox was not laid out.',
        'layout-mutation' => 'Render object mutated during its own layout; console retains details.',
        _ => 'Layout/paint FlutterError; console retains details.',
      },
      ownerKey,
      ownerId,
      device.settings,
    );
    record(p);
    // Error callbacks can occur during layout; notify only after the frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  bool _disposed = false;

  /// Flutter reports a continuous RenderFlex overflow once. Inspect public child
  /// extents to observe the same overflow at subsequent sweep samples as well.
  void sampleLayout() {
    final root = session.rootKey.currentContext as Element?;
    void visit(Element e, String? ownerKey, String? elementId) {
      final widget = e.widget;
      if (widget is AppButton) {
        final box = e.findRenderObject();
        if (box is RenderBox && box.hasSize && box.attached) {
          final envelope = box.semanticBounds;
          // Fully scrolled-out controls have no active target in this frame.
          // A partially visible envelope is still checked and reported.
          RenderObject? viewport = box.parent;
          while (viewport != null) {
            if (viewport is RenderAbstractViewport &&
                viewport is RenderBox &&
                (viewport as RenderBox).hasSize) {
              final rect = MatrixUtils.transformRect(
                box.getTransformTo(viewport),
                envelope,
              );
              if (!(Offset.zero & (viewport as RenderBox).size).overlaps(
                rect,
              )) {
                return;
              }
            }
            viewport = viewport.parent;
          }
          void identify(Element child) {
            if (child.widget case final ElementIdentity identity) {
              if (identity.componentId == 'button.base') {
                ownerKey = identity.effectiveKey;
                return;
              }
            }
            child.visitChildren(identify);
          }

          e.visitChildren(identify);
          RenderObject? region = box.parent;
          while (region != null && region is! RenderButtonHitRegion) {
            region = region.parent;
          }
          var delegated = region != null;
          RenderObject child = box;
          RenderObject? ancestor = box.parent;
          while (ancestor != null) {
            if (ancestor is RenderBox && ancestor.hasSize) {
              final inAncestor = MatrixUtils.transformRect(
                box.getTransformTo(ancestor),
                envelope,
              );
              final bounds = Offset.zero & ancestor.size;
              final clip = ancestor.describeApproximatePaintClip(child);
              bool contains(Rect outer) =>
                  outer
                      .inflate(precisionErrorTolerance)
                      .contains(inAncestor.topLeft) &&
                  outer
                      .inflate(precisionErrorTolerance)
                      .contains(inAncestor.bottomRight);
              if ((!delegated && !contains(bounds)) ||
                  clip != null && !contains(clip)) {
                record(
                  InspectionProblem(
                    'button-hit-envelope-constrained',
                    'Button 48dp hit envelope is outside ancestor ${ancestor.runtimeType} bounds or clip.',
                    ownerKey,
                    widget.elementId,
                    device.settings,
                  ),
                );
                break;
              }
            }
            if (ancestor == region) delegated = false;
            child = ancestor;
            ancestor = ancestor.parent;
          }
        }
      }
      if (e.widget is ElementIdentity) {
        final identity = e.widget as ElementIdentity;
        ownerKey = identity.effectiveKey;
        elementId = identity.elementId;
        final box = e.findRenderObject();
        if (identity.componentId == 'social.auth-tile' &&
            box is RenderBox &&
            box.hasSize &&
            (box.size.width < FieldMotion.tapExtent ||
                box.size.height < FieldMotion.tapExtent)) {
          record(
            InspectionProblem(
              'touch-target-below-minimum',
              'Social Auth target ${box.size.width} x ${box.size.height}; minimum ${FieldMotion.tapExtent}.',
              ownerKey,
              elementId,
              device.settings,
            ),
          );
        }
        if (identity.componentId == 'navigation.bar' &&
            box is RenderBox &&
            box.hasSize &&
            box.size.width < 252) {
          final p = InspectionProblem(
            'navigator-below-minimum',
            'Observed degraded layout below 252; targets non-compliant.',
            ownerKey,
            elementId,
            device.settings,
          );
          record(p);
        }
      }
      final r = e is RenderObjectElement ? e.renderObject : null;
      if (r is RenderOffstage && r.offstage ||
          r is RenderOpacity && r.opacity == 0) {
        return;
      }
      if (r is RenderFlex && r.hasSize && r.attached) {
        double extent = 0;
        int count = 0;
        r.visitChildren((child) {
          if (child is RenderBox && child.hasSize) {
            extent += r.direction == Axis.horizontal
                ? child.size.width
                : child.size.height;
            count++;
          }
        });
        extent += (count - 1).clamp(0, count) * r.spacing;
        final available = r.direction == Axis.horizontal
            ? r.size.width
            : r.size.height;
        if (extent > available + .01) {
          final p = InspectionProblem(
            'overflow',
            'Observed RenderFlex main-axis overflow; console retains details and stripes.',
            ownerKey,
            elementId,
            device.settings,
          );
          record(p);
        }
      }
      e.visitChildren((child) => visit(child, ownerKey, elementId));
    }

    if (root != null) visit(root, null, null);
  }

  void clear() {
    problems.clear();
    events.clear();
    _problemKeys.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (FlutterError.onError == _handler) FlutterError.onError = _previous;
    super.dispose();
  }
}

enum SweepAxis { width, height, grid }

class SweepPlan {
  const SweepPlan({
    this.axis = SweepAxis.width,
    this.minWidth = 200,
    this.maxWidth = 1400,
    this.minHeight = 300,
    this.maxHeight = 1400,
    this.widthStep = 4,
    this.heightStep = 8,
    this.scales = const [],
    this.locales = const [],
  });
  final SweepAxis axis;
  final double minWidth, maxWidth, minHeight, maxHeight, widthStep, heightStep;
  final List<double> scales;
  final List<List<Locale>> locales;
  Iterable<FrameSettings> frames(FrameSettings base) sync* {
    if (widthStep <= 0 || heightStep <= 0) {
      throw ArgumentError('Positive sweep steps required');
    }
    for (final scale in scales.isEmpty ? [base.scale] : scales) {
      for (final locale in locales.isEmpty ? [base.locales] : locales) {
        for (
          var w = axis == SweepAxis.height ? base.size.width : minWidth;
          w <= (axis == SweepAxis.height ? base.size.width : maxWidth);
          w += widthStep
        ) {
          for (
            var h = axis == SweepAxis.width ? base.size.height : minHeight;
            h <= (axis == SweepAxis.width ? base.size.height : maxHeight);
            h += heightStep
          ) {
            yield base.copyWith(
              size: Size(w, h),
              scale: scale,
              locales: locale,
            );
          }
        }
      }
    }
  }
}

/// Adjacent sampled failures are grouped, never extrapolated across unsampled px.
class SweepRunner extends ChangeNotifier {
  SweepRunner(this.device, this.recorder);
  final SimulatedDevice device;
  final ProblemRecorder recorder;
  bool running = false, cancelled = false;
  int completed = 0;
  List<Map<String, Object?>> ranges = [];
  Future<void> run(SweepPlan plan, Future<void> Function() frame) async {
    if (running) return;
    final saved = device.settings, savedMode = device.mode;
    running = true;
    cancelled = false;
    completed = 0;
    ranges = [];
    device.mode = FrameMode.free;
    final active = <String, Map<String, Object?>>{};
    try {
      for (final settings in plan.frames(saved)) {
        if (cancelled) break;
        final before = recorder.events.length;
        device.apply(settings);
        await frame();
        recorder.sampleLayout();
        final seen = <String>{};
        for (final p in recorder.events.skip(before)) {
          final key =
              '${p.group}|${settings.scale}|${settings.locales}|${settings.size.height}';
          if (!seen.add(key)) {
            continue;
          }
          final previous = active[key];
          if (previous != null &&
              (previous['lastWidth'] as double) + plan.widthStep ==
                  settings.size.width &&
              plan.axis != SweepAxis.height) {
            previous['lastWidth'] = settings.size.width;
          } else {
            final r = <String, Object?>{
              ...p.toJson(),
              'firstWidth': settings.size.width,
              'lastWidth': settings.size.width,
              'firstHeight': settings.size.height,
              'lastHeight': settings.size.height,
              'widthStep': plan.widthStep,
              'heightStep': plan.heightStep,
            };
            // Height sweeps group consecutive heights instead of widths.
            final hk =
                '${p.group}|${settings.scale}|${settings.locales}|${settings.size.width}';
            final hp = active[hk];
            if (plan.axis == SweepAxis.height &&
                hp != null &&
                (hp['lastHeight'] as double) + plan.heightStep ==
                    settings.size.height) {
              hp['lastHeight'] = settings.size.height;
            } else {
              ranges.add(r);
              active[plan.axis == SweepAxis.height ? hk : key] = r;
            }
          }
        }
        completed++;
        notifyListeners();
      }
    } finally {
      device.mode = savedMode;
      device.apply(saved);
      await frame();
      running = false;
      notifyListeners();
    }
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert({
    'format': 'p2e-sweep-v1.1',
    'completed': completed,
    'ranges': ranges,
  });
}
