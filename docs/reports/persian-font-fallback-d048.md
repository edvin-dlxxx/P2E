# Persian font fallback fix (D-048)

Date:2026-10-22. No commit, screen, Inspector, backend, dependency/SDK upgrade,
new typography token or Figma edit. No Figma access was needed; local source and
contracts were inspected. The graph inventory has no P2E index, so this report
uses direct source/rg evidence, not graph coverage claims.

## Diagnosis and resolution

The previous private TextStyle package metadata survived copyWith/merge. A
qualified fallback was prefixed again, producing
`packages/p2e_design_system/packages/p2e_design_system/Vazirmatn`.
Button labels lacked a usable bundled Persian chain. OTP cell/native-input
styles selected Outfit even when other fields already selected Persian.
Viewer custom component styles containing only color (notably Chip/tooltip)
were passed by Material directly to RichText without the shell font chain.

D-048 authorizes Persian pixel changes only, as a scoped exception to D-046.
`BundledTypography.resolve` reconstructs the style with qualified family names
and no private package metadata. Generated declarations remain byte-identical;
FigmaTextToken stores its original declaration and resolves only its public
style getter. Every non-family TextStyle property is copied, including numeric
metrics, colors, variations/features, decorations and leading behavior. A
localized lint suppression preserves the generated public `style:` constructor
argument while the backing field becomes private; no generated API is renamed.

The selected policy follows existing docs/design-system/fonts.md and R-003:
Outfit + bundled Vazirmatn fallback for generated token styles/Button/headings;
the existing locale-aware component resolvers keep Vazirmatn primary for Persian.
No new Persian design styles or metrics are invented; R-003 remains open.

| Text path | Resolution after fix |
|---|---|
| All3 exported TypographyTokens / FigmaTextToken | Outfit primary + qualified Vazirmatn fallback, package stripped at runtime boundary |
| ButtonThemeTokens map / ButtonSpec / Material Button text | Same canonical token style chain; no duplicated prefix after merge |
| Token-styled PageScaffold heading | Canonical Outfit fallback chain; previously double-prefixed inherited fallback repaired |
| ThemeData textTheme / primaryTextTheme, inherited PageScaffold content | Previous Material Latin primary preserved (including unmapped legacy Roboto); bundled Vazirmatn fallback stays qualified once |
| Badge | Existing Persian-aware Vazirmatn primary, Latin Outfit unchanged |
| Field / Password / Radio / labels, hints, supporting text, native input | Existing Persian-aware Vazirmatn primary, Latin resolver unchanged |
| OTP source cell, native input, runtime inspection snapshot | Now uses the same existing Persian directional selection instead of unconditional Outfit |
| App Bar: avatar, points/unit, coins | Existing Persian-aware Vazirmatn primary; sizes/weights/colors/chrome cap unchanged |
| Navigator: labels and private badge text | Existing Persian-aware Vazirmatn primary |
| Viewer shell/custom Material component text | Existing English theme untouched; Persian-only theme supplies Vazirmatn to color-only styles; specimen components use shared resolvers |
| AppIcon | No text/font path; original artwork untouched |

An initial blanket fallback addition to Latin Field styles changed supporting
text in one English2.0 golden (3654 pixels). No English baseline was updated.
A controlled run with the previous Latin resolver passed, so that approach was
rejected. Retaining the expressly allowed existing locale-aware resolver fixed
the issue: all38 English golden tests pass without updates. This did not require
an English rendering change or any typography-token change. The failed attempt,
control and final logs are retained under build/font-fallback-d048/.

## Tests and limits

- Four structural cases enumerate exported token styles, both ThemeData text
  themes, Button extension/spec paths and all source Badge/Field/App Bar/
  Navigator Persian paths, including derived Light fields, in both skins and
  brightness modes. Every Persian chain contains bundled Vazirmatn, no family
  contains the package prefix twice. Mounted paragraphs/native EditableText
  styles are checked too. A regression case reconstructs the original package
  merge fault and verifies visual attributes remain unchanged.
- Four render cases cover all9 text-bearing families × both skins/brightness.
  Pure Persian `پژوهش` and digits `۱۲۳۴۵۶۷۸۹۰` are compared with an explicit bundled
  Vazirmatn reference at the same style/scale: advances agree within0.001px and
  baseline-aligned glyph rasters agree exactly. Square-glyph rasters differ.
  Baseline alignment deliberately permits the primary-font ascent difference
  between Outfit-fallback and Vazirmatn-primary paragraphs; glyph shape and
  advance are what this check proves. No OS font fallback is needed for these
  runs. It is representative, not a font-selection API or exhaustive Unicode,
  mixed-script/IME/device rasterization proof. Mixed Latin text keeps Outfit.
- Actual Persian Viewer paragraphs, including its Button previews and custom
  Material chrome, have the bundled family chain and no doubled namespace.
- All20 existing English product contact sheets remain byte-identical. All38
  English baseline files are unchanged by SHA-256 and pass without updates.
- All generated token/spec files and bundled font assets retain their original
  SHA-256. No sizes, weights, line heights, letter spacing or colors changed.

## Goldens and owner samples

Only the28 sheets below contain Persian text and were regenerated. Text-free
AppIcon sheets were excluded, as were all English sheets. Eleven files changed
bytes;17 regenerated to the same bytes. Both complete no-update runs passed69/69.
No tolerant comparator, no English baseline update. All69 statuses remain
**pending review**; the previous missing-glyph blocker was removed from
[goldens-review.md](goldens-review.md). The8 requested sample copies are in
[golden-samples/README.md](golden-samples/README.md).

| Regenerated baseline | Bytes changed | Status |
|---|---|---|
| [appbar-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-dark-1.0-product-402.png) | no | pending review |
| [appbar-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-dark-2.0-product-402.png) | no | pending review |
| [appbar-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-light-1.0-product-402.png) | no | pending review |
| [badge-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-dark-1.0-product-402.png) | no | pending review |
| [badge-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-dark-2.0-product-402.png) | no | pending review |
| [badge-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-light-1.0-product-402.png) | no | pending review |
| [button-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-dark-1.0-product-402.png) | yes | pending review |
| [button-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-dark-2.0-product-402.png) | yes | pending review |
| [button-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-light-1.0-product-402.png) | yes | pending review |
| [navigator-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-dark-1.0-product-402.png) | no | pending review |
| [navigator-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-dark-2.0-product-402.png) | no | pending review |
| [navigator-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-light-1.0-product-402.png) | no | pending review |
| [otp-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/otp-fa-dark-1.0-product-402.png) | yes | pending review |
| [otp-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/otp-fa-dark-2.0-product-402.png) | yes | pending review |
| [pagescaffold-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-dark-1.0-product-402.png) | yes | pending review |
| [pagescaffold-fa-dark-1.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-dark-1.0-product-700.png) | yes | pending review |
| [pagescaffold-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-dark-2.0-product-402.png) | yes | pending review |
| [pagescaffold-fa-dark-2.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-dark-2.0-product-700.png) | yes | pending review |
| [pagescaffold-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-light-1.0-product-402.png) | yes | pending review |
| [pagescaffold-fa-light-1.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-light-1.0-product-700.png) | yes | pending review |
| [password-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/password-fa-dark-1.0-product-402.png) | no | pending review |
| [password-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/password-fa-dark-2.0-product-402.png) | no | pending review |
| [radio-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-dark-1.0-product-402.png) | no | pending review |
| [radio-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-dark-2.0-product-402.png) | no | pending review |
| [radio-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-light-1.0-product-402.png) | no | pending review |
| [textfield-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-dark-1.0-product-402.png) | no | pending review |
| [textfield-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-dark-2.0-product-402.png) | no | pending review |
| [textfield-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-light-1.0-product-402.png) | no | pending review |

## Exact commands and results

PowerShell aliases (all commands used this exact installed SDK):

```powershell
$dart = 'D:\Tools\flutter\bin\cache\dart-sdk\bin\dart.exe'
$flutterTools = 'D:\Tools\flutter\bin\cache\flutter_tools.snapshot'
$env:DART = $dart
$env:NODE = 'C:\Program Files\nodejs\node.exe'
```

All evidence paths below are under `build/font-fallback-d048/`.

| Working directory | Exact command | Result / log |
|---|---|---|
| root; DS; Viewer independently | `& $dart $flutterTools pub get` | all exit0; root-pub-get.log, ds-pub-get.log, viewer-pub-get.log |
| root; DS; Viewer independently | `& $dart analyze` | all zero issues; *-analyze.log |
| root; DS; Viewer independently | `& $dart $flutterTools analyze --no-pub` | all zero issues; *-flutter-analyze.log |
| root | `& $dart $flutterTools test --reporter expanded` | 45 passed, delta0 vs45; root-tests.log, including architecture negative tests |
| packages/design_system | `& $dart $flutterTools test --reporter expanded` | 498 passed, delta+9 vs489; ds-tests.log (69 goldens included) |
| apps/design_system_viewer | `& $dart $flutterTools test --reporter expanded` | 33 passed, delta+1 vs32; viewer-tests.log |
| packages/design_system | `& $dart $flutterTools test --dart-define=RUN_PIXEL_GUARD=true test/readiness/product_skin_preservation_test.dart test/readiness/persian_font_test.dart --reporter expanded` | 10 passed;20 English PNGs identical and font tests; font-preservation-final.log |
| packages/design_system | `& $dart $flutterTools test --tags golden --name '-en-' --reporter expanded` | 38 passed, no updates; english-goldens-final.log |
| packages/design_system | Persian-only command below | 28 passed; persian-goldens-update.log |
| packages/design_system | `& $dart $flutterTools test --tags golden --reporter expanded` twice consecutively | 69/69 both; goldens-verify-1.log, goldens-verify-2.log |
| root | `& $dart run tool/check_architecture.dart` | passed; architecture.log |
| root | `& $dart run tool/agents/sync_agent_files.dart --check` | 33 generated files current; agent-sync.log |
| root | `node tool/tokens/generate_{adaptive,app_bars,badges,fields,icons,navigation,readiness,skins}.cjs --check` each independently | all8 exit0; individual *-check.log |
| root | `& $dart run tool/tokens/generate_{buttons,button_spec,button_icons,motion_defaults}.dart --check` each independently | all4 exit0; individual *-check.log |
| root | `& $dart format --output=none --set-exit-if-changed .` | zero changed; format-check.log |
| root | `& $dart $flutterTools build apk --debug` | exit0; android-debug-build.log; APK built, JVM native-access warning only |
| root | `Test-Path dev_tools` | False, absent throughout all pub-get/analyze/test runs; no move needed |

No new blocker remains. Persian typography design (R-003) and golden approval
remain pending by policy; this fix does not claim either is designer-approved.
The pre-existing long App Bar wallet formatting limitation is outside D-048 and
unchanged. [Changed-file inventory](persian-font-fallback-d048-files.md).

### Reproducible Persian-only update and token checks

Run the update from packages/design_system, with the executable aliases above:

```powershell
& $dart $flutterTools test --tags golden --name '(button|badge|textfield|password|otp|radio|appbar|navigator|pagescaffold)-fa-' --update-goldens --reporter expanded
```

Token checks were run from root (each invocation returned0):

```powershell
foreach ($generator in Get-ChildItem -LiteralPath tool/tokens -Filter *.cjs) {
  & $env:NODE $generator.FullName --check
}
foreach ($generator in @('generate_buttons','generate_button_spec','generate_button_icons','generate_motion_defaults')) {
  & $dart run "tool/tokens/$generator.dart" --check
}
```
