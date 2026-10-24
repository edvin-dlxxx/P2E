> Superseded acceptance status: [D-062 follow-up](../auth-acceptance-followup/README.md) resolves the ink/copy and viewport gaps and preserves91/91 verified before images. This earlier report remains historical evidence.

# Auth Entry conformance corrections — 2026-10-23

The corrections are ready for review; this does not mark the screen accepted or pixel-identical. No Git commit was made, no removed build_runner option was used, and every Figma operation was read-only. Architecture exceptions were not expanded.

- [Font provenance, source URLs, versions, hashes and licenses](../../../packages/design_system/assets/fonts/FONTS.md). [Original bundle metadata](fonts-before.json), [current faces](fonts-after.json).
- [All90 Button variants /18 source sets](button-source-audit.md), including FIXED/HUG sizing, frame dimensions, padding and line-height; [raw audit](button-source-audit.json).
- [Exact rect/width/color/weight comparison and every deviation above0.5px](conformance.md). [Runtime measurements](runtime-measurements.json), [all94 comparisons](rect-comparison.json), [43 text-style comparisons](text-style-comparison.json).
- [Validation commands/results](validation.md); [file inventory](file-inventory.json).
- [All requested review samples and every changed golden](../golden-samples/auth-conformance/README.md).73 DS and18 root baselines changed; all changed references return to pending review. The list includes Navigator fa-dark, Password fa-dark, Radio fa-light, AppIcon en-dark, PageScaffold en-light2.0 at402/700, TextField fa-dark1.0 and OTP fa-dark1.0.

## Changes

D-059 makes rendered Figma frame height win over conflicting Button padding: text Small36, Medium46, Large56; icon frames use their own recorded dimensions. Vertical content is centered; source horizontal padding remains. A render proxy expands real hit testing and merged accessible bounds to48 without adding layout padding. It delegates to the existing native button; it does not add another gesture/control. Hosts must leave room and must not clip the envelope. Scaled/wrapped content can still grow for D-044 readability. E-011's padding-requires52 interpretation is withdrawn.

D-060 replaces the incorrectly mapped default100 variable Outfit face with real static400/500/600/700 instances from the pinned official Google Fonts1.100 release. Pubspec weights match each face's OS/2 metadata. The four representative raster tests match independent static reference faces byte-for-byte. Font binary metadata and the exact hashes are recorded; this is not a claim to inspect the engine face for every possible Unicode glyph. Vazirmatn33.003 is unchanged and remains provisional R-003.

Legal text is inline14/18: Regular body#a1a1a1, SemiBold links#00a6f4; the actual hex values are in the comparison report. The paragraph is two lines,36 high, at(25,813,352,36) in the live idle frame. Link semantics nodes and native keyboard activation remain separate; explicit traversal order preserves logical order in Persian. No48px padding enlarges inline prose. This follows the owner-authorized [WCAG2.5.8 inline exception](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html).

The idle Body includes its1px inside stroke in layout. Its live social section is129 high, correcting the old local-coordinate derivation. Field labels are centered inside their24px frame; idle label y468 matches live Figma. The explicit phone instance is16/24 with zero tracking; email remains18/24. Native caret height uses the source20px extent.

## Remaining measured differences

The report retains42 comparisons above0.5px, including repeated text/container bounds across four states. These are mainly intrinsic text advances and two native caret stroke-anchoring/pixel-snapping cases, not42 independent layout defects.43 size/weight/color comparisons pass.28/29 single-line widths match the calculated `ceil(Flutter advance − source tracking)` model; this is evidence for a trailing-tracking/bound-rounding difference, explicitly marked as an inference. Figma's font binary/version is unavailable. No per-string stretch, font-size reduction or fake width was introduced to conceal the differences. These visual differences still require reviewer acceptance.

The screenshots retain the real source status bar/keyboard on the Figma side and reserved inset space on the widget-test side. Native OS artwork is excluded from product conformance. Original hero/SVG assets are unchanged; matching asset viewports is separate from raster-sampling differences shown by the image diff.

| State | Side by side | Overlay |4× pixel diff|
|---|---|---|---|
|Idle|[image](side-by-side-idle.png)|[image](overlay-idle.png)|[image](diff-idle.png)|
|Active keyboard|[image](side-by-side-focused.png)|[image](overlay-focused.png)|[image](diff-focused.png)|
|Phone|[image](side-by-side-phone.png)|[image](overlay-phone.png)|[image](diff-phone.png)|
|Email|[image](side-by-side-email.png)|[image](overlay-email.png)|[image](diff-email.png)|
