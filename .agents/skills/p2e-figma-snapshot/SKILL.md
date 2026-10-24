---
name: p2e-figma-snapshot
description: Export a versioned, read-only snapshot of the P2E Figma design system (color variables, text styles, Outline and Fill icon SVGs, component-set specs, screen inventory, design lint), diff it against the previous snapshot and report what changed. Use when the designer publishes a new Figma version, before generating or regenerating tokens, icons or Inspector specs, or when the owner asks what changed in Figma.
---

# Figma snapshot

Read-only. The snapshot is the only input for token, icon and spec generation (D-008).

## Output layout
```
design/figma/
  LATEST                      # name of the newest snapshot folder
  <YYYY-MM-DD>_<version-label>/
    manifest.json             # fileKey, version label, date, counts per area, script versions
    variables.json            # collections + variables (all modes), sorted by collection, name
    text_styles.json
    components/<set-slug>.json  # one file per component set (variants, axes, layout, tokens, children)
    screens.json              # page_inventory of the EN page (and future FA / tablet pages)
    usage.json                # instance_usage of the EN page
    icons/outline/<icon_id>.svg
    icons/fill/<icon_id>.svg
    icons.json                # icon_id, raw Figma name, node ids (outline/fill), size
    lint.json                 # design_lint per page
    CHANGES.md                # diff vs previous snapshot
```
Pretty-print JSON (2 spaces), sort keys and arrays by name so git diffs stay readable.

## Steps
1. Confirm the file key (`docs/agents/figma-map.md`) and the designer's version label. If the file is still the "(Copy)",
   say so in the manifest.
2. Run the scripts from `tool/figma/` (call pattern in `tool/figma/README.md`):
   - `variables_export.js` with `offset` 0, 100, 200 … until `next` is null (expect 282 today).
   - `text_styles_export.js` (expect 63).
   - `component_sets_list.js` for each Design System and Components page; then `component_set_spec.js` per set,
     `limit` 6–10, `depth` 2–3, until `next` is null.
   - `page_inventory.js`, `instance_usage.js`, `design_lint.js` for the EN page.
   - `icons_export_svg.js` for `Outline` and `Fill`, `limit` 8, until `next` is null (expect 104 + 104).
3. Write the files. Icon id = snake_case of the variant value (`Icon=Attach File Add` → `attach_file_add`). Keep SVGs as
   exported; only strip ids/metadata. Check that both styles have the same 104 ids.
4. Diff against the folder named in `LATEST`: added / removed / renamed (same node id, new name) / changed values for
   variables, styles, variants (size, padding, radius, fills, children), icons (path changes), screens.
5. Lint and pairing checks: unstyled texts, unbound solid colors, hidden layers inside components, a Dark set without a Light
   twin (and vice versa), a variable present in only one of the Light/Dark collections, odd names.
6. Write `CHANGES.md`: a Persian summary for the owner first (what changed, what breaks, severity), then the English detail.
   Update `LATEST`.
7. Propose errata and designer requests via `p2e-design-registers`. Then, if approved, regenerate tokens / icons / specs
   with the generators in `tool/tokens/` (built in the tokens stage). Never patch generated Dart by hand.

## Gotchas
- Output limit is about 20 KB per call; scripts return `OUTPUT_TOO_LARGE` instead of truncating. Lower `limit` / `depth`.
- Variables are single-mode; values are hex (`#rrggbb` or `#rrggbbaa`) or `alias:<name>`.
- Text style `lineHeight` / `letterSpacing` carry units (`px`, `%`, `auto`); keep them.
- Never commit a partial snapshot. If a step fails, delete the folder and rerun.
