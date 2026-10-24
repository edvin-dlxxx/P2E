---
name: p2e-component-contract
description: Turn a P2E Figma component set (with its Light and Dark twins) into a component contract - variant axes as Dart enums, valid combinations, anatomy and slots, sizes, token bindings per theme and state, text styles, icons, open behavior questions and the Inspector spec. Use before building or changing any Design System component in lib/ui (AppButton, AppTextField, AppBadge, App Bar, navigation items, cards), when the designer changes a component set, or when a component has no design and needs a provisional contract.
---

# Component contract

Status of this skill: v0.9 draft. Refine it after the first real contract (AppButton).

## Output
- `docs/design-system/contracts/<component>.md` from `references/contract-template.md`.
- A machine-readable spec section (JSON block) that `tool/tokens/` turns into `lib/dev/specs/generated/` for the Inspector.

## Steps
1. Find the sets in `docs/agents/figma-map.md` and the latest snapshot (`design/figma/LATEST`). If the snapshot is older than the
   designer's latest version, run `p2e-figma-snapshot` first.
2. Pair Dark and Light sets (`… - Dark Mode` / `… - Light Mode`). A missing twin → erratum + designer request; the missing
   theme is `provisional`.
3. Axes → enums. One enum per variant axis and per size family; boolean props become slots or bool parameters
   (`Icon`, `Fill Icon`, `Outline Icon` → `leadingIcon` + `iconStyle`). Fix typos in Dart names; keep raw names.
   Theme axes ("Theme", "Therme") are not parameters.
4. Valid combinations: list exactly which combinations exist in Figma. Everything else is invalid.
5. Anatomy: container and every child (slot name, optional/required, which prop controls it).
6. Measurements per size: height (becomes min height), padding (start/top/end/bottom), gap, radius, border, icon size.
7. Tokens per theme × variant × state: Figma variable name → generated token name. Unbound colors → erratum, never a raw value.
8. Typography: text style per slot (`English/<group>/<style>`); Persian: "pending R-003".
9. States: what Figma shows vs required (`enabled`, `pressed`, `hovered`, `focused`, `disabled`, `loading`, `error` for fields).
   For a missing state propose a fallback (e.g. pressed = overlay token at 12 %), mark it `provisional`, list it under open questions.
10. Behavior: tap target ≥ 48 dp, semantics, keyboard / focus order, RTL mirroring, text overflow policy,2.0× content; only named chrome capped1.3 (D-044).
11. Open questions: everything you could not read from Figma. Do not guess; ask the owner and log designer requests.
12. Report to the owner in Persian: summary, invalid combos, provisional items, open questions.
