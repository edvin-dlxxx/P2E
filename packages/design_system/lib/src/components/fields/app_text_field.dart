import '../../theme/skin_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../icons/app_icon.dart';
import '../../identity/element_identity.dart';
import '../../tokens/field_spec.dart';
import '../../tokens/generated/auth_entry_tokens.g.dart';
import 'field_identity.dart';
import 'field_surface.dart';
import 'input_lease.dart';

/// Shared native editing configuration; no source-style/size/color overrides.
enum FieldInputPresentation { source, phoneNumber }

class FieldInputOptions {
  const FieldInputOptions({
    this.controller,
    this.focusNode,
    this.hint,
    this.supportingText,
    this.feedback = const FieldFeedback.neutral(),
    this.requirement = FieldRequirement.optional,
    this.requirementLabels,
    this.showRequirement = false,
    this.showSupporting = true,
    this.showSupportingIcon = true,
    this.enabled = true,
    this.readOnly = false,
    this.keyboardType,
    this.inputFormatters,
    this.autofillHints,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onSnapshot,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.autocorrect,
    this.enableSuggestions,
    this.identifierPrivacy = false,
    this.wrapHint = false,
    this.presentation = FieldInputPresentation.source,
  });
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hint, supportingText;
  final FieldFeedback feedback;
  final FieldRequirement requirement;
  final FieldRequirementLabels? requirementLabels;
  final bool showRequirement,
      showSupporting,
      showSupportingIcon,
      enabled,
      readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged, onSubmitted;
  final ValueChanged<FieldRuntimeSnapshot>? onSnapshot;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final bool? autocorrect, enableSuggestions;
  final bool identifierPrivacy;

  /// Grow a long localized placeholder; editing remains a single LTR line.
  final bool wrapHint;
  final FieldInputPresentation presentation;
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.label,
    this.options = const FieldInputOptions(),
  });
  final String elementId, label;
  final UiRuntimeLocator? runtimeLocator;
  final FieldInputOptions options;
  @override
  Widget build(BuildContext context) => _EditableField(
    elementId: elementId,
    locator: runtimeLocator,
    label: label,
    options: options,
  );
}

class AppPasswordField extends StatelessWidget {
  const AppPasswordField({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.label,
    required this.showPasswordLabel,
    required this.hidePasswordLabel,
    this.initiallyVisible = false,
    this.options = const FieldInputOptions(),
  });
  final String elementId, label, showPasswordLabel, hidePasswordLabel;
  final UiRuntimeLocator? runtimeLocator;
  final bool initiallyVisible;
  final FieldInputOptions options;
  @override
  Widget build(BuildContext context) => _EditableField(
    elementId: elementId,
    locator: runtimeLocator,
    label: label,
    options: options,
    password: true,
    initiallyVisible: initiallyVisible,
    showPasswordLabel: showPasswordLabel,
    hidePasswordLabel: hidePasswordLabel,
  );
}

class _EditableField extends StatefulWidget {
  const _EditableField({
    required this.elementId,
    this.locator,
    required this.label,
    required this.options,
    this.password = false,
    this.initiallyVisible = false,
    this.showPasswordLabel,
    this.hidePasswordLabel,
  });
  final String elementId, label;
  final UiRuntimeLocator? locator;
  final FieldInputOptions options;
  final bool password, initiallyVisible;
  final String? showPasswordLabel, hidePasswordLabel;
  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  late InputLease lease;
  late bool visible;
  String? published;
  @override
  void initState() {
    super.initState();
    visible = widget.initiallyVisible;
    lease = InputLease(
      widget.options.controller,
      widget.options.focusNode,
      changed,
    );
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(_EditableField old) {
    super.didUpdateWidget(old);
    lease.update(widget.options.controller, widget.options.focusNode);
  }

  @override
  void dispose() {
    lease.dispose();
    super.dispose();
  }

  void toggle() {
    final selection = lease.controller.selection;
    setState(() => visible = !visible);
    lease.controller.selection = selection;
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.options,
        focused = lease.focus.hasFocus,
        hasContent = lease.controller.text.isNotEmpty;
    final family = widget.password
        ? FieldFamily.password
        : FieldFamily.textField;
    final state = FieldStateMapper.input(
      focused: focused,
      hasContent: hasContent,
      validation: o.feedback.validation,
    );
    final spec = FieldSpec.lookup(
      family,
      state,
      Theme.of(context).brightness,
      passwordVisible: visible,
    ).withSkin(SkinTheme.of(context));
    final textSpec = FieldSpec.lookup(
      family,
      hasContent ? FieldVisualState.written : FieldVisualState.focused,
      Theme.of(context).brightness,
      passwordVisible: visible,
    ).withSkin(SkinTheme.of(context));
    final persian = Directionality.of(context) == TextDirection.rtl;
    final caretSpec = FieldSpec.lookup(
      family,
      FieldVisualState.focused,
      Theme.of(context).brightness,
      passwordVisible: visible,
    );
    final caretWidth = caretSpec.number('caret', 'width');
    final caretHeight = caretSpec.number('caret', 'height');
    final message = o.feedback.supporting(
      o.supportingText,
      show: o.showSupporting,
    );
    final inputStyle = o.presentation == FieldInputPresentation.phoneNumber
        ? textSpec
              .textStyle('input', persian: persian)
              .copyWith(
                fontSize: PhoneInputTypographyTokens.size,
                height:
                    PhoneInputTypographyTokens.line /
                    PhoneInputTypographyTokens.size,
                letterSpacing: PhoneInputTypographyTokens.spacing,
              )
        : textSpec.textStyle('input', persian: persian);
    final snapshot = FieldRuntimeSnapshot(
      spec: spec,
      state: state,
      elementId: widget.elementId,
      locator: UiIdentityScope.resolve(context, override: widget.locator),
      validation: o.feedback.validation,
      requirement: o.requirement,
      supporting: message?.trim().isNotEmpty ?? false,
      supportingIcon:
          o.showSupportingIcon && (message?.trim().isNotEmpty ?? false),
      focused: focused,
      hasContent: hasContent,
      enabled: o.enabled,
      readOnly: o.readOnly,
      identifierPrivacy: o.identifierPrivacy,
      passwordVisible: widget.password ? visible : null,
      showRequirement: o.showRequirement,
      effectiveFontFamily: textSpec
          .textStyle('input', persian: persian)
          .fontFamily,
      textScale: MediaQuery.textScalerOf(context).scale(1),
      motionReduced: MediaQuery.disableAnimationsOf(context),
      resolvedTypography: {
        'label': spec.typographyMetadata('label', persian: persian),
        'indicator': spec.typographyMetadata('indicator', persian: persian),
        'input': {
          ...textSpec.typographyMetadata('input', persian: persian),
          'fontSize': inputStyle.fontSize,
          'lineHeight': inputStyle.fontSize! * inputStyle.height!,
          'letterSpacing': inputStyle.letterSpacing,
          'presentation': o.presentation.name,
        },
        if (message?.trim().isNotEmpty ?? false)
          'supportText': spec.typographyMetadata(
            'supportText',
            persian: persian,
          ),
      },
    );
    final descriptor = snapshot.toJson().toString();
    if (published != descriptor) {
      published = descriptor;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) o.onSnapshot?.call(snapshot);
      });
    }
    final editor = Semantics(
      label: widget.label,
      child: TextField(
        key: ValueKey('${widget.elementId}.editor'),
        controller: lease.controller,
        focusNode: lease.focus,
        enabled: o.enabled,
        readOnly: o.readOnly,
        obscureText: widget.password && !visible,
        enableSuggestions: o.enableSuggestions ?? !widget.password,
        autocorrect: o.autocorrect ?? !widget.password,
        textDirection: o.textDirection,
        textAlign: o.textAlign,
        keyboardType:
            o.keyboardType ??
            (widget.password
                ? TextInputType.visiblePassword
                : TextInputType.text),
        inputFormatters: o.inputFormatters,
        autofillHints: o.autofillHints,
        textInputAction: o.textInputAction,
        onChanged: o.onChanged,
        onSubmitted: o.onSubmitted,
        style: inputStyle,
        // Source vector may be rotated; its longer local axis is the caret.
        cursorHeight: caretWidth > caretHeight ? caretWidth : caretHeight,
        cursorWidth: caretSpec.number('caret', 'strokeWeight'),
        cursorColor:
            spec.paint(spec.part('caret'), 'strokes') ??
            textSpec.textStyle('input', persian: persian).color,
        decoration: InputDecoration.collapsed(
          hintText: o.wrapHint ? null : o.hint ?? '',
          hint: o.wrapHint
              ? Text(
                  o.hint ?? '',
                  softWrap: true,
                  style:
                      FieldSpec.lookup(
                            family,
                            FieldVisualState.focused,
                            Theme.of(context).brightness,
                            passwordVisible: visible,
                          )
                          .withSkin(SkinTheme.of(context))
                          .textStyle('input', persian: persian),
                )
              : null,
          hintStyle:
              FieldSpec.lookup(
                    family,
                    FieldVisualState.focused,
                    Theme.of(context).brightness,
                    passwordVisible: visible,
                  )
                  .withSkin(SkinTheme.of(context))
                  .textStyle('input', persian: persian),
        ),
      ),
    );
    Widget? action;
    if (widget.password) {
      final icon = spec.icons.firstWhere(
        (i) => (i['width'] as num) >= spec.number('action', 'width') / 2,
      );
      action = Semantics(
        button: true,
        enabled: o.enabled,
        label: visible ? widget.hidePasswordLabel : widget.showPasswordLabel,
        onTap: o.enabled ? toggle : null,
        child: FocusableActionDetector(
          enabled: o.enabled,
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                toggle();
                return null;
              },
            ),
          },
          child: GestureDetector(
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTap: o.enabled ? toggle : null,
            child: SizedBox(
              width: FieldMotion.tapExtent,
              height: FieldMotion.tapExtent,
              child: Center(
                child: AssetAppIcon(
                  spec.icon(icon).id,
                  style: AppIconStyle.values.byName(icon['style'] as String),
                  size: (icon['width'] as num).toDouble(),
                  color: spec.iconPaint(icon),
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (action != null) {
      action = snapshot.wrap(action, slotPath: 'visibilityAction');
    }
    return snapshot.wrap(
      Semantics(
        textField: state == FieldVisualState.defaultState,
        label: state == FieldVisualState.defaultState ? widget.label : null,
        enabled: o.enabled,
        onTap: state == FieldVisualState.defaultState && o.enabled
            ? lease.focus.requestFocus
            : null,
        child: AppFieldSurface(
          spec: spec,
          label: widget.label,
          input: editor,
          requirement: o.requirement,
          requirementLabels: o.requirementLabels,
          showRequirement: o.showRequirement,
          feedback: o.feedback,
          supportingText: o.supportingText,
          showSupporting: o.showSupporting,
          showSupportingIcon: o.showSupportingIcon,
          trailing: action,
          visualKey: ValueKey('${widget.elementId}.visual'),
          onTap: o.enabled ? lease.focus.requestFocus : null,
        ),
      ),
    );
  }
}
