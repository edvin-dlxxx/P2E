---
name: p2e-build-ds-component
description: Implement or change a P2E Design System widget in lib/ui (AppButton, AppTextField, AppBadge, AppIcon, overlays, patterns) from its component contract, using generated tokens, enum parameters, ElementIdentity, Gallery entries, golden tests and the Inspector spec. Use whenever creating, modifying, restyling or fixing a widget under lib/ui/components, lib/ui/overlays or lib/ui/patterns.
---

# Build a Design System component

Status of this skill: v0.9 draft. Refine it after AppButton and AppTextField.

## Preconditions
- A contract exists in `docs/design-system/contracts/`. If not, run `p2e-component-contract` first.
- The tokens it references exist in `lib/ui/tokens/generated/`. If not, regenerate from the snapshot; do not add tokens by hand.

## Steps
1. **API.** Enums and parameters exactly as the contract's API table. No visual parameters (AGENTS.md rule 4).
   Add `assert` for invalid combinations with a message naming the missing Figma variant.
2. **Style resolver.** A private, pure function `(theme tokens, variant values, states) → resolved style`. Use `WidgetStateProperty`
   for state-dependent values. This keeps the widget small and the resolver unit-testable.
3. **Widget.** Build on the matching Material/Flutter widget and theme it. Directional APIs only. Min height from the contract;
   min touch target 48 dp. Semantics for icon-only use. Respect2.0× content scaling; only named chrome text caps at1.3 (D-044).
4. **Identity.** Wrap the root in `ElementIdentity` (id, variant values, Figma node id for the active theme, status).
5. **Gallery.** Register every valid combination × Light/Dark × en/fa (RTL sample text) × Compact/Medium in `lib/dev/gallery/`.
6. **Goldens.** Add golden tests that reuse the Gallery entries (matrix in the `tests-goldens` rule).
7. **Inspector spec.** Make sure the contract's spec block is generated into `lib/dev/specs/generated/`; never type expected values.
8. **Check.** Run the commands in AGENTS.md "Before you finish a change". Open `main_dev.dart`, inspect each variant, and fix
   every mismatch or explain it.
9. **Registers.** Overrides → `O-###`; Figma problems → errata; missing designs → designer requests.
10. **Report** to the owner in Persian: what was built, Inspector compliance per variant, provisional parts, open questions.

See `references/checklist.md` before you say "done".
