import 'package:flutter/foundation.dart' show precisionErrorTolerance;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:p2e_design_system/design_system.dart';

/// D-062: reveal a partly visible control's complete minimum tap envelope.
/// Layout/paint are unchanged. Fully offscreen controls do not pull the page.
class CompleteTapEnvelope extends StatefulWidget {
  const CompleteTapEnvelope({super.key, required this.child});
  final Widget child;

  @override
  State<CompleteTapEnvelope> createState() => _CompleteTapEnvelopeState();
}

class _CompleteTapEnvelopeState extends State<CompleteTapEnvelope> {
  ScrollPosition? _position;
  bool _pending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next == _position) return;
    _detach();
    _position = next;
    next?.addListener(_schedule);
    next?.isScrollingNotifier.addListener(_schedule);
  }

  void _detach() {
    _position?.removeListener(_schedule);
    _position?.isScrollingNotifier.removeListener(_schedule);
  }

  void _schedule() {
    if (_pending || !mounted || _position == null) return;
    _pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pending = false;
      final position = _position;
      if (!mounted ||
          position == null ||
          !position.hasContentDimensions ||
          position.isScrollingNotifier.value) {
        return;
      }
      final box = context.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) return;
      final viewport = RenderAbstractViewport.maybeOf(box);
      if (viewport is! RenderBox) return;
      final viewportBox = viewport as RenderBox;
      if (!viewportBox.hasSize) return;
      final envelope = Rect.fromCenter(
        center: box.size.center(Offset.zero),
        width: box.size.width < FieldMotion.tapExtent
            ? FieldMotion.tapExtent
            : box.size.width,
        height: box.size.height < FieldMotion.tapExtent
            ? FieldMotion.tapExtent
            : box.size.height,
      );
      final rect = MatrixUtils.transformRect(
        box.getTransformTo(viewport),
        envelope,
      );
      final visible = Offset.zero & viewportBox.size;
      if (!visible.overlaps(rect)) return;
      // Auth uses a downward vertical scroll view. No width-specific offsets.
      if (position.axisDirection != AxisDirection.down) return;
      final delta = rect.top < visible.top
          ? rect.top - visible.top
          : rect.bottom > visible.bottom
          ? rect.bottom - visible.bottom
          : 0.0;
      final target = (position.pixels + delta).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      );
      if ((target - position.pixels).abs() > precisionErrorTolerance) {
        // Never change scroll/state during layout, and never fight a user drag.
        position.jumpTo(target);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // A scroll child's height constraint stays unbounded when its viewport
    // height changes. Observe the simulated/system viewport as well.
    MediaQuery.sizeOf(context);
    _schedule();
    return LayoutBuilder(
      builder: (context, constraints) {
        _schedule();
        return widget.child;
      },
    );
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }
}
