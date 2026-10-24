import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart'
    show kReleaseMode, precisionErrorTolerance;

import '../../icons/app_icon.dart';
import '../../identity/element_identity.dart';
import '../../theme/button_theme_tokens.dart';
import '../../theme/skin_theme.dart';
import '../../tokens/specs/button_spec.dart';
import '../../tokens/specs/generated/app_button_spec.g.dart';
import '../../interaction/press_action.dart';
import '../../tokens/generated/readiness_tokens.g.dart';
import '../../tokens/field_spec.dart' show FieldMotion;

export '../../tokens/specs/button_spec.dart'
    show
        AppButtonFamily,
        AppButtonSize,
        AppButtonType,
        ButtonIconMode,
        AppButtonTone;

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.label,
    required this.onPressed,
    this.family = AppButtonFamily.hug,
    this.size = AppButtonSize.medium,
    this.type = AppButtonType.filled,
    this.tone = AppButtonTone.source,
    this.icon,
    this.iconMode = ButtonIconMode.none,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.statesController,
    this.loading = false,
    this.loadingSemanticsLabel,
  }) : assert(
         tone == AppButtonTone.source || type == AppButtonType.filled,
         'Accent tone is supported only for Filled Button',
       ),
       assert(
         family != AppButtonFamily.icon || iconMode != ButtonIconMode.none,
         'Icon-only Button requires an explicit fill/outline icon mode',
       ),
       assert(
         iconMode == ButtonIconMode.none || icon != null,
         'An icon-bearing Button requires real AppIcon artwork',
       ),
       assert(
         iconMode != ButtonIconMode.none || icon == null,
         'A no-icon Button cannot also receive artwork',
       );

  final String elementId;
  final UiRuntimeLocator? runtimeLocator;
  final String label;
  final VoidCallback? onPressed;
  final AppButtonFamily family;
  final AppButtonSize size;
  final AppButtonType type;
  final AppButtonTone tone;
  final AppIcon? icon;
  final ButtonIconMode iconMode;
  // Explicitly authorized owner parameters; default source paints stay central.
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  /// Optional framework state observation; no viewer dependency.
  final WidgetStatesController? statesController;
  final bool loading;
  final String? loadingSemanticsLabel;

  @override
  State<AppButton> createState() => _AppButtonState();

  Widget _build(BuildContext context, _AppButtonState state) {
    if ((family == AppButtonFamily.icon && iconMode == ButtonIconMode.none) ||
        (iconMode != ButtonIconMode.none && icon == null) ||
        (iconMode == ButtonIconMode.none && icon != null)) {
      throw ArgumentError('Invalid Button icon mode/artwork combination');
    }
    final theme = Theme.of(context);
    final roles = SkinTheme.of(context).valuesFor(theme.brightness);
    final tokens = theme.extension<ButtonThemeTokens>();
    if (tokens == null) {
      throw StateError('AppButton requires ButtonThemeTokens');
    }
    final enabled = onPressed != null && type != AppButtonType.disabled;
    final retainedDisabledFocus = !enabled && state.focusNode.hasFocus;
    ResolvedButtonStyle resolve(AppButtonType appearance) =>
        ButtonSpec.lookup(
          family: family,
          size: size,
          type: appearance,
          brightness: theme.brightness,
        ).resolve(
          tokens,
          iconMode: iconMode,
          backgroundColor:
              tone == AppButtonTone.accent &&
                  appearance != AppButtonType.disabled
              ? roles.actionAccent
              : backgroundColor,
          foregroundColor:
              tone == AppButtonTone.accent &&
                  appearance != AppButtonType.disabled
              ? roles.actionOnAccent
              : foregroundColor,
          borderColor: borderColor,
        );
    final normal = resolve(enabled ? type : AppButtonType.disabled);
    final paint = loading
        ? resolve(type == AppButtonType.disabled ? AppButtonType.filled : type)
        : normal;
    // D-045: keep the configured normal row's geometry, including disabled rows.
    final style = loading
        ? ResolvedButtonStyle(
            spec: normal.spec,
            iconMode: iconMode,
            background: paint.background,
            foreground: paint.foreground,
            iconColor: paint.iconColor,
            border: paint.border.copyWith(width: normal.border.width),
            sourceForeground: paint.sourceForeground,
            sourceIconColor: paint.sourceIconColor,
            readabilityOverride: paint.readabilityOverride,
          )
        : normal;
    final spec = style.spec;
    Widget? iconSlot;
    if (iconMode != ButtonIconMode.none) {
      iconSlot = SizedBox(
        key: const ValueKey('app-button-icon-slot'),
        width: spec.iconWidth,
        height: spec.iconHeight,
        child: IconTheme.merge(
          data: IconThemeData(color: style.iconColor, size: spec.iconWidth),
          child: ExcludeSemantics(
            child: icon!.forControl(
              iconMode == ButtonIconMode.fill
                  ? AppIconStyle.fill
                  : AppIconStyle.outline,
            ),
          ),
        ),
      );
    }
    final content = Row(
      textDirection: Directionality.of(context),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ?iconSlot,
        if (spec.hasText && iconSlot != null)
          SizedBox(key: const ValueKey('app-button-icon-gap'), width: spec.gap),
        if (spec.hasText)
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: style.spec.textStyle!.copyWith(color: style.foreground),
            ),
          ),
      ],
    );
    final button = PressAction(
      onPressed: loading || retainedDisabledFocus
          ? () {}
          : enabled
          ? onPressed
          : null,
      focusNode: state.focusNode,
      interactionSuppressed: loading || !enabled,
      style: style.material,
      statesController: statesController,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Opacity(opacity: loading ? 0 : 1, child: content),
          if (loading)
            Positioned.fill(
              child: Center(
                child: ExcludeSemantics(
                  child: SizedBox(
                    width: spec.iconWidth,
                    height: spec.iconHeight,
                    child: CircularProgressIndicator(
                      value: MediaQuery.disableAnimationsOf(context)
                          ? buttonLoadingStaticProgress
                          : null,
                      color: style.foreground,
                      strokeWidth: buttonLoadingStrokeWidth,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    final accessibleLabel = loading
        ? (loadingSemanticsLabel == null ||
                  loadingSemanticsLabel!.trim().isEmpty
              ? label
              : '$label, $loadingSemanticsLabel')
        : spec.hasText && !retainedDisabledFocus
        ? null
        : label;
    return _ButtonTapExtent(
      child: ElementIdentity(
        elementId: elementId,
        runtimeLocator: UiIdentityScope.resolve(
          context,
          override: runtimeLocator,
        ),
        componentId: 'button.base',
        structureRef: 'button.${family.name}.base',
        fileKey: appButtonSpecData['fileKey'] as String,
        variantId: spec.id,
        componentSetId: spec.setId,
        rawSetName: spec.setName,
        rawVariantName: spec.rawName,
        variants: {
          'family': family.name,
          'size': size.name,
          'type': spec.type.name,
          'iconMode': iconMode.name,
          'enabled': (enabled && !loading).toString(),
        },
        declared: {
          if (tone != AppButtonTone.source) 'tone': tone.name,
          'loading': loading,
          'colorOverride': {
            'value':
                backgroundColor != null ||
                foregroundColor != null ||
                borderColor != null,
            'origin': 'usage',
          },
          'iconId': {'value': icon?.iconId, 'origin': 'usage'},
          'iconMode': {'value': iconMode.name, 'origin': 'usage'},
        },
        resolved: {
          'tapEnvelopeMinimum': {
            'value': FieldMotion.tapExtent,
            'origin': 'engineering-D-059; layout-neutral hit envelope',
          },
          if (style.engineeringOverride != null)
            'disabledReadability': {
              'value': style.engineeringOverride,
              'origin': 'engineering-D-029',
            },
          'sourceGeometry': {
            'value': spec.data['geometry'],
            'origin': 'figma-reference',
          },
          'sourceType': {
            'value': spec.type.name,
            'origin': 'component-default',
          },
          'backgroundColor': {
            'value': style.background == null
                ? null
                : {
                    'r': style.background!.r,
                    'g': style.background!.g,
                    'b': style.background!.b,
                    'a': style.background!.a,
                  },
            'origin': backgroundColor == null ? 'runtime-resolver' : 'usage',
          },
          'foregroundColor': {
            'value': {
              'r': style.foreground.r,
              'g': style.foreground.g,
              'b': style.foreground.b,
              'a': style.foreground.a,
            },
            'origin': foregroundColor == null ? 'runtime-resolver' : 'usage',
          },
        },
        child: Semantics(
          label: accessibleLabel,
          button: true,
          enabled: enabled && !loading,
          focusable: loading || retainedDisabledFocus ? true : null,
          focused: loading || retainedDisabledFocus
              ? state.focusNode.hasFocus
              : null,
          onDidGainAccessibilityFocus: loading
              ? state.focusNode.requestFocus
              : null,
          child: ExcludeSemantics(
            excluding: loading || retainedDisabledFocus,
            child: Opacity(
              opacity: loading ? paint.spec.opacity : spec.opacity,
              child: family == AppButtonFamily.fill
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        if (!constraints.hasBoundedWidth) {
                          throw FlutterError(
                            'Fill AppButton requires a bounded parent width',
                          );
                        }
                        return SizedBox(
                          width: constraints.maxWidth,
                          child: button,
                        );
                      },
                    )
                  : button,
            ),
          ),
        ),
      ),
    );
  }
}

/// D-059: an invisible hit envelope, without adding layout/paint padding.
/// The host must leave room for targets, as with Flutter's padded buttons.
/// Place around a layout group inside its surrounding free space. This interaction
/// infrastructure has no visual/semantic identity of its own.
class ButtonHitRegion extends SingleChildRenderObjectWidget {
  const ButtonHitRegion({super.key, required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderButtonHitRegion();
}

/// Read-only type marker also used by the optional Inspector containment check.
class RenderButtonHitRegion extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final point = localToGlobal(position);
    var hit = false;
    void visit(RenderObject object) {
      if (hit ||
          object is RenderOffstage && object.offstage ||
          object is RenderIgnorePointer && object.ignoring ||
          object is RenderAbsorbPointer && object.absorbing) {
        return;
      }
      if (object is _RenderButtonTapExtent && object.hasSize) {
        final local = object.globalToLocal(point);
        if (!object.size.contains(local) && object._tapBounds.contains(local)) {
          hit = result.addWithRawTransform(
            transform: Matrix4.inverted(object.getTransformTo(this)),
            position: position,
            hitTest: (result, local) => object.hitTest(result, position: local),
          );
        }
      } else {
        object.visitChildren((child) {
          final clip = object.describeApproximatePaintClip(child);
          if (clip != null &&
              object is RenderBox &&
              !clip.contains(object.globalToLocal(point))) {
            return;
          }
          visit(child);
        });
      }
    }

    visit(child!);
    return hit || super.hitTest(result, position: position);
  }
}

class _ButtonTapExtent extends SingleChildRenderObjectWidget {
  const _ButtonTapExtent({required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderButtonTapExtent();
}

class _RenderButtonTapExtent extends RenderProxyBox {
  Rect get _tapBounds => Rect.fromCenter(
    center: size.center(Offset.zero),
    width: size.width < FieldMotion.tapExtent
        ? FieldMotion.tapExtent
        : size.width,
    height: size.height < FieldMotion.tapExtent
        ? FieldMotion.tapExtent
        : size.height,
  );

  @override
  Rect get semanticBounds => _tapBounds;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config.isSemanticBoundary = true;
    config.isMergingSemanticsOfDescendants = true;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final bounds = _tapBounds;
    if (!bounds.contains(position)) return false;
    // Overlapping padded targets use visual distance, not reverse paint order.
    // Keep native TextButton gestures and the layout/paint geometry untouched.
    final globalPoint = localToGlobal(position);
    double distanceToVisual(_RenderButtonTapExtent box) {
      final local = box.globalToLocal(globalPoint);
      final dx = local.dx < 0
          ? -local.dx
          : local.dx > box.size.width
          ? local.dx - box.size.width
          : 0.0;
      final dy = local.dy < 0
          ? -local.dy
          : local.dy > box.size.height
          ? local.dy - box.size.height
          : 0.0;
      return dx * dx + dy * dy;
    }

    final ownDistance = distanceToVisual(this);
    if (ownDistance > 0) {
      RenderObject root = this;
      while (root.parent != null) {
        root = root.parent!;
      }
      var closer = false;
      void visit(RenderObject object) {
        if (closer ||
            object is RenderOffstage && object.offstage ||
            object is RenderOpacity && object.opacity == 0 ||
            object is RenderIgnorePointer && object.ignoring ||
            object is RenderAbsorbPointer && object.absorbing) {
          return;
        }
        if (object is _RenderButtonTapExtent &&
            object != this &&
            object.attached &&
            object.hasSize &&
            object._tapBounds.contains(object.globalToLocal(globalPoint)) &&
            distanceToVisual(object) < ownDistance) {
          closer = true;
          return;
        }
        object.visitChildren(visit);
      }

      visit(root);
      if (closer) return false;
    }
    final inside = Offset(
      position.dx.clamp(0, size.width - precisionErrorTolerance),
      position.dy.clamp(0, size.height - precisionErrorTolerance),
    );
    return result.addWithPaintOffset(
      offset: position - inside,
      position: position,
      hitTest: (result, local) => super.hitTest(result, position: local),
    );
  }
}

class _AppButtonState extends State<AppButton> {
  final focusNode = FocusNode();
  bool reportedMissingLabel = false;
  @override
  void initState() {
    super.initState();
    focusNode.addListener(focusChanged);
  }

  void focusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    focusNode.removeListener(focusChanged);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kReleaseMode &&
        widget.loading &&
        (widget.loadingSemanticsLabel == null ||
            widget.loadingSemanticsLabel!.trim().isEmpty) &&
        !reportedMissingLabel) {
      reportedMissingLabel = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: FlutterError(
              'AppButton loading contract violation: loadingSemanticsLabel is missing; using button label as the accessible fallback.',
            ),
            library: 'p2e_design_system',
            context: ErrorDescription(
              'while rendering AppButton loading state (D-045)',
            ),
          ),
        );
      });
    }
    return widget._build(context, this);
  }
}
