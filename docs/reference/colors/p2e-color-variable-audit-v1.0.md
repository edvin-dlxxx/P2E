# P2E Color Variables — Technical Inventory v1.0

**Source:** Read-only Figma Plugin API, file `7PGTHT5CQzbTsWZQnPIQce`, 2026-10-19.  
**Status:** Variable **inventory verified**, color palette and semantic roles **not designer-approved**.

## Counts

| Collection | Variable count | Context |
|---|---:|---|
| `----- Color Palette -----` | 242 | 22 hue families, 11 levels each (50–950), basic primitive scale |
| `----- ⏾ - Dark Mode -----` | 14 | Candidate surface/outline/on-surface roles |
| `----- ☀︎ - Light Mode -----` | 14 | Matching names, separate Figma variable IDs |
| `Base Color` | 2 | `Alpha/Black`, `Alpha/White` (both alpha=1) |
| `----- Supportin Colors -----` | 10 | 5 `Primary/*` and 5 `Countainer/*` colors |
| **Total** | **282** | All variable values present; no alias values found |

## Technical findings

1. **Light/Dark are separate Collections, not two modes of one Collection.** Each of the five Collections has one mode called `Mode 1`.
2. **No aliases are used** in the recorded 282 values. The observed semantic names cannot be treated as a formally approved mapping to the 242 primitives without independent designer decisions or use evidence.
3. The Figma source uses **22 families × 11 levels = 242 primitive colors**. Matching source names and RGB values does not certify official palette status; these are current file contents.
4. **All values have alpha=1**. This does not mean all component paints are opaque: paint opacity and variable alpha are distinct.
5. **Source spelling retained:** `Supportin Colors` and `Countainer/*` are as authored. They should not be silently renamed in evidence. A future stable Flutter token registry may map spelling aliases centrally.
6. **Exact variable IDs included** in JSON and CSV; `figmaVariableId` is reference metadata, not a stable cross-file API key.
7. **No design approval claim.** This report is a technical baseline. A designer may adjust theme semantics, select primary brand colors, or revise contrast without changing UI element IDs or component structure.

## Architecture decision — provisional

- Keep raw **primitive palette**, **theme roles**, and **component-specific semantic mappings** in separate layers.
- Do not import all 242 primitives as public component parameters; expose semantic color roles on components and leave primitive scales as implementation references.
- A component's `colorRole` is logical and theme-aware; the concrete Hex is resolved by a theme resolver and reported by Dev Inspector along with origin (`figma-variable`, `engineering-default`, etc.) and approval status.
- Adding or revising a color at the central token/theme level should update all normal consumers. Exception-specific local override policies are out of scope.
- **No blanket interpretation** that `Primary/Pink` is the application's approved global primary; this is a literal Figma Variable name only.
- Similarly, **do not assume** palette variable `Neutral/800` is directly aliased to Dark `Surface Container/High`, despite matching Hex values.

## Exact examples

| Figma name | Source collection | Color | Qualification |
|---|---|---|---|
| `Neutral/900` | Color Palette | `#171717` | Observed primitive |
| `Surface Container/Base` | Dark | `#171717` | Observed semantic-name candidate |
| `Surface Container/Base` | Light | `#F5F5F5` | Observed semantic-name candidate |
| `On Surface/Base` | Dark | `#A1A1A1` | Observed semantic-name candidate |
| `On Surface/Base` | Light | `#525252` | Observed semantic-name candidate |
| `Primary/Pink` | Supporting Colors | `#83244D` | Observed source name; not approved brand primary |

## Caveats and next steps

- This is **complete for the currently enumerable local 282 color variables**. It does not include non-variable paint literals used elsewhere on the canvas.
- Connect component color bindings (Button, Badge, Text Field) to exact IDs in this registry; that can establish **actual usage**, but not final designer intent.
- Keep accessibility contrast and future brand-color choices as separate review tasks, without mutating this read-only evidence snapshot.
- Do not mark `Design Specification Final` until the designer approves semantic role mappings and theme behavior.
