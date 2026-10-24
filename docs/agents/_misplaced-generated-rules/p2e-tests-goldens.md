---
trigger: glob
description: "Testing and golden-test rules. Apply when editing anything under test or integration_test."
globs: "test/**, integration_test/**"
---
<!-- GENERATED from docs/agents/rules/tests-goldens.md by tool/agents/sync_agent_files.dart. Do not edit; edit the source. -->

# Tests and goldens

- `test/` mirrors `lib/`. Unit tests for logic, widget tests for screens (loading, empty, error, offline, success).
- Golden tests cover Design System components only (no full-screen goldens).
- Full matrix for `AppButton`, `AppTextField`, `AppTabs`, `AppListItem`, `AppSheet`, `AppSwitch`:
  Light/Dark × en/fa(RTL) × text scale 1.0/1.3 × Compact/Medium, plus the test skin.
  Other components: Light and Dark × en × 1.0, plus one RTL case and one 1.3× case.
- Goldens render from the same Gallery entries the Inspector uses. Fonts must be loaded in tests (no fallback boxes).
- Golden files are updated only on purpose (`--update-goldens`) and the diff is reviewed in the PR.
- Run goldens on one pinned CI OS with the pinned Flutter version.
