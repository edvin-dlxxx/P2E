import 'package:flutter/widgets.dart';

enum FieldFamily { textField, password, otp, radio }

enum FieldVisualState {
  defaultState,
  focused,
  written,
  edit,
  success,
  error,
  notSelected,
  notSelectedHover,
  selected,
  selectedHover,
}

enum FieldValidation { neutral, success, error }

enum FieldRequirement { required, optional }

@immutable
class FieldFeedback {
  const FieldFeedback.neutral({this.message})
    : validation = FieldValidation.neutral;
  const FieldFeedback.success({this.message})
    : validation = FieldValidation.success;
  factory FieldFeedback.error(String message) {
    if (message.trim().isEmpty) {
      throw ArgumentError(
        'Error feedback requires a nonblank caller-supplied message',
      );
    }
    return FieldFeedback._error(message);
  }
  const FieldFeedback._error(this.message) : validation = FieldValidation.error;
  final FieldValidation validation;
  final String? message;
  String? supporting(String? helper, {bool show = true}) =>
      validation == FieldValidation.error
      ? message
      : show
      ? (message ?? helper)
      : null;
}

class FieldRequirementLabels {
  const FieldRequirementLabels({
    required this.required,
    required this.optional,
  });
  final String required, optional;
  String forRequirement(FieldRequirement value) =>
      value == FieldRequirement.required ? required : optional;
}

abstract final class FieldStateMapper {
  static FieldVisualState input({
    required bool focused,
    required bool hasContent,
    FieldValidation validation = FieldValidation.neutral,
  }) => switch (validation) {
    FieldValidation.error => FieldVisualState.error,
    FieldValidation.success => FieldVisualState.success,
    FieldValidation.neutral =>
      focused
          ? FieldVisualState.focused
          : hasContent
          ? FieldVisualState.written
          : FieldVisualState.defaultState,
  };
  static FieldVisualState otp({
    required bool active,
    required bool populated,
    required FieldValidation validation,
  }) => validation == FieldValidation.error
      ? FieldVisualState.error
      : validation == FieldValidation.success
      ? FieldVisualState.success
      : active
      ? populated
            ? FieldVisualState.edit
            : FieldVisualState.focused
      : populated
      ? FieldVisualState.written
      : FieldVisualState.defaultState;
}
