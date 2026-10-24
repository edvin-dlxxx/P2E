# Inspector v1.1 follow-up — 2026-10-23

## Result and scope

Owner-authorized DS correction is limited to shared field size transitions. Windows Viewer minimum client bounds and removal of the obsolete build_runner flag are also included. No screen, new design, token change, golden update, SDK change, Inspector error filter or commit. Figma was not accessed. D-054 records the engineering policy; the existing field contract is updated.

## Root cause (medium-high)

Original owners: fixtures.field and fixtures.password, both through AppFieldSurface in packages/design_system/lib/src/components/fields/field_surface.dart. The body transition at line113 and supporting transition at line130 supplied FieldMotion.effective durations to AnimatedSize. Reduce motion resolves these durations to zero.

When an already-laid-out child changes intrinsic size (text-scale or locale/label metrics), Flutter RenderAnimatedSize._layoutStable calls _restartAnimation during performLayout. With duration zero, AnimationController.forward completes synchronously; its listener calls markNeedsLayout on that same render object before layout ends. The original stack is in build/inspector-followup/a11y-probe-before.log; local SDK source is rendering/animated_size.dart:92,311,332. This is not a DS setState/listener updating business state during layout.

The public SimulatedDevice API exercised all sixteen combinations of scale1/3, keyboard off/on, bold off/on and reduce motion off/on, with separate mount, keyboard toggle, scale toggle and locale change stages. Masks0..7 (reduce motion off) recorded no error. Masks8..15 recorded four mutation diagnostics each, owned by field/password during scale/locale size changes. Mount and keyboard-only transitions did not independently cause this error. Thus scale3, keyboard or bold alone were not sufficient; zero-duration size restart was the exact trigger.

Before/after diagnostic matrices are retained in evidence/followup (the after-probe predates the additional editor-state preservation refinement; the final host matrix and3612-sample sweep validate the final implementation). The temporary probe chained the original Flutter handler and consumed expected test exceptions only to record the reproduction; it was removed. Final normal host tests now assert no exception for every input combination and keyboard toggle. No production error is suppressed, caught or filtered.

## Correction and regression

_FieldSizeTransition (same file:196; zero-duration branch:220) lays out the target directly only when duration is zero. Nonzero animation keeps the original AnimatedSize duration, curve and alignment. No normal animation is removed. Reduced motion already required immediate completion, so an immediate layout implements its existing policy without a zero-duration animation controller.

Its stable keyed child (line215) retains native EditableText state across switching the motion wrapper. A preliminary direct-child implementation recreated editor state; the final keyed implementation corrects that. Regression in test/fields/reduced_motion_layout_test.dart checks both brightness modes, scale1/1.3/2/3, repeated keyboard inset300/0 and reduced-motion transitions, full error absence, retained editor State identities and retained controller values. It includes nonempty supporting text to cover both transition sites. Real bundled fonts and UiIdentityScope are used.

The existing product-host device/a11y test also asserts errors are absent after mounting the fixtures, verifies all sixteen OS-input combinations, and permits only the explicit Navigator diagnostic at width251.

## Final fixture sweep

Command, from dev_tools/inspector/hosts/product_host:

~~~powershell
$env:RUN_A11Y_SWEEP = '1'
& $dart $flutter test test/followup_sweep_test.dart --reporter expanded
Remove-Item Env:RUN_A11Y_SWEEP
~~~

The final source was swept at width200..1400 step4, height874, OS fa-IR/en-US x system scale1/2/3 x keyboard off/on. Reduced motion and bold were enabled throughout this stress sweep. This is3612 samples (1806 per keyboard state), with settings restored and collectorFailures zero. Each Flutter exception is checked; only the expected Navigator host contract warning is accepted. Product content applies its own2.0 cap and chrome applies1.3; device scale3 remains a genuine delivered input.

| Keyboard | OS locale | Device scale | Sampled width range | Kind | Owner |
|---|---|---:|---|---|---|
| off | fa-IR | 1.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| off | en-US | 1.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| off | fa-IR | 2.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| off | en-US | 2.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| off | fa-IR | 3.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| off | en-US | 3.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| on | fa-IR | 1.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| on | en-US | 1.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| on | fa-IR | 2.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| on | en-US | 2.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| on | fa-IR | 3.0 | 200..248 | navigator-below-minimum | fixtures.navigation |
| on | en-US | 3.0 | 200..248 | navigator-below-minimum | fixtures.navigation |

No mutation, other layout/paint error or overflow was recorded. No unsampled exact threshold is inferred. Existing host Problems handling/console chaining is unchanged.

## Viewer chrome bounds (low)

Standalone Viewer minimum Windows client area:640x740 logical pixels. viewer_host:1280x1000. WM_GETMINMAXINFO in each windows/runner/flutter_window.cpp:89 scales client dimensions by actual window DPI and includes non-client borders with AdjustWindowRectExForDpi. Initial runner heights are raised to740/1000, and EnforceInitialMinimum (line22, invoked at49) applies the same DPI-adjusted outer bounds before the first Flutter surface is created. No Viewer layout/control redesign or new dependency.

Viewer's scale1 overflow was observed through sampled width452, with next sample456 clear. Standalone640x740 was checked in fa/en. At the host minimum with its maximum600 panel, divider8 and existing viewport allowance40 leave632 logical pixels for the Viewer; the real Fit viewport test checks width>452 and no reported chrome overflow. Panel width is configured through its existing drag callback in the test; no native manual dragging claim is made.

These bounds constrain the native window, not the Free simulated device. Deliberately setting a smaller Free frame can still expose real Viewer chrome overflow. Scale2 chrome overflow remains accepted and documented in the historical SWEEP-v1.1.md. Minimum bounds apply to scale1.

## Validation

Executables, used directly rather than flutter.bat:

~~~powershell
$dart = 'D:\Tools\flutter\bin\cache\dart-sdk\bin\dart.exe'
$flutter = 'D:\Tools\flutter\bin\cache\flutter_tools.snapshot'
~~~

In root, packages/design_system, apps/design_system_viewer, dev_tools/inspector/inspector and each of the two optional hosts, independently:

~~~powershell
& $dart analyze
& $dart $flutter analyze --no-pub
& $dart $flutter test --reporter expanded
~~~

| Package | Dart + Flutter analysis | Full tests |
|---|---|---:|
| root | zero issues | 48 passed |
| design_system | zero issues | 506 passed (504+2 regressions) |
| Viewer | zero issues | 34 passed (33+1 viewport regression) |
| inspector core | zero issues | 15 passed |
| product_host | zero issues | 3 passed; 2 opt-in reports skipped |
| viewer_host | zero issues | 3 passed; 1 opt-in report skipped |

Both consecutive final no-update golden runs passed69/69. All69 PNG SHA-256 hashes are identical to the pre-change inventory. Architecture passed, including negative cases in the root suite; agent sync reports33 generated files up to date; format reports227 files, zero changes. Debug APK passed. Both Windows host builds and the standalone Viewer build passed. Final native startup-bound refinement is recorded in native-final-*.json.

The extended sweep passed as a separately enabled +1 test. Initial lint infos in new test strings/one unbraced progress branch were fixed; final Dart and Flutter analyses in every package report zero issues. No issue is waived.


Other exact invocations from root:

~~~powershell
& $dart run tool/check_architecture.dart
& $dart run tool/agents/sync_agent_files.dart --check
& $dart format --output=none --set-exit-if-changed .
& $dart $flutter build apk --debug
~~~

From each optional host and the standalone Viewer: & $dart $flutter build windows --debug.
From packages/design_system, twice consecutively without updating:
& $dart $flutter test test/goldens/readiness_goldens_test.dart --reporter expanded.

Build_runner's obsolete conflict-output option was removed from the only maintained occurrence (the historical VALIDATION-v1.1.md command). A hidden/no-ignore recursive search across maintained scripts/docs/agent rules/optional sources, excluding build/cache directories, found no remaining occurrence. No build_runner generation was needed for this correction; future invocations use dart run build_runner build.

## Changed files

- packages/design_system/lib/src/components/fields/field_surface.dart — immediate reduced-motion size path with retained editor subtree.
- packages/design_system/test/fields/reduced_motion_layout_test.dart — new two-brightness regression.
- docs/design-system/contracts/text_field_system.md — reduced-motion implementation clarification.
- apps/design_system_viewer/windows/runner/flutter_window.cpp and main.cpp — native minimum and startup height.
- apps/design_system_viewer/test/window_minimum_test.dart — new fa/en viewport check.
- dev_tools/inspector/hosts/viewer_host/windows/runner/flutter_window.cpp and main.cpp — host native minimum and startup height.
- dev_tools/inspector/hosts/viewer_host/test/host_test.dart — maximum-panel/minimum-viewport check.
- dev_tools/inspector/hosts/product_host/test/host_test.dart — strict device/a11y matrix and no swallowed unexpected exceptions.
- dev_tools/inspector/hosts/product_host/test/followup_sweep_test.dart — new opt-in stress sweep.
- docs/agents/registers/decisions.md — D-054.
- dev_tools/inspector/README.md, VALIDATION-v1.1.md and SWEEP-v1.1.md — current usage/limits and historical follow-up links; obsolete command option removed.
- dev_tools/inspector/FOLLOWUP-v1.1.md and evidence/followup/* — this report and durable evidence.

No maintained file or golden was deleted. Temporary a11y_probe_test.dart was removed after diagnosis. Existing fixture/gallery entries, identity/spec data, typography tokens, colors, sizes and runtime dependency directions are unchanged.

No remaining blocker. Native interactive resizing/manual usability was not separately exercised; native runner builds and logical viewport tests provide the stated bounds evidence.
