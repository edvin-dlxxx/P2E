import 'package:flutter/widgets.dart';

import '../../identity/element_identity.dart';
import '../../tokens/field_spec.dart';

/// Safe metadata: never includes entered text, passwords, OTP codes or messages.
class FieldRuntimeSnapshot {
  const FieldRuntimeSnapshot({
    required this.spec,
    required this.state,
    required this.elementId,
    this.locator,
    this.validation = FieldValidation.neutral,
    this.requirement = FieldRequirement.optional,
    this.supporting = false,
    this.supportingIcon = false,
    this.focused = false,
    this.hasContent = false,
    this.enabled = true,
    this.readOnly = false,
    this.passwordVisible,
    this.codeLength,
    this.complete,
    this.selected,
    this.runtimeExtension,
    this.showRequirement = false,
    this.effectiveFontFamily,
    this.textScale = 1,
    this.motionReduced = false,
    this.resolvedTypography = const {},
    this.identifierPrivacy = false,
  });
  final FieldSpec spec;
  final FieldVisualState state;
  final String elementId;
  final UiRuntimeLocator? locator;
  final FieldValidation validation;
  final FieldRequirement requirement;
  final bool supporting, supportingIcon, focused, hasContent, enabled, readOnly;
  final bool? passwordVisible, complete, selected;
  final int? codeLength;
  final String? runtimeExtension;
  final bool showRequirement, motionReduced;
  final String? effectiveFontFamily;
  final double textScale;
  final Map<String, Object?> resolvedTypography;
  final bool identifierPrivacy;
  String get componentId => switch (spec.family) {
    FieldFamily.textField => 'text-field.general',
    FieldFamily.password => 'text-field.password',
    FieldFamily.otp =>
      runtimeExtension?.startsWith('otp-group') == true
          ? 'text-field.otp-group'
          : 'text-field.otp',
    FieldFamily.radio => 'radio.base',
  };
  bool get sourceCovered =>
      !spec.derived && enabled && !readOnly && runtimeExtension == null;
  Map<String, Object?> toJson() => {
    'component': componentId,
    'elementId': elementId,
    'runtimeLocator': locator?.toJson(),
    'fileKey': spec.data['fileKey'],
    'variantId': sourceCovered ? spec.sourceId : null,
    'setId': sourceCovered ? spec.setId : null,
    'rawSetName': sourceCovered ? spec.data['setName'] : null,
    'rawVariantName': sourceCovered ? spec.rawName : null,
    'basisVariantId': spec.basisId,
    'sourceCovered': sourceCovered,
    'runtimeExtension': runtimeExtension,
    'state': state.name,
    'validation': validation.name,
    'requirement': requirement.name,
    'requirementIndicatorVisible': showRequirement,
    'effectiveFontFamily': effectiveFontFamily,
    'textScale': textScale,
    'motionReduced': motionReduced,
    'resolvedTypography': resolvedTypography,
    'supporting': supporting,
    'supportingIcon': supportingIcon,
    'focused': focused,
    'hasContent': hasContent,
    'enabled': enabled,
    'readOnly': readOnly,
    'passwordVisible': passwordVisible,
    'codeLength': codeLength,
    'complete': complete,
    'selected': selected,
  };
  Widget wrap(Widget child, {String? slotPath}) => ElementIdentity(
    elementId: elementId,
    runtimeLocator: slotPath == null ? locator : locator?.slot(slotPath),
    componentId: componentId,
    structureRef: spec.family == FieldFamily.radio
        ? 'radio.base'
        : '$componentId.base',
    fileKey: spec.data['fileKey'] as String,
    variantId: sourceCovered ? spec.sourceId : null,
    componentSetId: sourceCovered ? spec.setId : null,
    rawSetName: sourceCovered
        ? spec.data['setName'] as String
        : 'engineering-derived',
    rawVariantName: sourceCovered ? spec.rawName : 'engineering-derived',
    variants: {
      'state': state.name,
      'validation': validation.name,
      'type': enabled ? 'enabled' : 'disabled',
    },
    resolved: {
      'field': {
        'value': {
          ...toJson(),
          if (slotPath != null)
            'runtimeLocator': locator?.slot(slotPath).toJson(),
        },
        'origin': 'runtime-resolver',
      },
    },
    declared: {
      if (identifierPrivacy) 'privacy': 'identifier',
      if (identifierPrivacy) 'displayMask': '••••',
    },
    child: child,
  );
}
