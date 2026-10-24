# Golden follow-up Phase 0 — 2026-10-22

D-050 clarifies D-049: technical captions (variant paths and Figma node IDs) use ASCII digits in every locale; user-facing Persian values retain Persian digits. No component runtime or typography token changed.

## Approval outcome

Eight delegated approvals were applied before regeneration. Nine approvals remain in goldens-review.md: the three previous approvals plus six unchanged sheets from this review. TextField fa-dark-1.0-product-402 and OTP fa-dark-1.0-product-402 return to pending review. All other unapproved sheets remain pending.

Exact RGBA changed-pixel masks were tested against the union of actual before/after caption RenderParagraph rectangles (rounded outward to integer pixels). This is an exact comparison, with no tolerance. The two approved sheets changed outside that mask because caption metrics changed vertically centered cell contents. Approval was therefore not retained. Before-caption bounds were measured with a temporary restoration of the old caption expression; the harness source was restored byte-for-byte afterward.

| Sheet | Changed pixels | Outside caption bounds | Previous approval | Result |
|---|---:|---:|---|---|
| appicon-fa-dark-1.0-product-402 | 4275 | 1444 | no | pending review |
| appicon-fa-dark-2.0-product-402 | 4275 | 1444 | no | pending review |
| appicon-fa-light-1.0-product-402 | 4117 | 1286 | no | pending review |
| otp-fa-dark-1.0-product-402 | 5802 | 2639 | yes | pending review |
| otp-fa-dark-2.0-product-402 | 5952 | 2789 | no | pending review |
| password-fa-dark-1.0-product-402 | 39997 | 32765 | no | pending review |
| password-fa-dark-2.0-product-402 | 45533 | 38301 | no | pending review |
| radio-fa-dark-1.0-product-402 | 4164 | 1656 | no | pending review |
| radio-fa-dark-2.0-product-402 | 4860 | 2352 | no | pending review |
| radio-fa-light-1.0-product-402 | 4156 | 1684 | no | pending review |
| textfield-fa-dark-1.0-product-402 | 19803 | 16383 | yes | pending review |
| textfield-fa-dark-2.0-product-402 | 22571 | 19151 | no | pending review |
| textfield-fa-light-1.0-product-402 | 23529 | 20058 | no | pending review |

These are the only 13 regenerated baseline files, all under packages/design_system/test/goldens/baselines/windows/ with .png suffixes. The remaining 56 baseline files are byte-identical to the task-start inventory, including every English baseline. [Machine-readable pixel proof](golden-follow-up-phase0-proof.json).

## Review copies

The old eight sample copies were replaced with these five exact baseline copies in [golden-samples](golden-samples/README.md), all pending review:

- navigator-fa-dark-1.0-product-402.png
- password-fa-dark-1.0-product-402.png
- radio-fa-light-1.0-product-402.png
- appicon-en-dark-1.0-product-402.png
- pagescaffold-en-light-2.0-product-402.png

## Verification

From packages/design_system:

```powershell
# This recreates the exact affected-name expression used for regeneration.
$names = (Get-Content ../../docs/reports/golden-follow-up-phase0-proof.json -Raw | ConvertFrom-Json).name
$regex = '(' + (($names | ForEach-Object { [regex]::Escape($_) }) -join '|') + ')$'
flutter test test/goldens/readiness_goldens_test.dart --update-goldens --name $regex
flutter test test/goldens/readiness_goldens_test.dart --reporter expanded
flutter test test/goldens/readiness_goldens_test.dart --reporter expanded
```

The two consecutive no-update runs passed 69/69 each. The full DS suite passed 504/504. Caption assertions require the exact ASCII variant key; the Persian fixture-digit test excludes technical caption paragraphs. Raw run logs and captured paragraph rectangles are in build/inspector-v1/ (goldens-final1.log, goldens-final2.log, caption-update.log, captions/, captions-after/). This review grants no new visual approval to pending sheets.
