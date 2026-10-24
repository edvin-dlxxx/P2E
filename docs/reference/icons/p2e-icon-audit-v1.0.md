# P2E Icon Registry — Read-only Figma Audit v1.0

Date: 2026-10-19 · Source: Figma file `7PGTHT5CQzbTsWZQnPIQce`, page `14466:873`

## Verified inventory
- **104 unique icon names**, **208 variants** (104 Outline, 104 Fill).
- Figma component sets: Outline `14466:880`; Fill `14466:925`.
- Complete 1-to-1 pairing: **no missing partner** and **no duplicated names** in either set.
- All **208 component root frames are 24 × 24 px**, with exactly one child VECTOR, which remains within the 24px frame.
- All **208 vector fill paints** reference `VariableID:16433:9040` (a single shared Figma variable).
- Geometry comparison via serialized `vectorPaths`: **39 icon pairs have identical path data**, while **65 differ**. Do not assume every Filled/Outline pair has visually distinct shapes.
- No change was made to Figma. This catalog is a snapshot, not a live synchronization service.

## Naming and identity
The JSON retains **original `figmaName` exactly**, and assigns a stable engineering `iconId` in snake_case.
Unusual source names include `Add Larg`, `Arrow Wam Up`, and `Chess Rok`. Their engineering aliases are `add_large`, `arrow_warm_up`, and `chess_rook` respectively; original Figma names remain untouched.

**Material Design 3 compatibility is not independently verified.** The user describes the names as standard M3, but these are the Figma team's actual labels. The catalog is not a verified mapping to Material Symbols codepoints, SDK enum values, or Flutter icons. Exact glyph equivalence needs a separate validation against the selected icon implementation/font.

## Implementation contract (proposed)
- Separate **icon identity** (`iconId`) from **rendering style** (`outlined` / `filled`), **semantic color role**, and **render size**.
- Rendered size is a consumer parameter; the Figma design source has a standard 24px source frame.
- Maintain a single registry. A new icon requires adding an entry (and its style references); do not introduce a new button/textfield widget or modify an element ID.
- Missing styles for future entries should result in an explicit diagnostic/fallback rule; do not silently substitute an unrelated glyph.
- Avoid hardcoding the white Figma fill color in Flutter: vector fill is a bound design paint; component semantic tokens determine runtime color.
- Treat `iconId` as an independent stable identity; do not embed icon name/style in `elementId`.
- New icons can be reconciled by comparing Figma variant names and component IDs against this snapshot.

## Not verified
1. Pixel/shape equivalence to official Material Symbols, and Flutter icon font codepoints.
2. Exported SVG/paths suitable for production (this extraction records component metadata only).
3. All icons' actual usage across every Figma page.
4. Future additions/updates: require subsequent synchronization.
5. Whether typos in source are intentional or planned for rename.

## Next step
Use this registry as the **metadata contract**. Before shipping icons in Flutter, choose actual glyph source (Material Symbols package/asset export) and verify each canonical `iconId` against the intended visual shape and its Fill/Outline alternative.
