# Inspector v1.1 file inventory — 2026-10-23

Maintained source/document changes; build/cache output excluded. Historical v1 inventory remains in FILES.md. No v1.1 task-start hash manifest was available, so this is an explicit implementation inventory rather than a reconstructed git diff. No git repository or commit.

## Added

- lib/core/platform/device_inputs.dart
- test/app/device_inputs_test.dart
- dev_tools/inspector/inspector/lib/src/core/device.dart
- dev_tools/inspector/inspector/lib/src/core/problems.dart
- dev_tools/inspector/inspector/lib/src/host/device_toolbar.dart
- dev_tools/inspector/inspector/test/device_test.dart
- dev_tools/inspector/inspector/test/flutter_test_config.dart
- dev_tools/inspector/hosts/product_host/test/sweep_report_test.dart
- dev_tools/inspector/hosts/viewer_host/test/sweep_report_test.dart
- dev_tools/inspector/VALIDATION-v1.1.md
- dev_tools/inspector/SWEEP-v1.1.md
- dev_tools/inspector/FILES-v1.1.md

## Modified

- lib/app/app.dart
- lib/app/app.g.dart
- apps/design_system_viewer/lib/main.dart
- docs/agents/registers/decisions.md
- dev_tools/inspector/README.md
- dev_tools/inspector/inspector/lib/inspector.dart
- dev_tools/inspector/inspector/lib/src/host/inspector_host.dart
- dev_tools/inspector/inspector/lib/src/host/generated/tool_copy.g.dart
- dev_tools/inspector/inspector/l10n/tool_en.arb
- dev_tools/inspector/inspector/test/inspection_test.dart
- dev_tools/inspector/hosts/product_host/lib/main.dart
- dev_tools/inspector/hosts/product_host/test/host_test.dart
- dev_tools/inspector/hosts/viewer_host/lib/main.dart
- dev_tools/inspector/hosts/viewer_host/test/host_test.dart
- dev_tools/inspector/hosts/viewer_host/pubspec.yaml
- dev_tools/inspector/hosts/viewer_host/pubspec.lock
- dev_tools/inspector/tool/check_isolation.ps1
- dev_tools/inspector/tool/validate_snapshots.py

## Evidence added

All files under dev_tools/inspector/evidence/v1.1/ are new durable evidence:

- dev_tools/inspector/evidence/v1.1/analyze-viewer-complete.log
- dev_tools/inspector/evidence/v1.1/ds-neutrality-proof.json
- dev_tools/inspector/evidence/v1.1/final-agents.log
- dev_tools/inspector/evidence/v1.1/final-architecture.log
- dev_tools/inspector/evidence/v1.1/final-checks.json
- dev_tools/inspector/evidence/v1.1/final-copy.log
- dev_tools/inspector/evidence/v1.1/final-format.log
- dev_tools/inspector/evidence/v1.1/final-results-core.json
- dev_tools/inspector/evidence/v1.1/final-results-product_host.json
- dev_tools/inspector/evidence/v1.1/final-results-viewer_host.json
- dev_tools/inspector/evidence/v1.1/final-schema.log
- dev_tools/inspector/evidence/v1.1/isolation-blocked.log
- dev_tools/inspector/evidence/v1.1/isolation-final.log
- dev_tools/inspector/evidence/v1.1/isolation-results.json
- dev_tools/inspector/evidence/v1.1/isolation-status.json
- dev_tools/inspector/evidence/v1.1/product_host-sweep.json
- dev_tools/inspector/evidence/v1.1/release-exclusion-proof.json
- dev_tools/inspector/evidence/v1.1/restored-excerpts.json
- dev_tools/inspector/evidence/v1.1/restored-results-core.json
- dev_tools/inspector/evidence/v1.1/restored-results-product_host.json
- dev_tools/inspector/evidence/v1.1/restored-results-viewer_host.json
- dev_tools/inspector/evidence/v1.1/results-package.json
- dev_tools/inspector/evidence/v1.1/results-root.json
- dev_tools/inspector/evidence/v1.1/token-results.json
- dev_tools/inspector/evidence/v1.1/validation-excerpts.json
- dev_tools/inspector/evidence/v1.1/viewer_host-sweep.json

## Deleted

No maintained file deleted. Temporary sweep_probe_test.dart was removed after diagnosis. No golden baseline was created, modified or deleted. Existing DS component/token/font/icon files are unchanged.
