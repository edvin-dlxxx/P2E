# Optional Windows Inspector v1.1 — simulated device

This replaces the v1 host layout and device controls. Core identity, geometric selection, privacy-safe snapshot export, public source lookups and comparisons remain. Everything optional is inside this independently removable folder; no workspace, runtime, pubspec or required CI dependency points back here. No screens, backend scenarios, monkey runner, Figma calls or golden updates are added.

## Run

From the repository root, in separate terminals:

```powershell
cd dev_tools/inspector/hosts/product_host
flutter pub get
flutter run -d windows
```

```powershell
cd dev_tools/inspector/hosts/viewer_host
flutter pub get
flutter run -d windows
```

## Frame

Width 200–1400 and height 300–1400 are logical app pixels. Edit either numeric field and submit; Up/Down nudges the focused dimension by 1, Shift by 10. Drag physical-right, bottom or corner handles for live layout. Manual resize/preset/rotate uses Free mode. Fit window resolves available size before app layout. Product defaults to Free; standalone Viewer defaults to Fit window. Fit respects the same numeric bounds.

Nine presets are shortcuts: 320x568, 360x800, 402x874, 412x915, 600x960, 744x1133, 800x1280, 820x1180, 1024x1366. Default insets are editable engineering defaults: classic 320x568 uses top20/bottom0; other phone presets24/24; tablet presets24/20. These are plausible display inputs, not claims of exact hardware model measurements. Clockwise Rotate maps top<-left, right<-top, bottom<-right, left<-bottom. Bounds still apply (a rotated height below300 clamps to300).

Fit zoom centers the entire frame over a neutral backdrop. Border, ruler252/600/840, 600 content guide and size class stay in logical coordinates. 100% uses scrolling. The displayed percentage is visual only: app constraints, MediaQuery, measurement and hit-region exports are unchanged. Selection/highlight transformations track zoom. In Free mode panel resize/collapse changes only available zoom, never the logical app size.

## Device versus Dev

Device means OS input: an ordered locale list (fa-IR/en-US/de-DE and two ordered mixed presets), platform brightness, text scaler0.85–3.0 with quick1/1.3/2, directional safe-area edges, orientation, keyboard viewInsets (default300), reduce-motion/bold/high-contrast flags and Android/iOS target platform. The read-only App result reports resolved locale/direction, theme brightness, effective content scale and size class.

The host never overrides appLocaleProvider. Product deviceLocalesProvider observes real PlatformDispatcher locale updates outside this tool; the host overrides that input only. D-041 continues to choose fa even for en-US/de-DE. Viewer receives a neutral locale-list input while its existing explicit language choice remains authoritative; changing a device locale is not changing the Viewer's language picker. Fixture-only MaterialApp resolves its supplied OS locale normally. Product content clamps itself at2.0; DS chrome locally clamps itself at1.3. The fixture composition uses the same content clamp, not an app-state locale override.

Dev holds skin, fixture/product mode, Select and panel visibility. Product fixtures compose all real DS families without routes or fake services. The Viewer retains its original app controls and physical-left inspector. Its root child is retained across size changes, so host resize does not force a catalog rebuild through fresh callback identities. Device platform is a neutral root theme input; each app's own internal theme/configuration continues to decide preview behavior.

## Problems and Sweep

Problems chains FlutterError.onError and always calls the previous handler (or presentError). Console diagnostics and debug overflow stripes remain. Records use allowlisted kind/summary, nearest recoverable owning identity and a complete device snapshot; raw error text, entered values and lengths never enter exports. Unavailable ownership is explicit. Click a problem to restore its device snapshot and select its still-mounted owner.

Flutter reports a continuous RenderFlex overflow once. During sweep, public child main-axis extents additionally observe persistent overflow; hidden/offstage branches are skipped for these observations. Actual Navigator widths below252 are re-observed without spamming console diagnostics. Targets remain explicitly non-compliant. Collector failures are counted, not allowed to replace the original Flutter error handler.

Sweep runs current route only: width, height or row-wise grid, configurable bounds/steps (grid defaults4px/8px). Optional matrix is OS fa/en x scale1/1.3/2. Each sample changes device input and waits one frame; it does not tap, invoke app callbacks or navigate. Adjacent failing sampled points are grouped by kind/owner/settings, never extrapolated across unsampled pixels. Cancel stops after the active sample. Previous device settings and mode are restored in finally. Click a range restores the first failing device configuration and selects its owner; Copy JSON uses the separate p2e-sweep-v1.1 report format, not an invented modification of the adopted identity snapshot schema.

## Scriptable API

```dart
final device = SimulatedDevice();
// Pass device into either host. No application state is injected here.
device.apply(device.settings.copyWith(
  size: const Size(600, 960), locales: const [Locale('en', 'US')],
  scale: 3, keyboard: true, keyboardHeight: 300,
  platform: TargetPlatform.iOS, disableAnimations: true,
));
device.rotate();
// InspectorHostState exposes device, problems, session and sweep.
await hostState.sweep.run(
  const SweepPlan(minWidth: 200, maxWidth: 1400, widthStep: 4),
  hostState.frame,
);
final json = hostState.sweep.exportJson();
```

FrameSettings.toJson/fromJson round-trip all device fields; Dev skin is separate. Future input drivers can use this state API; no monkey runner or input simulator is implemented.

## Selection, inspection and limits retained from v1

Select intercepts pointers/hover; Esc restores normal interaction. Disabled/loading controls are geometrically selectable without normal hit testing. Transforms, public ancestor clips, offstage/transparent state, deepest candidates and parent/slot navigation are handled. Live refresh uses build notifications, no idle-frame traversal or global registry. Disposal/same-key remount uses full effective identity, never position/type. Overlay affects neither app layout nor semantics.

Source/resolved/measured values remain separate, with match/differs/not-comparable/engineering-defined/unavailable and the existing0.5logical-pixel tolerance. Colors are configuration, not sampled pixels. Glyph-specific selected font is not exposed by Flutter; configured bundled family/fallback chains are evidence only. Some custom clips/hit regions/radii are unavailable. Pure artwork has no interactive identity (D-023). Viewer OTP parity is group-level; child registry parity is separate. PageScaffold lacks a linked source/legacy inspector record. R-012 is not structured descriptor metadata; its ID is not invented. Identity JSON uses the unchanged adopted schema and D-035 envelopes; Password/OTP content, lengths and sensitive paragraph arrays remain excluded. Select is for resting interaction, not freezing a gesture already in progress.

## Checks and real sweeps

Run pub get, dart analyze and flutter test in all three optional packages. Build each host with flutter build windows --debug. Check generated ARB chrome from inspector/ using dart run tool/generate_copy.dart --check. Snapshot validator: python dev_tools/inspector/tool/validate_snapshots.py.

From each host, the explicitly enabled real report run is:

```powershell
$env:RUN_REAL_SWEEP = '1'
flutter test test/sweep_report_test.dart --reporter expanded
Remove-Item Env:RUN_REAL_SWEEP
```

This mounts the real default Viewer Buttons route or DS fixture composition. It performs width200..1400 step4 at height874 (1204 samples), then a coarse grid width200..1400 step200 x height300..1400 step220 (168 samples), each over OS fa/en x device scale1/2. Reports are written to root build/inspector-v1.1. Normal test runs skip this slow report test. No app callbacks/navigation occur within the sweeps; fixtures remain controlled.

Deletion proof: & ./dev_tools/inspector/tool/check_isolation.ps1 moves the entire optional directory to a checked sibling, runs existing app/package/Viewer checks plus architecture/debug APK, and restores in finally. Release exclusion scans every uncompressed debug/release APK entry for the retained unique marker in UTF-8/UTF-16LE and confirms it in the Windows host. [v1 evidence](VALIDATION.md) remains historical; see VALIDATION-v1.1.md for this revision's final evidence and findings.


## Owner-authorized v1.1 follow-up (2026-10-23)

Windows minimum client sizes are 640x740 for the standalone Viewer and 1280x1000 for viewer_host, in logical pixels with DPI and non-client frame adjustment. The latter reserves the maximum600 panel, divider8 and the existing viewport allowance40, leaving632 logical pixels for Viewer chrome (>452 observed failing boundary). Height bounds avoid the short-height overflows observed in the original coarse grid. Native minimum bounds do not restrict the independently simulated Free frame: deliberately setting that frame below the chrome's usable size can still expose overflow. Viewer chrome at device scale2 may overflow and remains accepted; minimum bounds are for scale1.

Shared fields now use immediate target-size layout for reduced motion rather than a zero-duration AnimatedSize; a stable keyed child retains native editing state across policy changes. Normal animation and all golden baselines are preserved. See FOLLOWUP-v1.1.md for reproduction, final validation and the extended3612-sample sweep.
