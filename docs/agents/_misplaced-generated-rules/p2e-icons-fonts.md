---
trigger: glob
description: "Rules for icon SVG assets, the AppIcon registry and bundled fonts. Apply when editing assets/icons, assets/fonts or lib/ui/icons."
globs: "assets/icons/**, assets/fonts/**, lib/ui/icons/**"
---
<!-- GENERATED from docs/agents/rules/icons-fonts.md by tool/agents/sync_agent_files.dart. Do not edit; edit the source. -->

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
