# Validation — D-062 Auth acceptance follow-up

Windows, Flutter3.47.7 / Dart3.13. `flutter` below was invoked as `D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe D:/Tools/flutter/bin/cache/flutter_tools.snapshot`. `dart` was the same SDK dart.exe. No commits. Only five owner-approved idle-copy baselines were updated once; every validation golden run below omits the update flag.

|Working directory|Exact command|Result|Output|
|---|---|---|---|
|.|`flutter test --no-pub --concurrency 2 --reporter expanded`|447 passed (previous431 +16 visibility regressions)|[log](validation-evidence/followup-root-tests.log)|
|packages/design_system|`flutter test --no-pub --concurrency 2 --reporter expanded`|541 passed|[log](validation-evidence/followup-tests-packages_design_system.log)|
|apps/design_system_viewer|`flutter test --no-pub --concurrency 2 --reporter expanded`|35 passed|[log](validation-evidence/followup-tests-apps_design_system_viewer.log)|
|dev_tools/inspector/inspector|`flutter test --no-pub --concurrency 2 --reporter expanded`|18 passed|[log](validation-evidence/followup-tests-dev_tools_inspector_inspector.log)|
|dev_tools/inspector/hosts/product_host|`flutter test --no-pub --concurrency 2 --reporter expanded`|4 passed; 3 opt-in skipped|[log](validation-evidence/followup-tests-dev_tools_inspector_hosts_product_host.log)|
|dev_tools/inspector/hosts/viewer_host|`flutter test --no-pub --concurrency 2 --reporter expanded`|3 passed; 1 opt-in skipped|[log](validation-evidence/followup-tests-dev_tools_inspector_hosts_viewer_host.log)|
|.|`flutter test --no-pub test/features/auth/tap_visibility_test.dart test/features/auth/figma_conformance_test.dart --reporter expanded`|20 passed|[log](validation-evidence/followup-regression.log)|
|dev_tools/inspector/hosts/product_host|`$env:RUN_AUTH_SWEEP='1'; flutter test --no-pub test/auth_entry_sweep_test.dart --reporter expanded`|1 passed;48 plans/10784 callbacks; zero supported-area Problems; no diagnostic filter|[log](validation-evidence/followup-sweep-final.log)|
|.|`dart run tool/check_architecture.dart`|passed; all49 architecture negative/positive tests also pass in the root suite|[log](validation-evidence/followup-architecture.log)|
|.|`dart run tool/agents/sync_agent_files.dart --check`|33 generated copies current|[log](validation-evidence/followup-agents.log)|
|.|`dart format --output=none --set-exit-if-changed .`|281 files; zero changes|[log](validation-evidence/followup-format.log)|
|.|`flutter test --no-pub test/goldens --reporter expanded`|18/18, pass1, no update|[log](validation-evidence/followup-root-goldens-1.log)|
|.|`flutter test --no-pub test/goldens --reporter expanded`|18/18, pass2, no update|[log](validation-evidence/followup-root-goldens-2.log)|
|packages/design_system|`flutter test --no-pub test/goldens --reporter expanded`|76/76, pass1, no update|[log](validation-evidence/followup-ds-goldens-1.log)|
|packages/design_system|`flutter test --no-pub test/goldens --reporter expanded`|76/76, pass2, no update|[log](validation-evidence/followup-ds-goldens-2.log)|
|.|`flutter analyze --no-pub`|zero issues|[log](validation-evidence/followup-analyze-_.log)|
|packages/design_system|`flutter analyze --no-pub`|zero issues|[log](validation-evidence/followup-analyze-packages_design_system.log)|
|apps/design_system_viewer|`flutter analyze --no-pub`|zero issues|[log](validation-evidence/followup-analyze-apps_design_system_viewer.log)|
|dev_tools/inspector/inspector|`flutter analyze --no-pub`|zero issues|[log](validation-evidence/followup-analyze-dev_tools_inspector_inspector.log)|
|dev_tools/inspector/hosts/product_host|`flutter analyze --no-pub`|zero issues|[log](validation-evidence/followup-analyze-dev_tools_inspector_hosts_product_host.log)|
|dev_tools/inspector/hosts/viewer_host|`flutter analyze --no-pub`|zero issues|[log](validation-evidence/followup-analyze-dev_tools_inspector_hosts_viewer_host.log)|
|.|`flutter pub get --offline`|passed with existing locks|[log](validation-evidence/followup-pub-_.log)|
|packages/design_system|`flutter pub get --offline`|passed with existing locks|[log](validation-evidence/followup-pub-packages_design_system.log)|
|apps/design_system_viewer|`flutter pub get --offline`|passed with existing locks|[log](validation-evidence/followup-pub-apps_design_system_viewer.log)|

Generator commands, each with --check (no output changes):

```powershell
$env:DART='D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe'
Get-ChildItem tool/tokens/generate_*.cjs | ForEach-Object { & 'C:/Program Files/nodejs/node.exe' $_.FullName --check }
Get-ChildItem tool/tokens/generate_*.dart | ForEach-Object { & $env:DART $_.FullName --check }
python tool/fonts/prepare_outfit.py --check
```

All9 Node and4 Dart generator checks passed; all four real static Outfit faces remain verified. [Captured stdout](validation-evidence/followup-generators.log).

Localization was regenerated with `flutter gen-l10n`. The five listed baselines were regenerated using `flutter test --no-pub test/goldens/auth_entry_goldens_test.dart --name auth-idle --update-goldens --reporter expanded`; all94 starting baselines were backed up first.

The historical-recovery test renders intentionally fail comparison against the current after-baselines. Their emitted test images were compared with the *original pre-conformance SHA-256*, not accepted by changing a tolerance or baseline. All32 replayed controls (14 DS +18 root) matched those hashes;19 previously missing files are identified in the recovery manifest. The temporary project was removed. These expected reconstruction mismatches are not suppressed product failures.

The preceding width-only policy sweep exposed height-only changes under an unbounded scroll child. The final policy observes MediaQuery viewport size as well as layout constraints; the entire final sweep passes with the original Problems rule unchanged.

Ink30/30, source text-style comparisons43/43 and before-image hashes91/91 pass. [Contact percentages](goldens.md) include actual native RGBA changes, including alpha. No APK or Windows rebuild is claimed for this scoped evidence/copy/visibility follow-up.
