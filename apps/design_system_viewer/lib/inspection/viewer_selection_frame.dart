import 'package:flutter/material.dart';

/// Viewer decoration and hit handling, outside the measured shared component.
class ViewerSelectionFrame extends StatelessWidget {
  const ViewerSelectionFrame({
    super.key,
    required this.selected,
    required this.child,
    this.onInspect,
  });

  final bool selected;
  final Widget child;
  final VoidCallback? onInspect;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    // The separate inspect control provides keyboard and semantic activation.
    excludeFromSemantics: true,
    onTap: onInspect,
    child: DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Theme.of(context).colorScheme.primary
              .withValues(alpha: selected ? 1 : 0),
        ),
      ),
      child: Padding(padding: const EdgeInsetsDirectional.all(2), child: child),
    ),
  );
}
