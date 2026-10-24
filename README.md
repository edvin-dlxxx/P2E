# MyGame P2E

The product Flutter app remains at the repository root. It currently boots a neutral root without product screens.

- Reusable library: packages/design_system (p2e_design_system).
- Independent Gallery and verification app: apps/design_system_viewer (p2e_design_system_viewer).
- Both consumers use a local path dependency and import package:p2e_design_system/design_system.dart. Neither imports src implementation files.
- Windows is a Debug-only viewer runner; it does not add Windows support to the product.

## Toolchain

Flutter 3.47.7 / Dart 3.13.x, pinned in .fvmrc. Do not upgrade SDKs as part of setup.

Run flutter pub get, flutter analyze --no-pub and flutter test --no-pub independently in the root and each package/app.
Run generators and their --check modes from the repository root:

    dart tool/tokens/generate_buttons.dart --check
    dart tool/tokens/generate_button_spec.dart --check
    dart tool/tokens/generate_button_icons.dart --check
    dart tool/tokens/generate_motion_defaults.dart --check
    dart tool/dev/generate_viewer_localizations.dart --check
    dart tool/dev/generate_viewer_catalog.dart --check
    dart tool/dev/generate_button_examples.dart --check
    dart tool/check_architecture.dart
    dart tool/agents/sync_agent_files.dart --check

From apps/design_system_viewer:

    flutter run -d windows --debug -t lib/main.dart

Text buttons default to ButtonIconMode.none. Fill/outline require a real AppIcon input and are independent of Filled/Tonal/Outlined/Text/Disabled appearance and Fill-width layout. All original icon SVGs from the complete development snapshot are bundled in the shared package. Button previews follow the actual master links (Edit Square for text; Crown Fill / Edit Square Outline for icon-only, E-012).

Fonts and licenses live in the package assets and use Flutter package namespaces. Geometry tests load the real bundled fonts. Source snapshots are immutable. Size checks are separate from visual/artwork approval; the existing source fixed-height/padding conflict remains provisional. No golden baseline is approved by this migration.

The Viewer has English/Persian UI, six tabs (Buttons and Icons populated; other tabs are explicit placeholders), combined filters and a physical-left desktop inspector. Gallery and verification share the Buttons board. Icons adds key/source/localized search, style/size/surface/tint previews and actual registry metadata. Shared press motion is engineering-defined (D-021); reduced animation preferences are respected.

Full icon reproduction/checks (from repository root):

    node tool/figma/assemble_icons_snapshot.cjs --check
    node tool/tokens/generate_icons.cjs --check
    node tool/dev/generate_icon_strings.cjs --check
    node --test tool/figma/test/icons_snapshot.test.cjs

Use `AssetAppIcon(AppIconId.crown, style: AppIconStyle.outline, size: 24)` from
`package:p2e_design_system/design_system.dart`. Original paint is default;
`color`/`useThemeColor` opt into monochrome tint. Decorative is default; a localized
semanticLabel labels a standalone icon. A Button owns the control label itself.
`AppIconRegistry.byKey('icon.crown')` returns explicit available style versions
and source/asset metadata. Unknown keys/styles throw MissingIconArtwork.
