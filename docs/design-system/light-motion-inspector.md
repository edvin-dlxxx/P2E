# Light fields, motion investigation and Inspector clipboard — 2026-10-20

## Appearance

D-026 generates role-specific Dark-to-Light bindings from the existing immutable
TextField twins. Equal variable names were insufficient: Dark body and helper
both use Surface Container/Base, but their Light counterparts use Lowest and
High respectively. Label/input roles also differ. Password/OTP preserve their
Dark anatomy and shared error color while applying these paired Light roles;
Password action and OTP success icons use the corresponding label/input roles.
Radio keeps its already designed Light source. Viewer defaults to both themes.

No Figma writes, new source variants or designer approvals are implied. Password
and OTP Light remain engineering-derived, with null dedicated source IDs and an
explicit Dark basis. Source coverage remains 34, independent of 16 derivatives.
The generator is `tool/tokens/generate_fields.cjs`; generated role bindings are
separate from the original source tables and snapshot bytes.

## Motion evidence

The selected sample published Inspector state/measurements through ViewerShell
setState. This rebuilt the entire board while its control was animating.
`test/motion_work_test.dart` uses the Flutter debug rebuild hook to reproduce
three press/release cycles and three focus-out/in cycles, after selection settles.

| Work in the measured interaction window | Before | After |
|---|---:|---:|
| ViewerShell rebuilds during Button cycles | 9 | 0 |
| Other ButtonSample rebuilds during Button cycles | 801 | 0 |
| ViewerShell rebuilds during TextField cycles | 36 | 0 |
| FieldBrowser rebuilds during TextField cycles | 36 | 0 |

Inspector updates now use their own ValueNotifier; selecting a different sample
still updates selection decoration once. Fields use indexed source/variable
lookups; ThemeData is reused per brightness. Component motion durations, curves,
disabled/reduced-motion behavior and editing ownership were not changed.

These counts measure unnecessary build work, not frame rate or a guaranteed
device performance level. A Windows Profile build was attempted and failed with
MSB8013 (Profile|x64): this project's CMake intentionally exposes only Debug.
That existing restriction was retained. Windows Debug build/run is supported.

## Clipboard

Inspector retains selectable values and adds localized Copy all / Copy actions.
The complete report contains the sample ID, group headings, field labels and the
same formatted values shown on screen. Copy exports only InspectionRecord;
controllers and entered Password/OTP text are never consulted. Both English and
Persian paths are covered by platform-channel clipboard tests.

## Validation

- Shared package: 239 tests passed; product regressions: 5 passed.
- Viewer: 21 tests passed, including isolated-rebuild and bilingual copy tests.
- Node extraction/snapshot tests: 33 passed.
- Source/derived Light roles are compared to TextField counterparts in tests;
  existing source ID classification and Radio Light source are verified.
- Generation check, formatter, architecture checker and agent sync are checked.
- No golden baselines were created or approved.

From `apps/design_system_viewer`, run `flutter run --debug -d windows --no-pub`.
