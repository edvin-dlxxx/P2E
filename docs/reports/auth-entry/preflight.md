# Auth Entry preflight — 2026-10-23

## Historical preflight: gate resolved by owner-approved D-055

The text below records the original stop, before implementation. The owner subsequently approved the exact-file exception with purity enforcement and positive/negative tests (D-055). Implementation continued under D-056–D-058. See `implementation.md` for the current result; statements below about unchanged files and unimplemented screens describe only that historical preflight.

The task says: 'Stop and report instead of improvising if ... the architecture check needs a rule exception.'

Domain repository interfaces must return the existing shared Result/AppFailure frontend types from Architecture14.1. These live in lib/core/errors/app_failure.dart:2,62 and are pure Dart, without imports. The existing Result<T> fixes its error type to AppFailure; it already represents the requested Result<T,AppFailure> semantics.

tool/check_architecture.dart:131-136 currently permits domain imports only from Dart SDK (excluding dart:io) or the same feature's domain. It rejects the shared core types regardless of their purity. Duplicating the failure/result hierarchy in auth, relocating it into a feature and exporting back from core, hiding the import behind part/export tricks, or weakening repository return types would evade the intended boundary rather than fulfill it; none was done.

## Reproduction

The probe uses a separate synthetic project in build/auth-entry-preflight/probe; no file was added to lib/features. It copies the real pure-Dart core error library and defines:

~~~dart
import 'package:mygame_p2e/core/errors/app_failure.dart';
abstract interface class WelcomeOfferRepository {
  Future<Result<int>> load();
}
~~~

Exact commands (root):

~~~powershell
$dart = 'D:\Tools\flutter\bin\cache\dart-sdk\bin\dart.exe'
& $dart run build/auth-entry-preflight/probe.dart
& $dart run tool/check_architecture.dart
~~~

Probe result:

~~~text
lib/features/auth/src/domain/welcome_offer_repository.dart: domain must be pure Dart
Confirmed: shared pure-Dart Result/AppFailure import is rejected.
~~~

The unmodified real project's architecture check passes. The probe is a negative contract demonstration, not a feature test or implementation. Logs are copied beside this report.

## Concrete proposed resolution (not applied)

Allow domain to import only lib/core/errors/app_failure.dart in addition to currently allowed imports. Validate that this approved library remains pure Dart: no Flutter, Riverpod, platform/IO/UI libraries, other project layers or external package dependencies; other core imports from domain remain forbidden. Add a positive shared-result import test and negative tests for Flutter/domain, other core/domain and impure dependencies introduced into the approved library. If the owner approves, record D-055 and update the canonical architecture guidance plus agent sync as needed. No checker or decision register change is applied before that approval.

## Read-only Figma evidence already completed

docs/snapshots/2026-10-23_auth-entry contains all four requested frames' metadata, resolved variable definitions, high-fidelity contexts and402x874 screenshots, plus normalized frame rects, manifest and SHA-256 hashes. Existing snapshot conventions use docs/snapshots; design/figma/LATEST does not exist in this repository.

Verified: mixed20/24/32 insets, accent CTA and label paints, brand palette values, keyboard top543 and CTA bottom523 (20 gap), hero relative y=-55/h264, and keyboard-specific hidden elements. Welcome bonus remains visible in keyboard states. The source has only Dark/English. PlayStation capitalization is the known owner-authorized text correction.

No contradictory Figma value was established during this scoped preflight. Full asset/binding extraction and pixel conformance are not claimed; they belong to implementation after the gate is resolved. Static source context/screenshot evidence is not a runtime image implementation.

## Current file scope and validation

Only this report/logs and the new scoped Figma snapshot were added. Product, DS, Inspector, schemas, dependencies, tokens, agent rules and decision registers are unchanged. No screen/fake backend or new golden was implemented, and no commit was made. Full feature tests/builds were not run because the task is stopped before implementation. The real architecture baseline passes.
