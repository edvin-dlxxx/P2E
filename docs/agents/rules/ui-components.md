---
id: p2e-ui-components
description: Rules for Design System widgets in lib/ui (components, overlays, patterns, adaptive). Apply when creating or editing any file under lib/ui.
globs:
  - "lib/ui/**"
  - "packages/design_system/lib/src/**"
---
# Design System widgets (`lib/ui`)

- `lib/ui` is plain Flutter. It must not import Riverpod, `lib/shared`, `lib/features`, `lib/app` or `lib/dev`.
- Start from the component contract in `docs/design-system/contracts/<component>.md`. No contract → run the
  `p2e-component-contract` skill first. Never read values from a screenshot by eye when the contract or snapshot has them.
- Public API = semantic parameters only:
  - one Dart enum per Figma variant axis (e.g. `AppButtonType { filled, tonal, outlined, text }`, `AppButtonSize { small, medium, large }`);
  - content slots (`label`, `leadingIcon: AppIconId?`, `supportingText`, …), callbacks, `enabled`, `loading`;
  - no `Color`, `TextStyle`, `EdgeInsets`, `BorderRadius` or size `double` parameters.
- Light/Dark is never a parameter. Figma has separate "- Dark Mode" / "- Light Mode" sets; in code the widget resolves both from the theme.
- Only Figma-existing combinations are valid. Add `assert(isValidCombination(...))` with a message that names the missing Figma variant.
- Resolve every visual value from tokens (`context.tokens`, `ThemeExtension`s). States (`pressed`, `hovered`, `focused`, `disabled`,
  `loading`) go through `WidgetStateProperty`. If Figma lacks a state, use the contract's approved fallback and mark it `provisional`.
- Wrap the root in `ElementIdentity(id:, variant:, figmaNodeId:, status:)`. It must stay cheap: const data, no lookups, no `lib/dev` import.
- Layout: directional APIs only. Minimum touch target 48 dp. Semantics labels are required for icon-only widgets.
- Content must survive2.0× without clipping; App Bar text/Navigator labels alone use chromeTextScaleCap=1.3 (D-044). D-059: fixed Button frames win over conflicting padding; preserve centered content, grow only when scaled/wrapped content requires it. Other fixed-height contracts remain as documented. Inline legal links use the WCAG2.5.8 inline exception, with separate semantics/focus.
- Build on Material/Flutter widgets and theme them; do not re-implement gestures, focus or semantics.
- Every widget gets Gallery entries and golden tests (see `tests-goldens` rule) in the same change.

## D-019 / D-020 migration

Design System runtime now lives in packages/design_system/lib/src (D-019). Apply these rules there too. Consumers import only design_system.dart. ButtonIconMode.none/fill/outline is the explicit icon choice (D-020).


## D-032 / D-033 / D-034 identity adoption

Identity v1.1 is adopted. Public controls require elementId only; runtimeLocator is an optional explicit override of UiIdentityScope. Route instance IDs are allocated once, never in build. Password visibility and OTP fixed cells use owner-relative slotPath; no new semantics or focus nodes. Unlinked designRef is omitted, not null. Identity-only corrections do not authorize visual changes or new golden baselines.
