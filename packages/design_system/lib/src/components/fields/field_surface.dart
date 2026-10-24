import '../../theme/skin_theme.dart';

import 'package:flutter/material.dart';

import '../../icons/app_icon.dart';
import '../../tokens/field_spec.dart';

/// Shared source presentation for native inputs and the dev reference harness.
class AppFieldSurface extends StatelessWidget {
  const AppFieldSurface({
    super.key,
    required this.spec,
    required this.label,
    required this.input,
    this.requirement = FieldRequirement.optional,
    this.requirementLabels,
    this.showRequirement = false,
    this.feedback = const FieldFeedback.neutral(),
    this.supportingText,
    this.showSupporting = true,
    this.showSupportingIcon = true,
    this.trailing,
    this.visualKey,
    this.onTap,
  });
  final FieldSpec spec;
  final String label;
  final Widget input;
  final FieldRequirement requirement;
  final FieldRequirementLabels? requirementLabels;
  final bool showRequirement, showSupporting, showSupportingIcon;
  final FieldFeedback feedback;
  final String? supportingText;
  final Widget? trailing;
  final Key? visualKey;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final spec = this.spec.withSkin(SkinTheme.of(context));
    if (showRequirement && requirementLabels == null) {
      throw ArgumentError('Visible requirement needs localized labels');
    }
    final message = feedback.supporting(supportingText, show: showSupporting);
    if ((spec.data['state'] as String).startsWith('Error') &&
        (message == null || message.trim().isEmpty)) {
      throw ArgumentError(
        'Error presentation requires a caller-supplied message',
      );
    }
    final floating =
        spec.data['state'] != 'Default' &&
        spec.data['state'] != 'Default - Visibility On' &&
        spec.data['state'] != 'Default - Visibility Off';
    final persian = Directionality.of(context) == TextDirection.rtl;
    final labelRow = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: spec.number('labelFrame', 'height'),
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        heightFactor: 1,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: spec.number('labelFrame', 'itemSpacing'),
          children: [
            AnimatedDefaultTextStyle(
              duration: FieldMotion.effective(context, FieldMotion.label),
              curve: FieldMotion.curve,
              style: spec.textStyle('label', persian: persian),
              child: Text(label),
            ),
            if (showRequirement)
              Text(
                requirementLabels!.forRequirement(requirement),
                style: spec.textStyle('indicator', persian: persian),
              ),
          ],
        ),
      ),
    );
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        labelRow,
        Offstage(offstage: !floating, child: input),
      ],
    );
    final decoration = BoxDecoration(
      color: spec.color('body'),
      border: Border.all(
        color: spec.color('body', stroke: true) ?? spec.color('body')!,
        width: spec.number('body', 'strokeWeight'),
      ),
      borderRadius: BorderRadiusDirectional.all(
        Radius.circular(spec.number('body', 'cornerRadius')),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: TweenAnimationBuilder<Decoration?>(
            duration: FieldMotion.effective(context, FieldMotion.color),
            curve: FieldMotion.curve,
            tween: DecorationTween(end: decoration),
            builder: (context, value, child) =>
                DecoratedBox(decoration: value!, child: child),
            child: ConstrainedBox(
              key: visualKey,
              constraints: BoxConstraints(
                minHeight: spec.number('body', 'height'),
              ),
              child: _FieldSizeTransition(
                duration: FieldMotion.effective(context, FieldMotion.label),
                curve: FieldMotion.curve,
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: spec.padding('body'),
                  child: Row(
                    children: [
                      Expanded(child: content),
                      ?trailing,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        _FieldSizeTransition(
          duration: FieldMotion.effective(context, FieldMotion.support),
          curve: FieldMotion.curve,
          alignment: AlignmentDirectional.topStart,
          child: message == null || message.trim().isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsetsDirectional.only(
                    top: (spec.data['gap'] as num).toDouble(),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: spec.color('support'),
                      borderRadius: BorderRadiusDirectional.all(
                        Radius.circular(spec.number('support', 'cornerRadius')),
                      ),
                    ),
                    child: Padding(
                      key: const ValueKey('field-supporting'),
                      padding: spec.padding('support'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showSupportingIcon && spec.icons.isNotEmpty) ...[
                            AssetAppIcon(
                              spec.icon(spec.icons.last).id,
                              style: AppIconStyle.values.byName(
                                spec.icons.last['style'] as String,
                              ),
                              size: (spec.icons.last['width'] as num)
                                  .toDouble(),
                              color: spec
                                  .textStyle('supportText', persian: persian)
                                  .color,
                            ),
                            SizedBox(
                              width: spec.number('support', 'itemSpacing'),
                            ),
                          ],
                          Expanded(
                            child: Semantics(
                              liveRegion:
                                  feedback.validation == FieldValidation.error,
                              child: Text(
                                message,
                                style: spec.textStyle(
                                  'supportText',
                                  persian: persian,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// A zero-duration AnimatedSize restarts its controller synchronously during
/// performLayout when the child changes size. Reduced motion lays out the target
/// directly; the normal nonzero animation retains its original curve/alignment.
class _FieldSizeTransition extends StatefulWidget {
  const _FieldSizeTransition({
    required this.duration,
    required this.curve,
    required this.alignment,
    required this.child,
  });
  final Duration duration;
  final Curve curve;
  final AlignmentGeometry alignment;
  final Widget child;

  @override
  State<_FieldSizeTransition> createState() => _FieldSizeTransitionState();
}

class _FieldSizeTransitionState extends State<_FieldSizeTransition> {
  // Preserve the native editor/focus/selection when the OS motion policy changes
  // the wrapper, rather than disposing the input subtree.
  final _childKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final child = KeyedSubtree(key: _childKey, child: widget.child);
    return widget.duration == Duration.zero
        ? child
        : AnimatedSize(
            duration: widget.duration,
            curve: widget.curve,
            alignment: widget.alignment,
            child: child,
          );
  }
}
