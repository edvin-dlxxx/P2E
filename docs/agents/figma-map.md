# Figma map — P2E Design System

Read-only reference for agents. Verified read-only on the date below; re-verify with `tool/figma/` scripts before relying on counts.

- **File key:** `7PGTHT5CQzbTsWZQnPIQce` — "P2E Platform - Design System (Copy)".
  ⚠️ This is a copy. Replace the key with the designer's master file when access is granted (designer request R-005).
- **Last verified:** 2026-10-19 (Figma MCP, read-only).
- Designs are iPhone-framed, 402 dp wide. No tablet frames, no Persian typography and no Persian screens yet.

## Pages
| Page | Id |
|---|---|
| -> Icons | `14466:873` |
| -> Special Logos | `14526:1461` |
| -> Flags | `16479:289` |
| -> Images | `18517:1282` |
| ⚓︎ ios Components (status bar, keyboards incl. FA, numpad) | `14433:12` |
| - Button System | `16433:9027` |
| - Badge System | `16433:9139` |
| - Text Field System | `18563:6534` |
| - App Bar | `18422:12211` |
| - Navigator Bar | `18422:11091` |
| - Games | `18448:10024` |
| EN (20 screens) | `16458:11` |
| -> Logo (empty) | `18419:7103` |

## Component sets
Light/Dark are separate sets (`… - Dark Mode` / `… - Light Mode`), not variable modes.

**Button System** — 18 sets × 5 variants. Axis `Button` = Filled / Tonal / Outlined / Text / …; props `Label` (text),
`Icon`, `Fill Icon`, `Outline Icon` (booleans).
| Size | Fill Button (Dark / Light) | Button (Dark / Light) | Icon Button (Dark / Light) |
|---|---|---|---|
| Small | `18436:1611` / `18436:1642` | `18436:1673` / `18436:1704` | `18436:1735` / `18436:1756` |
| Medium | `18437:1809` / `18437:1840` | `18437:1871` / `18437:1902` | `18437:1933` / `18437:1954` |
| Large | `18437:2005` / `18437:2036` | `18437:2067` / `18437:2098` | `18437:2129` / `18437:2150` |

**Badge System** — Small `16448:1663` / `16448:1712`, Medium `18437:2201` / `18437:2232`, Large `18437:2275` / `18437:2306` (Dark / Light, 5 variants each).

**Text Field System**
| Set | Dark | Light |
|---|---|---|
| Base Text Field (5) | `18562:5887` | `18563:6565` |
| Base Password Field (10) | `18675:14621` | **missing** (E-008) |
| OTP Field (6) | `16481:3382` | **missing** (E-008) |
| Radio Button (4) | `16481:4815` | `16481:5017` |

**Components**
| Set | Id | Variants |
|---|---|---|
| App Bar Container (axis named "Therme") | `18422:12447` | 5 |
| Vertical Navigation Item - Dark | `18422:11155` | 2 |
| Vertical Navigation Item - Light | `18422:11443` | 2 |
| Navigator Bar Container | `18422:11475` | 2 |
| Game Compact Card | `18457:14096` | 4 |
| Games Expand Card | `18457:14486` | 2 |
| Event and Offer Card | `18526:11872` | 2 |
| Comment | `18526:11914` | 2 |

**Icons** — `Outline` `14466:880`, `Fill` `14466:925`; 104 variants each, named `Icon=<Title Case Name>`, 24×24, bound to `Alpha/White`.
Only 28 of the 104 icons are used in the EN screens.

## Variables (all single-mode, no aliases)
| Collection | Count | Role |
|---|---|---|
| ----- Color Palette ----- | 242 | primitives |
| ----- ⏾ - Dark Mode ----- | 14 | semantic, dark |
| ----- ☀︎ - Light Mode ----- | 14 | semantic, light |
| Base Color | 2 | base (e.g. `Alpha/White`) |
| ----- Supportin Colors ----- | 10 | supporting (name typo, E-007) |

## Text styles
63 local styles, all Outfit, English only: `English/Muted/*` (21), `English/Variant/*` (21), `English/Baseline/*` (21).

## EN screens (`16458:11`)
- 12 frames for Authentication / Login (phone, OTP, email, password, forgot, create password): **Dark only** (R-001).
- Home Page and Game (Downloadable): Dark, Dark (Expand), Light, Light (Expand).
- "(Expand)" frames show the full scroll length of the same screen.

## Reading gotchas
- Counts include hidden layers: scripts set `figma.skipInvisibleInstanceChildren = false`.
- Call `page.loadAsync()` before reading a page (dynamic page loading).
- Resolve bound variables with `figma.variables.getVariableByIdAsync`; colors on nodes are `#hex@Variable/Name`.
- Identify components by main component / set id, not by layer name (names contain typos and duplicates).
- `use_figma` output is capped near 20 KB: paginate with `offset` / `limit`.
- `get_design_context` returns web (React/Tailwind) code: use it for values and structure only; never paste it.
