import '../../theme/skin_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../icons/app_icon.dart';
import '../../identity/element_identity.dart';
import '../../tokens/field_spec.dart';
import 'field_identity.dart';
import 'input_lease.dart';

class AppOtpCell extends StatelessWidget {
  const AppOtpCell({
    super.key,
    required this.spec,
    this.value = '',
    this.visualKey,
  });
  final FieldSpec spec;
  final String value;
  final Key? visualKey;
  @override
  Widget build(BuildContext context) {
    final spec = this.spec.withSkin(SkinTheme.of(context));
    final state = spec.data['state'],
        active = state == 'Focused' || state == 'Edit';
    final child = state == 'Success'
        ? AssetAppIcon(
            spec.icon(spec.icons.single).id,
            style: AppIconStyle.values.byName(
              spec.icons.single['style'] as String,
            ),
            size: (spec.icons.single['width'] as num).toDouble(),
            color: spec.iconPaint(spec.icons.single),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value.isNotEmpty)
                Text(
                  value,
                  style: spec.textStyle(
                    'otpText',
                    persian: Directionality.of(context) == TextDirection.rtl,
                  ),
                ),
              if (active)
                ColoredBox(
                  color: spec.paint(spec.part('caret'), 'strokes')!,
                  child: SizedBox(
                    width: spec.number('caret', 'strokeWeight'),
                    height: spec.number('caret', 'width'),
                  ),
                ),
            ],
          );
    return TweenAnimationBuilder<Decoration?>(
      tween: DecorationTween(
        end: BoxDecoration(
          color: spec.color('body'),
          border: Border.all(
            color: spec.color('body', stroke: true)!,
            width: spec.number('body', 'strokeWeight'),
          ),
          borderRadius: BorderRadiusDirectional.all(
            Radius.circular(spec.number('body', 'cornerRadius')),
          ),
        ),
      ),
      duration: FieldMotion.effective(context, FieldMotion.color),
      curve: FieldMotion.curve,
      builder: (context, value, child) =>
          DecoratedBox(decoration: value!, child: child),
      child: SizedBox(
        key: visualKey,
        width: spec.number('body', 'width'),
        height: spec.number('body', 'height'),
        child: Center(child: child),
      ),
    );
  }
}

class AppOtpField extends StatefulWidget {
  const AppOtpField({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.label,
    this.length = 6,
    this.controller,
    this.focusNode,
    this.feedback = const FieldFeedback.neutral(),
    this.supportingText,
    this.inputFormatters = const [],
    this.keyboardType = TextInputType.text,
    this.autofillHints = const [AutofillHints.oneTimeCode],
    this.enabled = true,
    this.readOnly = false,
    this.sourceDivider = false,
    this.onChanged,
    this.onCompleted,
    this.onSnapshot,
  }) : assert(length > 0);
  final String elementId, label;
  final UiRuntimeLocator? runtimeLocator;
  final int length;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FieldFeedback feedback;
  final String? supportingText;
  final List<TextInputFormatter> inputFormatters;
  final TextInputType keyboardType;
  final Iterable<String> autofillHints;
  final bool enabled, readOnly, sourceDivider;
  final ValueChanged<String>? onChanged, onCompleted;
  final ValueChanged<FieldRuntimeSnapshot>? onSnapshot;
  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  late InputLease lease;
  String? lastComplete, published;
  late String previousText;
  int? tapped;
  @override
  void initState() {
    super.initState();
    lease = InputLease(widget.controller, widget.focusNode, changed);
    previousText = lease.controller.text;
  }

  @override
  void didUpdateWidget(AppOtpField old) {
    super.didUpdateWidget(old);
    lease.update(widget.controller, widget.focusNode);
    if (old.length != widget.length) lastComplete = null;
  }

  @override
  void dispose() {
    lease.dispose();
    super.dispose();
  }

  void changed() {
    if (!mounted) return;
    setState(() {});
    final text = lease.controller.text;
    if (text == previousText) return;
    previousText = text;
    if (text.characters.length != widget.length) {
      lastComplete = null;
    } else if (lastComplete != text) {
      lastComplete = text;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && lastComplete == text) widget.onCompleted?.call(text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.length <= 0) throw ArgumentError.value(widget.length, 'length');
    final brightness = Theme.of(context).brightness,
        chars = lease.controller.text.characters.toList();
    final active = lease.focus.hasFocus
        ? lease.controller.text
              .substring(
                0,
                lease.controller.selection.extentOffset.clamp(
                  0,
                  lease.controller.text.length,
                ),
              )
              .characters
              .length
              .clamp(0, widget.length - 1)
        : -1;
    final state = FieldStateMapper.otp(
      active: lease.focus.hasFocus,
      populated: chars.isNotEmpty,
      validation: widget.feedback.validation,
    );
    final spec = FieldSpec.lookup(
          FieldFamily.otp,
          state,
          brightness,
        ).withSkin(SkinTheme.of(context)),
        composition = FieldMotion.otpComposition;
    final pad = (composition['padding'] as List).cast<num>();
    final message = widget.feedback.supporting(widget.supportingText);
    final snapshot = FieldRuntimeSnapshot(
      spec: spec,
      state: state,
      elementId: widget.elementId,
      locator: UiIdentityScope.resolve(
        context,
        override: widget.runtimeLocator,
      ),
      validation: widget.feedback.validation,
      focused: lease.focus.hasFocus,
      hasContent: chars.isNotEmpty,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      codeLength: widget.length,
      complete: chars.length == widget.length,
      supporting: message?.trim().isNotEmpty ?? false,
      effectiveFontFamily: spec
          .textStyle(
            'otpText',
            persian: Directionality.of(context) == TextDirection.rtl,
          )
          .fontFamily,
      textScale: MediaQuery.textScalerOf(context).scale(1),
      motionReduced: MediaQuery.disableAnimationsOf(context),
      resolvedTypography: {
        'otpText': spec.typographyMetadata('otpText'),
        if (message?.trim().isNotEmpty ?? false)
          'groupHelper':
              FieldSpec.lookup(
                    FieldFamily.textField,
                    widget.feedback.validation == FieldValidation.error
                        ? FieldVisualState.error
                        : FieldVisualState.defaultState,
                    brightness,
                  )
                  .withSkin(SkinTheme.of(context))
                  .typographyMetadata(
                    'supportText',
                    persian: Directionality.of(context) == TextDirection.rtl,
                  ),
      },
      runtimeExtension: 'otp-group composition; cell basis only',
    );
    final descriptor = snapshot.toJson().toString();
    if (published != descriptor) {
      published = descriptor;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onSnapshot?.call(snapshot);
      });
    }
    final children = <Widget>[];
    for (var i = 0; i < widget.length; i++) {
      if (i > 0) {
        children.add(SizedBox(width: (composition['gap'] as num).toDouble()));
      }
      if (widget.sourceDivider && i == composition['dividerAfter']) {
        final line = composition['dividerLine'] as Map<String, dynamic>,
            divider = composition['divider'] as Map;
        children.add(
          ColoredBox(
            color: spec.paint(line, 'strokes')!,
            child: SizedBox(
              width: (divider['width'] as num).toDouble(),
              height: (line['strokeWeight'] as num).toDouble(),
            ),
          ),
        );
        children.add(SizedBox(width: (composition['gap'] as num).toDouble()));
      }
      final cellState = FieldStateMapper.otp(
        active: active == i,
        populated: i < chars.length,
        validation: widget.feedback.validation,
      );
      final cellSpec = FieldSpec.lookup(
        FieldFamily.otp,
        cellState,
        brightness,
      ).withSkin(SkinTheme.of(context));
      children.add(
        FieldRuntimeSnapshot(
          spec: cellSpec,
          state: cellState,
          elementId: widget.elementId,
          locator: snapshot.locator,
          validation: widget.feedback.validation,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          focused: active == i,
          hasContent: i < chars.length,
        ).wrap(
          AppOtpCell(
            spec: cellSpec,
            value: i < chars.length ? chars[i] : '',
            visualKey: ValueKey('${widget.elementId}.cell.$i'),
          ),
          slotPath: 'cells.cell${i + 1}',
        ),
      );
    }
    // PHYSICAL: logical code order is LTR regardless of the surrounding UI.
    final cells = Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          pad[0].toDouble(),
          pad[1].toDouble(),
          pad[2].toDouble(),
          pad[3].toDouble(),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
    final editor = TextField(
      key: ValueKey('${widget.elementId}.editor'),
      controller: lease.controller,
      focusNode: lease.focus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      keyboardType: widget.keyboardType,
      autofillHints: widget.autofillHints,
      textDirection: TextDirection.ltr,
      inputFormatters: [
        ...widget.inputFormatters,
        LengthLimitingTextInputFormatter(widget.length),
      ],
      onChanged: widget.onChanged,
      onTap: () {
        if (tapped != null) {
          lease.controller.selection = TextSelection.collapsed(
            offset: chars.take(tapped!.clamp(0, chars.length)).join().length,
          );
        }
      },
      style: spec.textStyle(
        'otpText',
        persian: Directionality.of(context) == TextDirection.rtl,
      ),
      decoration: const InputDecoration.collapsed(hintText: ''),
    );
    return snapshot.wrap(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: widget.label,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Listener(
                onPointerDown: (event) {
                  final pitch =
                      spec.number('body', 'width') +
                      (composition['gap'] as num).toDouble();
                  var x = event.localPosition.dx - pad[0];
                  if (widget.sourceDivider && x > pitch) {
                    x -= (composition['divider'] as Map)['width'] as num;
                    x -= (composition['gap'] as num);
                  }
                  tapped = (x / pitch).floor().clamp(0, widget.length);
                },
                child: Stack(
                  key: ValueKey('${widget.elementId}.visual'),
                  children: [
                    ExcludeSemantics(child: cells),
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0,
                        alwaysIncludeSemantics: true,
                        child: editor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (message != null && message.trim().isNotEmpty)
            Padding(
              padding: EdgeInsetsDirectional.only(
                top: (composition['gap'] as num).toDouble(),
              ),
              child: Semantics(
                liveRegion: widget.feedback.validation == FieldValidation.error,
                child: Text(
                  message,
                  style:
                      FieldSpec.lookup(
                            FieldFamily.textField,
                            widget.feedback.validation == FieldValidation.error
                                ? FieldVisualState.error
                                : FieldVisualState.defaultState,
                            brightness,
                          )
                          .withSkin(SkinTheme.of(context))
                          .textStyle(
                            'supportText',
                            persian:
                                Directionality.of(context) == TextDirection.rtl,
                          ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
