# Inspector snapshot schema changelog

## 1.1.0 — 2026-10-23 (D-057)

- Add optional boolean `state.loading`; current descriptors emit it explicitly.
- Continue accepting existing1.0.0 snapshots for backwards compatibility.
- Auth identifiers declare privacy=identifier and a constant display mask.
  Inspection omits editable content, lengths, value-presence metadata and
  sensitive paragraph collection, while assistive semantics retain native input.
- Identity Contract v1.1 and component-spec versions are separate namespaces;
  neither is bumped by this snapshot serialization revision.
