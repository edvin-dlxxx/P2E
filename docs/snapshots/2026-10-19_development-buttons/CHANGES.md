# DEVELOPMENT Snapshot — Buttons

نسخهٔ نخست توسعه برای Buttons ساخته شد؛ این خروجی پوشش کامل Design System نیست. کنترل نسخه با مالک است و technical version lock برابر unverified است. هیچ ادعای stable یا designer-approved مطرح نمی‌شود.

- شدت medium در دادهٔ طراحی: lint تعداد 90 لایهٔ مخفی و 18 paint بدون binding گزارش کرده است؛ داده‌ها حفظ شده‌اند و تصمیم یا register تغییر نکرده است.
- 18 set، 90 Variant، 60 Text node و 18 Variable موردنیاز دریافت شد. IDها با inventory فعلی تطبیق دارند؛ مورد مفقود یا تکراری وجود ندارد.
- هر چهار lookup-only resolve شد؛ مقادیر اصلی و resolved جداگانه در variables.json ثبت شده‌اند.
- ۲۵ تست پاس شد. Snapshot تحویلی قبلی وجود ندارد؛ pilot به‌عنوان مبنای مصوب یا Snapshot قبلی در نظر گرفته نشده است.

## English detail

First DEVELOPMENT Buttons Snapshot. The owner explicitly waived version-lock and designer-approval delivery gates for this run only. Canonical rules/skills remain unchanged. No full-system LATEST pointer was created or updated.

All extraction responses are fresh; pilot data was not reused. Component inventory and exact set/variant/text-node membership were read before and after collection. Every page cursor terminates at null; the component completeness proof is recorded in manifest.json because component_set_spec has no complete field. Component trees used depth 2; no childrenNotExpanded boundaries were observed.

Raw Variables discovery enumerated 286 variables from all local collections, then scoped final variables.json to 18 Button-bound variables and recursively required aliases. All raw enumeration responses remain unchanged in raw/. Collections preserve original variableIds even where IDs lie outside this scoped output; includedVariableIds identifies actual inclusion. No API omission cause was invented for lookup-only variables.

Raw responses and exact request JS are preserved with per-file SHA-256 hashes and an aggregate input digest. The ordinary OUT_LIMIT errors did not occur with pilot-derived small pages. One local raw-write batch exceeded the Node tool 64000-byte auto-review limit; saving was retried in smaller chunks without rerunning or losing any Figma response. No extraction tool refactor was required.

Typography style objects expose some fields as missing (such as fontWeight/textStyleId on style objects); original missing tags are retained. Text nodes/segments independently preserve their API typography and style IDs. No inferred replacement values were inserted.

No Flutter, SDK, dependency, rule, skill or register edits; no Figma writes, SVG assets, tokens, Dart generation or commit.
