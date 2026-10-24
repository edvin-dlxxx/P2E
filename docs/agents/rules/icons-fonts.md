---
id: p2e-icons-fonts
description: Rules for icon SVG assets, the AppIcon registry and bundled fonts. Apply when editing assets/icons, assets/fonts or lib/ui/icons.
globs:
  - "assets/icons/**"
  - "assets/fonts/**"
  - "lib/ui/icons/**"
  - "packages/design_system/assets/**"
  - "packages/design_system/lib/src/icons/**"
---
# Icons and fonts

- Source of icons: the Figma "Icons" page, sets "Outline" and "Fill" (104 icons each, 24×24). Export them with the
  `p2e-figma-snapshot` skill; never draw, edit or download icons from elsewhere.
- Layout: `assets/icons/system/outline/<icon_id>.svg` and `assets/icons/system/fill/<icon_id>.svg`.
  `icon_id` = snake_case of the Figma variant value (`Icon=Attach File Add` → `attach_file_add`).
- Do not hand-edit SVG paths. Allowed normalization: strip ids/metadata, keep `viewBox="0 0 24 24"`. Color is applied at runtime
  by `AppIcon`, so the export's own fill color is irrelevant.
- `AppIconId` (generated enum) + `AppIcon(AppIconId id, {AppIconStyle style = outline, double? size from tokens, String? semanticLabel})`.
  The registry stores `rawFigmaName`, `outlineAsset`, `fillAsset` and `mirrorInRtl`.
- Both styles must exist for every id; a missing twin is an erratum.
- Fonts live in `assets/fonts/` and are declared in `pubspec.yaml`. Check licenses (Outfit and Vazirmatn are OFL).
  No `google_fonts` runtime fetching.

## D-019 / D-020 migration

Runtime fonts and scoped source SVGs live in packages/design_system/assets with licenses. Only the existing Edit Square pair is included for the current task; do not extract the full library. Assets use package resolution.

## D-023 full icon library (supersedes the scoped-pair restriction above)

The owner authorizes complete read-only icon extraction and size/color/semantics
parameters on the existing AppIcon API. Inventory actual definitions and styles;
do not assume historical counts or force pairs. Preserve original exported SVGs
byte-for-byte, including IDs/metadata, and hash them. Do not strip features or
flatten multicolor artwork. Default renderer paint is original; requested tint
applies only to verified monochrome SVGs. Missing styles are explicit diagnostics.
No license is established for the Figma icon artwork; font licenses are separate.
Use the full registry in the existing package, shared by both consumers.
