---
id: p2e-dev-tools
description: Rules for the dev-only Inspector, Gallery and spec registry in lib/dev and lib/main_dev.dart. Apply when editing those files.
globs:
  - "lib/dev/**"
  - "lib/main_dev.dart"
  - "apps/design_system_viewer/lib/**"
---
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

## D-019 / D-020 migration

D-019 supersedes the lib/dev and main_dev location rule: all dev UI, strings and diagnostic specs now live in apps/design_system_viewer. Its lib/main.dart opens Gallery and verification; the product cannot depend on the viewer.

D-022: the independent Viewer now has English/Persian generated localization and a persistent physical-left desktop inspector (collapsible drawer at narrow widths). Gallery/verification share the registry-based Buttons board. Future component sections remain honest localized placeholders.

D-023 populates Icons with the shared registry/renderer, source/localized search,
actual style counts, surface/size/tint controls and the same generic inspector.
Selection decoration and disabled-preview hit handling belong only to the Viewer,
outside shared artwork/control roots and measurement bounds.

D-024 populates TextFields from the 34-variant source registry with independent source/derived counts, shared reference primitives and live native editing. Inspector records safe configuration/state flags and measured bounds, never entered input, Password or OTP values.

D-025 splits the former mixed TextFields browser into TextField, Password, OTP and Radio tabs. Source rows, interactive examples, counts, states and controls must stay within each tab family. Password visibility and base state filters combine independently.

D-027: live Inspector state/measurement updates notify only its panel, not the catalog. Keep a regression test for selected-control motion rebuilding no unrelated samples. Clipboard exports use only the displayed safe InspectionRecord. D-026 defaults field coverage to both source and derived themes, with source totals separate.
