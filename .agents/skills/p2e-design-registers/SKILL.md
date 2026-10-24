---
name: p2e-design-registers
description: Add, update or supersede entries in the P2E project registers in docs/agents/registers - decisions (D-###), Figma errata (E-###), designer requests (R-###), overrides (O-###) and iOS/Android platform exceptions (PE-###) - and link them to code annotations. Use whenever a design or architecture decision is made or changed, a Figma inconsistency is found, something must be requested from the designer, a raw value must bypass tokens, or code must differ between iOS and Android.
---

# Project registers

Files: `docs/agents/registers/{decisions,errata,designer-requests,overrides,platform-exceptions}.md`.

## Rules
- Ids are sequential per file (`D-019` after `D-018`). Never reuse or renumber.
- Never delete an entry. To change a decision, add a new one and set the old status to `superseded by D-###`.
- Dates are ISO (`YYYY-MM-DD`). One table row per entry; keep cells short and link node ids, files or PRs.
- Owner approval is required for decisions, overrides and platform exceptions. Propose first, write after approval.
  Errata and designer requests may be added directly and reported.

## Code links
- Override: `// OVERRIDE(O-012): <reason>` on the line with the raw value.
- Platform exception: `// PLATFORM(PE-003): <reason>` in `lib/app/platform` only.
- Physical direction: `// PHYSICAL: <reason>` (no register entry needed).
- CI (planned) fails on annotations without a register entry and on entries without code.

## When an entry changes the rules
If a decision changes something in `AGENTS.md`, `docs/agents/rules/*` or a skill, update that file in the same change and run
`dart run tool/agents/sync_agent_files.dart`.

## Report
Tell the owner in Persian which entries were added or changed, why, and their severity.
