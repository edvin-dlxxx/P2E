# Auth Entry source snapshot — 2026-10-23

New scoped development snapshot of four explicitly requested EN frames, captured read-only from the Figma Copy. No designer named version/approval is available; none is claimed. Existing snapshots under docs/snapshots are immutable and unchanged. No global LATEST is introduced or token generator redirected.

Complete scope:402x874 idle, focused-empty, phone and email. Raw metadata, variable definitions, high-fidelity design context and screenshots are retained per frame; frames.json normalizes child rects into screen coordinates while preserving raw local/page positions. Variables are the resolved definitions returned by get_variable_defs, not a claim of raw binding IDs or complete palette enumeration. Keyboard/status-bar assets in design context describe OS artwork and are not product widgets.

Verified source facts:20 form/bonus/CTA,24 heading/social/legal,32 divider insets; keyboard begins at543 and CTA ends at523; hero Background is relative y=-55,height264. Enabled CTA uses Sky/500 #00a6f4 and On Surface/Emphasis. Brand tile definitions are Blue/700 #1447e6,Green/600 #00a63e and Alpha/White; legal links are Sky/500. Welcome bonus remains visible in keyboard states. Hero/remember/divider/social/legal are absent there. Light/Persian source is unavailable. Figma label 'Playstation' differs from the owner-authorized official spelling 'PlayStation'.

Implementation is stopped at the explicitly requested architecture gate; see docs/reports/auth-entry/preflight.md. No token, DS, feature or fake backend implementation is included in this snapshot.
