# Delegated golden review fixes — D-049

Date: 2026-10-22. Windows; Flutter 3.47.7 / Dart 3.13.5. No commit.

## Findings and changes

| Item | Evidence and result |
|---|---|
| Button RTL (reported high) | The reported left-side icon was not reproduced in current code. Before edits, the same RTL instance measured icon x=611.5..631.5 and label x=574.5..603.5, so the icon was already at logical start/right. The Row already inherited Directionality, used icon-first children and directional padding. Made its ambient textDirection explicit at `packages/design_system/lib/src/components/buttons/app_button.dart:132`; added placement coverage for every size/family with icons in en/fa, including normal/loading rows. No reversal or physical offset introduced. |
| Golden constraints (high, confirmed) | The sheet wrapped every specimen in a tight `SizedBox(width: width)`. `packages/design_system/test/support/readiness_sheet.dart:124` now gives loose constraints under Align to every family, with a width wrapper only for AppButton.fill. Hug/icon-only Buttons, Badges and source OTP cells regain intrinsic width. Field/Radio/AppBar/Navigator/PageScaffold keep their own bounded fill behavior. AppIcon artwork remains intrinsic and centered. Width assertions cover fill==402, hug/icon<402, Badge<402 and OTP<402. |
| Persian digits (medium, confirmed) | D-049 records Persian display digits, ASCII storage/transmission policy and caller-side conversion in shared/formatting; DS text is untouched. The fixture-only converter localizes Field, Password, OTP, App Bar, Badge and Navigator values, plus visible numeric sheet headers. Technical source keys/IDs remain ASCII. AppIcon/Radio fa sheets changed only because visible headers contain numeric source IDs. No new product formatter or storage normalization was implemented. |
| Avatar (low) | Existing ClipOval already clipped both text and custom content. Explicitly retained antiAlias at `packages/design_system/lib/src/components/app_bars/app_bar_content.dart:184`. API docs in `app_bar_configuration.dart:14` require caller-supplied localized initials of 1–2 graphemes. Fixtures now use CM / سم. A matrix checks scales 1.0/1.3/requested2.0 (clamped1.3), and an actual AppBar raster comparison verifies deliberately oversized text changes pixels inside the circle and none outside it (one-pixel edge allowance for antialiasing). |

No typography tokens, fonts, identity, Viewer structure, screens or numerical component geometry changed.

## Figma evidence (read-only)

Inspected file `7PGTHT5CQzbTsWZQnPIQce`, its top-level page inventory,
Button page `16433:9027` (18 sets / 90 variants), Medium Button Dark set
`18437:1871` through design context/screenshot, and EN page `16458:11` metadata.
The source uses icon-first LTR layout. No explicit Persian/RTL Button override
was found in those inspected sources. This is bounded evidence, not a claim to
have expanded every hidden instance. No Figma write tool was called.

The codebase graph had no indexed P2E project; direct source/rg fallback was used.

## Directional audit

| Component | Result |
|---|---|
| Button | Correct before change; explicit ambient direction plus regression tests. |
| Badge | Correct: icon-first Row, directional padding; LTR/RTL x-position test. |
| TextField helper | Correct: supporting icon-first Row; LTR/RTL x-position test. Password shares the supporting implementation. |
| App Bar | Correct: crown/currency rows follow ambient direction and action padding is directional; LTR/RTL positions tested. Numeric run direction does not reverse the containing Row. |
| Navigator badges | Correct: PositionedDirectional anchor mirrors around the icon; both locales tested. |
| Radio | Correct: control-first directional Row; LTR/RTL positions tested. |

## Review state and protected references

Exactly these three statuses are `approved — delegated review (2026-10-22)`:

- navigator-en-light-1.0-product-402
- pagescaffold-fa-dark-1.0-product-402
- pagescaffold-fa-dark-1.0-product-700

Their SHA-256 hashes are unchanged. All remaining 66 baselines remain pending
review. Horizontal PageScaffold padding remains deferred to the Login task.
All 69 baseline hashes were compared with the task-start inventory: exactly
38 changed, matching the failing set identified before regeneration; 31 unchanged.

Eight requested review samples were replaced with exact baseline copies; see
[the sample index](golden-samples/README.md). Obsolete sample copies were removed.

## Validation

All commands exited zero in the final validation. Flutter/Dart commands were
invoked through the installed SDK executables (equivalent commands below):

```powershell
$dart = 'D:\Tools\flutter\bin\cache\dart-sdk\bin\dart.exe'
$flutter = 'D:\Tools\flutter\bin\cache\flutter_tools.snapshot'
# flutter <args> was executed as: & $dart $flutter <args>
# dart <args> was executed as: & $dart <args>
```

| Working directory | Command | Result |
|---|---|---|
| root, packages/design_system, apps/design_system_viewer | `flutter pub get` (each) | All three pass; dependency/lock files unchanged. |
| same three directories | `dart analyze` and `flutter analyze --no-pub` (each) | Zero issues in all six runs. |
| root | `flutter test --reporter expanded` | 45 passed (baseline45); includes architecture negative tests for forbidden import directions and cross-package escape attempts. |
| packages/design_system | `flutter test --reporter expanded` | 504 passed (baseline498 + six new regression tests), including all69 goldens. |
| apps/design_system_viewer | `flutter test --reporter expanded` | 33 passed (baseline33). |
| packages/design_system | `flutter test --tags golden --reporter expanded` twice consecutively | 69/69 then69/69, no updates. |
| packages/design_system | `flutter test test/readiness/delegated_review_test.dart --name 'avatar paint' --reporter expanded` | Final raster probe1/1 passes; all six final regression tests also pass in the full suite. |
| root | `dart run tool/check_architecture.dart` | Pass. |
| root | `dart run tool/agents/sync_agent_files.dart` then `dart run tool/agents/sync_agent_files.dart --check` | Pass; canonical D-049 rule propagated,33 generated agent files synchronized. |
| root | `dart format --output=none --set-exit-if-changed .` | 199 files, zero changes. |
| root | `flutter build apk --debug` | Pass: build/app/outputs/flutter-apk/app-debug.apk. |

All 12 token reproducibility checks passed:

```powershell
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

Node used `C:\Program Files\nodejs\node.exe`; DART/NODE environment variables
pointed to the installed executables for subprocesses. No generated tokens changed.
`dev_tools/` is absent throughout; product/package/Viewer resolution, analysis
and tests therefore ran without it. Initial expected golden mismatch evidence
and final command logs are retained in `build/golden-review-d049/`.

Only affected baselines were updated using the exact anchored regex recorded in
`build/golden-review-d049/affected-regex.txt`:

```powershell
# Working directory: packages/design_system
$pattern = Get-Content ../../build/golden-review-d049/affected-regex.txt -Raw
& $dart $flutter test --tags golden --update-goldens --name $pattern --reporter expanded
```

The older opt-in D-048 English pixel guard is not claimed byte-identical here:
this task authorizes English harness/initials changes. The current English
goldens pass without updates after the specifically authorized regeneration.

## Regenerated baselines (38)

- [appbar-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-en-dark-1.0-product-402.png)
- [appbar-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-en-light-1.0-product-402.png)
- [appbar-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-en-light-1.0-test-402.png)
- [appbar-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-en-light-2.0-product-402.png)
- [appbar-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-dark-1.0-product-402.png)
- [appbar-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-dark-2.0-product-402.png)
- [appbar-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-light-1.0-product-402.png)
- [appicon-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-fa-dark-1.0-product-402.png)
- [appicon-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-fa-dark-2.0-product-402.png)
- [appicon-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-fa-light-1.0-product-402.png)
- [badge-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-en-dark-1.0-product-402.png)
- [badge-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-en-light-1.0-product-402.png)
- [badge-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-en-light-1.0-test-402.png)
- [badge-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-en-light-2.0-product-402.png)
- [badge-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-dark-1.0-product-402.png)
- [badge-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-dark-2.0-product-402.png)
- [badge-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-light-1.0-product-402.png)
- [button-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-en-dark-1.0-product-402.png)
- [button-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-en-light-1.0-product-402.png)
- [button-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/button-en-light-1.0-test-402.png)
- [button-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-en-light-2.0-product-402.png)
- [button-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-dark-1.0-product-402.png)
- [button-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-dark-2.0-product-402.png)
- [button-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-light-1.0-product-402.png)
- [navigator-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-dark-1.0-product-402.png)
- [navigator-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-dark-2.0-product-402.png)
- [navigator-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-light-1.0-product-402.png)
- [otp-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/otp-en-dark-1.0-product-402.png)
- [otp-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/otp-fa-dark-1.0-product-402.png)
- [otp-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/otp-fa-dark-2.0-product-402.png)
- [password-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/password-fa-dark-1.0-product-402.png)
- [password-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/password-fa-dark-2.0-product-402.png)
- [radio-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-dark-1.0-product-402.png)
- [radio-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-dark-2.0-product-402.png)
- [radio-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-light-1.0-product-402.png)
- [textfield-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-dark-1.0-product-402.png)
- [textfield-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-dark-2.0-product-402.png)
- [textfield-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-light-1.0-product-402.png)

## Files and blockers

See [the complete before/after file inventory](delegated-golden-review-d049-files.md).
No remaining blockers. No commit was made.
