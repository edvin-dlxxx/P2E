---
trigger: glob
description: "Rules for the dev-only Inspector, Gallery and spec registry in lib/dev and lib/main_dev.dart. Apply when editing those files."
globs: "lib/dev/**, lib/main_dev.dart"
---
<!-- GENERATED from docs/agents/rules/dev-tools.md by tool/agents/sync_agent_files.dart. Do not edit; edit the source. -->

# Dev tools (Inspector, Gallery, specs)

- Everything here is dev-only. Only `lib/main_dev.dart` imports `lib/dev/`. `lib/main.dart` (release) must never reach it,
  so tree shaking removes it from release builds. `tool/check_architecture.dart` enforces the import rule.
- The Inspector is off by default and toggled by a small overlay control. It must not change layout or timing when off.
- For a tapped widget the Inspector shows: component id, variant values, Figma node id (link), status (final/provisional),
  expected values from the spec (size, padding, radius, colors as token + raw Figma name, text style, icon) next to the
  measured values, and a per-property result (match / mismatch / not measurable).
- Expected values come from `lib/dev/specs/generated/` (built from the Figma snapshot). Never type expected values by hand.
- Compare at text scale 1.0 and the theme of the inspected subtree.
- The Gallery lists every component and every valid variant combination × Light/Dark × LTR(en)/RTL(fa sample text) ×
  Compact/Medium, plus the test skin. Golden tests reuse the Gallery entries.
- Check performance in profile/release builds too; the dev entrypoint is slower and hides problems.
