# Final acceptance validation

Flutter3.47.7 / Dart3.13, Windows. `flutter` below is exactly `D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe D:/Tools/flutter/bin/cache/flutter_tools.snapshot`. `dart` is that SDK dart.exe. No commit; no golden update. Ordinary suites pass; the opt-in sweep and ink acceptance are explicitly not passing.

|Working directory|Exact command|Result|Log|
|---|---|---|---|
|.|`flutter test --no-pub --concurrency 2 --reporter expanded`|431 passed|[output](validation-evidence/acceptance-root-tests-final.log)|
|packages/design_system|`flutter test --no-pub --concurrency 2 --reporter expanded`|541 passed|[output](validation-evidence/acceptance-ds-tests-final.log)|
|apps/design_system_viewer|`flutter test --no-pub --reporter expanded`|35 passed|[output](validation-evidence/acceptance-tests-apps_design_system_viewer.log)|
|dev_tools/inspector/inspector|`flutter test --no-pub --reporter expanded`|18 passed|[output](validation-evidence/acceptance-tests-dev_tools_inspector_inspector.log)|
|dev_tools/inspector/hosts/product_host|`flutter test --no-pub --reporter expanded`|4 passed; 3 opt-in skipped|[output](validation-evidence/acceptance-tests-dev_tools_inspector_hosts_product_host.log)|
|dev_tools/inspector/hosts/viewer_host|`flutter test --no-pub --reporter expanded`|3 passed; 1 opt-in skipped|[output](validation-evidence/acceptance-tests-dev_tools_inspector_hosts_viewer_host.log)|
|.|`flutter test --no-pub test/features/auth/hit_envelope_test.dart test/features/auth/figma_conformance_test.dart --reporter expanded`|12 passed; 32 envelope taps, four geometry states|[output](validation-evidence/acceptance-auth-geometry-final.log)|
|packages/design_system|`flutter test --no-pub test/ui/components/button_overlap_test.dart test/readiness/button_loading_test.dart --reporter expanded`|10 passed; disabled and loading activation preserved|[output](validation-evidence/acceptance-overlap-final.log)|
|.|`flutter test --no-pub test/tool/architecture_test.dart --reporter expanded`|49 passed|[output](validation-evidence/acceptance-architecture-negative.log)|
|.|`dart run tool/check_architecture.dart`|passed|[output](validation-evidence/acceptance-architecture.log)|
|.|`dart run tool/agents/sync_agent_files.dart --check`|33 copies current|[output](validation-evidence/acceptance-agents.log)|
|.|`dart format --output=none --set-exit-if-changed .`|279 files; 0 changes|[output](validation-evidence/acceptance-format.log)|
|.|`flutter test --no-pub test/goldens --reporter expanded`|18/18; no update; pass 1|[output](validation-evidence/acceptance-root-goldens-1.log)|
|.|`flutter test --no-pub test/goldens --reporter expanded`|18/18; no update; pass 2|[output](validation-evidence/acceptance-root-goldens-2.log)|
|packages/design_system|`flutter test --no-pub test/goldens --reporter expanded`|76/76; no update; pass 1|[output](validation-evidence/acceptance-ds-goldens-1.log)|
|packages/design_system|`flutter test --no-pub test/goldens --reporter expanded`|76/76; no update; pass 2|[output](validation-evidence/acceptance-ds-goldens-2.log)|
|packages/design_system|`flutter analyze --no-pub`|zero issues|[output](validation-evidence/acceptance-analyze-packages_design_system.log)|
|apps/design_system_viewer|`flutter analyze --no-pub`|zero issues|[output](validation-evidence/acceptance-analyze-apps_design_system_viewer.log)|
|dev_tools/inspector/inspector|`flutter analyze --no-pub`|zero issues|[output](validation-evidence/acceptance-analyze-dev_tools_inspector_inspector.log)|
|dev_tools/inspector/hosts/product_host|`flutter analyze --no-pub`|zero issues|[output](validation-evidence/acceptance-analyze-dev_tools_inspector_hosts_product_host.log)|
|dev_tools/inspector/hosts/viewer_host|`flutter analyze --no-pub`|zero issues|[output](validation-evidence/acceptance-analyze-dev_tools_inspector_hosts_viewer_host.log)|
|.|`flutter analyze --no-pub`|zero issues|[output](validation-evidence/acceptance-analyze-_.log)|
|dev_tools/inspector/hosts/product_host|`$env:RUN_AUTH_SWEEP='1'; flutter test --no-pub test/auth_entry_sweep_test.dart --reporter expanded`|FAIL:48 plans /10784 callbacks complete;16 supported-area viewport envelope ranges|[output](validation-evidence/acceptance-sweep-complete.log)|
|Root|`python tool/auth_acceptance/evidence.py`|Artifacts generated; ink acceptance29/30, before images72/91; both incomplete statuses retained|[ink](ink.md), [diff percentages](goldens.md)|

The earliest overlap regression failed in both directions before the routing correction. A temporary isolated reconstruction of old images failed to match the recorded hashes and is excluded from evidence; no reconstructed image is labeled as before. Root envelope tests mount a fresh route per tap because a previous offline-failure toast otherwise legitimately intercepts the next tap. No Flutter error was suppressed.

The complete new runtime-measurements JSON equals the preceding conformance JSON byte-for-value across all four states. Baseline hashes remain94/94 unchanged. Pixel/semantic/focus suites above retain their existing expected results. No APK or Windows rebuild is claimed for this evidence-only follow-up.
