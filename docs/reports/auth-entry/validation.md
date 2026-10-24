> Historical Auth implementation evidence. Reviewer did not accept this version. Current D-059/D-060 corrections and remaining measured differences are in [Auth conformance](../auth-conformance/README.md).

# Auth Entry validation — 2026-10-23

SDK: Flutter3.47.7 / Dart3.13. Commands below ran with the SDK at `D:/Tools/flutter`. In this environment `flutter` was invoked as `dart D:/Tools/flutter/bin/cache/flutter_tools.snapshot`. Logs remain in `build/auth-entry-preflight/`; selected evidence is copied alongside this report.

| Check | Result |
|---|---|
| Root `flutter test --no-pub` |423 passed|
| DS `flutter test --no-pub` |528 passed|
| Viewer `flutter test --no-pub` |35 passed|
| Inspector `flutter test --no-pub` |15 passed|
| product_host `flutter test --no-pub` |4 passed;3 opt-in sweeps skipped in ordinary run|
| viewer_host `flutter test --no-pub` |3 passed;1 opt-in matrix skipped|
| Root, DS, Viewer, Inspector and both hosts `dart analyze` |zero issues in all6 packages|
| DS `flutter test --no-pub test/goldens` twice |76/76 each, no update flag|
| Root `flutter test --no-pub test/goldens` twice |18/18 each, no update flag|
| `flutter test --no-pub test/tool/architecture_test.dart` |49 passed, including exact-file purity and forbidden directions|
| `dart run tool/check_architecture.dart` |passed|
| `dart run tool/agents/sync_agent_files.dart --check` |passed,33 generated files current|
| `dart format --output=none --set-exit-if-changed .` |274 files,0 changes|
| All9 `tool/tokens/generate_*.cjs --check` via Node and4 `.dart --check` via Dart |passed|
| `dart run build_runner build` |passed,23s,4 generated outputs; no generated file hand edits|
| `flutter build apk --debug --no-pub --dart-define-from-file=config/dev.json` |passed,127.8s|
| `flutter build apk --release --no-pub --dart-define-from-file=config/prod.json` |passed,343.8s,52.4MB|
| product_host and viewer_host `flutter build windows --debug --no-pub` |passed,157.8s /122.6s|

Product host build also passes `--dart-define-from-file=../../../../config/dev.json`. Android builds used process-local `GRADLE_OPTS=-Dorg.gradle.project.kotlin.incremental=false -Dorg.gradle.project.kotlin.compiler.execution.strategy=in-process` after the Kotlin incremental cache rejected different drive roots (pub cacheC:, checkoutD:). No Gradle version or project toolchain setting was changed. Release emits a framework Cupertino font-family warning; it succeeds. Material font is bundled for Flutter's native text-selection toolbar; product icons still use Figma SVGs.

Pub resolution ran for root, DS, Viewer and optional hosts. Cached `flutter pub get --offline` was also used because a later advisory-metadata request returned HTTP403. No dependency override was introduced. `url_launcher` is isolated behind the app platform adapter.

## Scripted screen sweep

From product_host:

```powershell
$env:RUN_AUTH_SWEEP='1'
flutter test --no-pub test/auth_entry_sweep_test.dart
```

Passed:48 plans,10,688 scheduled samples plus96 setup/restore callbacks,10,784 total. Four states, fa/en,1.0/2.0, keyboard on/off, widths200..1400 by4 at874 plus coarse and critical height grids. Zero problems in the acceptance region width≥320/height≥480. See `sweep-summary.md` and raw JSON for192 small-target and51 overflow ranges below the acceptance boundary. Social widths200/204/208 have44/45.333/46.667-wide targets; these are not claimed compliant.

## Baseline and release proof

`legacy-golden-proof.json`:69 legacy DS PNGs checked by SHA-256,0 changed. New7 DS and18 screen PNGs are pending review in `docs/reports/goldens-review.md`.

`fake-exclusion-proof.json` scans every uncompressed APK member for the unique fake marker in UTF-8 and UTF-16LE. Debug contains it in `kernel_blob.bin`; prod release contains no match. APK hashes are recorded there.

## Resolved validation failures

The new Gallery test initially lacked a route UiIdentityScope; its fixture now mounts one. Two new test-only style lints were fixed. An initial root Flutter analysis overlapped localization regeneration and reported a transient missing generated English class; the final sequential Dart analyses are clean. The first Inspector command used its parent directory; the final command ran in `dev_tools/inspector/inspector` and passed15 tests. No rendering exception was suppressed to pass these checks.

## Removal independence

The checked absolute `dev_tools` directory was atomically moved into excluded `build/auth-entry-preflight/dev-tools-away`, then restored in `finally`. While absent, root, DS and Viewer each passed `flutter pub get --offline` and `dart analyze`; root and Viewer full `flutter test --no-pub` passed423/35. `validation-evidence/deletion-summary.log` confirms absence and restoration; individual logs preserve outputs. No app or user process was killed.

`file-inventory.json` lists source, generated, asset and documentation files with hashes. Without a Git baseline, added/modified classifications use filesystem timestamps and are explicitly identified as such. `validation-evidence/` contains the final check/build outputs; earlier failed attempts remain in build logs for diagnosis.
