---
trigger: glob
description: "Rules for Design System widgets in lib/ui (components, overlays, patterns, adaptive). Apply when creating or editing any file under lib/ui."
globs: "lib/ui/**"
---
<!-- GENERATED from docs/agents/rules/ui-components.md by tool/agents/sync_agent_files.dart. Do not edit; edit the source. -->

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
- Text must survive 1.3× text scale without clipping. Fixed Figma heights become minimum heights.
- Build on Material/Flutter widgets and theme them; do not re-implement gestures, focus or semantics.
- Every widget gets Gallery entries and golden tests (see `tests-goldens` rule) in the same change.
