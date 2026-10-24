> Historical Auth implementation evidence. Reviewer did not accept this version. Current D-059/D-060 corrections and remaining measured differences are in [Auth conformance](../auth-conformance/README.md).

# Auth Entry implementation — 2026-10-23

One product screen is implemented. OTP, Password, Create Password, Forgot Password and Home remain placeholders. No commit was made. Figma access was read-only. Dark English is the source; Light, Persian and responsive extensions remain provisional.

## Architecture and SOLID

`lib/features/auth/src/domain` contains the pure classifier, identifier value objects, entities and four repository interfaces. Presentation imports these abstractions, not data implementations. `src/data` contains source contracts, DTOs, mappers, fake sources and typed remote stubs. `src/presentation` owns immutable code-generated Riverpod state, cancellation, stale response protection and a single failure-to-message mapper. Widget State owns editing/focus objects. `lib/app/auth_bindings.dart` selects implementations at the composition root.

Single responsibility: classification, DTO mapping, orchestration and rendering are separate. Interface segregation: welcome, phone, email and social have independent contracts. Dependency inversion: the controller receives domain repositories; platform links use a shared port with an app adapter. Repository contract suites exercise fakes through the same interfaces intended for remote implementations. Scenario overrides replace source behavior without changing screen logic. Auth-flow results live in a provider, not route extras; missing results redirect to Entry.

## Decisions and design follow-up

- D-055: exactly `core/errors/app_failure.dart` is allowed from domain, package and relative imports; checker enforces its pure Dart import whitelist. Positive and negative architecture fixtures cover the exception.
- D-056: provisional Auth primitives, accent skin roles and explicit brand-color test exclusions. Legacy Button geometry is retained.
- D-057: snapshot schema1.1.0 adds loading, identifier PII uses a constant mask, and new Auth goldens are authorized pending review.
- D-058: Auth composition, fake/stub selection, raw identifier display exception to D-049, neutral startup and placeholder destinations.
- R-013 requests an official accent Button variant; R-014 requests an official Google asset. Existing Light/Persian typography requests remain open.

## Source conformance

The four source frames, metadata, variables, original screenshots and asset hashes are in `docs/snapshots/2026-10-23_auth-entry`. See `figma-conformance.json` for measured rects. At402×874/top55, hero, field bounds, subtitle, mixed20/24/32 insets and keyboard CTA bottom gap match. Title width differs by−1.792 and reward width by−2.415 logical pixels due to bundled-font metrics.

E-011 remains explicit: Figma CTA is46 high while existing DS vertical padding and line height require52. Shared geometry is preserved, so the idle divider/social content moves6 pixels; keyboard CTA moves6 upward while retaining its20-pixel bottom gap. Legal prose grows from36 to96 high to provide separate non-overlapping48-pixel link targets. This is not pixel-identical Figma output. PlayStation spelling follows the authorized correction. The original hero illustration and exact exported elliptical mask are used; raster sampling differs from the source screenshot. Original brand artwork is not recolored.

## Fake backend and running

Fake defaults to600ms; `slow` is3seconds. Scenarios: `success`, `slow`, `offline`, `serverError`, `rateLimited`, `notConfigured`. Phone suffix0000 is blocked; email local part starting `new` is unregistered; welcome offer3500; social returns unavailable. Only scenario names are logged. Identifiers are redacted and Inspector exposes a constant mask, including JSON.

From the root:

```powershell
flutter run --dart-define-from-file=config/dev.json --dart-define=FAKE_SCENARIO=offline
flutter build apk --debug --dart-define-from-file=config/dev.json --dart-define=FAKE_SCENARIO=success
```

From `dev_tools/inspector/hosts/product_host`:

```powershell
flutter run -d windows --dart-define-from-file=../../../../config/dev.json --dart-define=FAKE_SCENARIO=slow
```

The host Dev group can change scenario without replacing product state. Product runs independently of Inspector. Stage/prod select remote stubs; production fake config is rejected. No endpoints or real backend behavior were invented. Terms/privacy URLs are config keys; missing URLs produce a typed failure/toast.

## Evidence

`validation.md` records exact commands, counts and build results. `inspector-auth-sweep.json` records every reported range; the sweep asserts no problems at width≥320 and height≥480. Smaller dimensions remain explicitly reported rather than certified compliant. `legacy-golden-proof.json` verifies69 existing DS baselines byte-for-byte. New18 screen and7 DS sheets remain pending owner review. The eight `auth-*-dark-1.0-402.png` images beside this report show all four states in English and Persian; keyboard screenshots reserve actual inset space rather than drawing a fake keyboard/status bar.

## Open product/design questions

MCI-only phone eligibility is undecided; current classifier accepts Iranian mobile numbers. Backend OD-2, legal URLs, official accent/Google artwork, Light/Persian/tablet approval and final Persian copy review remain open. These do not block exercising the in-app fake flow; they block claiming a production backend or final designer approval. Native publisher identifier remains provisional under the earlier foundation decision.
