# Temporary development pages

## ButtonVerificationPage

- Source: lib/dev/verification/button_verification_page.dart (TEMPORARY).
- Entry: lib/main_dev.dart only; existing Gallery remains reachable by callback.
- Purpose: inspect actual RenderBox bounds at adjustable phone widths on Windows,
  compare to Snapshot dimensions with 0.5px tolerance, and expose unresolved data.
- The measured box is AppButton's outer rendered box, including its accessibility
  target. It is not a recomputation of its visual surface or source minimum size.
- All 45 logical rows / 90 Light+Dark source variants are mounted and measured
  after bundled fonts load. Default view shows every variant in nine family/size
  groups, ordered by the typed family, size and type axes. Light and Dark samples
  sit side by side. Filters show the displayed count out of 90; Show all 90 resets
  every filter. Raw source names/IDs and detailed style diagnostics are expandable.
  Card padding sits outside the sample viewport and does not reduce its width.
- No DIFF is fixed by this page. Empty icon-slot outlines are dev annotations
  outside the Button and do not substitute for glyphs.
- Delete the page, measurement helper, label ARB/generator and generated labels
  when the real Gallery/Inspector supports real font loading, side-by-side themes,
  viewport/direction/scale controls, actual measurements and source/delta display.
  Keep source contracts, measurement evidence and production AppButton.
- Regenerate labels: dart run tool/dev/generate_verification_strings.dart.
- Launch: flutter run -d windows --debug -t lib/main_dev.dart.
