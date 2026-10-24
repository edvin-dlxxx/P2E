# Changes from 2026-10-19_development-buttons

Scope: Buttons only. Severity high for implementation consumers: source surface heights and actual child positions must be respected; the current Flutter component is not certified by this extraction.

## Source inventory

- Same 18 component-set IDs and 90 variant IDs. No variant was added, removed or renamed.
- The same 18 scoped Variable values and three typography styles remain represented. Light/Dark remain separate collections/sets; asymmetrical names are not filled by substitution.
- Four lookup-only IDs retain actual RGBA alpha values and owning Base Color mode. Their lookup success versus absence from local enumeration is an observation, not an invented explanation of Figma internals.

## Added coverage

- Full depth-8 component traversal with no remaining `childrenNotExpanded` boundary, plus explicit parent/child IDs for 660 source nodes.
- Source clipping, text alignment, text resizing/truncation and component property links now captured in versioned supplemental data.
- Three exact source SVGs: Fill/Edit Square, Outline/Edit Square and Fill/Crown; 180 instance references mapped without name-based substitution.
- All 18 unbound wrapper strokes listed, eliminating the prior 13 unsampled paint examples. No unbound paint was promoted to a token.
- All 90 hidden Outline instances and their descendants retained.
- All 774 scoped Variable discovery origins retained despite oversized monolithic tool responses, using separate value/origin pagination.
- Exact raw responses, errors, producer requests, per-file hashes and reproducible offline assembly/check command.

## Implementation implications

- Small/medium/large colored surfaces are 36/46/56 at original scale. Do not replace them with padding-derived 44/52/60 in the extraction.
- Text alignment is CENTER. Use source child coordinates/bounds when testing the original specimen; preserve the original padding fields independently.
- Text-family default icon is Edit Square, icon-only default is Crown. Hidden Outline instances point to Edit Square; no counterpart is inferred.
- Surface Container/High and Low asymmetry remains exactly source-defined. There is no new semantic decision or mode fallback.
- Font metadata is available; exact Figma font binary/version remains unavailable. No Flutter baseline/golden was created by this extraction.

## Boundaries

This is DEVELOPMENT data from the Copy file. Version control is owner-managed, technical version lock is unverified, and no designer-approved label was supplied. Full-system LATEST, old Snapshot, rules, skills, registers, Flutter and existing generated tokens are unchanged. All Figma operations were read-only.
