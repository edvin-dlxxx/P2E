# Entry foundation implementation and validation — 2026-10-21

The root product app remains the product package. Design System and Viewer retain their package locations. Login/Register and product Ready screens are not implemented; the router destinations explicitly identify themselves as temporary localized placeholders. No HTTP/API client, endpoint, SDK, DTO, fake server, token acquisition/storage, product Inspector, signing/release setup, skin system, golden baseline or commit was added. Figma was not accessed or changed.

## Decisions and namespaces

Project-register decisions are separate from Architecture D-01–D-25. See [docs/agents/registers/decisions.md:47](D:/My_Script/Hamrah-Aval/P2E/docs/agents/registers/decisions.md:47) and the appended [docs/architecture/MyGame_P2E_Flutter_Frontend_Architecture_v1.3.md:1219](D:/My_Script/Hamrah-Aval/P2E/docs/architecture/MyGame_P2E_Flutter_Frontend_Architecture_v1.3.md:1219).

| Project decision | Outcome |
|---|---|
| D-037 | OD-1: standalone Android APK; iOS remains a target. Future launch handoff belongs behind app/host and token acquisition behind shared/session; neither is implemented. |
| D-038 | OD-2 remains open. Backend integration must replace only future data-layer implementations. |
| D-039 | Viewer is the second DS consumer, satisfying section 5.2 and superseding only Architecture D-01's DS packaging restriction. Product remains one package. Provisional PageScaffold cap uses the compact boundary, 600. |
| D-040 | Optional development hosts are detachable; existing Viewer and mandatory build/check toolchain retain their explicit locations. |
| D-041 | Provisional default fa, en available; supersedes D-004. Product D-015's text cap remains 1.3. |
| D-042 | Provisional native identifier ir.mci.mygame.p2e, subject to publisher confirmation before APK distribution outside the development team. |
| D-043 | Version clarification for Architecture section 10 State Management: runtime Riverpod 3.x; generator/annotation 4.x and modern analyzer plugin. No architecture deviation. |

## Exact resolved toolchain

Flutter 3.47.7, framework abaf9c5237, channel [user-branch]; bundled Dart 3.13.5. `.fvmrc` pins Flutter 3.47.7. Versions match the requested numbers; the Flutter checkout is not on an official named channel. No SDK change was performed. See [SDK evidence](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/flutter-version.log).

Resolved from root pubspec.lock, not guessed:

| Package | Resolved |
|---|---|
| flutter_riverpod | 3.4.3 |
| riverpod | 3.4.3 |
| riverpod_annotation | 4.0.7 |
| riverpod_generator | 4.0.9 |
| riverpod_lint | 3.1.9 |
| analysis_server_plugin | 0.3.18 |
| analyzer | 13.3.0 |
| build_runner | 2.15.1 |
| build | 4.0.7 |
| source_gen | 4.2.4 |
| go_router | 18.1.1 |
| intl | 0.20.3 |

build_runner did not require a bump. build/source_gen are transitive, not new direct dependencies. No dependency_overrides. custom_lint and all custom_lint_* packages are absent from the resolved dependency graph and active configuration. Root is the only package defining providers, so only root enables top-level `plugins: riverpod_lint: ^3.1.9`; DS and Viewer receive no Riverpod plugin/dependency.

### Actual lint execution and code generation

A temporary `lib/lint_probe.dart` called runApp without ProviderScope. `dart analyze` exited nonzero and produced the Riverpod diagnostic:

```text
warning - lib\lint_probe.dart:4:16 - Flutter applications using Riverpod must contain a ProviderScope at the root of their widget tree. - missing_provider_scope
```

The sample was deleted; final root analyze reports `No issues found!`. The plugin also caught a real scoping declaration omission during validation, which was corrected without suppressing any lint.

Generator 4.0.9 regenerated all five `.g.dart` files (app locale, config, router, startup, session), then regenerated config metadata after its scoping declaration. No generated file was hand-edited. The full first run reported five generator outputs plus five combining outputs; the generated output compiled in tests and the APK. The first historical run supplied an obsolete cleanup option, which build_runner 2.15.1 ignored. D-044..D-047 readiness maintenance removes that option from maintained instructions and CI; current commands use plain `build`.

No runtime source API migration was forced by generator 4.x. Lint compatibility made the composition helper's return type explicitly ProviderScope and marked AppConfig `dependencies: []`; neutral wrapper/override parameters remain intact.

## Alignment evidence and remaining design gaps

The reproducible real-font suite is [packages/design_system/test/alignment/entry_alignment_test.dart:13](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/test/alignment/entry_alignment_test.dart:13). It covers all Button source size/type/family combinations and legal icon modes, Badge size/appearance/icon modes, live TextField/Password/OTP, grouped Radio, AssetAppIcon, available App Bar configurations with their adapter, every Navigator selection with its host and standalone item states. Shared field surfaces/cells/presentations are exercised through their controls. This is a family/source-variant smoke matrix at width402 with representative labels and written inputs, not an exhaustive arbitrary-content or every-field-state audit.

Fonts are actually loaded from the package's bundled Outfit and Vazirmatn assets by the test harness; no network fonts or substitute metrics. Each case measures paragraph layout/clipping and pairwise paragraph overlap, catches Flutter layout errors, and checks semantic tap bounds. Icon-only controls have no text-scaling claim; artwork/hit regressions remain covered by existing package tests. These measurements are not pixel-level golden approval or a blanket proof for arbitrary host constraints.

| Locale | Theme | Requested text scale | Measured cases | Layout errors / paragraph clipping / paragraph overlap |
|---|---|---|---|---|
| en | light | 2.0 | 179 | 0 / 0 / 0 |
| en | dark | 2.0 | 180 | 0 / 0 / 0 |
| fa | light | 2.0 | 179 | 0 / 0 / 0 |
| fa | dark | 2.0 | 180 | 0 / 0 / 0 |

Total: **718** cases, **660** measured tap targets, **0** below48 in this matrix. [Raw measurements](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/component-alignment.json), [summary](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/alignment-summary.json).

| Finding / severity | Source and tested result | Smallest proposed correction, not implemented |
|---|---|---|
| 200% limitation — medium | Product [lib/app/app.dart:27](D:/My_Script/Hamrah-Aval/P2E/lib/app/app.dart:27), App Bar [packages/design_system/lib/src/components/app_bars/app_bar_content.dart:33](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/lib/src/components/app_bars/app_bar_content.dart:33), Navigator [packages/design_system/lib/src/components/navigation/app_navigation_bar.dart:69](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/lib/src/components/navigation/app_navigation_bar.dart:69) preserve D-015. App Bar/Navigator paragraph scale measured1.3 when2.0 requested. Other textual families in this fixture measured2.0. | A new owner decision lifting D-015 plus targeted shared-component geometry validation before claiming 200% support. |
| No independent skin axis/test skin — medium | [packages/design_system/lib/src/theme/app_theme_factory.dart:7](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/lib/src/theme/app_theme_factory.dart:7) keys only by brightness. No SkinDefinition/test skin exists. | Introduce a typed skin definition/resolver with independent brightness and one test skin after token-role approval. |
| No loading state — medium | [packages/design_system/lib/src/components/buttons/app_button.dart:14](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/lib/src/components/buttons/app_button.dart:14) and AppButtonType expose enabled/disabled interaction, no loading/busy API or busy semantics. Other interactive controls have no explicit asynchronous loading API. | Extend the shared Button contract/API and semantics with owner-approved loading behavior, then add targeted state tests. |
| Back App Bar Light unavailable — medium, pre-existing | [packages/design_system/lib/src/components/app_bars/app_bar_content.dart:29](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/lib/src/components/app_bars/app_bar_content.dart:29); existing app_bar_test asserts no Light source. This unavailable variant is explicitly excluded from the rendered matrix; it is not marked as passing. R-010 remains open. | Obtain the missing Light source or an explicit appearance decision; do not fabricate a twin. |
| Golden policy gap — medium | Architecture19.1 asks representative fa/en, Light/Dark,1.0/2.0, compact/medium plus test skin. [docs/agents/rules/tests-goldens.md:14](D:/My_Script/Hamrah-Aval/P2E/docs/agents/rules/tests-goldens.md:14) and D-015 lower scaling to1.3. Reviewed baselines/test skin are absent and this task explicitly prohibits creating them. | A separately authorized baseline/review task after the skin and scaling decisions. |

No existing component geometry defect requiring a source fix was found in this matrix. Existing component rendering source was not restyled. The 379 pre-existing package tests still pass within the expanded suite.

## Foundation structure and hooks

- [lib/app/bootstrap.dart:10](D:/My_Script/Hamrah-Aval/P2E/lib/app/bootstrap.dart:10): config then diagnostics then ProviderScope/runApp; rootWrapper and providerOverrides are neutral and unused by production main. The wrapper lives inside the root scope so hosts can consume overrides.
- [lib/app/config/app_config.dart:8](D:/My_Script/Hamrah-Aval/P2E/lib/app/config/app_config.dart:8): APP_ENV only, dev/stage/prod define files, default dev, reject unknown environments. No secrets or speculative endpoints.
- [lib/app/app.dart:17](D:/My_Script/Hamrah-Aval/P2E/lib/app/app.dart:17): DS Light/Dark, System brightness, provisional fa default, en and generated delegates/directionality. No persistent language-picker/settings UI.
- [lib/app/startup/startup_controller.dart:13](D:/My_Script/Hamrah-Aval/P2E/lib/app/startup/startup_controller.dart:13): initializing → sessionCheck → entry/ready derives only from session read model. Sign-in, expiry, sign-out and stale work are tested. Router reads only startup state and uses uniform NoTransitionPage placeholders.
- [lib/shared/session/session.dart:6](D:/My_Script/Hamrah-Aval/P2E/lib/shared/session/session.dart:6): in-memory signedOut/signedIn/expired. app/host is deliberately not scaffolded before an actual handoff file is needed.
- [lib/shared/formatting/digits.dart:2](D:/My_Script/Hamrah-Aval/P2E/lib/shared/formatting/digits.dart:2): Persian/Arabic-Indic normalization to ASCII and localized output.
- [lib/core/errors/app_failure.dart:2](D:/My_Script/Hamrah-Aval/P2E/lib/core/errors/app_failure.dart:2): section14.1 sealed failures and Result fold/map/flatMap; no transport DTOs.
- [lib/core/diagnostics/app_logger.dart:6](D:/My_Script/Hamrah-Aval/P2E/lib/core/diagnostics/app_logger.dart:6): phone/OTP/token redaction before sinks, nested sensitive-key protection and log-level filtering.
- [packages/design_system/lib/src/adaptive/size_class.dart:6](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/lib/src/adaptive/size_class.dart:6) and [packages/design_system/lib/src/adaptive/page_scaffold.dart:8](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/lib/src/adaptive/page_scaffold.dart:8): plain Flutter, width-only boundaries600/840, safe-area/edge-to-edge, keyboard resize and focused-field scrolling, centered medium/expanded cap600, no navigation chrome. Identity is provisional and source-unlinked. Engineering tokens are generated from adaptive.json.
- [packages/design_system/test/adaptive/page_scaffold_test.dart:5](D:/My_Script/Hamrah-Aval/P2E/packages/design_system/test/adaptive/page_scaffold_test.dart:5): 24 widget cases = three widths × two themes × two directions × scales1.0/2.0, with nonzero safe insets and a focused field after keyboard opening, plus breakpoint unit coverage. Scale is inherited unchanged by PageScaffold.
- [apps/design_system_viewer/lib/components/page_scaffold_gallery.dart:7](D:/My_Script/Hamrah-Aval/P2E/apps/design_system_viewer/lib/components/page_scaffold_gallery.dart:7): three engineering Gallery fixtures in the existing Components category, actual simulated widths preserved by catalog scrolling, localized labels and distinct scopes. No product screen or new Inspector capability.

## Native baseline and runner preservation

Android: namespace/applicationId/MainActivity package are explicitly ir.mci.mygame.p2e. minSdk26, Flutter's current target/compileSdk36. supportsRtl true, adjustResize, target36 edge-to-edge with no opt-out and PageScaffold safe insets. Android launcher label has en/fa resources. APK badging confirms these values. No external launch/token handoff or release signing setup.

iOS: the three product build configurations use ir.mci.mygame.p2e; CFBundleLocalizations contains fa/en; phone orientations portrait, iPad all four. Default generated deployment target15.0 retained. The empty RunnerTests Swift sample and its test-only Xcode objects/scheme reference were removed. Remaining Xcode object references and scheme XML were checked structurally, **not compiled**. iOS cannot be built on Windows and still requires macOS/Xcode verification.

`flutter create --platforms=android,ios --no-pub .` was used in the root. Existing file hashes were captured beforehand. Flutter rewrote `.metadata`; its exact original bytes were recovered and its SHA-256 now matches the before-create hash. Existing app/main/pubspec source was not replaced with a counter template; intentional foundation edits are listed separately. Template widget test, IDE files, default MainActivity package path and native sample tests were removed. Native launcher/storyboard/assets needed by runners remain. See [native evidence](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/platform-validation.json), [APK badging](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/apk-badging.log) and the complete [file inventory](entry-foundation-files.md).

## Architecture enforcement

[tool/check_architecture.dart:5](D:/My_Script/Hamrah-Aval/P2E/tool/check_architecture.dart:5) remains a transparent lexical check, not a semantic proof. It checks all runtime trees, relative/package/conditional import/export/part boundaries, section9 layer matrix, approved section8 feature edges, private feature src, pure-Dart domain, data and presentation/provider boundaries, dart:io/platform placement, DS public barrel/plain Flutter, banned feature widgets including named constructors, raw feature/shared visual values, runtime fonts/icons and detachable-host references in runtime/native/config/pubspec/workspace/CI files.

[test/tool/architecture_test.dart:18](D:/My_Script/Hamrah-Aval/P2E/test/tool/architecture_test.dart:18) verifies **all11 forbidden layer pairs × relative/package syntax (22 assertions)**; another test checks **22 banned widget names × default/named construction (44 assertions)**. Separate negatives cover private imports, forbidden feature edges/home incoming dependencies, domain purity, data/presentation access, SDK boundary, platform usage, DS consumer bypass and host-tool references in product, Viewer, package, CI and workspace. Positive tests cover approved public feature and platform/core imports. Full root suite includes **30 architecture tests**. SDK-name detection currently covers api_sdk/backend_sdk sentinels only; any future actual SDK name must be added with its integration. Lexical checks are best-effort and do not replace analyzer/review.

## Validation commands and results

Exact executables used (no SDK upgrade):

```text
Dart: D:\Tools\flutter\bin\cache\dart-sdk\bin\dart.exe
Flutter tool: D:\Tools\flutter\bin\cache\flutter_tools.snapshot
```

In the table, `DART` and `FLUTTER_TOOLS` stand for those exact paths; the argument lists and working directories match the executed calls. Shell redirection only captured the linked logs.

| Working directory | Invocation | Result / evidence |
|---|---|---|
| root | `DART FLUTTER_TOOLS pub get` | exit0; [root resolution](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/pub-get-toolchain.log) |
| packages/design_system | `DART FLUTTER_TOOLS pub get` | exit0; [package resolution](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/pub-get-design-system.log) |
| apps/design_system_viewer | `DART FLUTTER_TOOLS pub get` | exit0; [Viewer resolution](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/pub-get-viewer.log) |
| root | `DART run build_runner build` | exit0, all5 outputs regenerated; [first run](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/codegen-v4.log), [metadata regeneration](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/codegen-final.log) |
| root; Viewer separately | `DART FLUTTER_TOOLS gen-l10n` | exit0; generated from ARBs, never hand-edited |
| root, negative sample present | `DART analyze` | expected nonzero, missing_provider_scope; [probe](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/lint-negative-probe.log) |
| root, sample deleted | `DART analyze` | exit0, zero issues; [root analysis](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/analyze-root.log) |
| packages/design_system | `DART analyze` | exit0, zero issues; [package analysis](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/analyze-design-system.log) |
| apps/design_system_viewer | `DART analyze` | exit0, zero issues; [Viewer analysis](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/analyze-viewer.log) |
| root | `DART FLUTTER_TOOLS test --no-pub --reporter expanded` | exit0,42 passed; [root tests](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/tests-root.log) |
| packages/design_system | same test invocation | exit0,408 passed (baseline379 + adaptive25 + alignment4); [package tests](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/tests-design-system.log) |
| apps/design_system_viewer | same test invocation | exit0,31 passed (baseline29 + catalog2); [Viewer tests](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/tests-viewer.log) |
| root | `DART run tool/check_architecture.dart` | exit0; [architecture](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/architecture.log) |
| root | `DART run tool/agents/sync_agent_files.dart --check` | exit0,33 generated files current |
| root | `node tool/tokens/generate_adaptive.cjs --check` | exit0 |
| root | `DART format --output=none --set-exit-if-changed lib test tool packages/design_system/lib packages/design_system/test packages/design_system/test_support apps/design_system_viewer/lib apps/design_system_viewer/test` | exit0,0 changed; maintained Dart source/test trees, excluding ignored build/cache evidence; [format](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/format-check.log) |
| root | `DART FLUTTER_TOOLS build apk --debug --no-pub --dart-define-from-file=config/dev.json` | exit0; [final build](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/android-build-final.log) |

The APK build logs contain a Kotlin daemon connection warning/fallback; Gradle still completed successfully. No SDK/JDK upgrade or workaround signing configuration was introduced. [Internal-development APK](D:/My_Script/Hamrah-Aval/P2E/build/app/outputs/flutter-apk/app-debug.apk).

### Detachable development-host check

`dev_tools/` did not exist before or during these final pub-get/analyze/test runs, so no directory move was necessary. Root, DS and Viewer resolved, analyzed and passed tests in that absent state; Android APK built in that same state. Architecture negative tests reject future references. [Deletion/absence evidence](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/deletion-check.json).

## Files and remaining limits

The complete added/modified/deleted/local-generated/template-cleanup list is [entry-foundation-files.md](entry-foundation-files.md), with machine-readable inventory at [file-inventory.json](D:/My_Script/Hamrah-Aval/P2E/build/entry-foundation/file-inventory.json). No pre-existing product source file was deleted. Build/cache evidence is kept under build/entry-foundation and the APK output path, not treated as source additions.

Foundation implementation has no unresolved dependency or test blocker. Remaining alignment/design gaps are the explicit table above; OD-2 remains intentionally open. Publisher confirmation blocks external APK distribution. iOS build/runtime verification requires macOS/Xcode. No product screens, Inspector implementation or backend work was started.

The CI workflow invokes the analyzer, all suites and architecture/synchronization/generation checks. It was authored and checked locally; no remote CI run is claimed from this workspace.
