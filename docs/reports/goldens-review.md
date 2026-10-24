# Initial DS golden review (D-047)

Owner-delegated review on 2026-10-22 approves the nine baselines marked below. All others remain **pending review**. Horizontal PageScaffold padding is deferred to Login and is not a golden defect.
Reference platform: Windows, Flutter 3.47.7 / Dart 3.13.5, DPR 1.0.
Real bundled Outfit/Vazirmatn use the alignment test font loader. Animations are
disabled, surfaces fixed by deterministic contact-sheet dimensions, no network,
and stock matchesGoldenFile without tolerance. All 69 tests carry `golden`.
The Linux CI explicitly excludes this tag because Windows owns these pixels.

Generated once with --update-goldens, then verified twice consecutively without
updates (69/69 each). Final code was verified twice again, also 69/69 each.
These are deterministic references of current behavior, not visual approval.

D-048 (2026-10-22) fixes the Persian family/fallback defect in Button,
token-styled PageScaffold headings and OTP. The previous missing-glyph review
blocker is removed for the fixed sheets. The later delegated approvals are recorded below.
Only28 sheets containing Persian text were regenerated;11 changed bytes. No
English baseline or text-free AppIcon baseline was updated. Both complete
no-update verification runs passed69/69. See [D-048 report](persian-font-fallback-d048.md)
for every regenerated path and [owner samples](golden-samples/README.md).

## Delegated corrections (2026-10-22)

D-049 localizes fixture digits and records caller display formatting. The harness now gives loose constraints except for fill Buttons; Avatar fixtures use initials. Exactly 38 affected baselines were regenerated, then two consecutive no-update runs passed 69/69. The three baselines approved in the preceding review stayed byte-identical; all others remain pending review. See [findings, commands and the full regenerated list](delegated-golden-review-d049.md).

Source omissions: no Light Password/OTP Figma variants exist. Their eight
otherwise-requested Light sheets are omitted (each: fa/light/1, en/light/1,
en/light/2 product, en/light/1 test). Existing D-026 derived Light live controls
are covered by behavior/alignment/leak tests, not fabricated as source goldens.
Back App Bar Light is omitted from Light App Bar sheets. Dark sheets cover Back.

Each available family sheet covers all source axes, including all normal Button
rows, icon modes and loading rows; Field source states/Password visibility;
Radio states; all 104 icon IDs × both styles; all App Bar categories available
for that brightness; all five Navigator selections and standalone item states.
PageScaffold has 402 and 700 widths for all seven configurations.

| Baseline | Status |
|---|---|
| [appbar-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-en-dark-1.0-product-402.png) | pending review |
| [appbar-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-en-light-1.0-product-402.png) | pending review |
| [appbar-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-en-light-1.0-test-402.png) | pending review |
| [appbar-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-en-light-2.0-product-402.png) | pending review |
| [appbar-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-dark-1.0-product-402.png) | approved — delegated review (2026-10-22) |
| [appbar-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-dark-2.0-product-402.png) | pending review |
| [appbar-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appbar-fa-light-1.0-product-402.png) | pending review |
| [appicon-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-en-dark-1.0-product-402.png) | pending review |
| [appicon-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-en-light-1.0-product-402.png) | pending review |
| [appicon-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-en-light-1.0-test-402.png) | pending review |
| [appicon-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-en-light-2.0-product-402.png) | pending review |
| [appicon-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-fa-dark-1.0-product-402.png) | pending review |
| [appicon-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-fa-dark-2.0-product-402.png) | pending review |
| [appicon-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/appicon-fa-light-1.0-product-402.png) | pending review |
| [badge-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-en-dark-1.0-product-402.png) | pending review |
| [badge-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-en-light-1.0-product-402.png) | pending review |
| [badge-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-en-light-1.0-test-402.png) | pending review |
| [badge-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-en-light-2.0-product-402.png) | pending review |
| [badge-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-dark-1.0-product-402.png) | pending review |
| [badge-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-dark-2.0-product-402.png) | pending review |
| [badge-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/badge-fa-light-1.0-product-402.png) | pending review |
| [button-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-en-dark-1.0-product-402.png) | pending review |
| [button-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-en-light-1.0-product-402.png) | pending review |
| [button-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/button-en-light-1.0-test-402.png) | pending review |
| [button-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-en-light-2.0-product-402.png) | pending review |
| [button-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-dark-1.0-product-402.png) | pending review |
| [button-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-dark-2.0-product-402.png) | pending review |
| [button-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/button-fa-light-1.0-product-402.png) | pending review |
| [navigator-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-en-dark-1.0-product-402.png) | pending review |
| [navigator-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-en-light-1.0-product-402.png) | pending review |
| [navigator-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-en-light-1.0-test-402.png) | pending review |
| [navigator-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-en-light-2.0-product-402.png) | pending review |
| [navigator-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-dark-1.0-product-402.png) | pending review |
| [navigator-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-dark-2.0-product-402.png) | pending review |
| [navigator-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/navigator-fa-light-1.0-product-402.png) | pending review |
| [otp-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/otp-en-dark-1.0-product-402.png) | pending review |
| [otp-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/otp-fa-dark-1.0-product-402.png) | pending review |
| [otp-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/otp-fa-dark-2.0-product-402.png) | pending review |
| [pagescaffold-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-en-dark-1.0-product-402.png) | pending review |
| [pagescaffold-en-dark-1.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-en-dark-1.0-product-700.png) | pending review |
| [pagescaffold-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-en-light-1.0-product-402.png) | pending review |
| [pagescaffold-en-light-1.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-en-light-1.0-product-700.png) | pending review |
| [pagescaffold-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-en-light-1.0-test-402.png) | pending review |
| [pagescaffold-en-light-1.0-test-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-en-light-1.0-test-700.png) | pending review |
| [pagescaffold-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-en-light-2.0-product-402.png) | pending review |
| [pagescaffold-en-light-2.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-en-light-2.0-product-700.png) | pending review |
| [pagescaffold-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-dark-1.0-product-402.png) | pending review |
| [pagescaffold-fa-dark-1.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-dark-1.0-product-700.png) | pending review |
| [pagescaffold-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-dark-2.0-product-402.png) | pending review |
| [pagescaffold-fa-dark-2.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-dark-2.0-product-700.png) | pending review |
| [pagescaffold-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-light-1.0-product-402.png) | pending review |
| [pagescaffold-fa-light-1.0-product-700.png](../../packages/design_system/test/goldens/baselines/windows/pagescaffold-fa-light-1.0-product-700.png) | pending review |
| [password-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/password-en-dark-1.0-product-402.png) | pending review |
| [password-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/password-fa-dark-1.0-product-402.png) | pending review |
| [password-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/password-fa-dark-2.0-product-402.png) | pending review |
| [radio-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-en-dark-1.0-product-402.png) | pending review |
| [radio-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-en-light-1.0-product-402.png) | pending review |
| [radio-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-en-light-1.0-test-402.png) | pending review |
| [radio-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-en-light-2.0-product-402.png) | pending review |
| [radio-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-dark-1.0-product-402.png) | pending review |
| [radio-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-dark-2.0-product-402.png) | pending review |
| [radio-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/radio-fa-light-1.0-product-402.png) | pending review |
| [textfield-en-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-en-dark-1.0-product-402.png) | pending review |
| [textfield-en-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-en-light-1.0-product-402.png) | pending review |
| [textfield-en-light-1.0-test-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-en-light-1.0-test-402.png) | pending review |
| [textfield-en-light-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-en-light-2.0-product-402.png) | pending review |
| [textfield-fa-dark-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-dark-1.0-product-402.png) | pending review |
| [textfield-fa-dark-2.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-dark-2.0-product-402.png) | pending review |
| [textfield-fa-light-1.0-product-402.png](../../packages/design_system/test/goldens/baselines/windows/textfield-fa-light-1.0-product-402.png) | pending review |

## Phase 0 follow-up (2026-10-22)

Eight further product-402 sheets were approved by delegated review before caption regeneration. Technical fixture captions now retain ASCII digits in every locale; D-049 applies only to user-facing content. Thirteen fa sheets were regenerated. Automated exact RGBA difference masks compare changed pixels with actual caption RenderParagraph bounds. TextField fa-dark-1.0 and OTP fa-dark-1.0 reset to pending review because changed caption text metrics also move cell content outside caption bounds. The other approved sheets were unchanged. Nine approvals remain. Unapproved affected sheets remain pending, including fa AppIcon where caption wrapping can move centered artwork. Proof: [exact pixel-mask results](golden-follow-up-phase0-proof.json); [full Phase 0 report](golden-follow-up-phase0.md). Five pending samples replace the previous review copies.

## Auth Entry additions (2026-10-23)

D-057 authorizes these new baselines; owner review remains pending. Existing approvals are unchanged.

| Baseline | Status |
|---|---|
| [auth-email-en-dark-1.0-402.png](../../test/goldens/baselines/windows/auth-email-en-dark-1.0-402.png) | pending review |
| [auth-email-en-light-1.0-402.png](../../test/goldens/baselines/windows/auth-email-en-light-1.0-402.png) | pending review |
| [auth-email-fa-dark-1.0-402.png](../../test/goldens/baselines/windows/auth-email-fa-dark-1.0-402.png) | pending review |
| [auth-email-fa-dark-2.0-402.png](../../test/goldens/baselines/windows/auth-email-fa-dark-2.0-402.png) | pending review |
| [auth-email-fa-light-1.0-402.png](../../test/goldens/baselines/windows/auth-email-fa-light-1.0-402.png) | pending review |
| [auth-focused-en-dark-1.0-402.png](../../test/goldens/baselines/windows/auth-focused-en-dark-1.0-402.png) | pending review |
| [auth-focused-en-light-1.0-402.png](../../test/goldens/baselines/windows/auth-focused-en-light-1.0-402.png) | pending review |
| [auth-focused-fa-dark-1.0-402.png](../../test/goldens/baselines/windows/auth-focused-fa-dark-1.0-402.png) | pending review |
| [auth-focused-fa-light-1.0-402.png](../../test/goldens/baselines/windows/auth-focused-fa-light-1.0-402.png) | pending review |
| [auth-idle-en-dark-1.0-402.png](../../test/goldens/baselines/windows/auth-idle-en-dark-1.0-402.png) | pending review |
| [auth-idle-en-dark-1.0-744.png](../../test/goldens/baselines/windows/auth-idle-en-dark-1.0-744.png) | pending review |
| [auth-idle-en-light-1.0-402.png](../../test/goldens/baselines/windows/auth-idle-en-light-1.0-402.png) | pending review |
| [auth-idle-fa-dark-1.0-402.png](../../test/goldens/baselines/windows/auth-idle-fa-dark-1.0-402.png) | pending review |
| [auth-idle-fa-light-1.0-402.png](../../test/goldens/baselines/windows/auth-idle-fa-light-1.0-402.png) | pending review |
| [auth-phone-en-dark-1.0-402.png](../../test/goldens/baselines/windows/auth-phone-en-dark-1.0-402.png) | pending review |
| [auth-phone-en-light-1.0-402.png](../../test/goldens/baselines/windows/auth-phone-en-light-1.0-402.png) | pending review |
| [auth-phone-fa-dark-1.0-402.png](../../test/goldens/baselines/windows/auth-phone-fa-dark-1.0-402.png) | pending review |
| [auth-phone-fa-light-1.0-402.png](../../test/goldens/baselines/windows/auth-phone-fa-light-1.0-402.png) | pending review |
| [auth-primitives-en-dark-1.0-product.png](../../packages/design_system/test/goldens/baselines/windows/auth-primitives-en-dark-1.0-product.png) | pending review |
| [auth-primitives-en-light-1.0-product.png](../../packages/design_system/test/goldens/baselines/windows/auth-primitives-en-light-1.0-product.png) | pending review |
| [auth-primitives-en-light-1.0-test.png](../../packages/design_system/test/goldens/baselines/windows/auth-primitives-en-light-1.0-test.png) | pending review |
| [auth-primitives-en-light-2.0-product.png](../../packages/design_system/test/goldens/baselines/windows/auth-primitives-en-light-2.0-product.png) | pending review |
| [auth-primitives-fa-dark-1.0-product.png](../../packages/design_system/test/goldens/baselines/windows/auth-primitives-fa-dark-1.0-product.png) | pending review |
| [auth-primitives-fa-dark-2.0-product.png](../../packages/design_system/test/goldens/baselines/windows/auth-primitives-fa-dark-2.0-product.png) | pending review |
| [auth-primitives-fa-light-1.0-product.png](../../packages/design_system/test/goldens/baselines/windows/auth-primitives-fa-light-1.0-product.png) | pending review |

## Auth conformance corrections (2026-10-23)

D-059/D-060: fixed Button frames, official static Outfit weights, inline legal links and field label centering. Every changed baseline returns to pending review; no previous visual approval is inherited. See [changed sheets and requested review samples](golden-samples/auth-conformance/README.md) and [complete changed-baseline list](auth-conformance/changed-goldens.json).

## Auth acceptance follow-up D-062 (2026-10-23)

Status remains **pending review**. Only the five idle Auth baseline files listed below were regenerated for the owner-approved `Playstation` source copy in both locales. No DS reference changed. Full before/after/diff component contacts, with91/91 verified before files and RGBA changed-pixel percentages, are in [the acceptance follow-up](auth-acceptance-followup/goldens.md).19 historically missing files were replayed in an isolated tree and accepted only after byte-identical SHA-256 equality against the original saved manifest.

- auth-idle-en-dark-1.0-402.png
- auth-idle-en-dark-1.0-744.png
- auth-idle-en-light-1.0-402.png
- auth-idle-fa-dark-1.0-402.png
- auth-idle-fa-light-1.0-402.png
