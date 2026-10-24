# <AppComponent> contract

- **Status:** final | provisional
- **Figma sets:** Dark `<id>` · Light `<id>` (snapshot `<folder>`)
- **Dart:** `lib/ui/components/<file>.dart`

## API
| Parameter | Type | Values / default | Figma source |
|---|---|---|---|
| type | `AppXType` | filled, tonal, outlined, text | axis `Button` |
| size | `AppXSize` | small, medium, large | set family |
| label | `String` | required | prop `Label` |
| leadingIcon | `AppIconId?` | null | prop `Icon` |

## Valid combinations
| type \ size | small | medium | large |
|---|---|---|---|
| filled | ✓ | ✓ | ✓ |

## Anatomy
container → [leadingIcon?] → label → [trailingIcon?]

## Measurements
| Size | min height | padding s/t/e/b | gap | radius | icon |
|---|---|---|---|---|---|

## Tokens (theme × variant × state)
| Variant | State | Part | Dark (Figma → token) | Light (Figma → token) |
|---|---|---|---|---|

## Typography
| Slot | Style |
|---|---|

## States
| State | In Figma? | Rule | Status |
|---|---|---|---|

## Behavior and accessibility
touch target, semantics, focus, RTL, overflow, text scale2.0×; named fixed chrome cap1.3 (D-044)

## Open questions
- …

## Inspector spec
```json
{"component": "AppX", "figma": {"dark": "<id>", "light": "<id>"}, "variants": []}
```
