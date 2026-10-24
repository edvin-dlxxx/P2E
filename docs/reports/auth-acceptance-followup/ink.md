# Glyph ink evidence

Figma captures are read-only 402×874 exports from the preceding conformance task. Coordinates are global pixels at DPR1. Each text crop uses its measured frame; the modal flat background and source foreground define the AA paint ramp. Every differing pixel on that ramp is included (minimum difference 1/255); a maximum residual of 2/255 permits channel rounding. Caret rects are excluded using independently recorded geometry plus a one-pixel vector AA fringe. Where caret and glyph ink overlap the original glyph cannot be recovered; the exclusion is conservative. No image registration or per-string offsets. This measures a bbox, not glyph-by-glyph raster equality or font identity.

|Element|State|Bounds Δ x/y/w/h|Figma ink x/y/w/h|Ours ink x/y/w/h|Ink Δ x/y/w/h|Result|
|---|---|---|---|---|---|---|
|Play. Earn. Win.|idle|+0.000/+0.000/-1.776/+0.000|[27, 260, 208, 39]|[26, 260, 208, 39]|[-1, 0, 0, 0]|PASS|
|pts|idle|-0.256/+0.000/-0.752/+0.000|[112, 399, 17, 13]|[111, 399, 17, 13]|[-1, 0, 0, 0]|PASS|
|Welcome bonus|idle|-1.008/+0.000/-1.392/+0.000|[135, 398, 106, 13]|[134, 398, 105, 13]|[-1, 0, -1, 0]|PASS|
|Email Address or Phone Number |idle|+0.000/+0.000/-0.520/+0.000|[38, 472, 210, 13]|[38, 472, 210, 13]|[0, 0, 0, 0]|PASS|
|Remember me for next time.|idle|+0.000/+0.000/-1.536/+0.000|[62, 528, 186, 13]|[62, 528, 185, 13]|[0, 0, -1, 0]|PASS|
|Continue|idle|+0.524/+0.000/-1.048/+0.000|[171, 593, 60, 13]|[171, 593, 60, 13]|[0, 0, 0, 0]|PASS|
|or continue with|idle|+0.539/+0.000/-1.078/+0.000|[156, 646, 90, 11]|[156, 646, 90, 11]|[0, 0, 0, 0]|PASS|
|Playstation|idle|+0.628/+0.000/-1.256/+0.000|[48, 731, 65, 14]|[48, 731, 66, 14]|[0, 0, 1, 0]|PASS|
|Xbox|idle|+0.628/+0.000/-1.256/+0.000|[185, 731, 32, 12]|[186, 731, 31, 12]|[1, 0, -1, 0]|PASS|
|Google|idle|+0.699/+0.000/-1.398/+0.000|[300, 731, 43, 14]|[300, 731, 43, 14]|[0, 0, 0, 0]|PASS|
|Play. Earn. Win.|focusedEmpty|+0.000/+0.000/-1.776/+0.000|[26, 87, 206, 31]|[25, 87, 206, 31]|[-1, 0, 0, 0]|PASS|
|pts|focusedEmpty|-0.256/+0.000/-0.752/+0.000|[111, 218, 17, 13]|[110, 218, 17, 13]|[-1, 0, 0, 0]|PASS|
|Welcome bonus|focusedEmpty|-1.008/+0.000/-1.392/+0.000|[134, 217, 106, 13]|[133, 217, 105, 13]|[-1, 0, -1, 0]|PASS|
|Email Address or Phone Number |focusedEmpty|+0.000/+0.000/-0.830/+0.000|[37, 281, 184, 12]|[36, 282, 185, 11]|[-1, 1, 1, -1]|PASS|
|Enter email or phone|focusedEmpty|+0.000/+0.000/-0.936/+0.000|[36, 298, 153, 22]|[36, 299, 152, 21]|[0, 1, -1, -1]|PASS|
|Continue|focusedEmpty|+0.524/+0.000/-1.048/+0.000|[171, 494, 60, 13]|[171, 494, 60, 13]|[0, 0, 0, 0]|PASS|
|Play. Earn. Win.|phone|+0.000/+0.000/-1.776/+0.000|[26, 87, 206, 31]|[25, 87, 206, 31]|[-1, 0, 0, 0]|PASS|
|pts|phone|-0.256/+0.000/-0.752/+0.000|[111, 218, 17, 13]|[110, 218, 17, 13]|[-1, 0, 0, 0]|PASS|
|Welcome bonus|phone|-1.008/+0.000/-1.392/+0.000|[134, 217, 106, 13]|[133, 217, 105, 13]|[-1, 0, -1, 0]|PASS|
|Email Address or Phone Number |phone|+0.000/+0.000/-0.830/+0.000|[37, 281, 184, 12]|[36, 282, 185, 11]|[-1, 1, 1, -1]|PASS|
|+98 912 827 9503|phone|+0.000/+0.740/-0.184/+0.000|[36, 303, 121, 13]|[36, 304, 122, 13]|[0, 1, 1, 0]|PASS|
|We'll text you a one-time code|phone|+0.000/+0.000/-1.166/+0.000|[56, 350, 171, 14]|[56, 351, 170, 13]|[0, 1, -1, -1]|PASS|
|Continue With Phone|phone|+0.596/+0.000/-1.192/+0.000|[131, 494, 140, 13]|[131, 494, 140, 13]|[0, 0, 0, 0]|PASS|
|Play. Earn. Win.|email|+0.000/+0.000/-1.776/+0.000|[26, 87, 206, 31]|[25, 87, 206, 31]|[-1, 0, 0, 0]|PASS|
|pts|email|-0.256/+0.000/-0.752/+0.000|[111, 218, 17, 13]|[110, 218, 17, 13]|[-1, 0, 0, 0]|PASS|
|Welcome bonus|email|-1.008/+0.000/-1.392/+0.000|[134, 217, 106, 13]|[133, 217, 105, 13]|[-1, 0, -1, 0]|PASS|
|Email Address or Phone Number |email|+0.000/+0.000/-0.830/+0.000|[37, 281, 184, 12]|[36, 282, 185, 11]|[-1, 1, 1, -1]|PASS|
|me.ardeshir.rashidi@gmail.com|email|+0.000/+0.000/-1.038/+0.000|[37, 303, 234, 17]|[36, 303, 235, 17]|[-1, 0, 1, 0]|PASS|
|You'll enter your password next if you register before.|email|+0.000/+0.000/-0.800/+0.000|[56, 350, 298, 14]|[56, 350, 298, 14]|[0, 0, 0, 0]|PASS|
|Continue With Email Address|email|+0.628/+0.000/-1.256/+0.000|[105, 494, 192, 13]|[105, 494, 192, 13]|[0, 0, 0, 0]|PASS|

Passed 30/30. Container aliases (title/reward) are represented by their text children; carets and divider strokes are not text.

All measured ink deltas are within1px. D-062 aligns the localized label with the source copy; no font, tracking, width or offset hack.
