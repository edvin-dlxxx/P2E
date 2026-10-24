# Reference reports

Baseline reports about the Figma file `7PGTHT5CQzbTsWZQnPIQce` (read-only, taken 2026-10-19).
They are **evidence and proposals, not decisions**. For the order of authority see "Source of truth" in `AGENTS.md`.

- Open only the folder that matches your task. Do not read everything.
- Values for code generation come from the Figma snapshot (`design/figma/LATEST`), not from these files (D-008).
  Use these reports to cross-check counts and names. A mismatch goes to `docs/agents/registers/errata.md`.
- A conflict with `decisions.md`, Addendum v1.4 or Architecture v1.3 is not yours to resolve. Follow them and log the conflict.
- Large JSON files: query with `jq` or `grep`. Do not read them whole. Prefer the CSV.
- Raw Figma names stay as authored (typos included). Dart names use the corrected ids from the registries.

## Contents

| Folder | Files | What it is | Status | Open it when |
|---|---|---|---|---|
| `identity/` | `P2E_UI_Identity_and_Inspection_Contract_v1.1.md`, `CHANGELOG_v1.1.md`, `figma_evidence_v1.1.json`, `p2e-ui-inspector-snapshot.schema.json` + `.example.json`, `p2e-ui-fix-request.schema.json` + `.example.json` | `ElementIdentity`, element ids, Inspector snapshot and fix-request formats | v1.1 supersedes v1.0. Identity v1.1 adopted by D-032; D-033/D-034/D-035 define scope, slots and structured metadata. | Building `ElementIdentity`, the Dev Inspector, or a fix request |
| `components/` | `P2E_Component_Foundation_Specification_v1.0.md`, `p2e-component-foundation-decision-register-v1.0.csv`, `p2e-three-additional-families-audit-v1.0.md` | Component families, variant axes, anatomy, open questions | Technical baseline. Open questions are not approved. | Writing a component contract or building a `lib/ui` widget |
| `typography/` | `p2e-typography-contract-v1.0.md`, `p2e-typography-audit-v1.0.md`, `p2e-typography-registry-v1.0.csv` + `.json`, `p2e-typography-usage-map-v1.0.csv`, `p2e-typography-extraction-summary-v1.0.json` | 63 text styles (Outfit), where each is used | Registry verified. Contract is **proposed**. Persian pending (R-003). | Generating text tokens, or choosing a text style for a component or screen |
| `icons/` | `p2e-icon-audit-v1.0.md`, `p2e-icon-registry-v1.0.csv` + `.json` | 104 icons × Outline/Fill (208 variants), `icon_id`, node ids | Metadata only. Material Design 3 match **not verified**. No SVGs here. | Exporting icons, building `AppIcon`, adding an icon |
| `colors/` | `p2e-color-variable-audit-v1.0.md`, `p2e-color-variable-registry-v1.0.csv` + `.json` | 282 color variables in 5 collections | Inventory verified. Palette and semantic roles **not designer-approved**. | Generating color tokens or the theme |

## Which file for which task

| Task | Start with |
|---|---|
| Tokens (colors, text, icons) | `colors/` audit, `typography/` contract, `icons/` audit, then the CSVs |
| New or changed Design System component | `components/` specification, then `identity/` contract |
| `ElementIdentity` / Inspector / fix request | `identity/` contract, schemas and examples |
| Building a screen | `typography/` usage map, `components/` specification |
| Adding or finding an icon | `icons/` registry CSV |

## Facts to keep in mind

- **Colors:** Light and Dark are separate collections, each with one mode. There are no aliases.
  `Primary/Pink` is a literal Figma name, not an approved brand primary. Equal hex values do not prove a palette-to-role mapping.
  Source spellings `Supportin Colors` and `Countainer/*` are kept in evidence.
- **Icons:** 39 Outline/Fill pairs share identical paths, 65 differ. A missing style is an explicit diagnostic, never a silent substitute.
  Source typos map to ids, for example `Add Larg` → `add_large`, `Arrow Wam Up` → `arrow_warm_up`, `Chess Rok` → `chess_rook`.
- **Typography:** select by full name `English/<Muted|Variant|Baseline>/<Role>-<Size>`. Never by size or weight alone.
  `height = lineHeightPx / fontSizePx`, `letterSpacing = fontSizePx × percent / 100`.
- **Counts to verify after every snapshot:** 282 variables, 63 text styles, 104 + 104 icons.

## Adding a new report

Put it in the matching folder, add a row to the table above with its status, and say what it supersedes.
Never keep two versions of the same report side by side.
