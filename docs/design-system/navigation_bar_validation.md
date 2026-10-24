# Navigator Bar validation — 2026-10-21

Scope: shared `AppNavigationBar`, its four source item endpoints, host adapter and
independent bilingual Viewer Components subcategory. No product routing, services,
screen, new root tab, golden baseline or commit. All Figma calls were read-only.

## Source and implementation

- Exactly2 bar variants (Dark/Light) from set18422:11475.
- Exactly4 nested item source states from sets18422:11155 and18422:11443.
- Three inventory pages consumed to next:null; all6 variant roots and ten complete
  source item-instance subtrees saved. Four actual consumers confirm content68 and
  a separate device Home Slider12. No device-artwork inset is hard-coded.
- Five concepts verified through actual instance master links, with all ten real
  paired SVG files nonempty and SHA-256 matched against the existing icon registry.
  Fill companions are resolved from registry relationships, not guessed filenames.
- Official Text Style IDs are empty. Source Outfit600 12/15 labels and Outfit700
  10/10 badges remain component-specific, source-unlinked/provisional; Persian
  uses the existing bundled provisional Vazirmatn convention.

See [contract](contracts/navigation_bar.md) and
[snapshot manifest](../snapshots/2026-10-21_development-navigation/manifest.json).
D-031 records owner-authorized engineering behavior. R-011 requests official
typography/motion specification with low severity; no missing bar/item variant.

## Actual results

| Check | Result |
|---|---|
| Product root analyze / tests | Clean / all5 passed |
| Shared package analyze / tests | Clean / all276 passed, including16 Navigator tests |
| Viewer analyze / tests | Clean / all25 passed, including English/Persian Navigator coverage |
| Repository format |144 Dart files, zero changes |
| Architecture and generated agent files | Passed;33 generated files current |
| Navigator registry/spec --check |2 bars,4 item states,5 exact icon pairs verified |
| Navigator bilingual strings --check | Passed |
| Isolated Flutter localization --check | All3 generated files matched |
| Existing icon --check |104 concepts,208 originals, no missing counterpart |
| Existing App Bar --check | All5 source variants current |
| Windows Debug build | Succeeded |
| Windows startup smoke run | Hidden launch alive for5 seconds; VM service and Impeller startup, no application error |

Full suite logs are local artifacts:
`build/navigation-validation/design-system-tests.log` and
`build/navigation-validation/viewer-tests.log`. Startup logs are in the same
folder. The smoke run is startup evidence, not a claim of manual desktop QA.

`build/navigation-validation/source-bars.png` is a visually inspected diagnostic
render with real bundled fonts,402×136 logical units at2×. It is not an approved
golden baseline. Both source endpoints match background, settled indicator,
label/icon tints and geometry, and the separate16×16 wrapper/16×14 pill placement.

Tests cover both bars and four standalone item states, all five selected
destinations with correct styles, controlled callbacks/reselection, invalid IDs
and count validation, stable keyed IDs through reorder/RTL/theme, optional/zero/
long badges, full semantic labels, merged indexed tab semantics, native keyboard
focus/Enter/Space, local press feedback, interrupted indicator transitions and
reduced motion. English/Persian layouts use real fonts at widths280/320/360/402/
900 and scales1.0/1.3. Minimum252 is explicit; no scrolling or hidden destinations.
Hit cells are checked for non-overlap with0.001dp arithmetic tolerance. Actual
bottom insets0/24/34 are counted once, independently of source content height.

Two issues found during implementation were corrected before passing validation:
the index/tab nodes needed MergeSemantics to satisfy Flutter's strict tabBar role
contract; indicator layout dimensions needed immediate constraints rather than
implicit size animation during responsive changes. Only indicator paint now
animates. Existing Button, Badge, Field, Icon, App Bar and Viewer regressions passed.

## Viewer and run

```powershell
cd D:\My_Script\Hamrah-Aval\P2E\apps\design_system_viewer
flutter run -d windows --debug
```

Open Components → Navigator Bar. Source bars and four nested examples remain
English LTR reference endpoints. The controlled runtime example supports theme,
selected ID, width, locale/direction, scale, editable labels and optional badge
text, long values, callback availability and simulated bottom inset. Changing
theme/language/direction preserves selected ID and caller badge strings. Clearing
a present badge input reports validation instead of inventing a count. Activations
stay local; the Viewer never navigates away. App Bar remains in its own subcategory.

The physical-left Inspector reads generated source data, actual runtime identity
descriptors and RenderBox measurements, including item/badge bounds and host/content
height. No unavailable measurement or official style identity is fabricated.

No implementation blocker remains. Design approval/version and official typography/
motion linking remain explicitly provisional; engineering policies are not Figma
prototype animation evidence.
