# Auth Entry Figma conformance — 2026-10-23

Read-only live Figma; EN/Dark402×874, scale1.0, top55. Rect tuples are(x,y,w,h), logical pixels; tolerance0.5. The previous local-coordinate snapshot omitted the idle Body inside stroke. The new absolute-coordinate capture includes it; this is not an unexplained one-pixel adjustment.

## Every measured deviation above0.5

| State / element | Figma | Ours | Delta | Cause / status |
|---|---|---|---|
| idle / title | (25.000, 260.000, 210.000, 40.000) | (25.000, 260.000, 208.224, 40.000) | (0.000, 0.000, -1.776, 0.000) | Fixed source frames/inside-stroke layout restored; remaining intrinsic widths use official1.100 metrics. fixed geometry; intrinsic-width delta retained |
| idle / reward | (21.000, 388.000, 230.000, 32.000) | (21.000, 388.000, 227.600, 32.000) | (0.000, 0.000, -2.400, 0.000) | Fixed source frames/inside-stroke layout restored; remaining intrinsic widths use official1.100 metrics. fixed geometry; intrinsic-width delta retained |
| idle / text 18613:11489 Play. Earn. Win. | (25.000, 260.000, 210.000, 40.000) | (25.000, 260.000, 208.224, 40.000) | (0.000, 0.000, -1.776, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / text 18618:11754 pts | (111.000, 395.000, 18.000, 18.000) | (110.744, 395.000, 17.248, 18.000) | (-0.256, 0.000, -0.752, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / text 18618:11758 Welcome bonus | (135.000, 394.000, 106.000, 20.000) | (133.992, 394.000, 104.608, 20.000) | (-1.008, 0.000, -1.392, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / text I18608:11456;18562:6068 Email Address or Phone Number | (37.000, 468.000, 211.000, 20.000) | (37.000, 468.000, 210.480, 20.000) | (0.000, 0.000, -0.520, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / text I18618:11599;16481:4819 Remember me for next time. | (61.000, 524.000, 188.000, 20.000) | (61.000, 524.000, 186.464, 20.000) | (0.000, 0.000, -1.536, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / text I18618:11633;18437:1839 Continue | (170.500, 589.000, 61.000, 20.000) | (171.024, 589.000, 59.952, 20.000) | (0.524, 0.000, -1.048, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / text 18613:11496 or continue with | (155.500, 642.000, 91.000, 18.000) | (156.039, 642.000, 89.922, 18.000) | (0.539, 0.000, -1.078, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / text 18613:11504 Playstation | (46.833, 728.000, 67.000, 18.000) | (46.460, 728.000, 67.746, 18.000) | (-0.373, 0.000, 0.746, 0.000) | Owner-authorized PlayStation capitalization; official font metrics. review required |
| idle / text 18613:11509 Xbox | (185.000, 728.000, 32.000, 18.000) | (185.628, 728.000, 30.744, 18.000) | (0.628, 0.000, -1.256, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / text 18613:11524 Google | (299.667, 728.000, 44.000, 18.000) | (300.366, 728.000, 42.602, 18.000) | (0.699, 0.000, -1.398, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| idle / divider line 18613:11494 | (33.000, 651.000, 112.500, 0.000) | (33.000, 651.000, 113.039, 0.000) | (0.000, 0.000, 0.539, 0.000) | Line consumes remaining width around the measured Outfit label. review required |
| idle / divider line 18613:11497 | (256.500, 651.000, 112.500, 0.000) | (255.961, 651.000, 113.039, 0.000) | (-0.539, 0.000, 0.539, 0.000) | Line consumes remaining width around the measured Outfit label. review required |
| focusedEmpty / title | (24.000, 79.000, 210.000, 40.000) | (24.000, 79.000, 208.224, 40.000) | (0.000, 0.000, -1.776, 0.000) | Fixed source frames/inside-stroke layout restored; remaining intrinsic widths use official1.100 metrics. fixed geometry; intrinsic-width delta retained |
| focusedEmpty / reward | (20.000, 207.000, 230.000, 32.000) | (20.000, 207.000, 227.600, 32.000) | (0.000, 0.000, -2.400, 0.000) | Fixed source frames/inside-stroke layout restored; remaining intrinsic widths use official1.100 metrics. fixed geometry; intrinsic-width delta retained |
| focusedEmpty / text 18618:12457 Play. Earn. Win. | (24.000, 79.000, 210.000, 40.000) | (24.000, 79.000, 208.224, 40.000) | (0.000, 0.000, -1.776, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| focusedEmpty / text 18618:12466 pts | (110.000, 214.000, 18.000, 18.000) | (109.744, 214.000, 17.248, 18.000) | (-0.256, 0.000, -0.752, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| focusedEmpty / text 18618:12468 Welcome bonus | (134.000, 213.000, 106.000, 20.000) | (132.992, 213.000, 104.608, 20.000) | (-1.008, 0.000, -1.392, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| focusedEmpty / text I18618:12471;18563:6178 Email Address or Phone Number | (36.000, 278.000, 185.000, 18.000) | (36.000, 278.000, 184.170, 18.000) | (0.000, 0.000, -0.830, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| focusedEmpty / text I18618:12471;18563:6188 Enter email or phone | (36.000, 297.000, 153.000, 24.000) | (36.000, 297.000, 152.064, 24.000) | (0.000, 0.000, -0.936, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| focusedEmpty / text I18618:12474;18437:1839 Continue | (170.500, 490.000, 61.000, 20.000) | (171.024, 490.000, 59.952, 20.000) | (0.524, 0.000, -1.048, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| focusedEmpty / caret (2px source stroke paint envelope) | (35.000, 299.000, 2.000, 20.000) | (36.000, 299.000, 2.000, 20.000) | (1.000, 0.000, 0.000, 0.000) | Native editable caret anchors/snaps its stroke to the text advance; source20px height restored. Raw Figma caret frame has zero width; compare its2px stroke envelope. native-control difference; review required |
| phone / title | (24.000, 79.000, 210.000, 40.000) | (24.000, 79.000, 208.224, 40.000) | (0.000, 0.000, -1.776, 0.000) | Fixed source frames/inside-stroke layout restored; remaining intrinsic widths use official1.100 metrics. fixed geometry; intrinsic-width delta retained |
| phone / reward | (20.000, 207.000, 230.000, 32.000) | (20.000, 207.000, 227.600, 32.000) | (0.000, 0.000, -2.400, 0.000) | Fixed source frames/inside-stroke layout restored; remaining intrinsic widths use official1.100 metrics. fixed geometry; intrinsic-width delta retained |
| phone / text 18618:12136 Play. Earn. Win. | (24.000, 79.000, 210.000, 40.000) | (24.000, 79.000, 208.224, 40.000) | (0.000, 0.000, -1.776, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| phone / text 18618:12145 pts | (110.000, 214.000, 18.000, 18.000) | (109.744, 214.000, 17.248, 18.000) | (-0.256, 0.000, -0.752, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| phone / text 18618:12147 Welcome bonus | (134.000, 213.000, 106.000, 20.000) | (132.992, 213.000, 104.608, 20.000) | (-1.008, 0.000, -1.392, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| phone / text I18618:12150;18563:6255 Email Address or Phone Number | (36.000, 278.000, 185.000, 18.000) | (36.000, 278.000, 184.170, 18.000) | (0.000, 0.000, -0.830, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| phone / text I18618:12150;18563:6265 +98 912 827 9503 | (36.000, 297.000, 123.000, 24.000) | (36.000, 297.740, 122.816, 24.000) | (0.000, 0.740, -0.184, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| phone / text I18618:12150;18563:6271 We'll text you a one-time code | (56.000, 347.000, 171.000, 18.000) | (56.000, 347.000, 169.834, 18.000) | (0.000, 0.000, -1.166, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| phone / text I18618:12153;18437:1815 Continue With Phone | (130.500, 490.000, 141.000, 20.000) | (131.096, 490.000, 139.808, 20.000) | (0.596, 0.000, -1.192, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| phone / caret (2px source stroke paint envelope) | (158.000, 299.000, 2.000, 20.000) | (159.000, 300.000, 2.000, 20.000) | (1.000, 1.000, 0.000, 0.000) | Native editable caret anchors/snaps its stroke to the text advance; source20px height restored. Raw Figma caret frame has zero width; compare its2px stroke envelope. native-control difference; review required |
| email / title | (24.000, 79.000, 210.000, 40.000) | (24.000, 79.000, 208.224, 40.000) | (0.000, 0.000, -1.776, 0.000) | Fixed source frames/inside-stroke layout restored; remaining intrinsic widths use official1.100 metrics. fixed geometry; intrinsic-width delta retained |
| email / reward | (20.000, 207.000, 230.000, 32.000) | (20.000, 207.000, 227.600, 32.000) | (0.000, 0.000, -2.400, 0.000) | Fixed source frames/inside-stroke layout restored; remaining intrinsic widths use official1.100 metrics. fixed geometry; intrinsic-width delta retained |
| email / text 18618:12657 Play. Earn. Win. | (24.000, 79.000, 210.000, 40.000) | (24.000, 79.000, 208.224, 40.000) | (0.000, 0.000, -1.776, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| email / text 18618:12666 pts | (110.000, 214.000, 18.000, 18.000) | (109.744, 214.000, 17.248, 18.000) | (-0.256, 0.000, -0.752, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| email / text 18618:12668 Welcome bonus | (134.000, 213.000, 106.000, 20.000) | (132.992, 213.000, 104.608, 20.000) | (-1.008, 0.000, -1.392, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| email / text I18618:12671;18563:6255 Email Address or Phone Number | (36.000, 278.000, 185.000, 18.000) | (36.000, 278.000, 184.170, 18.000) | (0.000, 0.000, -0.830, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| email / text I18618:12671;18563:6265 me.ardeshir.rashidi@gmail.com | (36.000, 297.000, 237.000, 24.000) | (36.000, 297.000, 235.962, 24.000) | (0.000, 0.000, -1.038, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| email / text I18618:12671;18563:6271 You'll enter your password next if you register before. | (56.000, 347.000, 299.000, 18.000) | (56.000, 347.000, 298.200, 18.000) | (0.000, 0.000, -0.800, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |
| email / text I18618:12674;18437:1815 Continue With Email Address | (104.500, 490.000, 193.000, 20.000) | (105.128, 490.000, 191.744, 20.000) | (0.628, 0.000, -1.256, 0.000) | Official Outfit1.100 text advance differs from Figma text-node bounds; source font binary/version is unavailable. No artificial width/stretch/tracking compensation. review required |

## Widths requested by the reviewer

Single-line runs use measured advance; fixed multi-line legal/subtitle frames use their constrained paragraph width. The editable field itself fills its available width; its text advance is measured separately. Figma does not disclose its underlying font binary/version. Official1.100 is verified, but small width differences remain, are not declared zero, and require review.

| State / run | Figma width | Ours | Delta |
|---|---:|---:|---:|
| idle / Play. Earn. Win. | 210.000 | 208.224 | -1.776 |
| idle / +3,500 | 52.000 | 51.744 | -0.256 |
| idle / Welcome bonus | 106.000 | 104.608 | -1.392 |
| idle / Continue | 61.000 | 59.952 | -1.048 |
| focusedEmpty / Play. Earn. Win. | 210.000 | 208.224 | -1.776 |
| focusedEmpty / +3,500 | 52.000 | 51.744 | -0.256 |
| focusedEmpty / Welcome bonus | 106.000 | 104.608 | -1.392 |
| focusedEmpty / Continue | 61.000 | 59.952 | -1.048 |
| phone / Play. Earn. Win. | 210.000 | 208.224 | -1.776 |
| phone / +3,500 | 52.000 | 51.744 | -0.256 |
| phone / Welcome bonus | 106.000 | 104.608 | -1.392 |
| phone / +98 912 827 9503 | 123.000 | 122.816 | -0.184 |
| phone / Continue With Phone | 141.000 | 139.808 | -1.192 |
| email / Play. Earn. Win. | 210.000 | 208.224 | -1.776 |
| email / +3,500 | 52.000 | 51.744 | -0.256 |
| email / Welcome bonus | 106.000 | 104.608 | -1.392 |
| email / me.ardeshir.rashidi@gmail.com | 237.000 | 235.962 | -1.038 |
| email / Continue With Email Address | 193.000 | 191.744 | -1.256 |
| idle / legal paragraph | 352.000 | 352.000 | +0.000 |

## Text colors and weights

| State / text segment | Weight Figma / ours | Size Figma / ours | Hex Figma / ours | Result |
|---|---|---|---|
| idle / Play. Earn. Win. | 600 / 600 | 32 / 32.0 | #ffffff / #ffffff | pass |
| idle / Enter your email or phone number and let the games begin. | 500 / 500 | 18 / 18.0 | #a1a1a1 / #a1a1a1 | pass |
| idle / +3,500 | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| idle / pts | 400 / 400 | 14 / 14.0 | #737373 / #737373 | pass |
| idle / Welcome bonus | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| idle / Email Address or Phone Number | 500 / 500 | 16 / 16.0 | #a1a1a1 / #a1a1a1 | pass |
| idle / Remember me for next time. | 400 / 400 | 16 / 16.0 | #a1a1a1 / #a1a1a1 | pass |
| idle / Continue | 600 / 600 | 16 / 16.0 | #404040 / #404040 | pass |
| idle / or continue with | 400 / 400 | 14 / 14.0 | #525252 / #525252 | pass |
| idle / Playstation | 600 / 600 | 14 / 14.0 | #ffffff / #ffffff | pass |
| idle / Xbox | 600 / 600 | 14 / 14.0 | #ffffff / #ffffff | pass |
| idle / Google | 600 / 600 | 14 / 14.0 | #ffffff / #ffffff | pass |
| idle / By continuing, you agree to our | 400 / 400 | 14 / 14.0 | #a1a1a1 / #a1a1a1 | pass |
| idle / Terms & Conditions | 600 / 600 | 14 / 14.0 | #00a6f4 / #00a6f4 | pass |
| idle / and | 400 / 400 | 14 / 14.0 | #a1a1a1 / #a1a1a1 | pass |
| idle / Privacy Policy | 600 / 600 | 14 / 14.0 | #00a6f4 / #00a6f4 | pass |
| idle / . | 400 / 400 | 14 / 14.0 | #a1a1a1 / #a1a1a1 | pass |
| focusedEmpty / Play. Earn. Win. | 600 / 600 | 32 / 32.0 | #ffffff / #ffffff | pass |
| focusedEmpty / Enter your email or phone number and let the games begin. | 500 / 500 | 18 / 18.0 | #a1a1a1 / #a1a1a1 | pass |
| focusedEmpty / +3,500 | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| focusedEmpty / pts | 400 / 400 | 14 / 14.0 | #737373 / #737373 | pass |
| focusedEmpty / Welcome bonus | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| focusedEmpty / Email Address or Phone Number | 500 / 500 | 14 / 14.0 | #737373 / #737373 | pass |
| focusedEmpty / Enter email or phone | 400 / 400 | 18 / 18.0 | #525252 / #525252 | pass |
| focusedEmpty / Continue | 600 / 600 | 16 / 16.0 | #404040 / #404040 | pass |
| phone / Play. Earn. Win. | 600 / 600 | 32 / 32.0 | #ffffff / #ffffff | pass |
| phone / Enter your email or phone number and let the games begin. | 500 / 500 | 18 / 18.0 | #a1a1a1 / #a1a1a1 | pass |
| phone / +3,500 | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| phone / pts | 400 / 400 | 14 / 14.0 | #737373 / #737373 | pass |
| phone / Welcome bonus | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| phone / Email Address or Phone Number | 500 / 500 | 14 / 14.0 | #737373 / #737373 | pass |
| phone / +98 912 827 9503 | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| phone / We'll text you a one-time code | 500 / 500 | 14 / 14.0 | #a1a1a1 / #a1a1a1 | pass |
| phone / Continue With Phone | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| email / Play. Earn. Win. | 600 / 600 | 32 / 32.0 | #ffffff / #ffffff | pass |
| email / Enter your email or phone number and let the games begin. | 500 / 500 | 18 / 18.0 | #a1a1a1 / #a1a1a1 | pass |
| email / +3,500 | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| email / pts | 400 / 400 | 14 / 14.0 | #737373 / #737373 | pass |
| email / Welcome bonus | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |
| email / Email Address or Phone Number | 500 / 500 | 14 / 14.0 | #737373 / #737373 | pass |
| email / me.ardeshir.rashidi@gmail.com | 600 / 600 | 18 / 18.0 | #ffffff / #ffffff | pass |
| email / You'll enter your password next if you register before. | 500 / 500 | 14 / 14.0 | #a1a1a1 / #a1a1a1 | pass |
| email / Continue With Email Address | 600 / 600 | 16 / 16.0 | #ffffff / #ffffff | pass |

## Scope and visual proof

All visible product text nodes from the live export are matched, including mixed legal styles. Main painted frames, hero, chip, field, CTA, divider strokes, social surfaces and original icon viewports are compared in rect-comparison.json. Layout-only intermediate wrappers and internal SVG paths do not have independent Flutter layout boxes; the enclosing visual viewport is compared instead. Native status bar and keyboard are OS UI, not product widgets, and are excluded from product conformance. Full screenshots deliberately retain that visible difference. The diff is4× channel difference, not a tolerance mask.

The legal paragraph is exactly(25,813,352,36) in idle and hidden in keyboard states. Idle field label is at y468 after source-frame centering. Hero is(0,0,402,264). Chip position/height match; its remaining width difference is intrinsic text. No English content is clipped at the reference viewport. Persian/2× content scrolls when taller than the viewport; it is not forced into the English two-line prose frame.

- idle: [side by side](side-by-side-idle.png), [overlay](overlay-idle.png), [4× diff](diff-idle.png).
- focused: [side by side](side-by-side-focused.png), [overlay](overlay-focused.png), [4× diff](diff-focused.png).
- phone: [side by side](side-by-side-phone.png), [overlay](overlay-phone.png), [4× diff](diff-phone.png).
- email: [side by side](side-by-side-email.png), [overlay](overlay-email.png), [4× diff](diff-email.png).

## Tracking/boundary evidence (inference, not a font-version claim)

For28/29 single-line comparisons, `ceil(Flutter advance − source letterSpacing)` equals the recorded Figma width. This strongly supports a difference in trailing tracking/text-frame rounding rather than missing real weights. Example: headline208.224 −(−1.28)=209.504, ceiling210; Continue59.952 −(−0.64)=60.592, ceiling61. Zero-tracking phone122.816 rounds to123. See tracking-bound-evidence.json. The idle field label includes a trailing source space and is an exception. Figma's font binary/version and renderer internals are not available, so this remains a measured inference. No artificial stretch, tracking change or per-label padding was added to conceal it.

Inline legal target exception reference: https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html .
