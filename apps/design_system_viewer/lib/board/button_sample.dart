import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../catalog/button_catalog.dart';
import '../inspection/inspection_record.dart';
import '../inspection/viewer_selection_frame.dart';
import '../l10n/generated/viewer_localizations.dart';
import '../verification/measurement.dart';
import 'preview_settings.dart';

String appearanceName(ViewerLocalizations l, AppButtonType type) =>
    switch (type) {
      AppButtonType.filled => l.filled,
      AppButtonType.tonal => l.tonal,
      AppButtonType.outlined => l.outlined,
      AppButtonType.text => l.textAppearance,
      AppButtonType.disabled => l.disabled,
    };
String familyName(ViewerLocalizations l, AppButtonFamily family) =>
    switch (family) {
      AppButtonFamily.fill => l.fillFamily,
      AppButtonFamily.hug => l.hugFamily,
      AppButtonFamily.icon => l.iconFamily,
    };

class ButtonSample extends StatefulWidget {
  const ButtonSample({
    super.key,
    required this.spec,
    required this.settings,
    required this.selected,
    required this.onSelect,
    required this.onObserve,
    this.referenceInstance,
  });
  final ButtonSpec spec;
  final PreviewSettings settings;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<InspectionRecord> onObserve;
  final Map<String, dynamic>? referenceInstance;
  String get sampleId => referenceInstance?['id'] as String? ?? spec.id;
  @override
  State<ButtonSample> createState() => _ButtonSampleState();
}

class _ButtonSampleState extends State<ButtonSample> {
  final controller = WidgetStatesController();
  ButtonMeasurement? measured;
  Timer? settleTimer;
  bool settling = false;
  bool wasPressed = false;
  @override
  void initState() {
    super.initState();
    controller.addListener(interaction);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) publish();
    });
  }

  @override
  void dispose() {
    settleTimer?.cancel();
    controller.removeListener(interaction);
    controller.dispose();
    super.dispose();
  }

  void interaction() {
    final pressed = controller.value.contains(WidgetState.pressed);
    if (pressed != wasPressed) {
      wasPressed = pressed;
      settleTimer?.cancel();
      settling = true;
      if (!pressed) {
        // Wait conservatively for both possible transition legs before comparison.
        settleTimer = Timer(
          ButtonMotion.pressDuration + ButtonMotion.releaseDuration,
          () {
            if (mounted) {
              setState(() => settling = false);
              publish();
            }
          },
        );
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
        publish();
      }
    });
  }

  Map<String, Object?>? get mountedIdentity {
    Map<String, Object?>? identity;
    void visit(Element element) {
      if (element.widget case final ElementIdentity current) {
        identity = current.descriptor();
      }
      element.visitChildren(visit);
    }

    context.visitChildElements(visit);
    return identity;
  }

  void publish() => widget.onObserve(record(ViewerLocalizations.of(context)));
  @override
  void didUpdateWidget(ButtonSample old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) publish();
    });
  }

  IconDefinition? get iconDefinition {
    if (mode == ButtonIconMode.none) return null;
    try {
      return AppIconRegistry.buttonArtwork(
        widget.spec.id,
        mode == ButtonIconMode.fill ? AppIconStyle.fill : AppIconStyle.outline,
      );
    } on MissingIconArtwork {
      return null;
    }
  }

  bool get unresolved => mode == ButtonIconMode.none
      ? widget.spec.family == AppButtonFamily.icon
      : iconDefinition == null;
  ButtonIconMode get mode => widget.referenceInstance == null
      ? widget.settings.iconMode
      : ButtonIconMode.none;
  String label(ViewerLocalizations l) {
    if (widget.referenceInstance case final Map instance) {
      if (widget.settings.reference) {
        return (instance['text'] as List).single['characters'] as String;
      }
      return widget.sampleId == '18618:12674' ? l.continueEmail : l.playNow;
    }
    if (widget.spec.family == AppButtonFamily.icon) {
      final icon = iconDefinition;
      return icon == null
          ? l.iconStyleRequired
          : l.iconLabel(icon.data['id'] as String);
    }
    return widget.settings.reference
        ? ButtonCatalog.referenceLabel(widget.spec)
        : widget.settings.longLabel
        ? l.longPreviewLabel
        : l.previewLabel;
  }

  Color? instancePaint(bool foreground) {
    final instance = widget.referenceInstance;
    if (instance == null) return null;
    final paints = foreground
        ? (instance['text'] as List).single['fills'] as List
        : instance['fills'] as List;
    final paint = paints.single as Map, c = paint['color'] as Map;
    return Color.from(
      alpha: (paint['opacity'] as num).toDouble(),
      red: (c['r'] as num).toDouble(),
      green: (c['g'] as num).toDouble(),
      blue: (c['b'] as num).toDouble(),
    );
  }

  double get parentWidth =>
      widget.referenceInstance != null &&
          widget.spec.family == AppButtonFamily.fill
      ? (widget.referenceInstance!['width'] as num).toDouble()
      : widget.settings.reference
      ? widget.spec.width
      : widget.settings.fillWidth;
  bool get compatible =>
      !widget.settings.loading &&
      identical(SkinTheme.of(context), productSkin) &&
      !unresolved &&
      widget.settings.reference &&
      widget.settings.scale == 1 &&
      widget.settings.direction == TextDirection.ltr &&
      !settling &&
      !controller.value.contains(WidgetState.pressed) &&
      (widget.referenceInstance != null || mode == ButtonIconMode.fill) &&
      (widget.spec.family != AppButtonFamily.fill ||
          parentWidth ==
              (widget.referenceInstance?['width'] ?? widget.spec.width));
  String comparison(ViewerLocalizations l) {
    if (settling || controller.value.contains(WidgetState.pressed)) {
      return l.settling;
    }
    if (!compatible) return l.notComparable;
    if (measured == null) return l.unavailable;
    return SizeComparison(measured!.visual, sourceSize).ok
        ? l.sizeOk
        : l.sizeDiff;
  }

  Size get sourceSize => Size(
    (widget.referenceInstance?['width'] as num? ?? widget.spec.width)
        .toDouble(),
    (widget.referenceInstance?['height'] as num? ?? widget.spec.height)
        .toDouble(),
  );

  InspectionRecord record(ViewerLocalizations l) {
    final spec = widget.spec;
    final theme = AppThemeFactory.build(
      skin: SkinTheme.of(context),
      brightness: spec.brightness,
    );
    final resolved = spec.resolve(
      theme.extension<ButtonThemeTokens>()!,
      iconMode: mode,
      backgroundColor: identical(SkinTheme.of(context), productSkin)
          ? instancePaint(false)
          : null,
      foregroundColor: identical(SkinTheme.of(context), productSkin)
          ? instancePaint(true)
          : null,
    );
    final font = spec.textStyle;
    final reduced = MediaQuery.disableAnimationsOf(context);
    final enabled = !unresolved && spec.type != AppButtonType.disabled;
    final motionEnabled = enabled && !reduced;
    final state = unresolved
        ? l.unresolved
        : !enabled
        ? l.disabled
        : controller.value.contains(WidgetState.pressed)
        ? l.pressed
        : settling
        ? l.settling
        : controller.value.contains(WidgetState.focused)
        ? l.focused
        : controller.value.contains(WidgetState.hovered)
        ? l.hovered
        : l.rest;
    final hasIcon = mode != ButtonIconMode.none && !unresolved;
    final selectedIcon = iconDefinition;
    final sourceArtwork = selectedIcon?.artwork(
      mode == ButtonIconMode.fill ? AppIconStyle.fill : AppIconStyle.outline,
    );
    final artwork = unresolved
        ? l.unresolved
        : !hasIcon
        ? l.notApplicable
        : '${selectedIcon!.key} / ${mode.name} / ${sourceArtwork!.nodeId}';
    InspectionField f(InspectionFieldId id, Object? value) =>
        InspectionField(id, value);
    return InspectionRecord(
      sampleId: widget.sampleId,
      groups: {
        InspectionGroup.identity: [
          f(InspectionFieldId.family, familyName(l, spec.family)),
          f(InspectionFieldId.setName, spec.setName),
          f(InspectionFieldId.setId, spec.setId),
          f(InspectionFieldId.variantName, spec.rawName),
          f(InspectionFieldId.variantId, spec.id),
          f(InspectionFieldId.fileKey, ButtonCatalog.fileKey),
          f(InspectionFieldId.runtimeIdentity, mountedIdentity?['identity']),
          f(
            InspectionFieldId.status,
            unresolved ? l.unresolved : l.provisional,
          ),
        ],
        InspectionGroup.configuration: [
          f(InspectionFieldId.size, switch (spec.size) {
            AppButtonSize.small => l.small,
            AppButtonSize.medium => l.medium,
            AppButtonSize.large => l.large,
          }),
          f(
            InspectionFieldId.theme,
            spec.brightness == Brightness.dark ? l.dark : l.light,
          ),
          f(InspectionFieldId.appearance, appearanceName(l, spec.type)),
          f(InspectionFieldId.enabled, unresolved ? null : enabled),
          f(InspectionFieldId.label, label(l)),
          f(
            InspectionFieldId.iconMode,
            unresolved
                ? l.unresolved
                : mode == ButtonIconMode.none
                ? l.none
                : mode == ButtonIconMode.fill
                ? l.fillIcon
                : l.outlineIcon,
          ),
          f(InspectionFieldId.artwork, artwork),
          f(InspectionFieldId.artworkSource, sourceArtwork?.data),
          f(
            InspectionFieldId.direction,
            widget.settings.direction == TextDirection.ltr ? l.ltr : l.rtl,
          ),
          f(InspectionFieldId.scale, widget.settings.scale),
          f(
            InspectionFieldId.constraints,
            BoxConstraints(maxWidth: previewWidth),
          ),
        ],
        InspectionGroup.visuals: [
          if (resolved.engineeringOverride != null)
            f(InspectionFieldId.issue, resolved.engineeringOverride),
          f(InspectionFieldId.background, resolved.background),
          f(InspectionFieldId.foreground, resolved.foreground),
          f(InspectionFieldId.borderColor, resolved.border.color),
          f(InspectionFieldId.borderWidth, resolved.border.width),
          f(InspectionFieldId.radius, spec.radius),
          f(InspectionFieldId.padding, spec.padding),
          f(InspectionFieldId.gap, hasIcon ? spec.gap : 0),
          f(
            InspectionFieldId.iconSize,
            unresolved
                ? l.unresolved
                : hasIcon
                ? Size(spec.iconWidth, spec.iconHeight)
                : l.notApplicable,
          ),
          f(InspectionFieldId.fontFamily, font?.fontFamily),
          f(InspectionFieldId.fontSize, font?.fontSize),
          f(InspectionFieldId.fontWeight, font?.fontWeight?.value),
          f(
            InspectionFieldId.lineHeight,
            font == null ? null : font.height! * font.fontSize!,
          ),
          f(InspectionFieldId.letterSpacing, font?.letterSpacing),
        ],
        InspectionGroup.geometry: [
          f(InspectionFieldId.sourceDimensions, sourceSize),
          f(
            InspectionFieldId.minimum,
            unresolved
                ? null
                : Size(
                    spec.family == AppButtonFamily.icon ? spec.width : 0,
                    spec.minimumHeightFor(mode),
                  ),
          ),
          f(InspectionFieldId.visual, measured?.visual),
          f(InspectionFieldId.outer, measured?.outer),
          f(InspectionFieldId.content, measured?.content),
          f(
            InspectionFieldId.comparison,
            '${comparison(l)}${spec.hasHeightConflict ? '\n${l.sourceConflict}' : ''}',
          ),
        ],
        InspectionGroup.interaction: [
          f(
            InspectionFieldId.pressedScale,
            motionEnabled ? ButtonMotion.pressedScale : ButtonMotion.restScale,
          ),
          f(
            InspectionFieldId.pressDuration,
            motionEnabled ? ButtonMotion.pressDuration.inMilliseconds : 0,
          ),
          f(
            InspectionFieldId.releaseDuration,
            motionEnabled ? ButtonMotion.releaseDuration.inMilliseconds : 0,
          ),
          f(InspectionFieldId.curve, ButtonMotion.curve),
          f(
            InspectionFieldId.motionOrigin,
            reduced
                ? '${l.engineeringMotion} · ${l.motionReduced}'
                : l.engineeringMotion,
          ),
          f(InspectionFieldId.currentState, state),
        ],
      },
    );
  }

  double get previewWidth => widget.spec.family == AppButtonFamily.fill
      ? parentWidth
      : widget.spec.family == AppButtonFamily.icon
      ? math.max(widget.spec.width, 72.0)
      : math.max(
          170.0,
          widget.settings.reference
              ? widget.spec.width
              : widget.settings.fillWidth,
        );
  @override
  Widget build(BuildContext context) {
    final l = ViewerLocalizations.of(context),
        spec = widget.spec,
        settings = widget.settings;
    final theme = AppThemeFactory.build(
      skin: SkinTheme.of(context),
      brightness: spec.brightness,
    );
    final width = previewWidth;
    return SizedBox(
      width: width + 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: '${l.inspect}: ${spec.rawName} / ${widget.sampleId}',
            child: TextButton(
              key: ValueKey('inspect-${widget.sampleId}'),
              onPressed: () {
                widget.onSelect();
                publish();
              },
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                appearanceName(l, spec.type),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          ViewerSelectionFrame(
            key: ValueKey('selection-${widget.sampleId}'),
            selected: widget.selected,
            onInspect: spec.type == AppButtonType.disabled || unresolved
                ? () {
                    widget.onSelect();
                    publish();
                  }
                : null,
            child: SizedBox(
              width: width,
              child: unresolved
                  ? Semantics(
                      label: l.sourceIconUnresolved,
                      child: SizedBox(
                        width: math.max(spec.width, 64),
                        height: spec.height,
                        child: Center(
                          child: Text(
                            mode == ButtonIconMode.none
                                ? l.iconStyleRequired
                                : l.unresolved,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    )
                  : Theme(
                      data: theme,
                      child: Directionality(
                        textDirection: settings.direction,
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            textScaler: TextScaler.linear(settings.scale),
                          ),
                          child: Align(
                            alignment: AlignmentDirectional.center,
                            child: MeasuredButton(
                              key: ValueKey(
                                'measurement-${widget.sampleId}-${settings.revision}',
                              ),
                              onMeasurement: (value) {
                                if (mounted) {
                                  setState(() => measured = value);
                                  publish();
                                }
                              },
                              child: AppButton(
                                key: ValueKey('button-${widget.sampleId}'),
                                elementId: widget.referenceInstance == null
                                    ? 'viewer.button.${spec.brightness.name}.${spec.data['logicalKey']}.control'
                                    : 'viewer.button.reference.node-${widget.sampleId.replaceAll(':', '-')}.control',
                                loading: widget.settings.loading,
                                loadingSemanticsLabel: l.buttonLoadingSemantics,
                                label: label(l),
                                family: spec.family,
                                size: spec.size,
                                type: spec.type,
                                iconMode: mode,
                                icon: mode == ButtonIconMode.none
                                    ? null
                                    : AssetAppIcon(iconDefinition!.id),
                                statesController: controller,
                                backgroundColor:
                                    identical(
                                      SkinTheme.of(context),
                                      productSkin,
                                    )
                                    ? instancePaint(false)
                                    : null,
                                foregroundColor:
                                    identical(
                                      SkinTheme.of(context),
                                      productSkin,
                                    )
                                    ? instancePaint(true)
                                    : null,
                                onPressed: spec.type == AppButtonType.disabled
                                    ? null
                                    : () {
                                        widget.onSelect();
                                        publish();
                                      },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          if (settings.measurements && !unresolved)
            Text(
              comparison(l),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
