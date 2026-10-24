# Inspector v1 validation — 2026-10-22

## Result and architecture

The optional inspector package, two standalone Windows hosts and generated host-only fixtures are implemented under this folder. All required checks below passed. Product/Viewer runtime Dart sources, existing dependencies/locks, native product configuration, typography tokens and the adopted snapshot schema are unchanged. No product/Viewer hook was added: existing composeApp(rootWrapper, providerOverrides) preserves frame MediaQuery on the installed SDK. D-050 records technical captions; D-051 records the measured reuse of neutral hooks and the separate read-only DS entrypoint.

Dependencies point from hosts to inspector/product/DS/Viewer only. No workspace membership or required CI/script/config dependency was introduced. The new DS inspection.dart exposes the existing alternate skin outside the main barrel. The root architecture negative test forbids product imports of that entrypoint. Existing Viewer identity/resolver API remains the source for metadata.

## Commands and results

Commands were invoked with the installed Dart executable and Flutter snapshot to avoid flutter.bat lock contention. Equivalent ordinary commands are shown below. Actual executables were D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe and D:/Tools/flutter/bin/cache/flutter_tools.snapshot. There were no SDK or signing changes.

| Working directory | Commands | Final result |
|---|---|---|
| root | flutter pub get; dart analyze; flutter analyze --no-pub; flutter test --reporter expanded | zero issues; 47 passed (baseline 45 + frame proof + architecture negative) |
| packages/design_system | same four commands | zero issues; 504 passed (baseline 504) |
| apps/design_system_viewer | same four commands | zero issues; 33 passed (baseline 33) |
| dev_tools/inspector/inspector | flutter pub get; dart analyze; flutter test --reporter expanded | zero issues; 11 passed |
| dev_tools/inspector/hosts/product_host | same three commands | zero issues; 2 passed |
| dev_tools/inspector/hosts/viewer_host | same three commands | zero issues; 2 passed |
| packages/design_system | flutter test test/goldens/readiness_goldens_test.dart --reporter expanded (twice, no update) | 69/69, then 69/69 |
| root | dart run tool/check_architecture.dart | passed; negative import cases exercised in root suite |
| root | dart run tool/agents/sync_agent_files.dart --check | 33 generated files up to date |
| root | dart format --output=none --set-exit-if-changed . | 215 files, 0 changed |
| root | flutter build apk --debug | passed, including while dev_tools was absent |
| root | flutter build apk --release | passed without signing changes |
| each Windows host | flutter build windows --debug | passed for both |
| root | python dev_tools/inspector/tool/validate_snapshots.py | 26 snapshots valid; zero schema errors |
| dev_tools/inspector/inspector | dart run tool/generate_copy.dart --check | generated ARB copy verified |

All 12 token generators passed --check, using the existing commands:

```powershell
# From root; run each name separately (no generation/write mode).
node tool/tokens/generate_adaptive.cjs --check
node tool/tokens/generate_app_bars.cjs --check
node tool/tokens/generate_badges.cjs --check
node tool/tokens/generate_fields.cjs --check
node tool/tokens/generate_icons.cjs --check
node tool/tokens/generate_navigation.cjs --check
node tool/tokens/generate_readiness.cjs --check
node tool/tokens/generate_skins.cjs --check
dart run tool/tokens/generate_buttons.dart --check
dart run tool/tokens/generate_button_spec.dart --check
dart run tool/tokens/generate_button_icons.dart --check
dart run tool/tokens/generate_motion_defaults.dart --check
```

## Deletion and release exclusion

`powershell -NoProfile -File dev_tools/inspector/tool/check_isolation.ps1` moved the whole dev_tools directory outside the repository to the checked sibling P2E-inspector-v1-detached, ran all 14 checks and restored it in finally. These comprise pub get, Dart analysis, Flutter analysis and full tests in all three existing packages, plus architecture and debug APK. All exit codes are zero. After restoration, all three optional packages independently passed pub get, analyze and tests. [Exit codes](evidence/isolation-results.json).

The unique retained host marker P2E_OPTIONAL_INSPECTOR_V1_20261022 is absent from every uncompressed entry of both final product APKs, checking UTF-8 and UTF-16LE. It is present in the Windows product host kernel asset. The final rescan records APK SHA-256 hashes and sizes in [release-exclusion-proof.json](evidence/release-exclusion-proof.json). This proves marker exclusion in these artifacts; it does not claim a general binary equivalence proof.

## Neutrality, selection and comparisons

The new root frame test verifies existing wrapper media size 402x874, safe-area insets, requested scale and brightness. Product-host tests compare plain app and host with Select off at the same frame: geometry, semantics and interaction remain equal. Panel collapse/open keeps fixed app constraints; the second Android preset is 360x800. Viewer fills remaining width and reports reduced width; its existing physical-left inspector is unchanged. Overrides exercise locale/direction, brightness, skin and scale. Real bundled fonts are loaded in test fixtures.

Core/host tests cover deepest overlapping candidate choice, all component families, disabled/loading Buttons, clips/transforms/visibility, parent/slot navigation, nearest-owner fallback, input interception with no callback/hover/press/focus changes, live loading changes, disposal/same-key remount/different-route identity, and zero idle traversals. Scans are event-triggered; there is no global identity registry, timer or perpetual traversal. Selection overlay is excluded from semantics.

Registry/descriptor equality is tested across the family matrix. Injected padding deviations produce differs; matching padding produces match. Text/width/scale/test-skin/basis-source caveats produce not comparable with explicit reasons. Comparison tolerance is the existing Viewer 0.5 logical pixel convention. Requested scale 2.0 versus effective chrome 1.3 is separately recorded. Viewer tests compare existing records across Button, Badge, Field, Password, OTP group, Radio, App Bar and Navigator; artwork uses the original AppIcon registry source.

26 exported snapshots validate against the unchanged adopted schema. D-035 property envelopes carry actual/comparison data; unsupported state.loading is not invented. Synthetic Password/OTP secrets, lengths and sensitive paragraph arrays are excluded. Full effective keys are preserved as their five decoded parts within schema limits. Safe truncation warnings remain explicit.

## Limits and reported identity/schema gaps

- Flutter exposes configured font family/fallback chains, not the font selected per shaped glyph. Colors are resolved configuration, not sampled pixels. Neither is a claim of visual equality.
- Some render objects do not expose internal gaps, radii or full hit regions; values remain unavailable. Custom clip approximation is limited by public render-object contracts.
- Pure DS artwork has no independent interactive identity (D-023); nearest-owner selection is intentional. Viewer icon.preview source artwork is looked up without inventing an owner designRef.
- Legacy Viewer OTP inspection is group-level. Child cell parity uses the public DS registry separately. Viewer PageScaffold has no existing inspector record to compare and no linked Figma source.
- Derived Light Password and child visibility slots do not acquire invented direct source geometry. Basis rows stay separate and comparisons are not comparable where appropriate.
- R-012 is a documented follow-up, not a structured descriptor field. No invented request ID was added to snapshots. Loading remains declared/provisional where the descriptor says so.
- Select is for resting interaction; freezing an interaction already in progress remains outside v1. No live editing, backend scenario, screenshot comparison or runtime Figma/network access was added.
- Windows builds and widget/integration-style host tests passed. No manual native-window usability session is claimed.

No remaining blocking issue. Raw complete command logs remain in build/inspector-v1/; compact durable evidence is copied beside this report. File inventory excludes generated build/cache artifacts. No commit was made.
