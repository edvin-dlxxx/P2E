# P2E Typography Audit v1.0

**Date:** 2026-10-19  
**Source:** Figma direct read-only Plugin API (`getLocalTextStylesAsync` + TEXT subtree inventory)  
**File:** `7PGTHT5CQzbTsWZQnPIQce`  
**Status:** Verified local-style catalog + scoped usage evidence; **not** an approved Flutter implementation specification.

## Executive findings

- **63/63 Figma local text styles** enumerated, exact names and IDs preserved, no duplicates.
- Three namespaces: `English/Muted` (21, Outfit Regular 400), `English/Variant` (21, Outfit Medium 500), `English/Baseline` (21, Outfit SemiBold 600).
- Each namespace has seven roles (`Headline`, `Title`, `Body`, `Label`, `Button`, `Status`, `Number`) × three sizes (`Large`, `Medium`, `Small`).
- All styles use `lineHeight` in **PIXELS**, `letterSpacing` in **PERCENT**; **Number=0%**, all other roles **−4%**. Figma style typography does not inherently define its text color.
- No local Persian-language text style exists in this inventory. This does **not** prove other external/library styles or future Persian styles are absent.
- In audited scope (Button, Badge, Text Field masters and 20 EN screens), **25 unique style IDs** are used; **38 local styles were not observed in this scope**. This is *not* a whole-file usage audit.

## Scope and usage validation

| Surface | Text nodes | Style-linked | Unstyled or mixed | Notes |
|---|---:|---:|---:|---|
| Button masters (`16433:9027`) | 60 | 60 | 0 | Three `English/Baseline/Button-*` styles, 20 each |
| Badge masters (`16433:9139`) | 30 | 30 | 0 | Three `English/Baseline/Status-*` styles, 10 each |
| Text Field page (`18563:6534`) | 120 | 120 | 0 | Seven distinct styles; includes Radio Button and OTP |
| EN (`16458:11`, 20 screens) | 1853 | 1085 | 768 | Three mixed-style nodes counted in unstyled/mixed |
| **Total checked** | **2063** | **1295** | **768** | Counts include texts in nested instances |

**Interpretation of EN data:** A considerable share of the 768 unstyled/mixed text nodes appears inside mock iOS status bars, keyboard components and other nested visuals. This is not automatically a typography violation. The audit groups by **style ID** and screen. Individual EN overrides and mixed-segment details require targeted follow-up; one existing earlier Text Field audit documented an unstyled changed `Written Text` sample. Do not infer that this single sample accounts for all 768 nodes.

## Typography ramp (each of the three weights)

| Role | Large (size/line) | Medium | Small | Tracking |
|---|---|---|---|---|
| Headline | 32/40 | 28/36 | 24/30 | −4% |
| Title | 22/28 | 20/26 | 18/24 | −4% |
| Body | 16/20 | 14/18 | 12/14 | −4% |
| Label | 20/24 | 16/20 | 14/18 | −4% |
| Button | 20/24 | 16/20 | 14/18 | −4% |
| Status | 12/14 | 10/12 | 8/10 | −4% |
| Number | 16/20 | 14/18 | 12/14 | **0%** |

The resulting 21 ramp entries are reproduced for all three namespaces/weights. For each, **the Style ID remains distinct even when numeric metrics coincide**, e.g. `Label-Small` and `Button-Small`.

## Exact observed cross-component mapping

- Button master → `English/Baseline/Button-Small|Medium|Large` (Outfit 600).
- Badge master → `English/Baseline/Status-Small|Medium|Large` (Outfit 600).
- Text Field default label → `English/Variant/Button-Medium` (Outfit 500); focused label and helper → `English/Variant/Label-Small` (Outfit 500); input text → `English/Baseline/Title-Small` (Outfit 600). Some roles use Muted styles.
- Radio is a separate component family despite sharing the Text Field Figma page.

## Risks and open items

1. **Do not merge identical numerical styles.** Role-specific ID and semantic name remain distinct.
2. **Tracking conversion:** `letterSpacingPx = fontSizePx × letterSpacingPercent / 100`. A −4% tracking at 16 px = −0.64 px. In Flutter this maps to `TextStyle.letterSpacing` with a derived pixel value; check font rendering in QA.
3. **Font line height:** `TextStyle.height = FigmaLineHeightPx / fontSizePx` is a starting point, not a guarantee of pixel-perfect glyph bounds. Font metrics, TextScaler, leading and locale must be tested.
4. **Style namespace != color role.** Do not derive a color automatically from `Muted`, `Variant`, or `Baseline` until Color Token mappings have been audited.
5. **Language coverage:** only `English/*` local Style paths are present. RTL/Persian font family and metrics require their own future design decision and platform rendering tests.
6. **Scope:** this records 63 local styles and usage in four named Figma pages; not a claim that every remote style/whole-file node is covered.
7. **Usage map:** CSV is aggregated by Style ID per screen or master page; does not reproduce PII-bearing example content from the Figma design.

## Artifacts

- `p2e-typography-registry-v1.0.json`: machine-readable authoritative local-style inventory.
- `p2e-typography-registry-v1.0.csv`: tabular projection for human QA.
- `p2e-typography-usage-map-v1.0.csv`: style usage by Button, Badge, Text Field and 20 EN screens.
- `p2e-typography-extraction-summary-v1.0.json`: coverage metrics.
- `p2e-typography-contract-v1.0.md`: proposed Flutter consumption rules, separate from verified Figma evidence.
