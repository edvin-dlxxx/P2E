# Button development tokens

Generate with the existing Dart SDK (no packages or Figma access):

    dart run tool/tokens/generate_buttons.dart

Verify reproducibility without writing:

    dart run tool/tokens/generate_buttons.dart --check

The default source is docs/snapshots/2026-10-19_development-buttons.
An explicit --snapshot directory is supported. Generated output is formatted by
the same Dart executable that runs the generator. The Snapshot is read-only.

Outputs:
- lib/ui/tokens/generated/button_tokens.g.dart
- docs/design-system/buttons-token-report.json
- docs/design-system/buttons-token-report.md

ColorTokens.allById preserves all 18 variables and mode identities. Light and
Dark each expose 12 active colors by exact Figma name: six shared Base Color
variables plus six theme-specific variables. Color.from retains API doubles,
including fractional alpha, rather than quantizing channels to hex. Aliases use
exact-mode lookup and fail on missing data/cycles, never guessed mode mappings.
Other collection/mode/type policies fail explicitly instead of inventing tokens.

There is a source parity gap: Surface Container/High is Light-only and Surface
Container/Low is Dark-only. Their missing twins are absent, not interchangeable.
No spacing/radius/motion variables exist in this scoped Snapshot. Component raw
geometry is not promoted to tokens in this task.

TypographyTokens addresses the three complete English/Baseline/Button-* names
and IDs. Original typography, units and missing tags remain separate from the
Flutter TextStyle. Font weight uses the Snapshot's numeric wght variation when
the scalar fontWeight is missing. Pixel line height is divided by font size;
percentage letter spacing is converted to logical pixels. Outfit font binaries
are not bundled yet; these tests prove data conversion, not rendered fidelity.

AppThemeFactory.build(brightness: ...) exposes ButtonThemeTokens through
ThemeData.extensions. No ColorScheme or TextTheme semantic mapping is inferred.
Consumers read Theme.of(context).extension<ButtonThemeTokens>(); no product
widget or application UI is built here. Unpaired color availability switches
discretely during lerp; only common colors interpolate. The empty app root is
not changed.

The generated report lists all 90 hidden nodes and the five detailed unbound
paint examples. Snapshot lint reports 18 unbound paints but retains only five
examples. Thirteen node IDs/colors cannot be recovered from this source, so the
report records this gap. Matching uses exact raw channels and unit paint opacity;
matches are suggestions only and never become tokens or bindings.

This is DEVELOPMENT data: version control is owner-managed, the technical
version lock is unverified, and neither designer approval nor complete Light/Dark
role parity is claimed.
