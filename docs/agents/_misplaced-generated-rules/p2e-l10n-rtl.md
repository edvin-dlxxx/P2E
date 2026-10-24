---
trigger: glob
description: "Localization and RTL rules for all Dart code and ARB files. Apply when editing any Dart file under lib or anything in l10n."
globs: "lib/**/*.dart, l10n/**"
---
<!-- GENERATED from docs/agents/rules/l10n-rtl.md by tool/agents/sync_agent_files.dart. Do not edit; edit the source. -->

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
