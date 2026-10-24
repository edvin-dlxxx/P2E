# Extraction contract 2.0.0

This versions the **tool response**, not the Inspector runtime schema, Dart token
API or a delivered snapshot. There is no snapshot assembler/generator in the
repository yet. Local tests produce no real Figma snapshot.

## Envelope and raw values

Every script returns JSON text with schemaVersion "2.0.0". Check the version and
error before reading payloads. V1 was unversioned; formatted strings and compact
row fields are not raw v2 data. No lossy v1 adapter is supplied. The existing
pack.dart consumer still concatenates helpers and one script without interpreting
their returned JSON; its actual packed result is exercised in the mock tests.

Raw numbers retain the JavaScript Number returned by the API and JSON.stringify.
No intentional rounding is applied. This does not promise decimal/arbitrary
precision beyond the API and JavaScript. Only display.hex quantizes to 8-bit
channels; it must never feed generation.

| Source value | Representation |
|---|---|
| numeric/scalar/object/array | same value, recursively serialized |
| undefined/unsupported property | {"$state":"missing"} |
| figma.mixed | {"$state":"mixed"} |
| typography AUTO | original {"unit":"AUTO"}, with no invented numeric height |
| explicit null | null, distinct from missing |
| failed reference lookup | {"$state":"unresolved","kind":...,"id":...,"error"?:...} |
| nonfinite number | {"$state":"non-finite","value":"NaN"} (or infinity string) |
| negative zero | {"$state":"negative-zero"} |

$state is reserved. Unknown symbol/function/BigInt values fail explicitly.
Object keys are sorted with code-unit comparison, independent of locale.
Ordered document children, paint layers and reaction arrays retain API order.

Paint fields contain {raw, display}. Raw paints retain original RGB(A), independent
paint opacity, visibility, gradients/transforms and original bound aliases/IDs.
Hidden paints remain. Bindings are not replaced by resolved names or values.
Effects and reactions remain raw structures instead of formatted summaries/counts.

Geometry includes dimensions, constraints (including zero), padding/gap,
cornerRadius/per-corner radii, stroke settings and transforms. Typography retains
family/style, size, original line-height/letter-spacing value AND unit and style
ID. Missing/mixed metrics stay explicit. No default fonts, style matching, semantic
roles or behavior decisions are inferred.

## Variable graph and explicit scope

Parameters: nodeIds, variableIds, offset, limit, include.

1. Seed IDs listed by all local collections and explicit variable IDs.
2. Bare explicit IDs such as 16447:59 normalize to VariableID:16447:59.
   Original spellings remain in provenance and scope.inputVariableIds.
3. Inspect only explicit node subtrees, including hidden/nested instance children.
   Alias references in boundVariables, paints, effects, grids and component
   properties are collected, including arrays and all property paths. TEXT nodes
   also expose styled-range bindings/paints through getStyledTextSegments;
   provenance records start/end ranges. Characters are intentionally omitted.
   Unsupported/throwing range APIs are reported and prevent complete:true.
4. No nodes are scanned by default. DOCUMENT roots are rejected. Multiple roots
   must share a page, switched at most once per call. Unresolved roots/collections
   are reported. Node IDs, normalized explicit IDs and policy remain in scope.
5. Recursively follow aliases in EVERY valuesByMode entry, deduplicating by ID,
   never by name. Same-name variables remain distinct.
6. Preserve aliases, raw values and mode IDs. Never guess cross-collection mode
   correspondence. Collections include original mode IDs/names.
7. Each discovered ID has exactly one available or unresolved record. Unresolved
   records contain no invented values; available records expose valuesByMode
   keyed by original mode ID and missingModeIds.

Each record retains all distinct origin references, deterministically ordered:

| kind | source fields |
|---|---|
| enumeration | collectionId |
| node-binding | rootId, nodeId, propertyPath array including indices |
| alias | variableId (source), modeId, propertyPath |
| explicit-lookup | inputId (original spelling) |

Diagnostics are separate: lookupOnlyIds lists available variables absent from
local enumeration; unresolvedReferences retains failed variable lookups and every
origin; unresolvedScope contains failed roots/collections. Missing declared mode
values are explicit in missingModeIds, never synthesized.

aliasCycles records deterministic DFS back-edge paths in the **union dependency
graph across modes**. This is a conservative reference diagnostic, not proof of
a cycle under any particular runtime mode selection. Original values/provenance
retain each edge's source mode. No runtime mode resolution is attempted.

complete means no observed unresolved references/scope/collections, missing
declared modes or reference cycles within the requested scope. It does not mean
all response pages have been downloaded or that the whole file was inspected.

## Pagination, deterministic ordering and completeness

Variable records sort by ID before slicing; unresolved records take normal slots.
total/offset/next refer to that deduplicated list. Limit must be a positive safe
integer; offset must be a nonnegative safe integer <= total. Every successful
response retains total, offset, next and complete, including metadata-only calls.
Collect all vars through next:null.

The optional include array selects vars, collections and/or diagnostics. For
backward compatibility the default includes all three. Use include:["vars"] for
variable pages so full collection variableIds and diagnostics cannot block every
page through fixed response overhead. Fetch include:["collections"] and
include:["diagnostics"] separately with the same scope. Omitted parts are absent,
not empty or successfully downloaded. Unknown part names fail explicitly.

Metadata-only calls retain the variable-list pagination counters; those counters
do not paginate collection IDs or diagnostics. A collection or diagnostic part
that alone exceeds the output cap still returns OUTPUT_TOO_LARGE. This targeted
selection fix makes vars fetchable independently; it does not add metadata
continuations or silently truncate metadata.

When merging scopes, union records/provenance by ID and retain every diagnostic.
Conflicting raw values for one ID are source changes, never last-write-wins.
Discovery repeats each call: no cross-call transaction isolation is available.
Keep the approved source version frozen; the future assembler must validate the
source version and consistency. Matching counts alone do not prove stability.

Oversized responses return ONLY schemaVersion/error/bytes/hint; no partial page
or successful cursor is returned. UTF-8 bytes are counted. Retry the same offset
with smaller limit/depth. For variables, first select only the needed part using
include. If that part or a single record remains too large, narrowing node scope
may help; local collection enumeration is not narrowed by nodeIds. Collection
metadata and diagnostics have no independent continuation yet.

Component trees are depth-bounded; childrenNotExpanded marks a boundary with
remaining descendants. Those trees are not exhaustive coverage claims. Variable
binding traversal scans full explicit subtrees independently of tree display
depth. Foundation extraction intentionally omits text contents; lint examples use
IDs/metadata, not input text. Authorized SVG exports retain exact API strings.

## V1 migration

| script | V2 replacement |
|---|---|
| variables_export | full row names, raw mode-ID values, status/provenance; include selects independent response parts |
| text_styles_export | styles[].typography/bindings instead of metric strings/resolved names |
| component_sets_list | paginated entries (kind set/component), original property keys; no 150-item cap |
| component_set_spec | rows[].geometry/fills/strokes/effects/reactions/bindings/children |
| page_inventory | frames[].geometry/background/bindings instead of rounded dimensions |
| icons_export_svg | icons[].geometry replaces rounded w/h; SVG unchanged |
| instance_usage | structured component-ID/nesting counts and unresolved diagnostics |
| design_lint | structured raw examples, total counters and explicit exampleLimit |
| list_pages | original file/pages plus schemaVersion |

README and local tests are maintained direct consumers. Canonical rules and skills
were left untouched; their v1 output examples are historical, not parsers for v2.
External readers must migrate explicitly before use. Inspector JSON schemas are
unrelated and unchanged.

## Verification boundary

Synthetic tests cover the four configurable Button ID fixtures, ordinary variables,
recursive aliases/modes/cycles, unresolved references, provenance, paging, raw
paints/metrics and deterministic order. They do not verify the real design,
availability or real coverage of Plugin API methods/text ranges, fonts,
actual mode behavior, access permissions, SVG fidelity, source version or live
performance. Scoped traversal is limited to declared node properties; an API
surface not exposed there requires a separately specified extraction extension.
