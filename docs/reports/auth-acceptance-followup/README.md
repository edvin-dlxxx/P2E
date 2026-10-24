# Auth acceptance follow-up — D-062, 2026-10-23

All three preceding acceptance gaps are resolved. Technical evidence is complete;
golden visual approval remains **pending review**. No commit was created. Figma
was not modified; this report reuses the previous read-only source captures.

- [Glyph-ink table](ink.md): **30/30 pass**, every delta within1px. EN/fa ARBs
  now pass the approved source label `Playstation`; Flutter gen-l10n regenerated
  the localization outputs. Font files, typography tokens, sizes, tracking and
  paint colors are unchanged. All43 measured source text style comparisons pass.
- [Sweep evidence](sweep-summary.json): **48 plans,10784 frame callbacks, zero
  supported-area problems**, width>=320 and height>=480, en/fa, scales1/2,
  keyboard off/on, all four entry states. Raw device/sampling coverage remains in
  [the complete report](inspector-sweep.json). The new hit-envelope rule is active,
  including viewport clips; no problem kind is filtered to claim this result.
- [Twelve component contact sheets and per-sample RGBA changed-pixel percentages](goldens.md):
  **91/91 before PNGs verified** against the original pre-conformance SHA-256.
  The19 previously unavailable PNGs were recreated in an isolated historical
  tree, using source/fixture records from this task's history, and admitted only
  after byte-identical SHA-256 equality. [Recovery manifest](recovery-manifest.json)
  distinguishes19 historical replays from72 saved originals. The complete set is
  preserved in [one before-image archive](review-before.zip). The temporary
  historical project was removed; it never changed product source or baselines.
- The diff table explicitly flags changes beyond font/Button height. In
  particular, the original Phone fixture was `09123456789`, and Email was
  `User12@example.com`; the earlier Figma conformance task changed them to the
  source frame contents. Those fixture-content differences are not font effects.

## Shared visibility behavior

`lib/shared/widgets/complete_tap_envelope.dart` hosts the general policy accepted
in D-062. If the control is partly visible, it computes its minimum48dp envelope
relative to the real scroll viewport and scrolls by only the missing extent.
Correction runs after layout and after a user drag/ballistic scroll settles.
Fully offscreen controls do not pull the page. Width/layout changes and changes
to viewport height are both observed; no breakpoint or per-width offset exists.
The keyboard footer is outside the scroll view and retains its existing layout.

Sixteen regression tests cover the former failure cases in both brightnesses,
full/offscreen references, and waiting for an actual drag to end. Existing real
Auth hit-envelope tests still verify32 outside/boundary taps with no double
activation or control-width change. No FlutterError is caught or suppressed.

## Visual changes and review

Only [five idle Auth golden files](followup-changed-goldens.json) changed, for the
localized source-copy correction. All76 DS baselines and the other13 root
baselines remain byte-identical to the preceding task. Of94 recorded reference
rects,93 are identical; only the renamed brand text's intrinsic width/centering
changes. No unrelated geometry is altered at402×874. See
[geometry summary](geometry-summary.json) and the full [conformance report](conformance.md).

Side by side / overlay / diff:

- Idle: [pair](side-by-side-idle.png), [overlay](overlay-idle.png), [diff](diff-idle.png).
- Focused: [pair](side-by-side-focused.png), [overlay](overlay-focused.png), [diff](diff-focused.png).
- Phone: [pair](side-by-side-phone.png), [overlay](overlay-phone.png), [diff](diff-phone.png).
- Email: [pair](side-by-side-email.png), [overlay](overlay-email.png), [diff](diff-email.png).

[Exact validation commands and outputs](validation.md). There are no remaining
implementation blockers for this follow-up. Visual review is not silently approved.

Recreate the ink table and12 contact PNGs from the preserved before archive and
captures (Pillow/numpy required):

```powershell
python tool/auth_acceptance/evidence.py --source docs/reports/auth-acceptance-followup --output docs/reports/auth-acceptance-followup
```
