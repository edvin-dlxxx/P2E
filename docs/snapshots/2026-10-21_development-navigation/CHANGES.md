# Navigator Bar DEVELOPMENT snapshot — 2026-10-21

خوانش Figma کاملاً read-only بود. دو نوار منبع Dark/Light و چهار حالت داخلی
Default/Active جداگانه ثبت شدند. شدت کم: typography فاقد Text Style ID است؛
مقادیر واقعی با وضعیت provisional نگه داشته شدند. هیچ طراحی تغییر نکرد.

First executable snapshot of this family. Counts agree with the scoped baseline:
two bar variants and four item states, never six bar variants. Three inventory
pages (one set per response) were consumed through next:null. Bar root metadata
and each of their ten complete item-instance subtrees are separate evidence
files joined by exact node IDs; four complete item masters are also retained.
All responses parsed as complete JSON; the generator rejects missing source
children, duplicate/missing inventory pages and missing icon counterparts.

Four actual consumers link the correct Dark/Light bar masters, content68 and
separate Home Slider12. The latter is device artwork, not a runtime safe inset.
Source paints, instance properties, overrides, hidden badges, geometry, clipping
and empty reactions are retained. All bound color variables resolve. All label
and badge text styles are unlinked; no official text-style identity is fabricated.
The five source icon concepts map to exact existing library master IDs; all ten
original Fill/Outline SVG versions are present, nonempty and hash-verified.

No named version ID or designer approval was available. This scoped DEVELOPMENT
snapshot does not replace the unrelated global token source or mutate older
snapshots. Runtime/spec outputs are generated from this evidence with
`node tool/tokens/generate_navigation.cjs`; --check verifies saved outputs.
Existing read-only packing supports navigation_export with explicit nodeId and
optional shallow:true for bar roots. Full descendants are the default.
D-031 and design/engineering/navigation.json own responsive/interaction policy;
these are not Figma selection animation evidence. No new golden baselines.
