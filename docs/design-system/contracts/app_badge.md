# AppBadge — development contract

Thirty live source variants in six size/theme sets. Retain the raw `Button` axis;
expose BadgeSize small/medium/large, BadgeAppearance filled/tonal/outlined/text/
disabled and BadgeIconMode none/fill/outline. Theme comes from context. Label is
caller supplied; an optional AppIcon override is supported. With an icon mode but
no override, resolve the actual master link for that variant/style. All current
links identify Edit Square: verified evidence, not an arbitrary universal glyph.

No icon is the default: omit slot and gap, hug actual text plus source padding,
never impose sample width. Long labels wrap under bounded constraints; height
grows at 1.0/1.3 and in RTL. Latin uses bundled Outfit; Persian uses the existing
provisional bundled Vazirmatn. Retain source line height, weight and spacing.

Presentational, including Disable appearance: no callback, minimum touch target,
ripple, press motion or button semantics. Icons are decorative. Viewer selection
and gestures wrap the shared root. Inspected descendants have no reactions; add
no animation. Source IDs identify the appearance basis; runtime preview options
remain explicit and do not inflate coverage. Development identity is provisional.

Source geometry: horizontal/vertical padding 8/4, gap 4, radius 6, icon slot 10.
Small/Medium/Large Latin line heights 10/12/14 produce heights 18/20/22. Large
Light Disable has an extra black 1-unit border on its nested label frame, included
in layout: 54x16 instead of 52x14, making 84x24 instead of 82x22 overall. Preserve
the nested border and layout contribution. Centered outer strokes paint their
outward half without changing content geometry. Raw unbound source paints stay
in generated source data. Do not apply the Button readability override to Badge.
