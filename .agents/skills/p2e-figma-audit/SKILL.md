---
name: p2e-figma-audit
description: Verify the claims in a P2E design document, registry, spec or bundle (md, csv, json, zip) against the live Figma design system, strictly read-only, and report discrepancies with severity. Use when the owner shares or mentions a design-system document (UI identity contract, typography, icon or color registry, component foundation spec, decision CSV) and asks to check, verify, audit or compare it with Figma, or asks whether a document is still up to date.
---

# Audit a design document against Figma

Read-only. Never run Figma tools or scripts that write (see AGENTS.md rule 1).

## Inputs
- The document(s). Unzip bundles; list every file.
- Figma file key and node ids from `docs/agents/figma-map.md`.

## Steps
1. **Extract claims.** Build a table: claim id, file + line, claim (number, name, node id, size, token, status), how to verify.
   Include internal-consistency claims (spec vs its CSV, totals vs rows, file names vs versions).
2. **Plan checks.** Group claims by Figma area so each call answers many claims. Prefer the scripts in `tool/figma/`:
   | Need | Script |
   |---|---|
   | pages, ids | `list_pages.js` |
   | screens, Light/Dark usage | `page_inventory.js` |
   | color variables | `variables_export.js` |
   | text styles | `text_styles_export.js` |
   | sets, axes, props | `component_sets_list.js` |
   | variant sizes, paddings, fills, children | `component_set_spec.js` |
   | instance counts | `instance_usage.js` |
   | unstyled text, unbound colors, hidden layers | `design_lint.js` |
   How to call: see `tool/figma/README.md`. Without `use_figma`, fall back to `get_metadata`, `get_variable_defs`,
   `get_design_context`, `get_screenshot`.
3. **Run and record.** Keep raw outputs in a scratch folder (not committed). Paginate when output nears 20 KB.
4. **Compare.** Mark each claim: ✅ match · ❌ mismatch (give Figma value) · ⚠️ not verifiable (say why) · ℹ️ document silent on
   something Figma has.
5. **Judge severity** for every ❌ and ℹ️: high (wrong code would ship / blocks a stage), medium (rework or confusion),
   low (cosmetic, naming).
6. **Report** with `references/report-template.md`. Offer register entries (errata, designer requests) through
   `p2e-design-registers`; do not write them without the owner's OK.

## Gotchas (learned on this file)
- Counts only reproduce with hidden layers included (`figma.skipInvisibleInstanceChildren = false`, set in helpers).
- Count nested instances separately from top-level ones; documents usually mean one of them, say which.
- Match by node / set id, not by layer name: names contain typos (`Therme`, `Samll Badge`, `Countainer`).
- Light/Dark are separate component sets and separate variable collections, not modes.
- Do not round: report Figma values as they are (e.g. 36 vs 36.5).
- A document may be newer than the Figma copy. If Figma looks outdated, say so instead of calling the document wrong.

## Output
Persian report to the owner (technical terms in English): outcome first, findings table with severity and effect,
verified-unchanged list, not-verified list, and the sentence that all Figma access was read-only.
