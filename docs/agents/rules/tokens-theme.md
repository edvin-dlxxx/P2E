---
id: p2e-tokens-theme
description: Rules for design tokens, theme factory, Figma snapshots and token generators. Apply when editing lib/ui/tokens, lib/ui/theme, design/ or tool/tokens.
globs:
  - "lib/ui/tokens/**"
  - "lib/ui/theme/**"
  - "design/**"
  - "tool/tokens/**"
  - "packages/design_system/lib/src/tokens/**"
  - "packages/design_system/lib/src/theme/**"
---
# Tokens and theme

- Tokens are generated, never typed by hand. Pipeline: Figma → `design/figma/<snapshot>/` (skill `p2e-figma-snapshot`)
  → `tool/tokens/` generator → `lib/ui/tokens/generated/`. Fix the source or the generator, then regenerate.
- Figma facts the generator relies on (check `docs/agents/figma-map.md` for current values):
  - Color variables have a single mode. Light and Dark are two parallel collections ("☀︎ - Light Mode", "⏾ - Dark Mode")
    with matching variable names. Generate `ColorTokens.light` and `ColorTokens.dark` from them; a name present in only one
    collection is an erratum, not a silent default.
  - "Color Palette" holds primitives; screens and components should bind to the semantic Light/Dark names.
  - Text styles are "English/<Muted|Variant|Baseline>/<Style>" in Outfit. Persian styles do not exist yet: keep the typography
    tokens keyed by script/locale so a Persian scale can be added without touching widgets.
- Naming: keep the raw Figma name next to every generated token (doc comment or mapping table). Correct typos in Dart names
  (`Countainer` → `container`) and log the typo in `errata.md`.
- `AppThemeFactory.build(skin, brightness)` maps tokens to `ColorScheme`, `TextTheme`, Material component themes and
  `ThemeExtension`s (with `lerp`). Keep the second test skin compiling and in the goldens.
- Motion (durations, curves), spacing and radii are tokens too. Values not in Figma are `provisional` and logged in `decisions.md`.
- Snapshot JSON is pretty-printed with stable ordering so diffs are reviewable. Never edit a snapshot after it is committed;
  take a new one.

## D-019 / D-020 migration

Generated runtime paths are packages/design_system/lib/src/tokens/. Diagnostic specs belong to apps/design_system_viewer/lib/specs/. Package fonts use namespaced Flutter font resolution (D-019).
