---
name: p2e-build-screen
description: Build or update a P2E app screen in lib/features from a Figma frame on the EN page, using only Design System components, shared widgets and tokens, with Light/Dark, RTL, size-class and loading/empty/error/offline states handled. Use when implementing any screen, page or flow (authentication, login, OTP, home, game detail, wallet, missions) or when asked to make a screen match Figma.
---

# Build a screen from Figma

Status of this skill: v0.9 draft. Refine it after the pilot screen "Login with Email - Dark".

## Steps
1. **Find the frames** in `docs/agents/figma-map.md` / `screens.json`: Dark and Light versions and the "(Expand)" frame for full
   scroll content. A missing theme → note it (R-001), build from tokens, mark provisional.
2. **Read the design.** `get_screenshot` for the visual, `get_metadata` / `component_set_spec.js` / `instance_usage.js` for structure.
   `get_design_context` returns web code: use its values and structure only.
3. **Map every element** to a `lib/ui` component, a `lib/shared/widgets` widget or a layout widget. Write the mapping in the PR.
   Anything unmapped → stop and propose a component (contract first). Never hand-style inside the feature.
4. **Layout.** `PageScaffold` / `SafeArea`; spacing tokens; directional APIs; scroll behaviour from the app (PE-001).
   Compact first. Medium/Expanded: max content width and `AdaptiveGrid` only.
5. **Strings** into `l10n/app_en.arb` with descriptions. No literals in widgets.
6. **States.** Loading, empty, error, offline and success. Use `lib/ui/patterns`; missing designs → provisional + R-009.
7. **State and routing** per Architecture v1.3 (Riverpod providers in the feature, routes via `app/router`).
8. **Verify.** Run on `main_dev.dart`; compare with the Figma screenshot in both themes; Inspector check on every component;
   Compact1.0/2.0 × en/fa × Light/Dark; content scrolls and never clips (D-044).
9. **Tests.** Widget tests for each state. No full-screen goldens.
10. **Report** to the owner in Persian: screenshots vs Figma, differences with severity, provisional parts, register entries.
