> Superseded acceptance status: [D-062 follow-up](../auth-acceptance-followup/README.md) resolves the ink/copy and viewport gaps and preserves91/91 verified before images. This earlier report remains historical evidence.

# Auth final acceptance evidence — 2026-10-23

Acceptance is **not yet clean**. No commit, typography change, font replacement,
localization change or golden update was made in this task. Figma evidence is
the preceding task's read-only captured source, not a new write/export claim.

- [Every deviating text node: 30-row glyph-ink table](ink.md): 29 pass, one
  fails. Figma `Playstation` and product `PlayStation` are different copy.
  Ink width65 vs68px, delta x/y/w/h=-1/0/+3/0. Both use14/18 Outfit600,
  tracking-0.56. E-016 proposes agreeing copy, without per-string geometry hacks.
- [Twelve component contact PNGs and every sample's native changed-pixel %](goldens.md).
  72/91 before images are hash verified. [Nineteen originals are unavailable](missing-before-images.json).
  Missing before/diff panels are visibly marked. A reconstruction experiment
  using the former font setup did not match original hashes and was rejected.
  Percentages are never inferred from thumbnails or hashes. Auth/legal/field/
  body/social/presentation changes beyond font/Button-height are flagged.
- [Complete Inspector sweep ranges](sweep.md): all48 plans and10784 callbacks
  ran;16 supported-area ranges report partial scroll-viewport clipping of the
  CTA envelope. The opt-in acceptance assertion fails. No diagnostic is filtered
  to turn this into a zero-problem sweep. These are viewport visibility findings,
  not RenderFlex overflows or navigation crashes.
- [Golden hashes](unchanged-goldens.json): all94 current DS/root baseline files
  remain byte-identical to this task's starting conformance state.

## D-059 hit testing / D-061 clarification

Checks proved two failures: overlapping small targets followed sibling traversal
instead of nearest visual distance, and non-clipping layout groups could reject
the real Auth CTA's expanded edge. The shared Button hit path now resolves the
nearest visual rectangle; `ButtonHitRegion` forwards outside-frame hits
across layout-only groups, inside the host's existing free space. Auth wraps its
form and keyboard footer. Visual layout/paint and native button gestures, focus,
semantics and callbacks remain unchanged. Actual ancestor clips are not bypassed.

Root regression covers both locales × Phone/Email × keyboard off/on. Each case
mounts a fresh real route for four taps, so a previous failure toast cannot
intercept the next tap. There is exactly one AppButton on the Auth screen: the
CTA. The idle/invalid CTA remains disabled by its existing contract. Social
controls have their own taller target and inline legal links retain D-059's
exception; neither is a46dp AppButton.

For a46dp frame centered in48dp, exactly1dp inside the envelope is the visual
edge, mathematically. Tests cover those exact top/bottom points and also points
0.5dp inside the envelope, which are strictly outside the visual frame. All32
real-screen taps activate exactly once, without moving the visual rect. Small
icon-button pairs use gaps2/4/10dp, LTR/RTL, and points in both sides of each
overlap; only the nearest visual control activates.

Inspector `button-hit-envelope-constrained` detects non-containing ancestors or
clips. Its regression has healthy, tight-bounds and ClipRect hosts. Bounds inside
the forwarding region are delegated; actual clips remain checked. Fully
scrolled-out controls have no active target in that frame; partly visible targets
are still reported. The complete sweep intentionally retains those reports.

## Outfit700 consumers

`NavigationItemSpec.textStyle('badgeLabel')` requests Outfit Bold10/10, tracking0
for Dark inactive18422:11156, Dark active18422:11154, Light inactive18422:11444
and Light active18422:11462. These four component-local styles have no linked
Figma textStyleId. They are used by Navigator badges. Named English typography
tokens use400/500/600;700 is bundled for the actual component-local consumers,
not merely as an unused convenience face. See the package FONTS.md.

## Remaining acceptance work

1. Resolve the `Playstation`/`PlayStation` copy difference (E-016); do not compensate
   through font size, tracking, transforms or offsets for this string.
2. Decide whether natural partial visibility at a scroll boundary is acceptable
   for the new Problems rule. If a fully exposed target is required whenever any
   portion is visible, a general scroll/visibility policy is needed; per-width
   padding patches would not be an appropriate correction.
3. Supply/recover the19 original PNGs for complete91-sample before/diff evidence.
   SHA-256 manifests cannot reconstruct missing pixels.

Reproduction: `python tool/auth_acceptance/evidence.py` uses Pillow/numpy and
saved capture/manifests. [Exact validation commands and logs](validation.md).
