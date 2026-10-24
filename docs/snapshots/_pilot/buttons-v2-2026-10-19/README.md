# Buttons v2 read-only pilot — 2026-10-19

Pilot evidence only. This is not a delivered snapshot; no LATEST or snapshot manifest was created.

- Source: Figma file 7PGTHT5CQzbTsWZQnPIQce; Button System page 16433:9027.
- Scope: all local collection enumeration plus variable bindings in the explicit Button page subtree; no explicit Variable IDs supplied. Component specs: the 18 mapped Button sets, depth 2.
- A targeted optional include parameter was added to variables_export. Defaults preserve existing v2 behavior; variables, collections and diagnostics can be requested independently. Metadata does not have its own continuation.
- Local test command: node --test tool/figma/test/extraction.test.cjs. Result: 25 passed, 0 failed, 0 skipped, including one new oversized-collections test.

## Observed results

- list_pages: 25 file pages, 2 calls (one initial save failure and one saved retry).
- variables_export: 31 calls = 25 successful variable pages + 2 successful metadata calls + 4 OUTPUT_TOO_LARGE responses. All 286 unique records downloaded through next:null. Every successful response reported complete:true. Five collections downloaded separately.
- component_set_spec: 91 calls = 90 successful single-variant pages + 1 OUTPUT_TOO_LARGE response. All 90 unique variants in 18 sets downloaded through next:null. This script has no complete field; cursor coverage is verified separately.
- Total real Figma calls: 124. Saved responses: 123, including all 5 OUTPUT_TOO_LARGE responses.
- No unresolved variable references, unresolved scope, alias cycles or missing variable modes observed. Four lookup-only IDs: 16447:43, 16447:46, 16447:59, 16447:60.
- All 60 exported TEXT nodes returned segment arrays. No unresolved component values or text-segment API errors were observed.
- Geometry retained API fractions (for example width 16.66666603088379); no extra precision is claimed. Negative-zero and unsupported-property tags occurred and were retained as designed.

## Output pressure and limitations

OUTPUT_TOO_LARGE: variable offset/limit 0/20 (26948 bytes), 20/10 (66047), 27/5 (25827), 27/2 (19906); component offset/limit 0/2 (19487). Retrying smaller pages succeeded. Variable provenance reached 127 origins for one record; mock tests did not predict the real pagination cost. There is no automatic page-size adaptation, metadata continuation, or single-record splitting. The real metadata fit in this pilot; the synthetic test covers metadata exceeding the cap.

Component tree depth is explicitly bounded at 2; 0 exported nodes mark childrenNotExpanded. This is not an exhaustive subtree spec. Variable discovery independently scanned the explicit subtree. No pinned source version, transaction isolation, SVG fidelity, other design-system pages, runtime mode resolution, or design correctness was verified. Repeated enumeration is performed on each variable request; matching counts do not establish that the live file stayed unchanged.

## Raw preservation and storage exception

Each saved call has the exact packed request JS, request JSON, serialized MCP wrapper and each returned text block as response-N.txt. The text files have no added newline or formatting; 123 text blocks were read back and matched exactly against their stored MCP wrapper content. Calls and derived summary are separate files.

The initial list_pages response could not be retained after a temporary PTY writer failed to acknowledge storage. It was repeated and saved as 002-list_pages. Call 001 is explicitly marked unpersisted; it is not represented as preserved raw evidence. The temporary writer was stopped. No other raw response was lost.

No Figma document edits, Dart/tokens/assets, Flutter/dependency/SDK changes, canonical rule/skill/register changes or commits were made. Hashes of 43 protected repository files matched the pre-change baseline.

