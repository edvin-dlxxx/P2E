import 'dart:async';

import '../../domain/models.dart';
import '../sources.dart';

enum FakeAuthScenario {
  success,
  slow,
  offline,
  serverError,
  rateLimited,
  notConfigured,
}

/// Unique marker must survive only the const-selected fake composition.
const fakeAuthMarker = 'P2E_AUTH_FAKE_ONLY_20261023';

final class FakeAuthEnvironment {
  FakeAuthEnvironment({
    required this.scenario,
    DateTime Function()? clock,
    this.log,
  }) : clock = clock ?? DateTime.now;
  final FakeAuthScenario Function() scenario;
  final DateTime Function() clock;
  final void Function(String scenario)? log;
  Future<void> wait(AuthCancellation? cancellation) async {
    final selected = scenario();
    log?.call(selected.name);
    if (cancellation?.isCancelled ?? false) {
      throw const AuthDataException(AuthDataFault.cancelled);
    }
    final done = Completer<void>();
    final timer = Timer(
      Duration(milliseconds: selected == FakeAuthScenario.slow ? 3000 : 600),
      done.complete,
    );
    void cancel() {
      timer.cancel();
      if (!done.isCompleted) {
        done.completeError(const AuthDataException(AuthDataFault.cancelled));
      }
    }

    cancellation?.onCancel(cancel);
    try {
      await done.future;
    } finally {
      cancellation?.removeListener(cancel);
      timer.cancel();
    }
    final fault = switch (selected) {
      FakeAuthScenario.offline => AuthDataFault.offline,
      FakeAuthScenario.serverError => AuthDataFault.server,
      FakeAuthScenario.rateLimited => AuthDataFault.rateLimited,
      FakeAuthScenario.notConfigured => AuthDataFault.notConfigured,
      _ => null,
    };
    if (fault != null) throw AuthDataException(fault);
  }
}

final class FakeWelcomeOfferSource implements WelcomeOfferSource {
  const FakeWelcomeOfferSource(this.environment);
  final FakeAuthEnvironment environment;
  @override
  Future<WelcomeOfferDto> load(AuthCancellation? cancellation) async {
    await environment.wait(cancellation);
    return const WelcomeOfferDto(3500);
  }
}

final class FakePhoneSignInSource implements PhoneSignInSource {
  const FakePhoneSignInSource(this.environment);
  final FakeAuthEnvironment environment;
  @override
  Future<OtpChallengeDto> requestOtp(
    String e164,
    bool rememberDevice,
    AuthCancellation? cancellation,
  ) async {
    await environment.wait(cancellation);
    if (e164.endsWith('0000')) {
      throw const AuthDataException(AuthDataFault.blocked);
    }
    return OtpChallengeDto(
      id: 'dev-challenge-1',
      length: 6,
      resendSeconds: 60,
      expires: environment.clock().add(const Duration(minutes: 5)),
      destination: '+98 ••• ••• ${e164.substring(e164.length - 4)}',
    );
  }
}

final class FakeEmailSignInSource implements EmailSignInSource {
  const FakeEmailSignInSource(this.environment);
  final FakeAuthEnvironment environment;
  @override
  Future<EmailStatusDto> checkEmail(
    String email,
    AuthCancellation? cancellation,
  ) async {
    await environment.wait(cancellation);
    return EmailStatusDto(
      !email.split('@').first.toLowerCase().startsWith('new'),
    );
  }
}

final class FakeSocialSignInSource implements SocialSignInSource {
  const FakeSocialSignInSource(this.environment);
  final FakeAuthEnvironment environment;
  @override
  Future<SocialStartDto> start(
    SocialProvider provider,
    AuthCancellation? cancellation,
  ) async {
    await environment.wait(cancellation);
    throw const AuthDataException(AuthDataFault.unavailable);
  }
}
