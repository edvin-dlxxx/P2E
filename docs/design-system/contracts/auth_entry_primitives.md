# Auth Entry primitives (D-056)

Sources: read-only snapshot `docs/snapshots/2026-10-23_auth-entry/`;
file `7PGTHT5CQzbTsWZQnPIQce`. All additions are provisional. Light and
Persian derive from the existing skin and typography contract (R-001/R-003).

| API | Anatomy, source and policy |
|---|---|
| `AppButtonTone.source/accent` | Existing source is the default, byte-preserving. Accent is valid only for Filled, binds Action/Accent and Action/OnAccent; disabled still uses existing disabled paints. Loading uses accent. No geometry change. Source instances 18618:12153 / 18618:12674. |
| `AppToggle` | Boolean, label, onChanged/enabled. Reuses AppRadioPresentation exactly; checkbox semantics, Space/Enter activation, minimum48 target; no mutually-exclusive group. Visual source18618:11599. |
| `LabeledDivider` | Flexible lines and wrapping label; horizontal32, gap10,14/18 Muted body. Source18613:11493. |
| `LinkText` | Localized prose and separate link segments, each with native focus and link semantics. D-059 uses the inline target exception; no target padding enlarges prose. Source18618:11677; source prose is14/18 Regular, links14/18 SemiBold, two lines at the reference size. |
| `HeroBanner` | Original exported illustration plus the exact source SVG elliptical radial alpha-mask matrix (generated). Surface behind alpha. The opaque composite export remains evidence only and is not used as a runtime fade. Source18618:12122,402×264. Source header height is system top inset plus180; artwork starts at physical top under system UI. No simulated status bar. |
| `SocialAuthTile` | Equal flexible widths, source38 tile,12 radius, label14/18 below6 gap, total minimum48 hit target. Enum PlayStation/Xbox/Google; source18613:11500,11505,11516. Original local artwork through AppIcon, never tinted. Brand colors explicitly excluded from alternate-skin leak tests: Blue/700, Green/600, Alpha/White and original artwork. Google asset provisional svgrepo source. |
| `AppToast` | Engineering provisional live region, surface/foreground skin roles, safe-area and keyboard aware. Generated engineering inset/radius/duration; auto-dismiss. Reduced motion renders without transition. No Figma node. |

AppToggle also reuses the Radio focus/hover presentation. PlayStation and Xbox artwork is40 logical pixels within the source38-high tile (one pixel bleed on each vertical edge); Google remains20. AppToast exposes the full message once in a live region and scrolls long messages within the available keyboard-safe space.

All components require ElementIdentity and derive locale/theme. Content grows or
wraps through2.0×; none uses the chrome cap. All visual metrics are generated.
RewardPill is product composition in shared/widgets, not a DS domain concept.

AppToast uses the explicit provisional4-second engineering duration in
design/engineering/auth_entry.json. It has no entrance/exit motion, including
reduced-motion mode. The keyboard transition uses direct layout; existing field
motion retains D-054 behavior.

PageScaffold adds opt-in `viewport` layout: bounded Scaffold body, keyboard resize,
source Surface/Base background, no automatic SafeArea/scroll/cap. The caller
owns hero bleed, system insets, scrolling and600 content cap. Default `scrolling`
layout, background, source geometry and golden pixels are unchanged.

FieldInputOptions adds LTR/alignment/autocorrect/suggestions configuration and
identifier privacy metadata, with existing defaults preserved. Auth Entry opts
into `wrapHint`: long localized placeholders wrap at2.0 without changing native
single-line editing or source typography. Existing fields remain unchanged.

## Fixed source frames — D-059 (supersedes E-011 interpretation)

The source CTA is362×46 before idle Body inside-stroke width reduction. Rendered fixed frame wins over contradictory vertical padding; vertical centering replaces padding-derived52. E-011 records the conflict but no longer requires enlargement. Native Button hit/semantic bounds are at least48 without consuming layout space.

Idle AuthEntryBodyFrame includes its1px inside stroke in layout. Its live social frame is129 high. FieldInputPresentation.phoneNumber resolves the explicit16/24 zero-tracking source instance; email retains18/24. The native caret uses the source20px extent and2px stroke. Small native caret anchoring/pixel snapping differences are documented in the conformance comparison.
