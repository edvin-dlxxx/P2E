# Navigator Bar / AppNavigationBar

DEVELOPMENT, 2026-10-21, read-only source `7PGTHT5CQzbTsWZQnPIQce`.
Two bar variants, set18422:11475: Dark18422:11474, Light18422:11476.
Four separate nested item variants: Default/Active in Dark18422:11155 and
Light18422:11443. These four states are not additional bar variants.
Machine spec: generated `docs/snapshots/2026-10-21_development-navigation/navigation.json`.
Reproduce/check: `node tool/tokens/generate_navigation.cjs [--check]`.

## Controlled API

`AppNavigationBar` takes exactly five `AppNavigationDestination`s, stable technical
`id`, localized `label`, paired `AppIconId`, optional `AppNavigationBadge`, optional
full semantic label, `selectedDestinationId`, and nullable `onDestinationSelected`.
IDs/labels and selected membership are validated in release as well as debug.
Duplicate IDs, absent selected ID, blank labels and missing real icon styles fail
explicitly. Null callback means unavailable. Reselection emits the same ID once.
No hidden selected state, route operation, persistence, data fetch or badge capping.
Consumer reordering retains each destination's keyed identity and selection ID.

`AppNavigationItemState {inactive, active}` normalizes raw Default/Active. Theme
comes from the ambient shared theme. `AppNavigationItem` is the same shared item
renderer used by the bar and the Viewer's four standalone nested-item examples.

## Exact source endpoint

Bar402x68, horizontal padding6, five equal flexible cells78 at reference width.
Item master80x68 (not the bar cell width), vertical padding8, indicator64x32/r16,
icon24 centered, gap4, label frame16 with Outfit600 12/15/tracking0.
Inactive has no indicator fill and Outline; active has source fill and Fill.
Source label and badge text have empty Text Style IDs: source-unlinked provisional
component typography, never fabricated official styles. Persian uses the already
bundled provisional Vazirmatn convention (R-003).
Dark background Surface Container/Base; Light Surface Container/Lowest. Active
Dark indicator High; Light Countainer/Teal. Icon and label tints resolve separately
from actual item source paints; original SVGs remain unchanged globally.

Badge is optional caller display/semantic copy. Source samples Mission1 and Shop2
are registry reference data only. Wrapper16x16 at indicator start32/top0, pill16x14
bottom-aligned (top2), radius16, white Outfit700 10/10 text. Label frame has1 bottom
padding. No Badge Base instance is linked. Absence mounts no badge descendants.

## Engineering behavior D-031

Content owns no safe-area inset. `AppNavigationBarHost` wraps content in exactly
one bottom SafeArea (top:false, maintainBottomViewPadding:true) and extends its
source background into the actual platform bottom inset. Use directly as
Scaffold.bottomNavigationBar without an additional outer SafeArea. No fake Home
Slider (the12-high source sample is separate), no keyboard visibility policy.

Minimum compliant bar width252 = source horizontal padding12 + five48-wide hit
cells (12 + 5×48). D-036 supersedes D-031's below-minimum rejection: a narrower
bounded host still renders all five equal-width, nonoverlapping full-item hit
regions in every build mode, without hidden destinations or scrolling. These
undersized targets are not compliant; the existing resolved layout/Inspector
itemWidth reports their actual size (47.8 at251, 37.6 at200). At and above252,
layout, semantics and interaction are unchanged. Indicator width clamps to the
cell below64; icons retain24 at the tested degraded widths251/200.
In debug/profile, one FlutterError per distinct below-minimum width per mounted
bar identifies the received width and252 minimum as a host contract violation.
Reporting is deferred until after rendering and never replaces navigation with
an error widget. Rebuilds (including selection changes), and revisiting a width
already reported by that bar, do not repeat it. Release emits no diagnostic.
The finite-width host requirement remains; unbounded constraints are invalid.
For degenerate hosts narrower than the12 source padding, padding contracts to
the available width and cell width bottoms out at zero. Text measurement also
floors a badge's available inner width at zero; neither can become negative.
Zero-area constraints cannot provide visible artwork or usable touch targets.
Their empty semantic group omits the tabBar role (which Flutter requires to have
visible children); positive-width cells retain the existing full tab semantics.
Labels wrap at cell width with full accessible copy; shared label/content height
grows to the tallest label, preserving top alignment and no selection-induced
layout changes.1.3 scaling is not shrunk; larger scales follow existing D-015 cap.
Badge grows from source16 using text advance plus symmetric allowance derived
from source geometry, bounded to indicator width. At that bound text wraps and
badge/indicator/content height grows. Growth shifts the overlay inward when
necessary to stay inside the cell. No clipping, cap or automatic value change.

Rows follow semantic Directionality once, data is not reversed. Registry artwork
is nondirectional. Badge numeric runs are isolated LTR; stored text is unchanged.
One selected tab control per destination, indexed inside a tabBar semantic group;
icon/label/badge descendants are excluded. Full-item native TextButton interaction,
visible focus, keyboard activation, nonoverlapping cells. Badge ignores pointers.
Shared PressAction scales only the pressed item without changing hit geometry.
Indicator fill uses shared ButtonMotion release duration/easeOut, engineering,
with interrupted transitions and reduced-motion immediate endpoints. Source
reactions are retained as empty arrays; no Figma animation claim.

Viewer remains under Components with App Bar available. It supplies source Dark/
Light, four nested-state samples and a controlled local example, editable synthetic
labels/badges, direction/language/scale/width and bottom inset simulation. Inspector
reads source resolver, runtime identities and measured boxes outside the component.
No new golden baselines or commits are authorized.
