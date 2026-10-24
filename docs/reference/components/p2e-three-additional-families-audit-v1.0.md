# P2E — Three Additional Figma Families: Read-only Evidence v1.0

**Date:** 2026-10-19 · **Source:** `7PGTHT5CQzbTsWZQnPIQce` · **Status:** `TECHNICAL BASELINE, NOT FINAL DESIGN SPEC`  
**Method:** Figma Plugin API inspection of three named pages, component sets, variants, top-level layout geometry, selected bound variables, text style identities and text metrics, nested `mainComponent` links; direct screenshot comparison of master designs. EN cross-check for linked instances (20 screens). No write, no executable motion playback, and no exhaustive interaction/accessibility test.

## Coverage and references

| Page | Link | Set(s) | Variants |
|---|---|---|---:|
| App Bar | https://www.figma.com/design/7PGTHT5CQzbTsWZQnPIQce/?node-id=18422-12211 | `18422:12447` | 5 |
| Navigator Bar | https://www.figma.com/design/7PGTHT5CQzbTsWZQnPIQce/?node-id=18422-11091 | `18422:11155`, `18422:11443`, `18422:11475` | 2+2+2 = 6 |
| Games | https://www.figma.com/design/7PGTHT5CQzbTsWZQnPIQce/?node-id=18448-10024 | `18457:14096`, `18457:14486`, `18526:11872`, `18526:11914` | 4+2+2+2 = 10 |

**Total:** 8 Component Sets / 21 Component Variants. Names and IDs are original Figma and must not be silently normalized when representing evidence.

## 1. App Bar

Set `18422:12447`, axis original spelled **`Therme`** (not `Theme`).

| Variant | Component ID | Parent size | Observed major children |
|---|---|---|---|
| `Home - Dark` | `18422:12446` | 402×64 | avatar48, empty flexible area, wallet212, trailing48 |
| `Home- Light` | `18422:12445` | 402×64 | as above |
| `Downloadable Game - Dark` | `18517:6274` | 402×64 | leading48, space, two action48, avatar48 |
| `Downloadable Game - Light` | `18533:6918` | 402×64 | as above |
| `Back - Dark` | `18618:13169` | 402×64 | leading48, space, help48 |

Root layout is `HORIZONTAL`, padding L/R16, clip true, height64. Home wallet Points Count uses official `English/Baseline/Number-Large` (Outfit600 16/20 tracking0) and `English/Muted/Label-Small` (Outfit400 14/18 tracking−4%). Avatar letter Outfit600 16/20 tracking−5% with no Text Style ID. App Bar page has **10 TEXT nodes: 6 style-linked, 4 unstyled**. Nested icons are real instances of the Icon Library.

**Not verified:** safe-area policy, scale, wallet actions, Back Light, navigation action, icon action callback, animations, loading, accessible tap bounds, long-value overflow.

## 2. Navigator Bar

| Set | ID | Variants | Geometry |
|---|---|---|---|
| Vertical Navigation Item — Dark | `18422:11155` | `Default`,`Active` | root80×68, padding top/bottom8, gap4; Indicator64×32 radius16 |
| Vertical Navigation Item — Light | `18422:11443` | `Default`,`Active` | as above |
| Navigator Bar Container | `18422:11475` | `Dark`,`Light` | root402×68, padding L/R6, five 78×68 child instances |

Default appears Outline icon, Active appears Fill icon; Active indicator background is bound in Dark to `VariableID:16429:162`, Light to `VariableID:18436:689`. The preview shows Home, Mission, Games, Leaderboard, Shop; badge-like numeric bubbles on Mission and Shop. Exposed Item props include label text, badge label, badge boolean and state. **No instances of Badge System Base are linked** in the inspected Navigation master instances; do not conclude identical structure to base Badge.

All **28 Navigator TEXT nodes** have empty Text Style ID. Their observed Outfit font metrics: destination 12/15 weight600 tracking0; numeric count 10/10 weight700 tracking0. Thus *even though* the 63-style Registry is complete, Navigation currently requires a **provisional component-level typography value**, not a fake official style binding.

**Not verified:** tap/press behavior, route guard, safe area, accessibility, animation, text scaling, 5-item limit or behavior with a different item count.

## 3. Games

| Set | ID | Actual Variants | Verified root geometry |
|---|---|---|---|
| Game Compact Card | `18457:14096` | `Detailed - Dark`, `Detailed - Light`, `Dark`, `Light` | 120×204 detailed; 120×178 minimal; image120×120 radius16, gap8 |
| Games Expand Card | `18457:14486` | `Dark`, `Light` | root370×226; inner image/container radius16 |
| Event and Offer Card | `18526:11872` | `Default`, `Light` | root370×270, Banner370×160, Details370×110 padding14, gap4 |
| Comment | `18526:11914` | `Dark`, `Light` | root338×190, Header48, Rate/Date34, Body108 |

**Composition evidence:** Expanded Card contains an instance of `Small Button - Dark Mode` (`18436:1680`) or Light (`18436:1711`), nested Star and Icon sources. Compact Card uses game artwork, reward and rating visuals. Event Offer uses reward visual plus text; Comment uses menu Outline icon and five Star/Star Half glyphs. The visual appearance of a badge does **not** prove a link to the 30-variant Badge System.

**Typography evidence:** Game name & event title = `English/Baseline/Title-Small` 18/24/600. Creator `English/Baseline/Label-Small` 14/18/600. Rating `English/Baseline/Number-Medium` 14/18/600 tracking0. Description and Comment Body `English/Muted/Body-Medium` 14/18/400. Comment Author `English/Baseline/Label-Medium` 16/20/600; Date `English/Baseline/Number-Medium` 14/18/600.

**Mismatch observed:** Event Offer reward numeric text style differs by theme (Dark Default uses `English/Baseline/Number-Medium` 14/18; Light uses `English/Baseline/Number-Small` 12/14). This is a source discrepancy, *not a decision to apply separate font sizes in Flutter*. In-app purchase hint and Comment Avatar have no official Style ID.

**Not verified:** responsive image sizes and aspect ratio scaling, dynamic text layout, content overflow, tap destinations, full Image Asset exports, gradient/complex paint export, long data and localization, motion, accessibility, program state.

## 4. EN screen connected consumer check (scope = 20 EN screens)

- App Bar `mainComponent` mapping finds **16 direct instances** (not on first four Login/Auth Screens); it includes 8 `Back-Dark` use instances and 8 Home/Game variant instances.
- Navigator: **8 container instances**, each containing **5 nested navigation items** = **40 Item Instance appearances** (48 matching instances if nesting is counted). Do not report 48 as 48 standalone bars.
- Games: **88 linked component instances** from the 10 Games variants across these screens. Includes Compact, Expanded, Event Offer and Comment; counts are appearance counts, not number of unique games.

The reference EN screen set is primarily duplicates of Dark/Light and expanded/unexpanded states; it is not an independent exhaustive functional application test. Detatched or visually similar Frames are excluded from linked component numbers.

## 5. Correct interpretation and constraints

- Figma width402 vs Flutter width is **sample geometry**, not a breakpoint contract.
- The screens and component sets are unfinished: unrepresented variants and platform states remain `designer-pending` or `unverified` rather than implicitly not supported.
- `ComponentSet` names and inconsistent axes such as `Therme`, `Home- Light`, and `Default` are evidence names, not API vocabulary.
- Typography binding can be missing even when visual metrics are explicit. Preserve those facts and do not silently claim official Registry linkage.
- Color variables are real source metadata, but palette & Semantic Role **not yet designer-approved**.
- This targeted review does **not** claim a motion or Figma Prototype test for these three pages.
- No Figma changes occurred.
