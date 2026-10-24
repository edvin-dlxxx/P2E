# Architecture check scope

Run: dart run tool/check_architecture.dart. Nonzero exit means real violations.

Checks all lib Dart imports, exports and parts (including conditional URI strings),
direct dev boundaries and the transitive lib/main.dart graph. Bans Icons and
CupertinoIcons, common icon packages, google_fonts, and literal font-download URLs.
Generated lib files, including JSON expected specs, require a GENERATED marker.
Text/Semantics direct string literals in lib/ui and lib/app are checked lexically;
generated paths and explicit TEMPORARY/DEV-ONLY headers are excluded from this
string rule only. The import/icon/font rules still apply to them.

Explicit scope exclusions: windows/ native C++/CMake (owner requested), build/
artifacts, tool/ scripts, tests and documentation. Pubspec dependencies are checked.
This script does not modify or silently auto-fix violations.

Not implemented from the broader architecture docs:

- Raw visual values, directional APIs and PHYSICAL annotations: require a Dart AST
  and token provenance rather than false positives on resolver math/JSON fields.
- Platform branches and PLATFORM register matching: beyond this minimum pass;
  needs annotation parsing and imports/conditional platform policy analysis.
- Full layer dependency restrictions and banned feature widgets: future rule set;
  current minimum targets production/dev separation only.
- Identity/spec/Gallery completeness, override/errata consistency, localization
  coverage, RTL mirroring, accessibility and real visual parity: require semantic
  registries and runtime tests, not lexical source scanning.
- Generated output freshness and source hash checks: owned by generators --check;
  this checker checks headers only. Agent Sync remains its separate script.
- Computed strings, aliased icon classes, dynamic network/font loading and arbitrary
  package internals cannot be proven absent by regex. This is best-effort detection,
  not a complete Dart parser or a security guarantee.

Fixture tests verify permitted dev imports, transitive leaks, missing generated
headers, Text/Semantics literals and prohibited icon/font dependencies.
