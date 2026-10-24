// TEMPORARY: dev-only RenderBox measurement, never imported by production UI.
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Material;
import 'package:p2e_design_system/design_system.dart'
    show ElementIdentity, identityValueEquals;

class SizeComparison {
  const SizeComparison(this.measured, this.figma, {this.tolerance = 0.5});
  final Size measured;
  final Size figma;
  final double tolerance;
  Size get delta =>
      Size(measured.width - figma.width, measured.height - figma.height);
  bool get ok =>
      delta.width.abs() <= tolerance && delta.height.abs() <= tolerance;
}

/// Reports this child's actual laid-out box, including its accessibility target.
class MeasureBox extends SingleChildRenderObjectWidget {
  const MeasureBox({super.key, required this.onSize, required super.child});
  final ValueChanged<Size> onSize;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureRender(onSize);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    (renderObject as _MeasureRender).onSize = onSize;
  }
}

class _MeasureRender extends RenderProxyBox {
  _MeasureRender(this.onSize);
  ValueChanged<Size> onSize;
  Size? previous;
  @override
  void performLayout() {
    super.performLayout();
    final actual = size;
    if (previous == actual) return;
    previous = actual;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) onSize(actual);
    });
  }
}

@immutable
class ButtonMeasurement {
  const ButtonMeasurement({
    required this.outer,
    required this.visual,
    required this.content,
    this.identity,
  });
  final Size outer, visual, content;
  final Map<String, Object?>? identity;
  @override
  bool operator ==(Object other) =>
      other is ButtonMeasurement &&
      other.outer == outer &&
      other.visual == visual &&
      other.content == content;
  @override
  int get hashCode => Object.hash(outer, visual, content);
}

/// Measures the Material surface separately from TextButton's tap-target box.
class MeasuredButton extends StatefulWidget {
  const MeasuredButton({
    super.key,
    required this.child,
    required this.onMeasurement,
  });
  final Widget child;
  final ValueChanged<ButtonMeasurement> onMeasurement;
  @override
  State<MeasuredButton> createState() => _MeasuredButtonState();
}

class _MeasuredButtonState extends State<MeasuredButton> {
  final anchor = GlobalKey();
  ButtonMeasurement? published;
  Size? latestOuter;
  @override
  void didUpdateWidget(MeasuredButton old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && latestOuter != null) measure(latestOuter!);
    });
  }

  void measure(Size outer) {
    latestOuter = outer;
    final context = anchor.currentContext;
    if (context == null) return;
    Size? visual, content;
    Map<String, Object?>? identity;
    void visit(Element element) {
      final render = element.findRenderObject();
      if (element.widget case final ElementIdentity widget) {
        identity = widget.descriptor();
      }
      if (element.widget is Material && render is RenderBox) {
        visual = render.size;
      }
      if (element.widget is Text && render is RenderBox) content = render.size;
      element.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
    if (visual != null) {
      final next = ButtonMeasurement(
        outer: outer,
        visual: visual!,
        content: content ?? Size.zero,
        identity: identity,
      );
      if (next == published &&
          identityValueEquals(next.identity, published?.identity)) {
        return;
      }
      published = next;
      widget.onMeasurement(next);
    }
  }

  @override
  Widget build(BuildContext context) =>
      MeasureBox(key: anchor, onSize: measure, child: widget.child);
}
