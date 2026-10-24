# Design System readiness D-044–D-047

Historical readiness report: its Persian font finding was resolved by
[D-048 on2026-10-22](persian-font-fallback-d048.md). The evidence and original
findings below describe the earlier D-044..D-047 run.


Implemented the delegated decisions; no Entry screen, new Inspector, backend,
SDK/dependency upgrade, or commit. The Figma connection was strictly read-only.
Technical checks pass; visual readiness is **not approved**. The known Persian
fallback defect below blocks acceptance of affected golden images.

## Per-phase results

- **D-044 final:** D-015 content cap superseded. Root uses TextScaler.clamp at
  2.0, preserving non-linear behavior (18→32.4, 24→48 in the non-linear test).
  A single generated chromeTextScaleCap=1.3 is used by App Bar and Navigator.
  It covers every App Bar paragraph, including avatar/wallet values and units;
  Navigator's private badge chrome inherits it too. Standalone Badge and all
  other content keep 2.0. Inspector comparison remains 1.0. The complete
  alignment matrix verifies paragraph scales, clipping/overlap and hit targets.
  Full semantic wallet values/units remain available. Future screen rules use
  compact × 1/2 × en/fa × Light/Dark with scrolling content.
- **D-045 final behavior, provisional visual:** live Figma Button page
  16433:9027 contains 18 sets/90 variants, only Filled/Tonal/Outlined/Text/Disable.
  Read-only metadata and design context of set 18437:1871 found no loading axis.
  Metadata evidence: build/readiness/figma-button-metadata.txt. R-012 requests
  designer loading visuals. AppButton adds loading/default false and caller
  loadingSemanticsLabel; enabled paints, icon-sized token indicator, static
  reduced motion. Invisible original content keeps all 90 normal visual/hit
  sizes. Callbacks/press/hover suppressed; keyboard and accessibility focus
  retained, including ending in disabled state without a semantic tap action.
  One non-blocking debug/profile missing-label report per instance, release
  silent. Complete disabled-button semantics; no indicator semantics. Boolean
  config metadata preserves identity; **no identity schema change**. Viewer
  has a localized loading toggle, source comparison is disabled while loading.
- **D-046 final:** typed 35 required non-null existing raw color roles per
  brightness; omission is a compile error. Product default preserves old theme
  values, source paint floats and 20 captured English product contact sheets
  byte-for-byte (both brightness modes, all variants). Independent product/test
  resolver, appSkinProvider and neutral overrides; no product picker. The actual
  package is p2e_design_system: its testing.dart alone exposes testSkin and moved
  identity helpers. Old test_support is deleted and imports updated. Architecture
  rejects product lib imports, allows Viewer/tests. Viewer skin selector is next
  to brightness. Best-effort exact-ARGB leak guard passes all ten families in
  both brightness modes, including derived Light Password/OTP live controls.
  Original standalone SVG artwork and multi-color artwork inside controls are
  excluded explicitly; arbitrary overrides/composited colors are not proven.
  See ../design-system/contracts/skins.md for scope and generator inputs.
- **D-047 final policy, initial images pending review:** 69 Windows baselines;
  missing Light Password/OTP sources omit eight sheets, Back Light omitted from
  App Bar Light sheets. PageScaffold runs all seven configurations at402/700.
  Bundled fonts, fixed DPR/surfaces, disabled animations, no network/tolerance.
  Generated once, then two consecutive 69/69 no-update passes; repeated against
  final code. Linux CI excludes golden with an explicit Windows rationale.
  [Every baseline and its review status](goldens-review.md).

## Known gaps and limits

1. **High — Persian fallback:** affected Button/PageScaffold golden sheets
   contain missing-glyph boxes. This is pre-existing rendering, not skin color
   drift. Real Vazirmatn is loaded; source Field Persian glyphs render correctly.
   The diagnostic log shows a duplicated packages/p2e_design_system prefix in
   the token-styled heading fallback and no usable Button fallback. The
   tests-goldens rule's no-boxes criterion is not met, so affected baselines
   cannot be accepted as readiness approval. Kept visible rather than silently
   changing product pixels under D-046. See build/readiness/font-diagnostic.log.
2. **Medium — six-digit wallet visibility at402:** with effective chrome1.3,
   complete values + units need **489 en /474 fa** pixels in both brightness
   modes. They do **not** simultaneously fit402. Existing horizontal canvas
   scrolls, without further shrink/ellipsis; semantics stays complete. The API
   documents caller-owned compact formatting, like Badge counts. Measurement
   evidence: build/readiness/six-digit-wallet.json. Passing paragraph/semantics
   tests are not presented as a simultaneous-visibility pass.
3. Loading visual and Persian typography remain provisional (R-012/R-003);
   golden review remains pending. No new sourced designs were fabricated.

## Exact validation commands and evidence

PowerShell executable aliases below expand to these exact installed paths:

```powershell
$dart = 'D:\Tools\flutter\bin\cache\dart-sdk\bin\dart.exe'
$flutterTools = 'D:\Tools\flutter\bin\cache\flutter_tools.snapshot'
```

Commands run in each named working directory (not workspace commands):

| Working directory | Command | Actual result / evidence in build/readiness/ |
|---|---|---|
| root | `& $dart $flutterTools pub get` | exit0, root-pub-get.log |
| packages/design_system | `& $dart $flutterTools pub get` | exit0, ds-pub-get.log |
| apps/design_system_viewer | `& $dart $flutterTools pub get` | exit0, viewer-pub-get.log |
| all three independently | `& $dart analyze` | zero issues; root-analyze.log, ds-analyze.log, viewer-analyze-final.log (final repeats: *-dart-analyze-final.log) |
| all three independently | `& $dart $flutterTools analyze --no-pub` | zero issues; *-flutter-analyze.log |
| root | `& $dart $flutterTools test --reporter expanded` | 45 passed, +3 vs42; root-tests-final.log |
| packages/design_system | `& $dart $flutterTools test --reporter expanded` | 489 passed, +81 vs408 =420 other +69 golden; ds-tests-final.log |
| apps/design_system_viewer | `& $dart $flutterTools test --reporter expanded` | 32 passed, +1 vs31; viewer-tests-final.log |
| packages/design_system | `& $dart $flutterTools test test/goldens/readiness_goldens_test.dart --update-goldens --reporter expanded` | 69 generated, goldens-generate.log |
| packages/design_system | `& $dart $flutterTools test --tags golden --reporter expanded` twice consecutively | 69/69 each, goldens-final-1.log and goldens-final-2.log; no updates |
| packages/design_system | `& $dart $flutterTools test --dart-define=RECORD_PRODUCT_BEFORE=true test/readiness/product_skin_preservation_test.dart --reporter expanded` before skin integration | 20 PNG references recorded, product-before.log |
| packages/design_system | `& $dart $flutterTools test --dart-define=RUN_PIXEL_GUARD=true test/readiness/product_skin_preservation_test.dart --reporter expanded` | 1 passed,20 byte-equal sheets plus prior theme comparisons; product-preservation-final.log |
| packages/design_system | `& $dart $flutterTools test test/readiness/skin_test.dart --reporter expanded` | 3 passed, leak-final.log; includes derived Light live controls |
| packages/design_system | `& $dart analyze test/readiness/negative_missing_skin_role.dart` | expected exit3,35 missing_required_argument errors, skin-negative-compile.log; temporary file removed, clean analyze rerun |
| root | `& $dart run build_runner build` | exit0, generated app provider output, codegen.log; no hand-edited output/API break |
| Viewer | `& $dart $flutterTools gen-l10n` | exit0, generated localized controls from ARBs |
| root | `& $dart run tool/check_architecture.dart` | passed, architecture-final.log |
| root (included in full suite) | architecture negative tests in `test/tool/architecture_test.dart` | forbidden layer directions/relative+package imports, product testing entrypoint and existing dependency/dev boundaries fail as expected; root-tests-final.log |
| root | `& $dart run tool/agents/sync_agent_files.dart --check` | 33 generated files up to date, agent-sync-check-final.log |
| root | `node tool/tokens/generate_{adaptive,app_bars,badges,fields,icons,navigation,readiness,skins}.cjs --check` (each expanded and run independently) | all8 exit0, token-checks.log; portable skins-check-final.log |
| root | `& $dart run tool/tokens/generate_{buttons,button_spec,button_icons,motion_defaults}.dart --check` (each expanded independently) | all4 exit0, individual generator-check logs |
| root | `& $dart format --output=none --set-exit-if-changed .` | final zero changed; format-check-final.log. Initial whole-tree check also reached8 old build/identity-audit scratch Dart files; only formatting was applied there, outside maintained source inventory. |
| root | `& $dart $flutterTools build apk --debug` | exit0, app-debug.apk, android-debug-build-final.log; Gradle JVM native-access warning only |
| root | `Test-Path dev_tools` | False. Folder absent throughout all three pub-get/analyze/full-test runs; no move/deletion required. Architecture also rejects references. |

All maintained scripts/docs/CI use plain build_runner build; obsolete cleanup
switch removed. Token data and Riverpod/l10n/agent files were regenerated from
sources, never hand-edited. Source formatting is clean. No dependency versions
were changed in this readiness task. iOS build is not performed on Windows.

[Added/modified/deleted maintained files](design-system-readiness-files.md).
