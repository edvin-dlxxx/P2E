# P2E Design System

Use the public `package:p2e_design_system/design_system.dart` barrel from either
consumer. Runtime has no dependency on the product or Viewer.

## Text Field System

The 34 source variants, raw evidence, bindings and hashes live in
`docs/snapshots/2026-10-20_development-text-fields` at repository root.
Contract: `docs/design-system/contracts/text_field_system.md`.

```dart
AppTextField(
  elementId: 'email', runtimeLocator: locator, label: l.email,
  options: FieldInputOptions(controller: emailController,
    requirement: FieldRequirement.required,
    feedback: error == null ? const FieldFeedback.neutral()
      : FieldFeedback.error(error)),
);
AppPasswordField(
  elementId: 'password', runtimeLocator: locator, label: l.password,
  showPasswordLabel: l.showPassword, hidePasswordLabel: l.hidePassword,
  options: FieldInputOptions(controller: passwordController),
);
AppOtpField(
  elementId: 'code', runtimeLocator: locator, label: l.code,
  length: 6, controller: codeController, onCompleted: verifyCode,
);
AppRadioGroup<String>(
  value: choice, onChanged: setChoice,
  child: AppRadio<String>(elementId: 'choice.email', runtimeLocator: locator,
    value: 'email', label: l.email),
);
```

Caller owns supplied controllers/focus nodes and localized strings. Error feedback
rejects blank messages and remains visible even when helpers are hidden. Empty
helpers remove their gap; required/optional are mutually exclusive. OTP accepts
text by default; configure keyboard and input formatters explicitly. Password
and OTP Light previews are engineering derivatives with null source IDs.

`AppOtpCell`, `AppFieldSurface` and `AppRadioPresentation` share the rendering
used by live controls and the inert Viewer reference harness. The Viewer owns
selection borders; controls never draw inspection decoration.

Generate/check: `node tool/tokens/generate_fields.cjs [--check]` from repository
root. Motion defaults originate in `design/engineering/field_motion.json`;
Radio hover is source-extracted. No golden baselines are approved by generation.
