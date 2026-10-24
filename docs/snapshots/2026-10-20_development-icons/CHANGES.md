# Development icon extraction — 2026-10-20

Scope: complete Figma page 14466:873, read-only MCP, file
7PGTHT5CQzbTsWZQnPIQce. The live page contains exactly the Outline (14466:880)
and Fill (14466:925) sets, each with 104 component definitions. There are no
additional sets, standalone icon definitions or preview instances on the page.

Compared with the prior completed Button snapshot, runtime coverage expands
from the scoped Edit Square pair to all 104 concepts / 208 artwork versions.
The old snapshot and original exports are preserved. Stable existing naming
corrections are matched by explicit source node IDs and checked against live
variant names; pairs are not joined by position or visual similarity.

All original SVG_STRING exports are retained unchanged. Inventory and export
pagination are checked for gaps, totals, duplicates and a final null next value.
Some export batches were reduced from eight to four after OUTPUT_TOO_LARGE;
the rejected offsets were retried and were never skipped.

All exports contain SVG/path only; no masks, clipping, gradients, embedded images
or other complex feature cases occur. Every SVG is monochrome white, bound to
Alpha/White where recorded. Original color remains the renderer default.
All 208 versions pass decode, raster paint/nonempty pixels and shared-widget
rendering. No SVG derivation or optimizer was required.

E-012 records the icon-only source mismatch: visible Fill uses Crown; the
hidden Outline child uses Edit Square. This is retained explicitly.
The Buttons board remains 90 source variants. Icon-only none remains invalid;
localized explanations replace only that preview, without adding fake variants.

Version label/version ID/designer approval and redistribution license are
unavailable. This is a development extraction, not a published or approved
library. No commit, external package publication or Figma mutation was made.

Reproduce from saved read-only evidence:

    node tool/figma/assemble_icons_snapshot.cjs --check
    node tool/tokens/generate_icons.cjs --check
    node --test tool/figma/test/icons_snapshot.test.cjs

For a later source revision, collect a NEW snapshot, using icons_inventory.js
then icons_export_svg.js via the existing pack/MCP workflow. Iterate each
response's next until null and respect output-size errors. Do not overwrite this
snapshot with a later Figma revision. See tool/figma/README.md.
