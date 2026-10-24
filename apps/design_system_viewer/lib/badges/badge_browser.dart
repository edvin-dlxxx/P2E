import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../inspection/inspection_record.dart';
import '../inspection/viewer_selection_frame.dart';
import '../l10n/generated/viewer_localizations.dart';
import '../verification/measurement.dart';
import '../viewer_style.dart';

String badgeAppearance(ViewerLocalizations l, BadgeAppearance appearance) =>
    switch (appearance) {
      BadgeAppearance.filled => l.filled,
      BadgeAppearance.tonal => l.tonal,
      BadgeAppearance.outlined => l.outlined,
      BadgeAppearance.text => l.textAppearance,
      BadgeAppearance.disabled => l.disabled,
    };

class BadgeBrowser extends StatefulWidget {
  const BadgeBrowser({
    super.key,
    required this.selected,
    required this.onInspect,
  });
  final String? selected;
  final ValueChanged<InspectionRecord?> onInspect;
  @override
  State<BadgeBrowser> createState() => _BadgeBrowserState();
}

class _BadgeBrowserState extends State<BadgeBrowser> {
  String theme = 'all', size = 'all', appearance = 'all', direction = 'auto';
  BadgeIconMode iconMode = BadgeIconMode.fill;
  double scale = 1;
  bool reference = true, longLabel = false;
  ViewerLocalizations get l => ViewerLocalizations.of(context);
  TextDirection get previewDirection => direction == 'auto'
      ? Directionality.of(context)
      : direction == 'rtl'
      ? TextDirection.rtl
      : TextDirection.ltr;
  List<BadgeSpec> get rows => BadgeSpec.all
      .where(
        (s) =>
            (theme == 'all' || s.brightness.name == theme) &&
            (size == 'all' || s.size.name == size) &&
            (appearance == 'all' || s.appearance.name == appearance),
      )
      .toList();
  void change(VoidCallback fn) {
    setState(fn);
    if (widget.selected != null && !rows.any((s) => s.id == widget.selected)) {
      widget.onInspect(null);
    }
  }

  Widget control(
    String key,
    String label,
    String value,
    Map<String, String> choices,
    ValueChanged<String> onChanged,
  ) => SizedBox(
    width: 190,
    child: DropdownButtonFormField<String>(
      key: ValueKey('badge-$key-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      icon: ExcludeSemantics(child: Text(l.dropdownMark)),
      items: [
        for (final e in choices.entries)
          DropdownMenuItem(
            value: e.key,
            child: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) {
        if (v != null) change(() => onChanged(v));
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    final visible = rows;
    // PHYSICAL: preserve source set order (size, then Dark/Light) on the board.
    final sets = visible.map((s) => s.setId).toSet();
    return SingleChildScrollView(
      key: const ValueKey('badges-scroll'),
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewerPanel(
            color: ViewerStyle.panelRaised,
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    control('theme', l.theme, theme, {
                      'all': l.all,
                      'dark': l.dark,
                      'light': l.light,
                    }, (v) => theme = v),
                    control('size', l.size, size, {
                      'all': l.all,
                      'small': l.small,
                      'medium': l.medium,
                      'large': l.large,
                    }, (v) => size = v),
                    control(
                      'appearance',
                      l.fieldLabel('appearance'),
                      appearance,
                      {
                        'all': l.all,
                        for (final a in BadgeAppearance.values)
                          a.name: badgeAppearance(l, a),
                      },
                      (v) => appearance = v,
                    ),
                    control('icon', l.iconMode, iconMode.name, {
                      'none': l.noIcon,
                      'fill': l.fillIcon,
                      'outline': l.outlineIcon,
                    }, (v) => iconMode = BadgeIconMode.values.byName(v)),
                    control(
                      'copy',
                      l.previewLabel,
                      reference ? 'source' : 'localized',
                      {
                        'source': l.badgeReference,
                        'localized': l.badgeLocalized,
                      },
                      (v) => reference = v == 'source',
                    ),
                    control('scale', l.textScale, scale.toString(), {
                      '1.0': '1.0',
                      '1.3': '1.3',
                    }, (v) => scale = double.parse(v)),
                    control('direction', l.previewDirection, direction, {
                      'auto': l.followLanguage,
                      'ltr': l.ltr,
                      'rtl': l.rtl,
                    }, (v) => direction = v),
                    FilterChip(
                      key: const ValueKey('badge-long'),
                      label: Text(l.fieldLongCopy),
                      selected: longLabel,
                      onSelected: (v) => change(() => longLabel = v),
                    ),
                    TextButton(
                      key: const ValueKey('badge-reset'),
                      onPressed: () => change(() {
                        theme = size = appearance = 'all';
                        direction = 'auto';
                        iconMode = BadgeIconMode.fill;
                        scale = 1;
                        reference = true;
                        longLabel = false;
                      }),
                      child: Text(l.reset),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l.badgeCount(visible.length, BadgeSpec.all.length),
                  key: const ValueKey('badge-count'),
                ),
                Text(l.badgePreviewNotice),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (visible.isEmpty)
            Text(l.emptyState)
          else
            Wrap(
              textDirection: TextDirection.ltr,
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final set in sets)
                  Column(
                    key: ValueKey('badge-set-$set'),
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(visible.firstWhere((s) => s.setId == set).setName),
                      const SizedBox(height: 8),
                      ColoredBox(
                        color: ButtonThemeTokens.forBrightness(
                          visible.firstWhere((s) => s.setId == set).brightness,
                        ).color('Surface/Base'),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.all(12),
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              for (final spec in visible.where(
                                (s) => s.setId == set,
                              ))
                                BadgeSample(
                                  key: ValueKey('badge-sample-${spec.id}'),
                                  spec: spec,
                                  label: longLabel
                                      ? l.badgeLong
                                      : reference
                                      ? spec.referenceLabel
                                      : l.badgeShort,
                                  sourceReference: reference && !longLabel,
                                  iconMode: iconMode,
                                  scale: scale,
                                  direction: previewDirection,
                                  selected: widget.selected == spec.id,
                                  onInspect: widget.onInspect,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class BadgeSample extends StatefulWidget {
  const BadgeSample({
    super.key,
    required this.spec,
    required this.label,
    required this.sourceReference,
    required this.iconMode,
    required this.scale,
    required this.direction,
    required this.selected,
    required this.onInspect,
  });
  final BadgeSpec spec;
  final String label;
  final bool sourceReference, selected;
  final BadgeIconMode iconMode;
  final double scale;
  final TextDirection direction;
  final ValueChanged<InspectionRecord?> onInspect;
  @override
  State<BadgeSample> createState() => _BadgeSampleState();
}

class _BadgeSampleState extends State<BadgeSample> {
  final anchor = GlobalKey();
  Size? measured;
  Map<String, Object?>? identity;
  @override
  void didUpdateWidget(BadgeSample old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.selected) publish();
    });
  }

  void measure(Size size) {
    measured = size;
    readIdentity();
    if (widget.selected) publish();
  }

  void readIdentity() {
    void visit(Element e) {
      if (e.widget case final ElementIdentity w) {
        identity = w.descriptor();
      }
      e.visitChildren(visit);
    }

    anchor.currentContext?.visitChildElements(visit);
  }

  void publish() {
    readIdentity();
    final l = ViewerLocalizations.of(context), s = widget.spec;
    final styles = s.resolved(
      iconMode: widget.iconMode,
      persian: widget.direction == TextDirection.rtl,
    );
    final font = s.textStyle(persian: widget.direction == TextDirection.rtl),
        stroke = s.border(s.body);
    InspectionField f(InspectionFieldId id, Object? value) =>
        InspectionField(id, value);
    widget.onInspect(
      InspectionRecord(
        sampleId: s.id,
        groups: {
          InspectionGroup.identity: [
            f(InspectionFieldId.family, l.badges),
            f(InspectionFieldId.runtimeIdentity, identity),
            f(InspectionFieldId.fileKey, s.fileKey),
            f(InspectionFieldId.setId, s.setId),
            f(InspectionFieldId.setName, s.setName),
            f(InspectionFieldId.variantId, s.id),
            f(InspectionFieldId.variantName, s.rawName),
            f(InspectionFieldId.status, l.provisional),
            f(InspectionFieldId.sourceCovered, true),
          ],
          InspectionGroup.configuration: [
            f(InspectionFieldId.size, s.size.name),
            f(InspectionFieldId.theme, s.brightness.name),
            f(InspectionFieldId.appearance, badgeAppearance(l, s.appearance)),
            f(InspectionFieldId.label, widget.label),
            f(InspectionFieldId.iconMode, widget.iconMode.name),
            f(InspectionFieldId.artworkSource, s.artwork(widget.iconMode)),
            f(InspectionFieldId.scale, widget.scale),
            f(InspectionFieldId.direction, widget.direction.name),
          ],
          InspectionGroup.visuals: [
            f(InspectionFieldId.background, s.paint(s.body, 'fills')),
            f(InspectionFieldId.foreground, s.effectiveForegroundColor),
            f(InspectionFieldId.borderColor, stroke.color),
            f(InspectionFieldId.borderWidth, stroke.width),
            f(InspectionFieldId.radius, s.radius),
            f(InspectionFieldId.padding, s.padding),
            f(
              InspectionFieldId.gap,
              widget.iconMode == BadgeIconMode.none ? 0 : s.gap,
            ),
            f(
              InspectionFieldId.iconSize,
              widget.iconMode == BadgeIconMode.none
                  ? null
                  : Size(s.iconWidth, s.iconHeight),
            ),
            f(InspectionFieldId.fontFamily, font.fontFamily),
            f(InspectionFieldId.fontSize, font.fontSize),
            f(InspectionFieldId.fontWeight, font.fontWeight?.value),
            f(InspectionFieldId.lineHeight, font.height! * font.fontSize!),
            f(InspectionFieldId.letterSpacing, font.letterSpacing),
            f(InspectionFieldId.resolvedStyles, {
              ...styles,
              'sourceReferenceConfiguration':
                  widget.sourceReference &&
                  widget.iconMode == BadgeIconMode.fill &&
                  widget.scale == 1 &&
                  widget.direction == TextDirection.ltr,
              'engineeringVisualOverrides': [
                if (s.readabilityOverride) 'D-029',
              ],
              'unresolvedMappings': const <String>[],
            }),
            f(
              InspectionFieldId.issue,
              s.readabilityOverride
                  ? s.engineeringOverride(widget.iconMode)
                  : s.id == '18437:2331'
                  ? l.badgeGeometryNote
                  : null,
            ),
          ],
          InspectionGroup.geometry: [
            f(InspectionFieldId.sourceDimensions, s.sourceSize),
            f(InspectionFieldId.visual, measured),
            f(InspectionFieldId.outer, measured),
          ],
          InspectionGroup.interaction: [
            f(InspectionFieldId.motion, styles['motion']),
          ],
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.spec;
    return ViewerSelectionFrame(
      selected: widget.selected,
      onInspect: publish,
      child: Theme(
        data: AppThemeFactory.build(
          skin: SkinTheme.of(context),
          brightness: s.brightness,
        ),
        child: Directionality(
          textDirection: widget.direction,
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(widget.scale)),
            child: MeasureBox(
              onSize: measure,
              child: KeyedSubtree(
                key: anchor,
                child: AppBadge(
                  elementId: 'viewer.badge.${s.identityKey}',
                  label: widget.label,
                  size: s.size,
                  appearance: s.appearance,
                  iconMode: widget.iconMode,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
