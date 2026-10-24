import '../../theme/skin_theme.dart';

import 'package:flutter/material.dart';

import '../../icons/app_icon.dart';
import '../../identity/element_identity.dart';
import '../../tokens/badge_spec.dart';

/// Content-sized, presentational Badge. Disable is an appearance, not behavior.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.label,
    this.size = BadgeSize.medium,
    this.appearance = BadgeAppearance.filled,
    this.iconMode = BadgeIconMode.none,
    this.icon,
  });
  final String elementId, label;
  final UiRuntimeLocator? runtimeLocator;
  final BadgeSize size;
  final BadgeAppearance appearance;
  final BadgeIconMode iconMode;
  final AppIcon? icon;
  @override
  Widget build(BuildContext context) {
    final spec = BadgeSpec.lookup(
      size,
      appearance,
      Theme.of(context).brightness,
    ).withSkin(SkinTheme.of(context));
    final persian = Directionality.of(context) == TextDirection.rtl;
    final labelBorder = spec.border(spec.labelFrame),
        outerBorder = spec.border(spec.body);
    final text = DecoratedBox(
      decoration: BoxDecoration(
        color: spec.paint(spec.labelFrame, 'fills'),
        border: Border.fromBorderSide(labelBorder),
      ),
      child: Padding(
        // Nested source label strokes participate in layout (84x24 exception).
        padding: EdgeInsetsDirectional.all(labelBorder.strokeInset),
        child: _BadgeLabel(
          label: label,
          // ENGINEERING(D-029): Light disabled foreground readability remap;
          // source paint stays surfaced in spec.resolved().
          style: spec.labelStyle(persian: persian),
        ),
      ),
    );
    Widget? artwork;
    if (iconMode != BadgeIconMode.none) {
      assert(spec.artwork(iconMode) != null, 'Missing source Badge icon style');
      final style = iconMode == BadgeIconMode.fill
          ? AppIconStyle.fill
          : AppIconStyle.outline;
      artwork = ExcludeSemantics(
        child: SizedBox(
          key: const ValueKey('badge-icon-slot'),
          width: spec.iconWidth,
          height: spec.iconHeight,
          child: IconTheme.merge(
            data: IconThemeData(
              size: spec.iconWidth,
              color: spec.effectiveIconColor(iconMode),
            ),
            child:
                icon?.forControl(style) ??
                AssetAppIcon(
                  spec.icon(iconMode).id,
                  style: style,
                  size: spec.iconWidth,
                  color: spec.effectiveIconColor(iconMode),
                ),
          ),
        ),
      );
    }
    return ElementIdentity(
      elementId: elementId,
      runtimeLocator: UiIdentityScope.resolve(
        context,
        override: runtimeLocator,
      ),
      componentId: 'badge.base',
      structureRef: 'badge.base',
      fileKey: spec.fileKey,
      variantId: spec.id,
      componentSetId: spec.setId,
      rawSetName: spec.setName,
      rawVariantName: spec.rawName,
      variants: {
        'size': size.name,
        'appearance': appearance.name,
        'iconMode': iconMode.name,
      },
      declared: {'iconOverride': icon?.iconId, 'iconMode': iconMode.name},
      resolved: {
        'badge': {
          'value': spec.resolved(iconMode: iconMode, persian: persian),
          'origin': 'runtime-resolver',
        },
      },
      child: Opacity(
        opacity: spec.opacity,
        child: DecoratedBox(
          key: const ValueKey('badge-surface'),
          decoration: BoxDecoration(
            color: spec.paint(spec.body, 'fills'),
            border: Border.fromBorderSide(outerBorder),
            borderRadius: BorderRadiusDirectional.all(
              Radius.circular(spec.radius),
            ),
          ),
          child: Padding(
            padding: spec.padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ?artwork,
                if (artwork != null)
                  SizedBox(
                    key: const ValueKey('badge-icon-gap'),
                    width: spec.gap,
                  ),
                Flexible(fit: FlexFit.loose, child: text),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma HUG widths exclude final tracking and round the text advance upward.
/// Measure consumer content, never reserve the source sample's text-frame width.
class _BadgeLabel extends StatelessWidget {
  const _BadgeLabel({required this.label, required this.style});
  final String label;
  final TextStyle style;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scaler = MediaQuery.textScalerOf(context);
      final painter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        textScaler: scaler,
      )..layout();
      final tracking =
          (style.letterSpacing ?? 0) *
          scaler.scale(style.fontSize!) /
          style.fontSize!;
      final natural = (painter.width - tracking).ceilToDouble();
      painter.dispose();
      final width = constraints.hasBoundedWidth
          ? natural.clamp(0, constraints.maxWidth).toDouble()
          : natural;
      return SizedBox(
        width: width,
        child: Text(
          label,
          style: style,
          textAlign: TextAlign.center,
          softWrap: true,
        ),
      );
    },
  );
}
