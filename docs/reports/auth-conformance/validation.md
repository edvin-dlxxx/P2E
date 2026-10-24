# Validation — Auth conformance corrections

Flutter3.47.7 / Dart3.13 on Windows. Exact SDK invocation used `D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe D:/Tools/flutter/bin/cache/flutter_tools.snapshot` for `flutter`. No builds from the previous task are claimed as rebuilt by this follow-up.

| Working directory / command | Result |
|---|---|
|Root: `flutter test --no-pub`|423 passed|
|`packages/design_system`: `flutter test --no-pub`|535 passed, previously528; seven new static-face/hit-envelope regressions|
|`apps/design_system_viewer`: `flutter test --no-pub`|35 passed|
|`dev_tools/inspector/inspector`: `flutter test --no-pub`|15 passed|
|`dev_tools/inspector/hosts/product_host`: `flutter test --no-pub`|4 passed;3 opt-in sweeps skipped in ordinary suite|
|`dev_tools/inspector/hosts/viewer_host`: `flutter test --no-pub`|3 passed;1 opt-in matrix skipped|
|Root: `flutter test --no-pub test/goldens` twice|18/18 both times, no update flag|
|DS: `flutter test --no-pub test/goldens` twice|76/76 both times, no update flag|
|All six package directories: `dart analyze`|zero issues|
|Root: `flutter test --no-pub test/tool/architecture_test.dart`|49 passed; D-055 exact-file/purity protections unchanged|
|`dart run tool/check_architecture.dart`|passed|
|All9 Node `tool/tokens/generate_*.cjs --check` and4 Dart generators `--check`|passed|
|`python tool/fonts/prepare_outfit.py --check`|four real static weights verified|
|`dart run tool/agents/sync_agent_files.dart --check`|passed;33 generated copies current|
|`dart format --output=none --set-exit-if-changed .`|276 files,0 changes|
|Root: `flutter test --no-pub test/features/auth/figma_conformance_test.dart`|4 states passed; emitted final measured evidence|

Initial root/DS `flutter pub get --offline` succeeded after the font manifest change. Font assets are loaded from the real generated manifests in all golden/layout tests. Generator outputs were regenerated from source; none was hand-edited.

To run the scripted sweep from product_host:

```powershell
$env:RUN_AUTH_SWEEP='1'
flutter test --no-pub test/auth_entry_sweep_test.dart
```

The final run passed with48 plans and10,784 callbacks (10,688 scheduled samples plus setup/restore callbacks), all four states, fa/en,1.0/2.0, keyboard on/off, width200..1400 step4 plus height grids. [Acceptance extraction](sweep-acceptance.json) confirms zero reported problems at width≥320/height≥480. Raw below-boundary reports remain in [the full sweep JSON](inspector-sweep.json), without claiming undersized targets compliant. Persian widget and DS alignment matrices also pass no-overflow/clipping checks; taller translated content can scroll.

The changed goldens were intentionally regenerated using `flutter test --no-pub test/goldens --update-goldens`, then verified twice without that flag.91 changed references are listed individually in [changed-goldens.json](changed-goldens.json); no golden was silently approved. Three existing DS sheets remain byte-identical to the pre-fix hashes.

All final command outputs are in [validation-evidence/](validation-evidence). Early failures were corrected: old test-local variable-font loaders now use the package-wide real manifest; weight tests now assert static-face selection; merged internal semantics nodes are excluded from duplicate target counting; inline link semantics and RTL traversal have explicit coverage. No Flutter error was caught/filtered to make these regressions pass.
