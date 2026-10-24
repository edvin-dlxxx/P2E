---
id: p2e-l10n-rtl
description: Localization and RTL rules for all Dart code and ARB files. Apply when editing any Dart file under lib or anything in l10n.
globs:
  - "lib/**/*.dart"
  - "l10n/**"
  - "packages/design_system/lib/**/*.dart"
  - "apps/design_system_viewer/lib/**/*.dart"
  - "apps/design_system_viewer/l10n/**"
---
# Localization and RTL

- English ships first, Persian later. Code must already be correct in RTL: directional APIs only
  (`EdgeInsetsDirectional`, `AlignmentDirectional`, `BorderRadiusDirectional`, `PositionedDirectional`, `TextAlign.start/end`).
- Physical left/right only with `// PHYSICAL: reason` (charts, media controls, sliders with a fixed physical meaning).
- Directional icons (arrows, chevrons, back/forward) mirror in RTL. The mirroring flag lives in the icon registry, not at call sites.
- No hard-coded user-visible strings. Add keys to `l10n/app_en.arb` with a description; `app_fa.arb` is added when Persian starts.
- Locale: first launch uses the OS locale; the user can change it on the first-launch language picker and in settings.
  Until Persian ships, `supportedLocales = [en]`.
- Dates, numbers and money go through `lib/shared/formatting` and `lib/shared/money` (Jalali and Persian digits for `fa`).
- Fonts: Outfit for Latin; Vazirmatn is bundled now as the provisional Persian fallback so Persian user text renders the same
  on iOS and Android.

## D-019 / D-020 migration

Apply to both new package/app Dart trees. Viewer ARBs live in apps/design_system_viewer/l10n; no dev strings belong in runtime.

## D-037–D-042 Entry foundation

D-041 supersedes OS-first/en-only locale guidance: product defaults provisionally to fa, with en available through generated ARBs. No picker/preferences screen yet. D-044 supports product text through 2.0; App Bar text and Navigator labels alone use chromeTextScaleCap=1.3. PageScaffold inherits scale. Bootstrap exposes neutral wrapper/provider-override hooks, unused by production main. Optional host tools are isolated under removable dev_tools/; no app, package, pubspec, workspace or CI reference is allowed. D-019 retains the independent Viewer. No product main_dev or Inspector is authorized.
