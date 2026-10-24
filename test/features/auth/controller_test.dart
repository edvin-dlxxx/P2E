import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/core/errors/app_failure.dart';
import 'package:mygame_p2e/features/auth/auth.dart';

class Repositories
    implements
        WelcomeOfferRepository,
        PhoneSignInRepository,
        EmailSignInRepository,
        SocialSignInRepository {
  final pending = Completer<Result<OtpChallenge>>();
  AuthCancellation? cancellation;
  int calls = 0;
  Result<WelcomeOffer> offer = const Success(WelcomeOffer(3500));
  Result<EmailAccountStatus> email = const Success(
    EmailAccountStatus.registered,
  );
  @override
  Future<Result<WelcomeOffer>> load({AuthCancellation? cancellation}) async =>
      offer;
  @override
  Future<Result<OtpChallenge>> requestOtp(
    Phone phone, {
    required bool rememberDevice,
    AuthCancellation? cancellation,
  }) {
    calls++;
    this.cancellation = cancellation;
    return pending.future;
  }

  @override
  Future<Result<EmailAccountStatus>> checkEmail(
    Email email, {
    AuthCancellation? cancellation,
  }) async => this.email;
  @override
  Future<Result<void>> start(
    SocialProvider provider, {
    AuthCancellation? cancellation,
  }) async => const Failure(BusinessFailure('social_unavailable'));
}

void main() {
  late Repositories repos;
  late ProviderContainer container;
  setUp(() {
    repos = Repositories();
    container = ProviderContainer(
      overrides: [
        welcomeOfferRepositoryProvider.overrideWith((_) => repos),
        phoneSignInRepositoryProvider.overrideWith((_) => repos),
        emailSignInRepositoryProvider.overrideWith((_) => repos),
        socialSignInRepositoryProvider.overrideWith((_) => repos),
      ],
    );
    container.listen(authEntryControllerProvider, (_, _) {});
  });
  tearDown(() => container.dispose());
  AuthEntryController controller() =>
      container.read(authEntryControllerProvider.notifier);
  AuthEntryState state() => container.read(authEntryControllerProvider);

  test('typing classifies without error or mutation of editing text', () {
    expect(state().canSubmit, false);
    controller().identifierChanged('۰۹۱۲ ۳۴۵ ۶۷۸۹');
    expect(state().raw, '۰۹۱۲ ۳۴۵ ۶۷۸۹');
    expect(state().identifier, isA<Phone>());
    expect(state().canSubmit, true);
    controller().identifierChanged('bad');
    expect(state().fieldError, isNull);
    expect(state().canSubmit, false);
  });
  test('loading prevents duplicate submit and remember mutation', () async {
    controller().identifierChanged('09123456789');
    controller().rememberToggled();
    final first = controller().submit();
    await controller().submit();
    controller().rememberToggled();
    expect(state().busy, true);
    expect(state().rememberDevice, true);
    expect(repos.calls, 1);
    repos.pending.complete(const Failure(OfflineFailure()));
    await first;
    expect(state().toast, AuthMessage.offline);
    expect(state().rememberDevice, true);
  });
  test('changed input cancels request and ignores stale response', () async {
    controller().identifierChanged('09123456789');
    final first = controller().submit();
    controller().identifierChanged('new@example.com');
    expect(repos.cancellation!.isCancelled, true);
    repos.pending.complete(const Failure(ServerFailure()));
    await first;
    expect(state().raw, 'new@example.com');
    expect(state().toast, isNull);
    expect(state().destination, isNull);
  });
  test('dispose cancels in-flight request', () async {
    controller().identifierChanged('09123456789');
    final first = controller().submit();
    container.dispose();
    expect(repos.cancellation!.isCancelled, true);
    repos.pending.complete(const Failure(ServerFailure()));
    await first;
    // Replace the disposed container so tearDown remains valid.
    container = ProviderContainer();
  });
  for (final status in EmailAccountStatus.values) {
    test('email result retained in flow: $status', () async {
      repos.email = Success(status);
      controller().identifierChanged('new@EXAMPLE.COM');
      controller().rememberToggled();
      await controller().submit();
      final flow = container.read(authFlowProvider) as EmailFlowResult;
      expect(flow.email.normalized, 'new@example.com');
      expect(flow.rememberDevice, true);
      expect(
        state().destination,
        status == EmailAccountStatus.registered
            ? AuthStep.password
            : AuthStep.createPassword,
      );
      expect(state().raw, 'new@EXAMPLE.COM');
    });
  }
  test('welcome offer initially absent, loaded asynchronously', () async {
    expect(state().welcomeOffer, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(state().welcomeOffer!.points, 3500);
    repos.offer = const Failure(ServerFailure());
    await controller().retryWelcomeOffer();
    expect(state().welcomeOffer, isNull);
    expect(state().toast, isNull);
  });
  test('social failure becomes toast', () async {
    await controller().socialRequested(SocialProvider.google);
    expect(state().toast, AuthMessage.socialUnavailable);
  });
  for (final entry in <AppFailure, AuthMessage>{
    const OfflineFailure(): AuthMessage.offline,
    const NetworkFailure(): AuthMessage.offline,
    const TimeoutFailure(): AuthMessage.offline,
    const ServerFailure(): AuthMessage.server,
    const BusinessFailure('backend_not_configured'): AuthMessage.notConfigured,
    const BusinessFailure('social_unavailable'): AuthMessage.socialUnavailable,
    const UnknownFailure(): AuthMessage.unknown,
  }.entries) {
    test('failure maps once: ${entry.key.runtimeType} ${entry.value}', () {
      expect(AuthFailureMapper.map(entry.key).toast, entry.value);
      expect(AuthFailureMapper.map(entry.key).field, isNull);
    });
  }
  for (final code in ['blocked', 'rate_limited']) {
    test('field error $code does not become toast', () async {
      controller().identifierChanged('09123456789');
      final request = controller().submit();
      repos.pending.complete(Failure(ValidationFailure({'identifier': code})));
      await request;
      expect(
        state().fieldError,
        code == 'blocked' ? AuthMessage.blocked : AuthMessage.rateLimited,
      );
      expect(state().toast, isNull);
    });
  }
}
