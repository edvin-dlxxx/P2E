# Adopted UI identity implementation

D-032 adopts the canonical v1.1 contract in docs/reference/identity. D-033 adds
UiIdentityScope; D-034 applies its slotPath model; D-035 explicitly extends safe
structured metadata in the canonical schema. No Figma design/interaction changes.

Controls accept elementId and optional runtimeLocator. Wrap one mounted route in:

```dart
UiIdentityScope(
  routeName: 'viewer.password',
  instanceKey: 'preview-a', // optional; otherwise allocated once in initState
  child: AppPasswordField(
    elementId: 'login.password.input',
    label: localizedLabel,
    showPasswordLabel: localizedReveal,
    hidePasswordLabel: localizedConceal,
  ),
)
```

Password's visibilityAction and OTP's cells.cell1...cellN keep the owner's
elementId and append slotPath to the locator. Their metadata never contains entered
input. The group has no designRef; each source-backed cell has its effective spec.
Decorative artwork ownership remains D-023. Existing App Bar action/destination
identities remain independent. No additional Semantics/focus/render nodes.

The effective key is routeName, routeInstanceId, elementId, entityKey, slotPath.
No runtime uniqueness registry is installed; shared test-only traversal in
packages/design_system/test_support detects collisions including Offstage elements.

Missing scope asserts clearly in debug/tests. Release UI still renders with a
null locator; descriptor serialization is unavailable for that unscoped metadata
and throws only if explicitly requested. No fake route or source is emitted.
