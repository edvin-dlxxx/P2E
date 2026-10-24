# Text Field delivery validation — 2026-10-20

Implemented contract: [text_field_system.md](contracts/text_field_system.md).
Public API examples: [shared package README](../../packages/design_system/README.md).
Evidence: [development snapshot](../snapshots/2026-10-20_development-text-fields/README.md).

## Results

- Shared package full suite: **238 passed**, including the eight Text Field tests.
- Independent Viewer full suite: **14 passed**, including two bilingual FieldBrowser tests.
- Product regressions: **5 passed**.
- Node extraction/snapshot suite: **33 passed**.
- After final semantics/typography/background refinements: all eight field tests
  and both FieldBrowser tests passed again.
- `flutter analyze --no-pub`: product, shared package and Viewer passed separately.
- `dart format --set-exit-if-changed .`: 111 files, no changes at final check.
- Fields, icons, icon/field ARB, generated localization checks passed.
- Architecture checker passed for all three runtime trees; agent sync check passed.
- 1,290 pre-existing snapshot files match their pre-task hashes.
- `flutter build windows --debug`: final executable built successfully.
- Windows Viewer launched successfully; TextFields live/reference layouts were
  inspected through the Computer Use skill. Source OTP cell states and rounded
  Radio shape are visible. No golden baselines were created or approved.

The tests exercise source coverage, exact source surface/cell geometry with real
bundled fonts, safe metadata, controller/selection/focus ownership, optional helper
spacing, mandatory errors, requirement exclusivity, Password combinations/toggle,
single-editor OTP paste/replacement/deletion/formatters/completion/LTR order,
Radio selection/keyboard/hover/semantics, reduced/interrupted motion, bilingual
Viewer filtering, stable editing state and source/derived counts. Existing Button
and Icon regressions remain included in the full suites.

## Commands

From each of root, `packages/design_system` and `apps/design_system_viewer`:
`flutter analyze --no-pub` and `flutter test --reporter expanded`.

From repository root:

```powershell
node tool/tokens/generate_fields.cjs --check
node tool/tokens/generate_icons.cjs --check
node tool/dev/generate_icon_strings.cjs --check
node tool/dev/generate_field_strings.cjs --check
dart run tool/dev/generate_viewer_localizations.dart --check
node --test tool/figma/test/*.test.cjs
dart run tool/check_architecture.dart
dart run tool/agents/sync_agent_files.dart --check
dart format --set-exit-if-changed .
```

Run the Viewer:

```powershell
Set-Location 'D:\My_Script\Hamrah-Aval\P2E\apps\design_system_viewer'
flutter run --debug -d windows --no-pub
```

The built executable is `build/windows/x64/runner/Debug/p2e_design_system_viewer.exe`
inside the Viewer folder. Choose TextFields (فیلدهای متن).

## Remaining source limitations

No execution blocker remains. Password/OTP have no Light source twins (E-008);
their Light previews are explicitly engineering-derived with null source IDs.
Persian typography remains provisional (D-006/R-003). No named source version,
designer approval, golden approval or pixel-equivalence certification is claimed.
Required/optional source defaults remain a designer erratum (E-013); runtime
normalization is authorized by the owner's task and recorded in D-024.

## D-025 Viewer organization correction

The mixed TextFields catalog is superseded by four independent tabs: TextField, Password, OTP and Radio. Each mounts only its family, reports its own 10/10/6/8 source count and exposes applicable states/controls. Password visibility and base state now filter independently. Long-copy controls affect live and reference labels/helpers. Previous Inspector selection is cleared on tab navigation. Validation for this correction is recorded in apps/design_system_viewer/build/field-tabs-tests.log.
