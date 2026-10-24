# App Bar DEVELOPMENT snapshot — 2026-10-20

خوانش Figma فقط read-only بود. پنج واریانت منبع در سه دسته استخراج شد؛
شدت محدودیت متوسط: Back Light وجود ندارد. متن آواتار فاقد Text Style ID
است و با اندازه‌های واقعی، provisional باقی می‌ماند. هیچ طراحی تغییر نکرد.

First implementation snapshot for this scoped family; no previous executable
App Bar snapshot to diff. Baseline report counts agree (one set, five variants).
Full inventory returned total5/next:null; all five descendant trees parsed as
complete JSON, not a truncated page summary. All bound colors and both official
text styles resolve. Four actual consumers confirm separate system/status area.
Consumer background bindings are saved independently; App Bar root stays empty.
All artwork reuses exact hash-verified existing icon SVG exports via master IDs.
No icon export, global recoloring or Figma asset URL is introduced into runtime.
No source reactions found in the five trees. Engineering behavior is D-030,
generated from design/engineering/app_bar.json with existing D-021 motion.
Version ID/designer approval unavailable; this is not a named design delivery.

Reproduce local registry/spec: `node tool/tokens/generate_app_bars.cjs`.
Validate immutability/current output: same command with `--check`.
Live tree extraction uses the existing packer with `app_bars_export` and explicit
nodeId; one variant per call. Captured evidence remains the generator input.
