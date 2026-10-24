import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:p2e_design_system/design_system.dart';

import 'inspection.dart';

class InspectionSession extends ChangeNotifier {
  InspectionSession(this.rootKey, {this.requestedScale});
  final GlobalKey rootKey;
  double? requestedScale;
  bool selecting = false, disposedSelection = false;
  int traversals = 0, buildSignals = 0, refreshes = 0;
  List<InspectionNode> tree = [], candidates = [];
  InspectionNode? selected;
  Map<String, Object?>? snapshot;
  String? retainedKey, rawType, notice;
  VoidCallback? _previousBuildScheduled, _buildListener;
  bool _pending = false, _disposed = false;

  void watchBuilds() {
    final owner = WidgetsBinding.instance.buildOwner!;
    _previousBuildScheduled = owner.onBuildScheduled;
    _buildListener = () {
      buildSignals++;
      _previousBuildScheduled?.call();
      if (_pending || retainedKey == null || _disposed) return;
      _pending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pending = false;
        if (!_disposed) refresh();
      });
    };
    owner.onBuildScheduled = _buildListener;
  }

  void setSelecting(bool value) {
    selecting = value;
    if (value) scan();
    notifyListeners();
  }

  void refreshTree() {
    scan();
    notifyListeners();
  }

  void scan() {
    tree = [];
    final context = rootKey.currentContext;
    final root = context?.findRenderObject();
    if (context == null || root is! RenderBox || !root.hasSize) return;
    traversals++;
    final nodes = <InspectionNode>[];
    void visit(Element e, InspectionNode? owner, int depth) {
      var next = owner;
      if (e.widget is ElementIdentity) {
        final r = e.findRenderObject();
        Rect bounds = Rect.zero, clipped = Rect.zero;
        var visible = r is RenderBox && r.hasSize && r.attached;
        if (r is RenderBox && r.hasSize && r.attached) {
          bounds = MatrixUtils.transformRect(
            r.getTransformTo(root),
            Offset.zero & r.size,
          );
          clipped = bounds.intersect(Offset.zero & root.size);
          RenderObject child = r;
          while (true) {
            if (child is RenderOffstage && child.offstage ||
                child is RenderOpacity && child.opacity == 0 ||
                child is RenderAnimatedOpacity && child.opacity.value == 0) {
              visible = false;
            }
            final parent = child.parent;
            if (parent == null) break;
            final clip = parent.describeApproximatePaintClip(child);
            if (clip != null) {
              clipped = clipped.intersect(
                MatrixUtils.transformRect(parent.getTransformTo(root), clip),
              );
            }
            if (parent == root) break;
            child = parent;
          }
          visible = visible && !clipped.isEmpty;
          if (clipped.isEmpty) clipped = Rect.zero;
        }
        next = InspectionNode(e, owner, depth, bounds, clipped, visible, root);
        nodes.add(next);
      }
      e.visitChildren((child) => visit(child, next, depth + 1));
    }

    visit(context as Element, null, 0);
    tree = nodes;
  }

  bool _insideExactClips(InspectionNode n, Offset point) {
    RenderObject? r = n.element.findRenderObject();
    final global = n.root.localToGlobal(point);
    if (r is RenderBox &&
        r.hasSize &&
        !(Offset.zero & r.size).contains(r.globalToLocal(global))) {
      return false;
    }
    while (r != null && r != n.root) {
      if (r is RenderClipOval && r.hasSize && r.clipBehavior != Clip.none) {
        final local = r.globalToLocal(global);
        final clip = r.clipper?.getClip(r.size) ?? Offset.zero & r.size;
        final half = clip.size / 2;
        if (half.width == 0 || half.height == 0) return false;
        final x = (local.dx - clip.center.dx) / half.width;
        final y = (local.dy - clip.center.dy) / half.height;
        if (x * x + y * y > 1) return false;
      } else if (r is RenderClipRRect &&
          r.hasSize &&
          r.clipBehavior != Clip.none) {
        final clip =
            r.clipper?.getClip(r.size) ??
            r.borderRadius
                .resolve(r.textDirection)
                .toRRect(Offset.zero & r.size);
        if (!clip.contains(r.globalToLocal(global))) return false;
      } else if (r is RenderClipPath &&
          r.hasSize &&
          r.clipBehavior != Clip.none) {
        final clip = r.clipper?.getClip(r.size);
        if (clip != null && !clip.contains(r.globalToLocal(global))) {
          return false;
        }
      }
      r = r.parent;
    }
    return true;
  }

  void pick(Offset point) {
    scan();
    candidates =
        tree
            .where(
              (n) =>
                  n.visible &&
                  n.clipBounds.contains(point) &&
                  _insideExactClips(n, point),
            )
            .toList()
          ..sort((a, b) => b.depth.compareTo(a.depth));
    rawType = null;
    final root = rootKey.currentContext;
    var deepest = -1;
    void raw(Element e, int depth) {
      final r = e is RenderObjectElement ? e.renderObject : null;
      if (r is RenderBox && r.hasSize && r.attached && tree.isNotEmpty) {
        final rect = MatrixUtils.transformRect(
          r.getTransformTo(tree.first.root),
          Offset.zero & r.size,
        );
        if (rect.contains(point) && depth > deepest) {
          rawType = '${e.widget.runtimeType} / ${r.runtimeType}';
          deepest = depth;
        }
      }
      e.visitChildren((c) => raw(c, depth + 1));
    }

    if (root != null) raw(root as Element, 0);
    if (candidates.isEmpty) {
      notice =
          'No independent identity or owner at this point. Raw type: ${rawType ?? 'unavailable'}';
      notifyListeners();
    } else {
      choose(candidates.first);
      notice =
          'Nearest identity owner; raw widget/render: ${rawType ?? 'unavailable'}';
      notifyListeners();
    }
  }

  void choose(InspectionNode node) {
    if (!node.element.mounted) {
      retainedKey = node.key;
      selected = null;
      snapshot = null;
      disposedSelection = true;
      notice = 'Selected element is no longer mounted';
      notifyListeners();
      return;
    }
    selected = node;
    retainedKey = node.key;
    disposedSelection = false;
    snapshot = node.capture(requestedScale: requestedScale);
    // Catch a rebuild already scheduled before this selection was established.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) refresh();
    });
    notice = null;
    notifyListeners();
  }

  void refresh() {
    refreshes++;
    if (retainedKey == null) return;
    scan();
    final found = tree.where((n) => n.key == retainedKey).toList();
    if (found.isEmpty) {
      if (!disposedSelection) {
        disposedSelection = true;
        selected = null;
        snapshot = null;
        notice = 'Selected element is no longer mounted';
        notifyListeners();
      }
      return;
    }
    final next = found.first.capture(requestedScale: requestedScale);
    selected = found.first;
    if (disposedSelection || jsonEncode(snapshot) != jsonEncode(next)) {
      snapshot = next;
      disposedSelection = false;
      notice = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    final owner = WidgetsBinding.instance.buildOwner;
    if (owner?.onBuildScheduled == _buildListener) {
      owner!.onBuildScheduled = _previousBuildScheduled;
    }
    tree = [];
    candidates = [];
    selected = null;
    snapshot = null;
    super.dispose();
  }
}
