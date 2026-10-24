# Text Field System — DEVELOPMENT snapshot

Read-only live Figma extraction, file `7PGTHT5CQzbTsWZQnPIQce`, page
`18563:6534`. No named version ID or designer approval was available. This is
development evidence, not a published or approved design release.

| Family | Sets | Variants | Source themes |
|---|---:|---:|---|
| Base TextField | 2 | 10 | Dark, Light |
| Password | 1 | 10 | Dark |
| OTP cell | 1 | 6 | Dark |
| Radio | 2 | 8 | Dark, Light |
| Total | 6 | 34 | |

`evidence/page-inventory.json` enumerates the page. Each complete variant tree
retains geometry, layout, paints, bindings, effects, text styles, component links,
visibility and scoped reactions. `foundations.json` holds 29 resolved variables
and seven text styles. Both complete OTP consumer trees retain the actual divider
after the first cell, cell spacing and padding. Manifest hashes bind this evidence.

Four representative source nodes were additionally inspected with read-only
design context and screenshots: 18562:5888, 18675:14659, 16481:5006, 16481:3473.
No Figma nodes or variables were changed. Source text in evidence is synthetic
design copy; runtime entered text is never collected by Inspector.

`fields.json` and the shared generated Dart table are reproducibly assembled by
`node tool/tokens/generate_fields.cjs`. `--check` verifies bytes without rewriting
source outputs. Runtime motion defaults are a separate authored input at
`design/engineering/field_motion.json`; only Radio hover timing is extracted.

Theme gaps E-008 and indicator normalization E-013 remain explicit. The 16 Light
Password/OTP derivatives are runtime previews, not additional source variants.
