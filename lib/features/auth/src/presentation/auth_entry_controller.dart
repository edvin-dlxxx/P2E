import 'dart:async';

import 'package:mygame_p2e/core/errors/app_failure.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/identifier.dart';
import '../domain/models.dart';
import 'dependencies.dart';
import 'auth_flow.dart';
import 'auth_messages.dart';
part 'auth_entry_controller.g.dart';

enum AuthSubmission { idle, loading, failure }

const _absent = Object();

final class AuthEntryState {
  const AuthEntryState({
    this.raw = '',
    this.identifier = const Empty(),
    this.rememberDevice = false,
    this.welcomeOffer,
    this.submission = AuthSubmission.idle,
    this.fieldError,
    this.toast,
    this.toastSerial = 0,
    this.destination,
  });
  final String raw;
  final SignInIdentifier identifier;
  final bool rememberDevice;
  final WelcomeOffer? welcomeOffer;
  final AuthSubmission submission;
  final AuthMessage? fieldError, toast;
  final int toastSerial;
  final AuthStep? destination;
  bool get busy => submission == AuthSubmission.loading;
  bool get canSubmit => !busy && (identifier is Phone || identifier is Email);
  AuthEntryState copyWith({
    String? raw,
    SignInIdentifier? identifier,
    bool? rememberDevice,
    Object? welcomeOffer = _absent,
    AuthSubmission? submission,
    Object? fieldError = _absent,
    Object? toast = _absent,
    int? toastSerial,
    Object? destination = _absent,
  }) => AuthEntryState(
    raw: raw ?? this.raw,
    identifier: identifier ?? this.identifier,
    rememberDevice: rememberDevice ?? this.rememberDevice,
    welcomeOffer: identical(welcomeOffer, _absent)
        ? this.welcomeOffer
        : welcomeOffer as WelcomeOffer?,
    submission: submission ?? this.submission,
    fieldError: identical(fieldError, _absent)
        ? this.fieldError
        : fieldError as AuthMessage?,
    toast: identical(toast, _absent) ? this.toast : toast as AuthMessage?,
    toastSerial: toastSerial ?? this.toastSerial,
    destination: identical(destination, _absent)
        ? this.destination
        : destination as AuthStep?,
  );
}

// Repositories are overridden in the root composition, not nested UI scopes.
@riverpod
class AuthEntryController extends _$AuthEntryController {
  AuthCancellation? _request, _welcome;
  int _revision = 0, _welcomeRevision = 0;
  @override
  AuthEntryState build() {
    // Read abstract contracts only. Concrete repositories are supplied by app/.
    ref.watch(welcomeOfferRepositoryProvider);
    ref.watch(phoneSignInRepositoryProvider);
    ref.watch(emailSignInRepositoryProvider);
    ref.watch(socialSignInRepositoryProvider);
    ref.listen(
      authFlowProvider,
      (_, _) {},
    ); // auth-flow lifetime without rebuilding entry on result.
    ref.onDispose(() {
      _request?.cancel();
      _welcome?.cancel();
    });
    scheduleMicrotask(() {
      if (ref.mounted) unawaited(retryWelcomeOffer());
    });
    return const AuthEntryState();
  }

  void identifierChanged(String raw) {
    if (raw == state.raw) return;
    _request?.cancel();
    _revision++;
    state = state.copyWith(
      raw: raw,
      identifier: IdentifierClassifier.classify(raw),
      submission: AuthSubmission.idle,
      fieldError: null,
      toast: null,
      destination: null,
    );
  }

  void rememberToggled() {
    if (!state.busy) {
      state = state.copyWith(rememberDevice: !state.rememberDevice);
    }
  }

  Future<void> retryWelcomeOffer() async {
    _welcome?.cancel();
    final token = AuthCancellation();
    _welcome = token;
    final revision = ++_welcomeRevision;
    state = state.copyWith(welcomeOffer: null);
    final result = await ref
        .read(welcomeOfferRepositoryProvider)
        .load(cancellation: token);
    if (!ref.mounted || token.isCancelled || revision != _welcomeRevision) {
      return;
    }
    state = state.copyWith(
      welcomeOffer: result is Success<WelcomeOffer> ? result.value : null,
    );
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;
    final identifier = state.identifier, remember = state.rememberDevice;
    final token = AuthCancellation();
    _request = token;
    final revision = ++_revision;
    state = state.copyWith(
      submission: AuthSubmission.loading,
      fieldError: null,
      toast: null,
      destination: null,
    );
    final Result<AuthFlowResult> result;
    if (identifier is Phone) {
      result =
          (await ref
                  .read(phoneSignInRepositoryProvider)
                  .requestOtp(
                    identifier,
                    rememberDevice: remember,
                    cancellation: token,
                  ))
              .map((challenge) => PhoneFlowResult(challenge, remember));
    } else if (identifier is Email) {
      result =
          (await ref
                  .read(emailSignInRepositoryProvider)
                  .checkEmail(identifier, cancellation: token))
              .map((status) => EmailFlowResult(identifier, status, remember));
    } else {
      return;
    }
    if (!ref.mounted || token.isCancelled || revision != _revision) return;
    switch (result) {
      case Success<AuthFlowResult>(:final value):
        ref.read(authFlowProvider.notifier).accept(value);
        state = state.copyWith(
          submission: AuthSubmission.idle,
          destination: value.step,
        );
      case Failure<AuthFlowResult>(:final error):
        _fail(error);
    }
  }

  Future<void> socialRequested(SocialProvider provider) async {
    if (state.busy) return;
    final token = AuthCancellation();
    _request = token;
    final revision = ++_revision;
    state = state.copyWith(
      submission: AuthSubmission.loading,
      fieldError: null,
      toast: null,
      destination: null,
    );
    final result = await ref
        .read(socialSignInRepositoryProvider)
        .start(provider, cancellation: token);
    if (!ref.mounted || token.isCancelled || revision != _revision) return;
    if (result is Failure<void>) {
      _fail(result.error);
    } else {
      state = state.copyWith(submission: AuthSubmission.idle);
    }
  }

  void _fail(AppFailure failure) {
    final mapped = AuthFailureMapper.map(failure);
    state = state.copyWith(
      submission: AuthSubmission.failure,
      fieldError: mapped.field,
      toast: mapped.toast,
      toastSerial: state.toastSerial + 1,
    );
  }
}
