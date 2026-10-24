import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../inspection/inspection_record.dart';
import '../inspection/viewer_selection_frame.dart';
import '../l10n/generated/viewer_localizations.dart';
import '../verification/measurement.dart';
import '../viewer_style.dart';

class FieldBrowser extends StatefulWidget {
  const FieldBrowser({
    super.key,
    required this.selected,
    required this.onInspect,
    required this.family,
  });
  final FieldFamily family;
  final String? selected;
  final ValueChanged<InspectionRecord?> onInspect;
  @override
  State<FieldBrowser> createState() => _FieldBrowserState();
}

class _FieldBrowserState extends State<FieldBrowser> {
  final text = TextEditingController(),
      password = TextEditingController(),
      otp = TextEditingController();
  final records = <String, FieldRuntimeSnapshot>{};
  final sizes = <String, ({Size outer, Size? visual})>{};
  String theme = 'all',
      state = 'all',
      coverage = 'all',
      visibility = 'all',
      direction = 'auto',
      feedback = 'neutral';
  double scale = 1;
  bool required = true,
      indicator = true,
      supporting = true,
      supportIcon = true,
      reference = true,
      longCopy = false,
      allowDeselect = false;
  int? radio;
  String? localeCode;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Localizations.localeOf(context).languageCode;
    if (localeCode != next) {
      localeCode = next;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.selected != null) select(widget.selected!);
      });
    }
  }

  @override
  void dispose() {
    text.dispose();
    password.dispose();
    otp.dispose();
    super.dispose();
  }

  ViewerLocalizations get l => ViewerLocalizations.of(context);
  String familyLabel(FieldFamily f) => switch (f) {
    FieldFamily.textField => l.fieldText,
    FieldFamily.password => l.fieldPassword,
    FieldFamily.otp => l.fieldOtp,
    FieldFamily.radio => l.fieldRadio,
  };
  FieldRequirement get requirement =>
      required ? FieldRequirement.required : FieldRequirement.optional;
  FieldRequirementLabels get labels => FieldRequirementLabels(
    required: l.fieldRequired,
    optional: l.fieldOptional,
  );
  FieldFeedback get validation => feedback == 'error'
      ? FieldFeedback.error(longCopy ? l.fieldLongHelper : l.fieldError)
      : feedback == 'success'
      ? FieldFeedback.success(message: l.fieldSuccess)
      : const FieldFeedback.neutral();
  TextDirection get previewDirection => direction == 'auto'
      ? Directionality.of(context)
      : direction == 'rtl'
      ? TextDirection.rtl
      : TextDirection.ltr;
  List<FieldSpec> get sourceSpecs =>
      FieldSpec.all.where((s) => s.family == widget.family).toList();
  bool get isText => widget.family == FieldFamily.textField || isPassword;
  bool get isPassword => widget.family == FieldFamily.password;
  bool get isRadio => widget.family == FieldFamily.radio;
  bool get hasDerived => isPassword || widget.family == FieldFamily.otp;
  Set<String> get states => {
    for (final s in sourceSpecs)
      (s.data['state'] as String).split(' - Visibility')[0],
  };
  List<FieldSpec> get allPreviews => [
    if (coverage != 'derived') ...sourceSpecs,
    if (coverage != 'source' && hasDerived)
      for (final s in sourceSpecs.where((s) => s.brightness == Brightness.dark))
        FieldSpec(s.data, Brightness.light, derived: true),
  ];
  List<FieldSpec> get rows => allPreviews
      .where(
        (s) =>
            (theme == 'all' || s.brightness.name == theme) &&
            (state == 'all' ||
                (s.data['state'] as String).split(' - Visibility')[0] ==
                    state) &&
            (s.family != FieldFamily.password ||
                visibility == 'all' ||
                (s.data['state'] as String).endsWith(
                  visibility == 'shown' ? ' On' : ' Off',
                )),
      )
      .toList();
  InspectionRecord inspection(String id, FieldRuntimeSnapshot snapshot) {
    final data = snapshot.toJson(), spec = snapshot.spec, measured = sizes[id];
    InspectionField f(InspectionFieldId key, Object? value) =>
        InspectionField(key, value);
    return InspectionRecord(
      sampleId: id,
      groups: {
        InspectionGroup.identity: [
          f(InspectionFieldId.family, familyLabel(spec.family)),
          f(InspectionFieldId.runtimeIdentity, data),
          f(InspectionFieldId.fileKey, spec.data['fileKey']),
          f(InspectionFieldId.variantId, data['variantId']),
          f(InspectionFieldId.setId, data['setId']),
          f(InspectionFieldId.setName, data['rawSetName']),
          f(InspectionFieldId.variantName, data['rawVariantName']),
          f(InspectionFieldId.sourceCovered, snapshot.sourceCovered),
          f(
            InspectionFieldId.status,
            snapshot.sourceCovered ? l.fieldSource : l.fieldDerived,
          ),
        ],
        InspectionGroup.configuration: [
          f(InspectionFieldId.currentState, snapshot.state.name),
          f(InspectionFieldId.validation, snapshot.validation.name),
          f(InspectionFieldId.requirement, {
            'value': snapshot.requirement.name,
            'indicatorVisible': snapshot.showRequirement,
          }),
          f(InspectionFieldId.supporting, snapshot.supporting),
          f(InspectionFieldId.supportingIcon, snapshot.supportingIcon),
          f(InspectionFieldId.passwordVisible, snapshot.passwordVisible),
          f(InspectionFieldId.codeLength, snapshot.codeLength),
          f(InspectionFieldId.complete, snapshot.complete),
          f(InspectionFieldId.radioSelection, snapshot.selected),
          f(InspectionFieldId.enabled, snapshot.enabled),
        ],
        InspectionGroup.visuals: [
          f(InspectionFieldId.background, spec.color('body')),
          f(InspectionFieldId.borderColor, spec.color('body', stroke: true)),
          f(InspectionFieldId.resolvedStyles, {
            ...spec.visualMetadata,
            'effectiveFontFamily': snapshot.effectiveFontFamily,
            'actualTypography': snapshot.resolvedTypography,
            'textScale': snapshot.textScale,
            'unresolvedMappings': const <String>[],
            if (snapshot.runtimeExtension?.startsWith('otp-group') == true)
              'groupHelperRole':
                  'Base TextField/supportText (engineering composition)',
          }),
          f(InspectionFieldId.artworkSource, spec.icons),
        ],
        InspectionGroup.geometry: [
          f(
            InspectionFieldId.sourceDimensions,
            snapshot.runtimeExtension?.startsWith('otp-group') == true
                ? null
                : spec.sourceSize,
          ),
          f(InspectionFieldId.visual, measured?.visual),
          f(InspectionFieldId.outer, measured?.outer),
        ],
        InspectionGroup.interaction: [
          f(InspectionFieldId.motion, {
            ...FieldMotion.metadata,
            'reduced': snapshot.motionReduced,
            'effectiveMilliseconds': {
              'label': snapshot.motionReduced
                  ? 0
                  : FieldMotion.label.inMilliseconds,
              'color': snapshot.motionReduced
                  ? 0
                  : FieldMotion.color.inMilliseconds,
              'support': snapshot.motionReduced
                  ? 0
                  : FieldMotion.support.inMilliseconds,
              'radioHover': snapshot.motionReduced
                  ? 0
                  : FieldMotion.hover.inMilliseconds,
            },
          }),
        ],
      },
    );
  }

  void observe(String id, FieldRuntimeSnapshot value) {
    records[id] = value;
    if (widget.selected == id) widget.onInspect(inspection(id, value));
  }

  void select(String id) {
    final record = records[id];
    if (record != null) widget.onInspect(inspection(id, record));
  }

  void change(VoidCallback fn) {
    setState(fn);
    if (widget.selected != null &&
        widget.selected!.startsWith('reference.field.') &&
        !rows.any((s) => sampleId(s) == widget.selected)) {
      widget.onInspect(null);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.selected != null &&
          records[widget.selected] != null) {
        select(widget.selected!);
      }
    });
  }

  String sampleId(FieldSpec s) => 'reference.field.${s.identityKey}';
  Widget control(
    String key,
    String label,
    String value,
    Map<String, String> choices,
    ValueChanged<String> changed,
  ) => SizedBox(
    width: 190,
    child: DropdownButtonFormField<String>(
      key: ValueKey('fields-$key-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      icon: ExcludeSemantics(child: Text(l.dropdownMark)),
      items: choices.entries
          .map(
            (e) => DropdownMenuItem(
              value: e.key,
              child: Text(
                e.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) changed(v);
      },
    ),
  );
  Widget check(
    String key,
    String label,
    bool selected,
    ValueChanged<bool> changed,
  ) => FilterChip(
    key: ValueKey('fields-$key'),
    label: Text(label),
    selected: selected,
    onSelected: changed,
  );
  Widget probe(String id, Widget child) => ViewerSelectionFrame(
    key: ValueKey('field-selection-$id'),
    selected: widget.selected == id,
    child: Listener(
      onPointerDown: (_) => select(id),
      child: _FieldProbe(
        id: id,
        onMeasure: (outer, visual) {
          sizes[id] = (outer: outer, visual: visual);
          if (widget.selected == id) select(id);
        },
        child: child,
      ),
    ),
  );
  FieldInputOptions options(String id, TextEditingController controller) =>
      FieldInputOptions(
        controller: controller,
        hint: l.fieldHint,
        supportingText: longCopy ? l.fieldLongHelper : l.fieldHelper,
        feedback: validation,
        requirement: requirement,
        requirementLabels: labels,
        showRequirement: indicator,
        showSupporting: supporting,
        showSupportingIcon: supportIcon,
        onSnapshot: (s) => observe(id, s),
      );
  Widget live(Brightness brightness) => Theme(
    data: AppThemeFactory.build(
      skin: SkinTheme.of(context),
      brightness: brightness,
    ),
    child: ColoredBox(
      color: ButtonThemeTokens.forBrightness(brightness).color('Surface/Base'),
      child: Padding(
        padding: const EdgeInsetsDirectional.all(10),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            if (widget.family == FieldFamily.textField)
              SizedBox(
                width: 370,
                child: probe(
                  'live.text',
                  AppTextField(
                    key: const ValueKey('live-text'),
                    elementId: 'live.text',

                    label: longCopy ? l.fieldLongLabel : l.fieldInputLabel,
                    options: options('live.text', text),
                  ),
                ),
              ),
            if (isPassword)
              SizedBox(
                width: 370,
                child: probe(
                  'live.password',
                  AppPasswordField(
                    key: const ValueKey('live-password'),
                    elementId: 'live.password',

                    label: longCopy ? l.fieldLongLabel : l.fieldPasswordLabel,
                    showPasswordLabel: l.fieldShowPassword,
                    hidePasswordLabel: l.fieldHidePassword,
                    options: options('live.password', password),
                  ),
                ),
              ),
            if (widget.family == FieldFamily.otp)
              SizedBox(
                width: 370,
                child: probe(
                  'live.otp',
                  AppOtpField(
                    key: const ValueKey('live-otp'),
                    elementId: 'live.otp',

                    label: longCopy ? l.fieldLongLabel : l.fieldOtpLabel,
                    controller: otp,
                    sourceDivider: true,
                    feedback: validation,
                    supportingText: supporting
                        ? (longCopy ? l.fieldLongHelper : l.fieldHelper)
                        : null,
                    onSnapshot: (s) => observe('live.otp', s),
                  ),
                ),
              ),
            if (isRadio)
              SizedBox(
                width: 370,
                child: AppRadioGroup<int>(
                  value: radio,
                  allowDeselect: allowDeselect,
                  onChanged: (v) => setState(() => radio = v),
                  child: Column(
                    children: [
                      for (final option in [0, 1])
                        probe(
                          'live.radio.option:${option == 0 ? 'a' : 'b'}',
                          AppRadio<int>(
                            elementId:
                                'live.radio.option:${option == 0 ? 'a' : 'b'}',

                            value: option,
                            label:
                                '${option == 0 ? l.fieldOptionA : l.fieldOptionB}${longCopy ? ': ${l.fieldLongLabel}' : ''}',
                            requirement: requirement,
                            requirementLabels: labels,
                            showRequirement: indicator,
                            onSnapshot: (s) => observe(
                              'live.radio.option:${option == 0 ? 'a' : 'b'}',
                              s,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
  FieldVisualState visualState(FieldSpec spec) => FieldSpec.names.entries
      .singleWhere(
        (e) =>
            e.value == (spec.data['state'] as String).split(' - Visibility')[0],
      )
      .key;
  Widget referenceCard(FieldSpec spec) {
    final id = sampleId(spec),
        state = visualState(spec),
        error = state == FieldVisualState.error;
    final helper = longCopy
        ? l.fieldLongHelper
        : reference
        ? (spec.part('supportText')?['characters'] as String?)
        : l.fieldHelper;
    final message = error
        ? FieldFeedback.error(helper ?? l.fieldError)
        : const FieldFeedback.neutral();
    final label = longCopy
        ? l.fieldLongLabel
        : reference
        ? ((spec.part('label')?['characters'] as String?) ??
              familyLabel(spec.family))
        : familyLabel(spec.family);
    final synthetic = reference
        ? ((spec.part('input')?['characters'] as String?) ?? '')
        : l.fieldHint;
    Widget content;
    if (spec.family == FieldFamily.otp) {
      content = AppOtpCell(
        spec: spec,
        value: spec.part('otpText')?['characters'] as String? ?? '',
        visualKey: ValueKey('$id.visual'),
      );
    } else if (spec.family == FieldFamily.radio) {
      content = AppRadioPresentation(
        spec: spec,
        label: label,
        requirement: requirement,
        requirementLabels: labels,
        showRequirement: indicator,
        visualKey: ValueKey('$id.visual'),
      );
    } else {
      Widget? action;
      if (spec.family == FieldFamily.password) {
        final icon = spec.icons.first;
        action = SizedBox(
          width: spec.number('action', 'width'),
          height: spec.number('action', 'height'),
          child: Center(
            child: AssetAppIcon(
              spec.icon(icon).id,
              style: AppIconStyle.values.byName(icon['style'] as String),
              size: (icon['width'] as num).toDouble(),
              color: spec.iconPaint(icon),
            ),
          ),
        );
      }
      content = AppFieldSurface(
        spec: spec,
        label: label,
        input: Text(
          synthetic,
          style: spec.textStyle(
            'input',
            persian: previewDirection == TextDirection.rtl,
          ),
        ),
        requirement: requirement,
        requirementLabels: labels,
        showRequirement: indicator,
        feedback: message,
        supportingText: helper,
        showSupporting: supporting,
        showSupportingIcon: supportIcon,
        trailing: action,
        visualKey: ValueKey('$id.visual'),
      );
    }
    final snapshot = FieldRuntimeSnapshot(
      spec: spec,
      state: state,
      elementId: id,
      locator: UiIdentityScope.resolve(context),
      validation: error
          ? FieldValidation.error
          : state == FieldVisualState.success
          ? FieldValidation.success
          : FieldValidation.neutral,
      requirement: requirement,
      showRequirement: indicator,
      effectiveFontFamily: spec.family == FieldFamily.otp
          ? spec
                .textStyle(
                  'otpText',
                  persian: previewDirection == TextDirection.rtl,
                )
                .fontFamily
          : spec
                .textStyle(
                  'label',
                  persian: previewDirection == TextDirection.rtl,
                )
                .fontFamily,
      textScale: scale,
      motionReduced: MediaQuery.disableAnimationsOf(context),
      resolvedTypography: {
        for (final role in [
          'label',
          'indicator',
          'input',
          'supportText',
          'otpText',
        ])
          if (spec.part(role)?['fontSize'] != null)
            role: spec.typographyMetadata(
              role,
              persian:
                  role != 'otpText' && previewDirection == TextDirection.rtl,
            ),
      },
      supporting:
          spec.family != FieldFamily.otp &&
          spec.family != FieldFamily.radio &&
          (error || supporting),
      supportingIcon:
          supportIcon &&
          spec.family != FieldFamily.otp &&
          spec.family != FieldFamily.radio &&
          (error || supporting),
      passwordVisible: spec.family == FieldFamily.password
          ? (spec.data['state'] as String).endsWith(' On')
          : null,
      selected: spec.family == FieldFamily.radio
          ? (spec.data['state'] as String).startsWith('Selected')
          : null,
    );
    records[id] = snapshot;
    return SizedBox(
      width: spec.family == FieldFamily.otp ? 120 : spec.sourceSize.width + 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            key: ValueKey('inspect-$id'),
            onPressed: () => select(id),
            child: Text(
              '${familyLabel(spec.family)} · ${spec.brightness.name} · ${spec.data['state']}',
            ),
          ),
          if (spec.derived) Text(l.fieldDerived),
          Theme(
            data: AppThemeFactory.build(
              skin: SkinTheme.of(context),
              brightness: spec.brightness,
            ),
            child: ColoredBox(
              color: ButtonThemeTokens.forBrightness(spec.brightness)
                  .color('Surface/Base'),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(10),
                child: ViewerSelectionFrame(
                  selected: widget.selected == id,
                  onInspect: () => select(id),
                  child: _FieldProbe(
                    id: id,
                    onMeasure: (outer, visual) {
                      sizes[id] = (outer: outer, visual: visual);
                      if (widget.selected == id) select(id);
                    },
                    child: snapshot.wrap(content),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = theme == 'light' ? Brightness.light : Brightness.dark;
    return SingleChildScrollView(
      key: const ValueKey('fields-scroll'),
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
                    }, (v) => change(() => theme = v)),
                    if (hasDerived)
                      control('coverage', l.fieldSourceStatus, coverage, {
                        'source': l.fieldSource,
                        'derived': l.fieldDerived,
                        'all': l.all,
                      }, (v) => change(() => coverage = v)),
                    control('state', l.fieldState, state, {
                      'all': l.all,
                      for (final s in states) s: s,
                    }, (v) => change(() => state = v)),
                    if (isText || isRadio)
                      control(
                        'requirement',
                        l.fieldRequirement,
                        required ? 'required' : 'optional',
                        {
                          'required': l.fieldRequired,
                          'optional': l.fieldOptional,
                        },
                        (v) => change(() => required = v == 'required'),
                      ),
                    if (isPassword)
                      control('visibility', l.fieldVisibility, visibility, {
                        'all': l.all,
                        'shown': l.fieldShown,
                        'hidden': l.fieldHidden,
                      }, (v) => change(() => visibility = v)),
                    if (!isRadio)
                      control('feedback', l.fieldFeedback, feedback, {
                        'neutral': l.fieldNeutral,
                        'success': l.fieldSuccess,
                        'error': l.fieldError,
                      }, (v) => change(() => feedback = v)),
                    control('scale', l.textScale, scale.toString(), {
                      '1.0': '1.0',
                      '1.3': '1.3',
                    }, (v) => change(() => scale = double.parse(v))),
                    control('direction', l.previewDirection, direction, {
                      'auto': l.followLanguage,
                      'ltr': l.ltr,
                      'rtl': l.rtl,
                    }, (v) => change(() => direction = v)),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isText || isRadio)
                      check(
                        'indicator',
                        l.fieldIndicator,
                        indicator,
                        (v) => change(() => indicator = v),
                      ),
                    if (!isRadio)
                      check(
                        'support',
                        l.fieldSupporting,
                        supporting,
                        (v) => change(() => supporting = v),
                      ),
                    if (isText)
                      check(
                        'support-icon',
                        l.fieldSupportingIcon,
                        supportIcon,
                        (v) => change(() => supportIcon = v),
                      ),
                    if (widget.family != FieldFamily.otp)
                      check(
                        'reference',
                        l.fieldReferenceCopy,
                        reference,
                        (v) => change(() => reference = v),
                      ),
                    check(
                      'long',
                      l.fieldLongCopy,
                      longCopy,
                      (v) => change(() => longCopy = v),
                    ),
                    if (isRadio)
                      check(
                        'deselect',
                        l.fieldAllowDeselect,
                        allowDeselect,
                        (v) => change(() => allowDeselect = v),
                      ),
                    TextButton(
                      onPressed: () {
                        text.clear();
                        password.clear();
                        otp.clear();
                        setState(() => radio = null);
                      },
                      child: Text(l.fieldReset),
                    ),
                  ],
                ),
                Text(
                  l.fieldCoverage(sourceSpecs.length),
                  key: const ValueKey('fields-source-count'),
                ),
                Text(
                  l.fieldVisibleCount(rows.length),
                  key: const ValueKey('fields-visible-count'),
                ),
                if (isText || isRadio) Text(l.fieldSourceIndicatorNotice),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Directionality(
            textDirection: previewDirection,
            child: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.fieldInteractive,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  live(brightness),
                  const SizedBox(height: 24),
                  Text(
                    l.fieldReference,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  if (rows.isEmpty)
                    Text(l.emptyState)
                  else
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: [for (final spec in rows) referenceCard(spec)],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldProbe extends StatefulWidget {
  const _FieldProbe({
    required this.id,
    required this.child,
    required this.onMeasure,
  });
  final String id;
  final Widget child;
  final void Function(Size, Size?) onMeasure;
  @override
  State<_FieldProbe> createState() => _FieldProbeState();
}

class _FieldProbeState extends State<_FieldProbe> {
  final anchor = GlobalKey();
  @override
  Widget build(BuildContext context) => MeasureBox(
    onSize: (outer) {
      Size? visual;
      void visit(Element e) {
        if (e.widget.key == ValueKey('${widget.id}.visual')) {
          final box = e.findRenderObject();
          if (box is RenderBox) visual = box.size;
        }
        e.visitChildren(visit);
      }

      anchor.currentContext?.visitChildElements(visit);
      widget.onMeasure(outer, visual);
    },
    child: SizedBox(key: anchor, child: widget.child),
  );
}
