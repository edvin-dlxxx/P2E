import '../../theme/skin_theme.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../identity/element_identity.dart';
import '../../tokens/field_spec.dart';
import 'field_identity.dart';

class AppRadioPresentation extends StatelessWidget {
  const AppRadioPresentation({
    super.key,
    required this.spec,
    required this.label,
    this.requirement = FieldRequirement.optional,
    this.requirementLabels,
    this.showRequirement = false,
    this.duration = Duration.zero,
    this.visualKey,
  });
  final FieldSpec spec;
  final String label;
  final FieldRequirement requirement;
  final FieldRequirementLabels? requirementLabels;
  final bool showRequirement;
  final Duration duration;
  final Key? visualKey;
  @override
  Widget build(BuildContext context) {
    final spec = this.spec.withSkin(SkinTheme.of(context));
    if (showRequirement && requirementLabels == null) {
      throw ArgumentError('Visible requirement needs localized labels');
    }
    final inner = spec.part('radioInner')!, effects = inner['effects'] as List;
    final selected = (spec.data['state'] as String).startsWith('Selected');
    final effect = effects.isEmpty ? null : effects.first as Map;
    final inset = (effect?['spread'] as num? ?? 0).toDouble(),
        radius = spec.number('radioInner', 'cornerRadius');
    final ring = selected && effect != null
        ? Color.from(
            alpha: (effect['color']['a'] as num).toDouble(),
            red: (effect['color']['r'] as num).toDouble(),
            green: (effect['color']['g'] as num).toDouble(),
            blue: (effect['color']['b'] as num).toDouble(),
          )
        : null;
    final ringColor = spec.derived
        ? spec.paint({
            'fills': [
              {
                'type': 'SOLID',
                'color': effect?['color'],
                'boundVariables': {
                  'color': (effect?['boundVariables']?['color'] as Map?),
                },
                'opacity': 1,
              },
            ],
          }, 'fills')
        : ring == null
        ? null
        : skinPaint(spec.skin, spec.brightness, ring);
    final icon = DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? ringColor : spec.color('radioInner'),
        border: Border.all(
          color: spec.color('radioInner', stroke: true)!,
          width: spec.number('radioInner', 'strokeWeight'),
        ),
        borderRadius: BorderRadiusDirectional.all(Radius.circular(radius)),
      ),
      child: SizedBox(
        width: spec.number('radioInner', 'width'),
        height: spec.number('radioInner', 'height'),
        child: selected
            ? Padding(
                padding: EdgeInsetsDirectional.all(inset),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: spec.color('radioInner'),
                    borderRadius: BorderRadiusDirectional.all(
                      Radius.circular((radius - inset).clamp(0, radius)),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
    return Row(
      key: visualKey,
      children: [
        TweenAnimationBuilder<Decoration?>(
          tween: DecorationTween(
            end: BoxDecoration(
              color: spec.color('radioOuter'),
              borderRadius: BorderRadiusDirectional.all(
                Radius.circular(spec.number('radioOuter', 'cornerRadius')),
              ),
            ),
          ),
          duration: FieldMotion.effective(context, duration),
          curve: FieldMotion.curve,
          builder: (context, value, child) =>
              DecoratedBox(decoration: value!, child: child),
          child: Padding(padding: spec.padding('radioOuter'), child: icon),
        ),
        Expanded(
          child: Padding(
            padding: spec.padding('labelFrame'),
            child: Wrap(
              spacing: spec.number('labelFrame', 'itemSpacing'),
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  label,
                  style: spec.textStyle(
                    'label',
                    persian: Directionality.of(context) == TextDirection.rtl,
                  ),
                ),
                if (showRequirement)
                  Text(
                    requirementLabels!.forRequirement(requirement),
                    style: spec.textStyle(
                      'indicator',
                      persian: Directionality.of(context) == TextDirection.rtl,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RadioPolicy extends InheritedWidget {
  const _RadioPolicy({required this.allowDeselect, required super.child});
  final bool allowDeselect;
  @override
  bool updateShouldNotify(_RadioPolicy old) =>
      old.allowDeselect != allowDeselect;
}

class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    super.key,
    required this.value,
    required this.onChanged,
    required this.child,
    this.allowDeselect = false,
  });
  final T? value;
  final ValueChanged<T?> onChanged;
  final Widget child;
  final bool allowDeselect;
  @override
  Widget build(BuildContext context) => _RadioPolicy(
    allowDeselect: allowDeselect,
    child: RadioGroup<T>(groupValue: value, onChanged: onChanged, child: child),
  );
}

class AppRadio<T> extends StatefulWidget {
  const AppRadio({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.value,
    required this.label,
    this.groupValue,
    this.onChanged,
    this.focusNode,
    this.enabled = true,
    this.requirement = FieldRequirement.optional,
    this.requirementLabels,
    this.showRequirement = false,
    this.onSnapshot,
  });
  final String elementId, label;
  final UiRuntimeLocator? runtimeLocator;
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final FocusNode? focusNode;
  final bool enabled, showRequirement;
  final FieldRequirement requirement;
  final FieldRequirementLabels? requirementLabels;
  final ValueChanged<FieldRuntimeSnapshot>? onSnapshot;
  @override
  State<AppRadio<T>> createState() => _AppRadioState<T>();
}

class _AppRadioState<T> extends State<AppRadio<T>> with RadioClient<T> {
  late FocusNode node;
  bool hover = false, focused = false;
  Duration duration = Duration.zero;
  String? published;
  @override
  T get radioValue => widget.value;
  @override
  bool get enabled => widget.enabled;
  @override
  bool get tristate =>
      context
          .dependOnInheritedWidgetOfExactType<_RadioPolicy>()
          ?.allowDeselect ??
      false;
  @override
  FocusNode get focusNode => node;
  @override
  void initState() {
    super.initState();
    node = widget.focusNode ?? FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registry = RadioGroup.maybeOf<T>(context);
  }

  @override
  void didUpdateWidget(AppRadio<T> old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      if (old.focusNode == null) node.dispose();
      node = widget.focusNode ?? FocusNode();
    }
    if (old.groupValue != widget.groupValue) duration = Duration.zero;
  }

  @override
  void dispose() {
    registry = null;
    if (widget.focusNode == null) node.dispose();
    super.dispose();
  }

  bool get selected =>
      (registry?.groupValue ?? widget.groupValue) == widget.value;
  void selectOption() {
    if (!enabled) return;
    duration = Duration.zero;
    final next = selected && tristate ? null : widget.value;
    if (registry != null) {
      registry!.onChanged(next);
    } else {
      widget.onChanged?.call(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = selected
        ? (hover || focused
              ? FieldVisualState.selectedHover
              : FieldVisualState.selected)
        : (hover || focused
              ? FieldVisualState.notSelectedHover
              : FieldVisualState.notSelected);
    final spec = FieldSpec.lookup(
      FieldFamily.radio,
      state,
      Theme.of(context).brightness,
    ).withSkin(SkinTheme.of(context));
    final snapshot = FieldRuntimeSnapshot(
      spec: spec,
      state: state,
      elementId: widget.elementId,
      locator: UiIdentityScope.resolve(
        context,
        override: widget.runtimeLocator,
      ),
      enabled: enabled,
      requirement: widget.requirement,
      focused: focused,
      selected: selected,
      showRequirement: widget.showRequirement,
      effectiveFontFamily: spec
          .textStyle(
            'label',
            persian: Directionality.of(context) == TextDirection.rtl,
          )
          .fontFamily,
      textScale: MediaQuery.textScalerOf(context).scale(1),
      motionReduced: MediaQuery.disableAnimationsOf(context),
      resolvedTypography: {
        'label': spec.typographyMetadata(
          'label',
          persian: Directionality.of(context) == TextDirection.rtl,
        ),
        'indicator': spec.typographyMetadata(
          'indicator',
          persian: Directionality.of(context) == TextDirection.rtl,
        ),
      },
      runtimeExtension: focused && !hover
          ? 'focus uses source hover paint'
          : null,
    );
    final descriptor = snapshot.toJson().toString();
    if (descriptor != published) {
      published = descriptor;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onSnapshot?.call(snapshot);
      });
    }
    return snapshot.wrap(
      Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: true,
        enabled: enabled,
        label: widget.label,
        onTap: enabled ? selectOption : null,
        child: FocusableActionDetector(
          focusNode: node,
          enabled: enabled,
          onFocusChange: (v) => setState(() => focused = v),
          onShowHoverHighlight: (v) => setState(() {
            hover = v;
            duration = FieldMotion.hover;
          }),
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                selectOption();
                return null;
              },
            ),
          },
          child: GestureDetector(
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? selectOption : null,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: FieldMotion.tapExtent),
              child: ExcludeSemantics(
                child: AppRadioPresentation(
                  spec: spec,
                  label: widget.label,
                  requirement: widget.requirement,
                  requirementLabels: widget.requirementLabels,
                  showRequirement: widget.showRequirement,
                  duration: duration,
                  visualKey: ValueKey('${widget.elementId}.visual'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
