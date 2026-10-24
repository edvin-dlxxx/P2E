# Read-only Figma extraction tools

Current output contract: **2.0.0**. Read [the extraction contract](extraction-contract-v2.md)
before collecting data. V2 replaces the unversioned, lossy v1 response.
V2 has not been validated against live Figma; tests use synthetic mocks.

## Consumers and compatibility

Repository searches found no token generator, snapshot assembler or executable
v1 JSON reader. The direct consumer is pack.dart: it concatenates helpers.js
and one script, replacing JSON parameters. It is unchanged and covered by a test
that executes its actual packed output with a mock. All scripts sharing the
helper were migrated together. Inspector schemas in docs/reference describe a
different runtime artifact and are not changed.

The canonical snapshot skill still describes v1 Hex/string examples. It was not
edited in this task. Use the explicit v2 contract for these scripts; external v1
consumers require migration.

## Packing (does not contact Figma)

    dart run tool/figma/pack.dart variables_export '{"nodeIds":["18436:1611"],"variableIds":["16447:59"],"limit":10}'

The optional --out writes packed JavaScript, not snapshot data.
Execute against a read-only Plugin API runner only when separately authorized.

Every response carries schemaVersion 2.0.0. OUTPUT_TOO_LARGE means **no partial
data** was returned. Retry the same offset with a smaller limit/depth or narrower
explicit scope; never advance on an error.

| Script | Parameters | V2 payload |
|---|---|---|
| list_pages | {} | file and page IDs/names |
| variables_export | nodeIds?, variableIds?, offset?, limit=100 | dependency graph, collections, origins and diagnostics |
| text_styles_export | offset?, limit=80 | raw typography/units/bindings |
| component_sets_list | pageId, offset?, limit=100 | paginated sets and standalone components |
| component_set_spec | ids, depth=2, offset?, limit=10 | raw geometry, paints, effects, reactions, bounded children |
| page_inventory | pageId | direct children in document order, raw geometry/background/bindings |
| instance_usage | pageId, frameIds? | component-ID/nesting counts; unresolved diagnostics |
| design_lint | rootId, examples=5, includeInstances? | counters and explicitly limited examples |
| icons_export_svg | setId, offset?, limit=8 | raw geometry and exact API SVG strings |

Node roots must be explicit. Variable roots must share a page; use separate calls
per page and merge by variable ID, unioning provenance. With no node IDs, only
local collection enumeration and optional explicit variable IDs are read.
No implicit document-wide node scan is added.

## Local tests (no connector, network or new dependencies)

    node --test tool/figma/test/extraction.test.cjs

Uses Node's built-in test runner/assertions and local fixtures. Set the DART
environment variable to an existing Dart executable if it differs from
D:/Tools/flutter/bin/cache/dart-sdk/bin/dart.exe. No SDK installation occurs.
The pack integration test runs Dart directly. Mock SVG text is not a production
asset or a real export.

Mock success does not verify API availability, permissions, actual variables,
mode selection, rendering, SVG fidelity or performance.

## Full icon development extraction (D-023)

`icons_inventory.js` records definition identities, set-wide properties and
paint/binding evidence before export. It accepts setId/offset/limit and returns
next until null. `button_icon_links.js` reads nested master links for explicit
Button set IDs. Both are read-only and compatible with the existing packer.
`icons_export_svg.js` was exercised live on the complete 2026-10-20 icon page;
original SVG_STRING responses and full pagination are retained in
`docs/snapshots/2026-10-20_development-icons/evidence`. Eight-item batches that
exceeded OUTPUT_TOO_LARGE were retried at the same offset with four items.

Assembly/check:

    node tool/figma/assemble_icons_snapshot.cjs --check
    node tool/tokens/generate_icons.cjs --check
    node --test tool/figma/test/icons_snapshot.test.cjs

These commands use saved local evidence and do not contact or modify Figma.
Renderer proof comes from `packages/design_system/test/icons/icon_library_test.dart`;
its generated local `build/icon-render-validation.json` was retained unchanged as
the snapshot's validation.json. New source deliveries require a new snapshot.
