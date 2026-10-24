# Real sweep findings — 2026-10-23

Historical observations before the follow-up. The mutation finding was subsequently fixed; see [FOLLOWUP-v1.1.md](FOLLOWUP-v1.1.md) for the extended post-fix sweep.
Default dark/product fixtures and the real default Viewer Buttons route were mounted with bundled fonts. One frame per sample; no app callbacks/navigation were invoked. Device inputs: OS fa-IR/en-US x scale1/2. DS fixtures resolve fa/en. Product policy remains fa; Viewer keeps its existing explicit fa language choice for both OS lists. Thus the Viewer matrix tests OS delivery/fallback, not an app-language override.

Width sweep: 200..1400 step4 at height874, 1204 samples per host. Coarse grid: width200..1400 step200 x height300..1400 step220, 168 samples per host. Previous device settings restored. Every sampled range is listed below; no interpolation/extrapolation across unsampled pixels. Unknown owner means Viewer chrome without an ElementIdentity, not an invented DS identity.

## All observed ranges

| Host/plan | Kind | Owner | OS locale | Scale | Width range | Height range | Step W/H |
|---|---|---|---|---:|---|---|---|
| product_host/width | navigator-below-minimum | fixtures.navigation | fa-IR | 1 | 200..248 | 874..874 | 4/8 |
| product_host/width | navigator-below-minimum | fixtures.navigation | en-US | 1 | 200..248 | 874..874 | 4/8 |
| product_host/width | navigator-below-minimum | fixtures.navigation | fa-IR | 2 | 200..248 | 874..874 | 4/8 |
| product_host/width | navigator-below-minimum | fixtures.navigation | en-US | 2 | 200..248 | 874..874 | 4/8 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 1 | 200..200 | 300..300 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 1 | 200..200 | 520..520 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 1 | 200..200 | 740..740 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 1 | 200..200 | 960..960 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 1 | 200..200 | 1180..1180 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 1 | 200..200 | 1400..1400 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 1 | 200..200 | 300..300 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 1 | 200..200 | 520..520 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 1 | 200..200 | 740..740 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 1 | 200..200 | 960..960 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 1 | 200..200 | 1180..1180 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 1 | 200..200 | 1400..1400 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 2 | 200..200 | 300..300 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 2 | 200..200 | 520..520 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 2 | 200..200 | 740..740 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 2 | 200..200 | 960..960 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 2 | 200..200 | 1180..1180 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | fa-IR | 2 | 200..200 | 1400..1400 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 2 | 200..200 | 300..300 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 2 | 200..200 | 520..520 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 2 | 200..200 | 740..740 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 2 | 200..200 | 960..960 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 2 | 200..200 | 1180..1180 | 200/220 |
| product_host/coarseGrid | navigator-below-minimum | fixtures.navigation | en-US | 2 | 200..200 | 1400..1400 | 200/220 |
| viewer_host/width | overflow | unavailable (Viewer chrome) | fa-IR | 1 | 200..452 | 874..874 | 4/8 |
| viewer_host/width | overflow | unavailable (Viewer chrome) | en-US | 1 | 200..452 | 874..874 | 4/8 |
| viewer_host/width | overflow | unavailable (Viewer chrome) | fa-IR | 2 | 200..612 | 874..874 | 4/8 |
| viewer_host/width | overflow | unavailable (Viewer chrome) | en-US | 2 | 200..612 | 874..874 | 4/8 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 1 | 200..1400 | 300..300 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 1 | 200..600 | 520..520 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 1 | 200..400 | 740..740 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 1 | 200..200 | 960..960 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 1 | 1200..1200 | 520..520 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 1 | 200..1400 | 300..300 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 1 | 200..600 | 520..520 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 1 | 200..400 | 740..740 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 1 | 200..200 | 960..960 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 1 | 1200..1200 | 520..520 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 2 | 200..1400 | 300..300 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 2 | 200..1400 | 520..520 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 2 | 200..800 | 740..740 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 2 | 200..400 | 960..960 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 2 | 200..400 | 1180..1180 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 2 | 200..400 | 1400..1400 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | fa-IR | 2 | 1200..1200 | 740..740 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 2 | 200..1400 | 300..300 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 2 | 200..1400 | 520..520 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 2 | 200..800 | 740..740 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 2 | 200..400 | 960..960 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 2 | 200..400 | 1180..1180 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 2 | 200..400 | 1400..1400 | 200/220 |
| viewer_host/coarseGrid | overflow | unavailable (Viewer chrome) | en-US | 2 | 1200..1200 | 740..740 | 200/220 |

## Interpretation and limits

- Fixtures: Navigator warning at widths200..248 in the width sweep, all four matrix combinations. Width252 passes this warning boundary. Coarse grid observes warning only at sampled width200, at all six heights and matrix combinations. Below-minimum hit targets are explicitly non-compliant.
- Viewer: width overflow at200..452 for device scale1 and200..612 for device scale2, for both ordered single-locale inputs. Coarse-grid rows above list all observed combinations, including non-contiguous width ranges separately. Do not infer unsampled exact thresholds from step4 or step200.
- Width/height boundary probe uses a host-only overflow fixture: at step1, width295..299 fails and300..305 does not; height395..399 fails and400..405 does not. This verifies exact range collection independently of application findings.
- An additional accessibility test (device scale3 + keyboard300 + reduce motion/bold/high contrast) observes RenderAnimatedSize mutation during its own layout when mounting/resizing real DS fixtures. It is classified as layout-mutation; original console diagnostics are retained. This finding is outside the required scale1/2 sweep matrix. No DS/SDK correction was applied.
- Flutter emits continuous overflow diagnostics once. Public RenderFlex child extents re-observe persistent overflow, and actual mounted Navigator geometry re-observes its one-time host warning without console spam. Hidden/offstage synthesized observations are skipped. Other custom layout/paint failures depend on FlutterError reports; ownership may be unavailable when the framework diagnostic has no recoverable element.
- These are findings, not fixes or visual approval. No component source or golden baseline was changed. Raw diagnostic messages are not exported; JSON contains only allowlisted summaries, identities and device inputs.

Machine-readable reports: [fixtures](evidence/v1.1/product_host-sweep.json), [Viewer](evidence/v1.1/viewer_host-sweep.json).
