# Skin axis (D-046)

`AppThemeFactory.build(skin: ..., brightness: ...)` resolves two independent axes.
The default `productSkin` preserves the old brightness-only ThemeData values,
source paint floats, typography, geometry, identity, and original artwork.
`SkinRoleValues` requires all 35 existing consumed raw color roles, with non-null
colors, separately for Light/Dark. Raw names (including `Countainer/*`) are kept;
Dart fields correct the spelling. No full-palette semantic roles are invented.
`tool/tokens/generate_skins.cjs` reads the immutable component foundations listed
in that generator. All 35 have existing values for both brightness modes;
shared Base/Supporting Color/Palette values remain shared source values.

`SkinTheme` carries the selection. Bound paints resolve by exact source variable
name; alternate-skin unbound paints (including the unbound Radio effect) use the
existing `Outline/Variant` diagnostic role explicitly, without hex matching.
Source IDs and evidence remain intact. Alternate skins are engineering probes,
not a designer-approved brand. Root `appSkinProvider` defaults to product and is
available through the existing neutral `providerOverrides` hook; no product UI.

`package:p2e_design_system/testing.dart` alone exports `testSkin` and identity
test helpers. It is not re-exported by the runtime barrel. The old test_support
folder is removed. Product lib imports are rejected by architecture checks;
Viewer and tests may import it. A missing role fails with
`missing_required_argument` (temporary negative analyzer probe, then deleted).

The test skin deliberately changes every role. Pixel leak checks cover all ten
families at both brightness modes against exact product-only role ARGB values.
This is **best-effort**: it is not a proof over arbitrary caller overrides,
composited/antialiased colors, or all possible states. Original AppIcon artwork
is excluded as source artwork (all standalone gallery icons, and multi-color
icons inside controls); monochrome controls are tested with resolved tint.
Original SVG paints are not semantic roles and multi-color artwork is never
force-tinted. Light Password/OTP source sheets are unavailable and omitted;
existing D-026 live derived Light controls remain exercised by live/leak tests.

20 pre-skin English contact sheets (all source states, both brightness modes)
were captured before integration and compared byte-for-byte after integration.
The old ThemeData constructor is also reconstructed and compared, including all
non-extension fields and Button color/text-style maps. Local pre-skin captures
live under build/readiness/product-before and are evidence, not CI dependencies.
Set RUN_PIXEL_GUARD=true only when those captures exist; normal test runs always
check previous ThemeData values, and D-047 goldens are the portable references.
