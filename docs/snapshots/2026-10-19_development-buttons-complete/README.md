# Buttons design-system extraction

DEVELOPMENT extraction of file `7PGTHT5CQzbTsWZQnPIQce`, page `16433:9027`.
Run started under the 2026-10-19 folder label; assembly/verification completed on 2026-10-20.
Version control is owner-managed; technical version lock is unverified. No designer-approved label is asserted.

## Inventory

- 18 source sets, 90 unique variants: three families, three sizes, five Button values, Light/Dark twins.
- 18 required Variables in three owning collections, all original mode IDs and values; four lookup-only variables resolved.
- Three Outfit text styles and 60 text nodes. Font family/style/variation metadata is preserved; Figma does not expose a font binary/version here.
- 660 node records, including hidden instance descendants; 180 main-component references mapped to three exact exported SVGs.
- 774 variable discovery references retained. No unresolved Variable, main-component, style, alias cycle or missing mode remains in the captured scope.

## Files

| File | Purpose |
|---|---|
| `manifest.json` | Scope, counts, completeness evidence and version limitations |
| `components/*.json` | Source axes, properties, raw geometry, paints, typography and bounded-tree records; depth 8 leaves no boundary in this scope |
| `visual_layout.json` | Parent/child IDs, actual hierarchy, clipping, text alignment, original labels, boolean property references and main-component links |
| `variables.json` | Scoped values, collections, all provenance, diagnostics and explicit lookup-only resolutions |
| `text_styles.json` | Three source styles, original units and explicit missing fields |
| `icons.json`, `icons/fill/`, `icons/outline/` | Exact source icon exports and every instance reference |
| `variant-index.csv` | Human-readable index of all 90 variants and their visible source icon IDs |
| `lint.json` | Full lists for the 18 unbound paints and 90 hidden nodes |
| `component_sets.json` | Matching before/after inventory reads; this is not a technical version lock |
| `raw/`, `calls.json`, `raw-inputs.sha256.json` | Exact returned text, MCP wrappers, executed requests, failed oversized responses and SHA-256 hashes |
| `EXTRACTION-CONTRACT.md` | V2 compatibility and explicitly versioned extraction addenda |
| `CHANGES.md` | Differences from the previous Buttons extraction and implementation implications |

## Offline assembly and verification

From repository root (Node built-ins only; no Figma call):

```
node tool/figma/assemble_buttons_snapshot.cjs
node tool/figma/assemble_buttons_snapshot.cjs --check
node --test tool/figma/test/extraction.test.cjs tool/figma/test/buttons_snapshot.test.cjs
```

Assembly only writes this new extraction directory. Existing Snapshot, tokens, Flutter, canonical rules, skills and registers are unchanged. No full-system LATEST pointer was updated.

## Reading the source correctly

Source surface heights are 36/46/56. Declared vertical padding is not permission to enlarge those surfaces in extracted data. Actual child locations and text bounds remain authoritative source facts. Accessible hit targets belong to implementation and are separate from the colored surface.

Text-bearing Buttons use Fill/Edit Square by default. Icon-only Buttons use Fill/Crown. The hidden Outline instances reference Edit Square, including in the icon-only family. Preserve that source distinction; do not silently replace Crown or invent an Outline/Crown counterpart.

The 18 unbound paints are the component-set wrapper strokes, not Button variant borders. All 18 raw paints are now listed. The 90 hidden nodes are Outline instances; they and their descendants were extracted rather than discarded.

This package certifies data coverage of the declared scope. It does not certify the current Flutter widget as visually equivalent.
