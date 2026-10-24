# AppButton contract — package and optional-icon revision

Source variants: immutable docs/snapshots/2026-10-19_development-buttons.
Read-only optionality evidence: ../evidence/2026-10-20-button-optionality.json,
../evidence/2026-10-20-button-layouts.json and ../evidence/2026-10-20-text-only-examples.json.
Source version lock and visual approval remain unverified. D-019/D-020 authorize this change.

## Public API

Import package:p2e_design_system/design_system.dart. Existing elementId,
runtimeLocator, label, callback, family, size, appearance and optional color
parameters are preserved. The old showIcon boolean is removed.

ButtonIconMode: none (text-button default), fill, outline. Mapping:
- none: Icon=false; the entire icon container is absent, regardless of child flags.
- fill: Icon=true, Fill Icon=true, Outline Icon=false.
- outline: Icon=true, Fill Icon=false, Outline Icon=true.

The independent AppIcon input identifies artwork. fill/outline require it;
none rejects it. Icon-only family rejects none. D-023 expands AssetAppIcon to the
complete source icon registry. Viewer examples now resolve the real master links:
Edit Square for text buttons, Crown Fill / Edit Square Outline for icon-only
(E-012). No substitute artwork or Material Icons are allowed. Invalid icon-only
none previews remain explicit and do not construct blank controls.

## Verified layout and remaining conflict

All 18 master sets have CENTER primary/counter alignment; text is CENTER.
Play Now 18533:4263 (Dark) and 18533:4803 (Light) are Hug 80x36 with
Icon=false, label width 56 and horizontal padding 12. Hidden icon containers
do not consume width or item spacing. Continue With Email Address 18618:12674
is Fill 362x46 with Icon=false and centered label width 193 (x=84.5).

Hug width follows actual content plus source padding; the icon-bearing master's
sample width is never a text-button minimum. Fill follows bounded parent width.
With none, both slot and gap are omitted; the source frame height stays unchanged. With artwork, source slot size and gap remain. Text can wrap
within parent constraints and remains centered as a content group in LTR/RTL.

D-059 supersedes the padding-derived height policy: source fixed frames are36/46/56 for Small/Medium/Large text Buttons. Source icon-only frames remain their recorded widths/heights. Vertical padding conflicts are retained as E-011 evidence, but content is centered inside the rendered frame with only source horizontal padding. Scaled or wrapped text may grow beyond the minimum to remain readable.

A root render proxy expands hit testing to at least48×48 around the unchanged layout box. It delegates transformed hit coordinates to the existing native TextButton; no duplicate gesture/focus/semantics control is introduced. Ancestors must leave room and must not clip the envelope; layouts must space neighboring controls. Regression taps cover the envelope without changing the visual rect.

Visual surface, label and outer/tap-target boxes are measured separately.

## Runtime and tooling

Family hug/fill/icon, size small/medium/large, appearance filled/tonal/outlined/
text/disabled and the 90 source IDs remain. Theme is read from ThemeData.
Null callback or disabled appearance selects the real disabled source row.
Colors, border, radius, padding and typography retain existing bindings.
Pressed/hover/focus source coverage is unchanged; engineering loading is specified below (D-045). Fonts are bundled
in the package and all geometry tests load their real namespaced faces.

ElementIdentity preserves usage/source IDs and records iconMode separately from
appearance and iconId. It does not capture labels or invent measurements.
Runtime generated data is projected from the full contract; diagnostic copies,
Gallery, verification, example evidence projections and ARB maps live in viewer.
Both apps consume the same runtime package through the public barrel only.

Regression tests measure label centering against Material, not the tap target,
across sizes/types/themes/directions/scales and short/long labels. D-047 now authorizes initial Windows golden
baselines, pending review and size checks do not imply pixel/artwork completeness.

## Engineering press interaction (D-021)

The owner-requested baseline is scale 0.98, 80ms press, 120ms release/cancel, easeOut.
These are engineering defaults generated from design/engineering/button_motion.json,
not Figma motion. AppButton owns the WidgetStatesController-driven animation.
Transform.scale changes paint only and uses transformHitTests:false; the outer
layout/tap target stays stable. Framework keyboard activation/callback handling is
retained. Disabled and MediaQuery.disableAnimations preferences render at rest.
An optional framework statesController supports observation without any Viewer dependency.
Reference comparisons use settled, unpressed visual bounds.

## D-045 loading contract

loading defaultsfalse; loadingSemanticsLabel is caller-localized. Loading wins over disabled, never invokes onPressed, remains focusable and retains focus, with press/hover effects suppressed. Normal label/icon stay in layout with zero opacity; an excluded centered indicator uses icon dimensions, foreground role and generated engineering stroke/static-progress tokens. Reduced motion renders a non-ticking static indicator. Missing/blank loading label reports one non-blocking debug/profile FlutterError per mounted instance and is silent in release; accessible fallback is the button label. Otherwise semantics is label + comma + loadingSemanticsLabel, button=true, enabled=false. Loading is declared boolean configuration, not a fabricated Figma axis; existing identity schema supports it and effective instance identity stays stable. No schema change.

Read-only live Button metadata/context on2026-10-21 found18 sets/90 variants, each Filled/Tonal/Outlined/Text/Disable; no loading/busy/progress variant. The D-045 visual is provisional (D-013), tracked by R-012. Existing normal source rows/geometry are retained; loading on an explicitly disabled row uses filled enabled-state paints while preserving that row's geometry.

## Delegated RTL/golden review (2026-10-22)

The content Row explicitly follows ambient Directionality: icon is logical start (right in RTL), then gap and label. No reversed children or physical alignment is used. Pre-change measured RTL placement was already correct; this is now explicit and tested for all sizes/families/icon modes/states. Golden cells pass loose constraints to Hug/icon-only; only Fill gets the full bounded cell width. No source geometry or tokens change.

## D-059 acceptance: expanded target hosting

Visual frames remain36/46/56. ButtonHitRegion is layout/paint/semantics-neutral interaction infrastructure placed around a layout group inside its host's free space. It forwards only points outside a Button visual rect but inside its48dp envelope to the native Button hit path. Overlapping envelopes choose the nearest visual rect; equal-distance ties retain deterministic traversal order. Disabled/loading nearest controls retain their native non-activation; they do not forward to a farther enabled neighbor. No callback is manually invoked and native gesture/focus semantics remain in charge. Auth wraps its form group and keyboard footer inside existing padding; no source rect or token changes.

Inspector Problems reports button-hit-envelope-constrained when a visible envelope is clipped or not contained by an ancestor. Layout-only bounds inside ButtonHitRegion are delegated to that region; actual clips are always checked. Fully scrolled-out envelopes are inactive until scrolled into view, while partial visibility remains reportable.

D-062: the Auth product host uses shared CompleteTapEnvelope to reveal a partly visible target with the minimum post-frame scroll correction after user scrolling settles. It observes both width/layout and viewport-height changes. Fully offscreen targets never pull the page; active drags are not interrupted. This changes neither the Button visual frame nor its native activation/semantics. The Inspector rule remains active and unfiltered.
