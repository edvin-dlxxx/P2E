# Buttons live audit — 2026-10-19

Result: FAIL. Current AppButton is not visually equivalent to the live source.
All Figma access was read-only. Product code, generated tokens, Snapshot, extraction tools and registers were not changed by this audit.

## Scope and evidence

- File: `7PGTHT5CQzbTsWZQnPIQce`; page `16433:9027` (`- Button System`).
- Live inventory: 18 component sets, 90 distinct variants; exact ID-set match with the DEVELOPMENT Snapshot.
- Pagination: 18 successful data pages of five variants, ending at `next: null`. One initial 15-row response exceeded the MCP 48,000-byte limit; retried from offset zero with five rows. No data was accepted from that failed response.
- Main-node geometry, paints, opacity and effects matched the Snapshot for all 90 variants. Checked descendant geometry/paints matched for 480 records. All 60 text-node typography records matched. All 18 scoped variable values by mode matched; none unresolved.
- Raw evidence, source PNG, runtime PNG and independent measurement test: `.dart_tool/buttons-live-audit/` (scratch, not a delivered Snapshot). SHA-256 hashes and per-variant evidence: `buttons-live-2026-10-19.json` beside this report.
- Independent Flutter measurement: bundled Outfit and Vazirmatn, English `Text Label`, LTR, scale 1, each variant constrained to its actual source width. Measured the inner Material surface separately from AppButton's outer touch/layout bounds. No icon was passed, matching the current viewer.

## Findings

| Severity | Finding | Extent | Required correction / acceptance condition |
|---|---|---|---|
| high | Generator enlarges the source surface to fit declared vertical padding plus content. Live Figma retains its fixed height and centers children. | 60 text-bearing variants | Preserve source surface heights at scale 1; reproduce actual child placement. Keep the accessible hit region separate. Do not treat `padding + child height` as the expected visible height. |
| high | Visible source icon artwork is absent from the viewer; an empty slot is reserved. | 90 source variants | Bundle the exact source SVG artwork and render through AppIcon, preserving size, paint and positioning. No substitute glyph. |
| medium | Text uses `TextAlign.start`, whereas all source labels use CENTER. A short one-line sample may conceal the difference. | 60 text variants | Use source alignment and test constrained/multiline labels separately from source equivalence. |
| medium | Text metrics differ despite matching typography metadata. Example: source width 60 versus Flutter 59.30748748779297. | Sample proven; per-node actual widths are in companion JSON | Investigate source font binary/metrics and text-box sizing; compare actual text bounds and baseline. Metadata equality is insufficient evidence of pixel equivalence. |
| medium | Viewer compared outer accessible bounds with source visual bounds and used a 390px parent for a 330px fill source. | Previous 80 DIFF headline | Compare the inner painted surface at the same source width and scale. Report hit target separately; outer differences alone are not visual failures. |
| medium | Existing style tests accept the generated enlarged minimum size as their expectation. | All generated style tests | Add independent source-based surface/child/baseline checks and actual reference-image comparisons. A green internal test suite must not be labeled Figma equivalence. |

All 90 live variants also report `clipsContent: true`; clipping is not recorded in the current normalized geometry contract. Current TextButton does not explicitly set clipping. This needs explicit coverage for overflowing content; no clipping defect was demonstrated for the short source label.

## Measured surface versus outer region

| Family | Source height | Actual colored surface | Outer bounds height | Count |
|---|---:|---:|---:|---:|
| Text small (hug/fill, both themes) | 36 | 44 | 48 | 20 |
| Text medium | 46 | 52 | 52 | 20 |
| Text large | 56 | 60 | 60 | 20 |
| Icon small | 36 | 36 | 48 | 10 |
| Icon medium | 46 | 46 | 48 | 10 |
| Icon large | 56 | 56 | 56 | 10 |

The 30 icon variants match surface size, but remain visually incomplete because the artwork is missing. No complete variant is certified as visually equivalent.

## Exact example: 18436:1612

- Live source: Small Fill Button - Dark Mode, Filled, 330×36, radius 10, white background, black foreground.
- Icon slot: x=121, y=8, 20×20, visible Fill instance. Text wrapper: x=149, y=9, 60×18.
- Runtime: surface 330×44; outer region 330×48. Text x=149.34625625610352, y=13 relative to surface, width=59.30748748779297, height=18. Icon artwork absent.
- The source screenshot confirms a 36px surface containing both the icon and label. The previous inference that this requires correcting Figma was unjustified. E-011 remains open; this audit does not edit registers.

## Verification limits

- Audit measurement command: `flutter test --no-pub .dart_tool/buttons-live-audit/render_test.dart --reporter expanded` — passed (one audit test measured all 90). Passing means measurements were collected successfully, not that they matched.
- No full 90-variant image-diff suite was run. Source and Flutter screenshots were inspected for 18436:1612.
- Figma font family/style/variation data is available; exact source font binary/version was not exposed by this read.
- No technical version-lock or designer approval claim is made. This is a live read-only audit, not a replacement Snapshot.
- Hover, pressed, focus, long labels, RTL and 1.3× scaling are distinct behavior tests; source-frame equivalence is assessed at its original content, size and scale 1.
