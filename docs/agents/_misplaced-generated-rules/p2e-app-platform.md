---
trigger: glob
description: "Rules for the app composition root and platform layer in lib/app (bootstrap, router, shell, platform). Apply when editing lib/app."
globs: "lib/app/**"
---
<!-- GENERATED from docs/agents/rules/app-platform.md by tool/agents/sync_agent_files.dart. Do not edit; edit the source. -->

# App and platform

- iOS and Android behave the same. Only `lib/app/platform` may inspect the platform, and only for an approved entry in
  `docs/agents/registers/platform-exceptions.md`. Mark code with `// PLATFORM(PE-###): reason`.
- Approved now: PE-001 scroll physics (iOS bounce, Android stretch), PE-002 system back (Android back/predictive back,
  iOS edge-swipe back). Page transitions are one shared transition on both platforms.
- Set page transitions (`PageTransitionsTheme`, same builder for every platform) and scroll behavior (`ScrollBehavior`, PE-001)
  once in `MaterialApp`. Per-platform behavior built into Flutter widgets (text selection handles, context menu, keyboard)
  is accepted; if one changes look or motion in a way the owner would notice, propose a PE entry instead of patching it.
- `MaterialApp.router` sets `theme`, `darkTheme`, `themeMode` (System default, user choice from `shared/preferences`),
  locale (OS locale on first launch, then the user's choice; `supportedLocales = [en]` until Persian ships) and a text
  scaler clamped to 1.3×.
- Orientation: phones portrait-only; tablets (Medium/Expanded) portrait and landscape.
- `lib/main.dart` is the release entrypoint and never imports `lib/dev`. `lib/main_dev.dart` wraps the same app with the Inspector.
