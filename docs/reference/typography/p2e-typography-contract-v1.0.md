# P2E Typography Consumption Contract — Proposed v1.0

## Purpose and status

This is a **proposed engineering contract**, not a Figma-approved runtime specification. The preceding registry is a verified source inventory; this document defines how to consume it in Flutter without hard-coding 63 classes or duplicating styles in components.

## Core rule

Select typography by its **full semantic style name** `English/<Muted|Variant|Baseline>/<Role>-<Size>` or generated strongly-typed alias mapping exactly to the Figma Style ID. Never select by fontSize or fontWeight alone. Never collapse equivalent metric values across roles.

Component roots (Button, Badge, TextField, Radio, etc.) resolve their default typography role from a central `ComponentSpec`; a specific screen does not need to repeat font metrics. The same typography registry serves all components. No screen-specific overrides are needed for the general contract.

## Proposed data flow

`Figma exact Style ID/name → versioned TypographyRegistry → TypographyResolver(locale, styleRef, theme) → Flutter TextStyle`.

`styleRef` and Figma ID are immutable references in a snapshot; a code alias may be renamed as long as a migration map preserves the original Figma name. Resolved runtime font measurements belong in Dev Inspector separately from declared Figma metrics.

## Metric conversion

```
fontFamily: Outfit
fontWeight: 400 / 500 / 600
fontSize: fontSizePx
height: lineHeightPx / fontSizePx
letterSpacing: fontSizePx * (letterSpacingPercent / 100)
```

`TextStyle.height` and font rasterization cannot be treated as exact pixel-equivalent to every Figma layout. Respect accessibility TextScaler and perform screenshots across device density, locales, RTL, and mixed scripts. Do not set the input label text style using button-specific font metrics just because both include the word `Button`.

## Registry authority and defaults

- **Verified:** original Figma ID/name and numeric style metrics, exactly as read.
- **Provisional:** fallback for missing/unavailable font, locale-specific typography, rendering corrections, or values awaiting designer decision. Keep defaults in centralized typography foundation, not scattered widgets.
- **Pending:** semantic mapping of `Muted`/`Variant`/`Baseline` to specific color roles; Persian styles; text scale/wrapping rules not designed in Figma.

Any designer change in a base typography role is performed once in the registry and resolves across every standard component. This is **not** an approval for per-instance visual overrides.

## Inspector fields

`elementId`, `componentType`, `typographyRef` (exact style name), `figmaStyleId`, `declaredMetrics` (px / percent), `resolvedTextStyle` (Flutter size/weight/height/letterSpacing), `renderedSize`, `locale`, `directionality`, `sourceStatus` (`verified|provisional|pending`), `sourceLocation` when explicitly registered.

Never copy text field values such as passwords or one-time passcodes into inspector snapshots.

## Suggested acceptance criteria

1. All 63 records addressable by name and immutable Figma ID; no accidental collisions.
2. The Number role returns `letterSpacing == 0` for each of its nine styles.
3. All other 54 styles use computed -4% tracking.
4. Distinct Role labels remain distinct even if the resolved numerical TextStyle objects are equal.
5. Button/Badge/TextField component specs reference central style names; 20 EN screens need not declare raw typography metrics.
6. Debug snapshot displays Figma declared values separately from resolved and measured Flutter values.
7. Typography registry can be updated centrally without changing element IDs or inspector schemas.
8. The Flutter runtime and fonts have not been tested yet; implementation and visual parity are separate upcoming tasks.
