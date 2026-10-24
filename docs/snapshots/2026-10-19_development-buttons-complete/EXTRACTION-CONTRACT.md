# Buttons extraction contract

## Existing kit schema

This scoped package keeps the installed Snapshot layout and extraction response schema `2.0.0`. Component records retain the existing `set`, `variants`, `geometry`, `{raw,display}` paints, text style/segment and binding structures. Mode IDs, aliases, raw Figma names and Variable IDs remain source values. No semantic token role, behavioral state or runtime geometry is inferred.

Raw numeric channels and opacity remain separate; display Hex is not a generation source. Missing/mixed/unresolved values retain the kit's `$state` encoding. Child order, paint order and reaction order are preserved. This does not promise precision beyond the API and JavaScript Number.

## Addendum: `button-visual-layout/1.0.0`

`visual_layout.json` supplements, rather than replaces, component schema v2. Its `variants[]` has `variantId` and flat `nodes[]`. Each node carries `id`, `parentId`, ordered `childIds`, raw name/type, visibility, clipping and component property references. TEXT nodes also carry original source characters, horizontal/vertical alignment and resizing/truncation fields. INSTANCE nodes retain component properties and exact `mainComponent` identity, owning set and raw variant properties.

Geometry remains in `components/*.json`, joined by node ID. Node coordinates are relative to their actual parent, never treated as relative to a flattened variant. Source text is design specimen text, not production localization. Unsupported fields stay explicitly missing. No text baseline value is invented.

## Addendum: scoped Variable graph and provenance `1.0.0`

The unchanged v2 tool can return `OUTPUT_TOO_LARGE` even for a small page when one shared Variable has many discovery origins. This run encountered that defect. It never advanced an unsuccessful cursor.

Captured requests named `scoped_variable_values` and `scoped_variable_provenance` reuse the existing graph discovery, raw serialization, alias traversal and diagnostics. The supplementary producer selects node-bound and explicit IDs plus recursive alias dependencies. It emits values separately from origin records, so origins do not make a single value record unpageable.

- `scoped-variable-graph/1.0.0`: scoped `vars`, original collection metadata, diagnostics, `complete` and declared `provenanceTotal`.
- `scoped-variable-provenance/1.0.0`: paginated `{variableId, origin}` records with `total`, `offset`, `next`; pages hold at most 50 references.
- Batch envelopes contain independent serialized pages. Each page still obeys the existing 19,000-byte cap. Batching does not truncate a record or silently change a cursor.
- The assembler checks every origin page and declared total, deduplicates no data away, and restores `vars[].provenance` in `variables.json`.
- Collection `variableIds` retain full original metadata. `includedVariableIds` names only the delivered dependency closure. Raw global enumeration included 286 discovered IDs; normalized output includes the 18 needed by Buttons.

No existing extraction script or its v2 contract was modified. The exact executed addendum producers are in raw request JSON. Do not assume the old token/spec generators consume `visual_layout.json`; a future implementation change must explicitly use its source hierarchy and alignment.

## Asset and completeness rules

SVG strings are saved byte-for-byte as returned by Figma `SVG_STRING`, with their own SHA-256. These are three main-component exports required by this scope, not all icon styles in the design system. Per-instance paint bindings remain in component data; master SVG default color does not override them.

Completeness requires inventory counts and exact variant IDs to agree; all component/layout/origin page chains to end at `next:null`; no duplicate IDs, unexpanded descendants or broken parent/child links; all referenced Variables, modes, styles and main-component SVGs to exist. Data completeness is separate from file-version consistency and visual-equivalence approval.

Raw text blocks are compared byte-for-byte with the stored MCP wrapper text. Raw response/request files are hashed individually and as an aggregate index. Failed oversized attempts are retained in the call log and excluded from assembled data. Before/after inventory equality is recorded without asserting a technical version lock.
