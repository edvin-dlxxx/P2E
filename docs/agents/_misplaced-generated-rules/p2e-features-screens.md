---
trigger: glob
description: "Rules for feature screens and product widgets in lib/features and lib/shared/widgets. Apply when building or editing screens, pages, flows or product widgets."
globs: "lib/features/**, lib/shared/widgets/**"
---
<!-- GENERATED from docs/agents/rules/features-screens.md by tool/agents/sync_agent_files.dart. Do not edit; edit the source. -->

# Features and screens

- Use the `p2e-build-screen` skill for any screen built from a Figma frame.
- Compose `lib/ui` components and `lib/shared/widgets` only. If something is missing, stop and propose a component
  (contract first). Do not hand-build a one-off look inside a feature.
- No raw colors, sizes, radii, font sizes or durations. Spacing comes from spacing tokens. Overrides need `// OVERRIDE(O-###)`.
- Banned widgets (v1.3 §15.3) stay banned; `tool/check_architecture.dart` enforces it.
- Screens use `PageScaffold` / `SafeArea` and respect system insets (Android edge-to-edge).
- Each screen implements loading, empty, error, offline and success states, even when Figma shows only success.
  Missing designs for those states → provisional pattern from `lib/ui/patterns` plus a designer request.
- Product widgets used by several features (`CurrencyChip`, `RewardPill`, …) live in `lib/shared/widgets`; the game card stays in
  the `games` feature public API. `lib/ui` stays product-agnostic.
- Tablet (Medium/Expanded): only the safe rules from the architecture (max content width, `AdaptiveGrid` column count).
  Do not invent tablet layouts; they arrive with the tablet design.
- All user-visible strings come from ARB files. Mixed-direction content (nicknames, numbers) uses bidi isolation.
