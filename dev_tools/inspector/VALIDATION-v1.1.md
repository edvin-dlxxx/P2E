# Inspector v1.1 validation — 2026-10-23

Historical record of v1.1 completion. The later owner-authorized DS/Windows follow-up is documented in [FOLLOWUP-v1.1.md](FOLLOWUP-v1.1.md); its fixes supersede the mutation finding below.
## Outcome

Simulated-device frames, OS inputs, separate Dev controls, Problems, scripted settings and Sweep are implemented. D-052 records neutral locale/platform inputs with D-041's provisional fa unchanged; D-053 records optional host behavior and privacy-safe sampling. No product screen, DS fix, golden update, native configuration change, SDK change or commit. Figma was not accessed.

Product contains no Inspector dependency or naming. Viewer retains its explicit language choice and existing skin selector; neutral device inputs and a controlled skin/callback keep the optional host synchronized.

## Exact invocations and results

Installed executables were invoked directly to avoid flutter.bat lock contention:

~~~powershell
$dart = 'D:\Tools\flutter\bin\cache\dart-sdk\bin\dart.exe'
$flutter = 'D:\Tools\flutter\bin\cache\flutter_tools.snapshot'
& $dart $flutter pub get
& $dart analyze
& $dart $flutter analyze --no-pub
& $dart $flutter test --reporter expanded
~~~

These four commands ran independently in each directory:

| Directory | Analysis | Full suite |
|---|---|---|
| root | Dart + Flutter: zero issues | 48 passed (v1:47) |
| packages/design_system | Dart + Flutter: zero issues | 504 passed (unchanged) |
| apps/design_system_viewer | Dart + Flutter: zero issues | 33 passed (unchanged) |
| dev_tools/inspector/inspector | Dart + Flutter: zero issues | 15 passed (v1:11) |
| dev_tools/inspector/hosts/product_host | Dart + Flutter: zero issues | 3 passed; 1 opt-in report skipped (v1:2) |
| dev_tools/inspector/hosts/viewer_host | Dart + Flutter: zero issues | 3 passed; 1 opt-in report skipped (v1:2) |

Additional commands, with dart/flutter shorthand for the executables above:

| Directory | Command | Result |
|---|---|---|
| root | dart format --output=none --set-exit-if-changed . | 224 files; 0 changed |
| root | dart run tool/check_architecture.dart | passed; root suite includes forbidden-direction negative tests |
| root | dart run tool/agents/sync_agent_files.dart --check | 33 generated files up to date |
| root | flutter build apk --debug | passed |
| root | flutter build apk --release | passed |
| each Windows host | flutter build windows --debug | passed for both |
| packages/design_system | flutter test test/goldens/readiness_goldens_test.dart --reporter expanded | 69/69, twice consecutively, no updates |
| root | python dev_tools/inspector/tool/validate_snapshots.py | 26 adopted-schema snapshots valid; zero errors |
| dev_tools/inspector/inspector | dart run tool/generate_copy.dart --check | generated ARB copy matches |
| root | dart run build_runner build | succeeded; 4 outputs |

Python executable: C:/Users/alish/miniforge3/python.exe. No generated Dart source was hand-edited. All twelve token generators passed --check:

~~~powershell
$env:DART = $dart
& 'C:\Program Files\nodejs\node.exe' tool/tokens/generate_adaptive.cjs --check
& 'C:\Program Files\nodejs\node.exe' tool/tokens/generate_app_bars.cjs --check
& 'C:\Program Files\nodejs\node.exe' tool/tokens/generate_badges.cjs --check
& 'C:\Program Files\nodejs\node.exe' tool/tokens/generate_fields.cjs --check
& 'C:\Program Files\nodejs\node.exe' tool/tokens/generate_icons.cjs --check
& 'C:\Program Files\nodejs\node.exe' tool/tokens/generate_navigation.cjs --check
& 'C:\Program Files\nodejs\node.exe' tool/tokens/generate_readiness.cjs --check
& 'C:\Program Files\nodejs\node.exe' tool/tokens/generate_skins.cjs --check
& $dart run tool/tokens/generate_buttons.dart --check
& $dart run tool/tokens/generate_button_spec.dart --check
& $dart run tool/tokens/generate_button_icons.dart --check
& $dart run tool/tokens/generate_motion_defaults.dart --check
~~~

The skins check initially failed because its child Dart executable was unavailable; setting DART fixed it. An initial format check found one formatting difference in problems.dart; formatting was applied and the final check is clean. Complete raw logs remain in root build/inspector-v1.1; compact evidence is copied beside this report.

## Real sweep

From each optional host:

~~~powershell
$env:RUN_REAL_SWEEP = '1'
& $dart $flutter test test/sweep_report_test.dart --reporter expanded
Remove-Item Env:RUN_REAL_SWEEP
~~~

Both report tests passed (+1 each): DS fixtures 1m33s, real Viewer 5m04s. Each ran width200..1400 step4 at height874 (1204 samples), then width200..1400 step200 x height300..1400 step220 (168 samples), over OS fa-IR/en-US x device scale1/2. Reports assert restoration of previous settings. Sweep never invokes app callbacks or navigates; the core step1 fixture test also asserts callback count zero.

All 56 observed sampled ranges are listed in [SWEEP-v1.1.md](SWEEP-v1.1.md), with complete safe JSON in evidence/v1.1. DS fixtures report Navigator below-minimum at sampled widths200..248; 252 is clear. Viewer reports chrome overflow at width200..452 for scale1 and200..612 for scale2, plus the listed coarse-grid ranges. Viewer keeps its explicit fa app choice for both OS lists; this is OS-input/fallback coverage, not a claim of English app UI. No unsampled threshold is inferred. No reported DS/Viewer layout was fixed.

The separate device/a11y test observes RenderAnimatedSize 'mutated in its own performLayout' with scale3/keyboard/flags. It is captured as layout-mutation with the original Flutter diagnostic preserved. This is outside the required scale1/2 sweep; no DS or Flutter fix is included.

## Isolation and release proof

The repeated v1.1 deletion check PASSED all 14 checks. Exact invocation from root: & ./dev_tools/inspector/tool/check_isolation.ps1. The complete dev_tools directory was atomically moved to the verified sibling D:/My_Script/Hamrah-Aval/P2E-inspector-v1-detached. While it was absent, root/DS/Viewer independently passed pub get, Dart analyze, Flutter analyze and full tests (48/504/33), followed by architecture and a debug APK build. All fourteen exit codes are zero. The script restored dev_tools in finally, and the detached sibling is absent. [Exit codes](evidence/v1.1/isolation-results.json).

Earlier attempts were blocked by Explorer directory handles; the owner released them. The historical isolation-blocked.log is retained only as provenance and is superseded by isolation-final.log and the passed isolation-status.json. There is no remaining directory-lock blocker. After restoration, pub get, dart analyze and flutter test --reporter expanded passed again independently in the core and both hosts: 15/3/3 tests, zero analysis issues. Both slow report tests were skipped as intended during these normal runs. Exact invocations are the same direct executable commands listed above; restored exit codes/excerpts are in evidence/v1.1. No remaining validation blocker.

The marker P2E_OPTIONAL_INSPECTOR_V1_20261022 is absent from every uncompressed entry of both final product APKs (UTF-8 and UTF-16LE), and present in the Windows product host kernel. [Artifact hashes and matches](evidence/v1.1/release-exclusion-proof.json). This is marker exclusion, not binary equivalence.

260 existing DS source/token/font/icon files match the original task-start SHA-256 inventory byte for byte. [Neutrality evidence](evidence/v1.1/ds-neutrality-proof.json). Product/Viewer pubspecs and locks have no optional tool dependency; only the optional Viewer host promotes its already-resolved DS dependency to direct.

## Coverage and limits

Tests retain v1 selection/privacy/schema coverage and add three handles, numeric input and +/-1/Shift10 nudges, presets/rotation/insets, Fit, logical geometry under zoom, picking at50%/75%, size classes599/600/839/840, OS locale updates, app fa policy for en/de, content3→2/chrome3→1.3, platform/brightness/keyboard/a11y delivery, banners absent, problem ownership, one-time loading warning capture, exact step1 width/height ranges, zero callbacks and state restoration.

Problems chains the original FlutterError handler; console/stripes remain. Raw exception text is classified in memory, not exported. Public RenderFlex extents re-observe continuous overflow; this is not universal custom-render-object or pixel detection. Owner is unavailable for Viewer chrome lacking ElementIdentity. Multiple ambiguous one-time emitters are not assigned invented owners. Collector failures remain observable. Bundled font evidence is family/fallback configuration, not glyph-level introspection. Original identity/schema limitations remain in README.md and historical VALIDATION.md.

Builds, widget tests and real mounted sweeps were exercised. No manual native-window usability session is claimed. No monkey runner or app screen was started.
