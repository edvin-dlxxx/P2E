# P2E UI Identity & Inspection Contract — Changes in v1.1

**Date:** 2026-10-19  
**Source:** read-only verification of Figma Copy `7PGTHT5CQzbTsWZQnPIQce` and reconciliation of original v1.0 bundle.  
**Machine schema versions remain `1.0.0`**, because the JSON data contract has not been changed.

| Area | v1.0 issue | v1.1 correction |
|---|---|---|
| `DEC-004` Badge Variables | 10 IDs reported lookup-only and absent from enumerations | Flagged as **not reproduced** in Copy; **12/12** variant-bound IDs in `getVariableByIdAsync`, local enumeration, and collection `variableIds` (282 locals); 14 IDs including Set backgrounds. Original/Copy mismatch remains hypothesis, not established cause. |
| `DEC-012` Radio reactions | No verified Radio motion documented | 8 variants each with one Reaction; 4 hover `SMART_ANIMATE`/`EASE_OUT`/`0.3s`; 4 click reactions with `null` transitions. Selected-hover click switches back to Not Selected; prototype behavior needs product sign-off. |
| Theme coverage | Password/OTP Light behavior underqualified | General Text has Dark+Light; Password and OTP only Dark sets in inspected Design System page. Light is `designer-pending`. |
| State coverage | Success/Edit missing in test matrix | General/Password/OTP Success; OTP Edit included in test and mapping notes. |
| Badge raw variant axis | `Button` left unexplained | `Button` recognized as raw Figma axis, mapped to `appearance` in semantic catalog. |
| Small Badge typography | Risk not flagged | Small text `8px/10px` recorded and A11y review required. |
| Button geometry | Radius generalization inaccurate | Small text and Fill 10px; Small Icon 12px; all Medium/Large 12px. |
| EN button usage | Consumer coverage not explicit | 43 instances across 5 of 18 sets; no Large in EN; warns against extrapolation. |
| Runtime Locator | Table included `elementId` inside locator and omitted `routeName` | Matched schema: `identity.elementId`, `runtimeLocator={routeName, routeInstanceId, entityKey?, slotPath?}`. |
| `structureRef` | `default` in table, `base` in example | Canonical `text-field.general.base` until explicit migration. |
| Traceability | Earlier audit statements mixed with fresh evidence | Added evidence ledger and `figma_evidence_v1.1.json` containing fileKey, nodes, API methods, date, and limitations. |

## Bundled content

- `P2E_UI_Identity_and_Inspection_Contract_v1.1.md` — revised human-readable contract
- `figma_evidence_v1.1.json` — read-only inspection results and provenance
- `p2e-ui-inspector-snapshot.schema.json` / `.example.json` — **unchanged from original**, v1.0.0
- `p2e-ui-fix-request.schema.json` / `.example.json` — **unchanged from original**, v1.0.0

No Figma file changes, Flutter implementation, or API changes were made.
