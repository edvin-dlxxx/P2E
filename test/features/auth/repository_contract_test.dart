import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/core/errors/app_failure.dart';
import 'package:mygame_p2e/features/auth/auth.dart';
import 'package:mygame_p2e/features/auth/auth_data.dart';

// These interface-level suites are reusable for a configured remote backend.
// No DTO, fake class or transport exception is asserted inside the contracts.
void welcomeContract(String name, WelcomeOfferRepository Function() create) {
  group('WelcomeOfferRepository contract: $name', () {
    test('returns a domain offer', () async {
      final value = await create().load();
      expect(value, isA<Success<WelcomeOffer>>());
      expect(
        (value as Success<WelcomeOffer>).value.points,
        greaterThanOrEqualTo(0),
      );
    });
    test(
      'pre-cancelled operation returns a failure without throwing',
      () async {
        final cancel = AuthCancellation()..cancel();
        expect(
          await create().load(cancellation: cancel),
          isA<Failure<WelcomeOffer>>(),
        );
      },
    );
  });
}

void phoneContract(String name, PhoneSignInRepository Function() create) {
  group('PhoneSignInRepository contract: $name', () {
    test('returns an OTP challenge and no raw destination', () async {
      final phone = IdentifierClassifier.classify('09123456789') as Phone;
      final result = await create().requestOtp(phone, rememberDevice: true);
      expect(result, isA<Success<OtpChallenge>>());
      final challenge = (result as Success<OtpChallenge>).value;
      expect(challenge.challengeId, isNotEmpty);
      expect(challenge.codeLength, greaterThan(0));
      expect(challenge.resendAfter.isNegative, false);
      expect(challenge.maskedDestination, isNot(contains(phone.e164)));
    });
    test('cancellation is a typed failure', () async {
      final cancel = AuthCancellation();
      final result = create().requestOtp(
        IdentifierClassifier.classify('09123456789') as Phone,
        rememberDevice: false,
        cancellation: cancel,
      );
      cancel.cancel();
      expect(await result, isA<Failure<OtpChallenge>>());
    });
  });
}

void emailContract(String name, EmailSignInRepository Function() create) {
  group('EmailSignInRepository contract: $name', () {
    test('returns a domain status', () async {
      expect(
        await create().checkEmail(
          IdentifierClassifier.classify('user@example.com') as Email,
        ),
        isA<Success<EmailAccountStatus>>(),
      );
    });
    test('cancelled request does not throw', () async {
      final cancel = AuthCancellation()..cancel();
      expect(
        await create().checkEmail(
          IdentifierClassifier.classify('user@example.com') as Email,
          cancellation: cancel,
        ),
        isA<Failure<EmailAccountStatus>>(),
      );
    });
  });
}

void socialContract(String name, SocialSignInRepository Function() create) {
  group('SocialSignInRepository contract: $name', () {
    for (final provider in SocialProvider.values) {
      test(
        '$provider returns a Result without leaking source exceptions',
        () async {
          expect(
            await create().start(provider),
            anyOf(isA<Success<void>>(), isA<Failure<void>>()),
          );
        },
      );
    }
  });
}

void main() {
  FakeAuthEnvironment environment([
    FakeAuthScenario scenario = FakeAuthScenario.success,
  ]) => FakeAuthEnvironment(
    scenario: () => scenario,
    clock: () => DateTime.utc(2026, 10, 23),
  );
  welcomeContract(
    'fake',
    () => WelcomeOfferRepositoryImpl(FakeWelcomeOfferSource(environment())),
  );
  phoneContract(
    'fake',
    () => PhoneSignInRepositoryImpl(FakePhoneSignInSource(environment())),
  );
  emailContract(
    'fake',
    () => EmailSignInRepositoryImpl(FakeEmailSignInSource(environment())),
  );
  socialContract(
    'fake',
    () => SocialSignInRepositoryImpl(FakeSocialSignInSource(environment())),
  );

  for (final scenario in FakeAuthScenario.values) {
    test(
      'scenario $scenario maps through DTO repository without throwing',
      () async {
        final watch = Stopwatch()..start();
        final result = await WelcomeOfferRepositoryImpl(
          FakeWelcomeOfferSource(environment(scenario)),
        ).load();
        switch (scenario) {
          case FakeAuthScenario.success || FakeAuthScenario.slow:
            expect((result as Success<WelcomeOffer>).value.points, 3500);
          case FakeAuthScenario.offline:
            expect((result as Failure).error, isA<OfflineFailure>());
          case FakeAuthScenario.serverError:
            expect((result as Failure).error, isA<ServerFailure>());
          case FakeAuthScenario.rateLimited:
            expect((result as Failure).error, isA<ValidationFailure>());
          case FakeAuthScenario.notConfigured:
            expect((result as Failure).error, isA<BusinessFailure>());
        }
        expect(
          watch.elapsedMilliseconds,
          greaterThanOrEqualTo(scenario == FakeAuthScenario.slow ? 2900 : 550),
        );
      },
    );
  }
  test('deterministic blocked suffix and new email rule', () async {
    final env = environment();
    final phone = await PhoneSignInRepositoryImpl(FakePhoneSignInSource(env))
        .requestOtp(
          IdentifierClassifier.classify('09123450000') as Phone,
          rememberDevice: false,
        );
    expect((phone as Failure).error, isA<ValidationFailure>());
    final email = await EmailSignInRepositoryImpl(FakeEmailSignInSource(env))
        .checkEmail(
          IdentifierClassifier.classify('new.person@EXAMPLE.COM') as Email,
        );
    expect(
      (email as Success<EmailAccountStatus>).value,
      EmailAccountStatus.notRegistered,
    );
  });
  test(
    'remote stubs map typed not-configured failures through same mappers',
    () async {
      final results = await Future.wait<Result<Object?>>([
        const WelcomeOfferRepositoryImpl(RemoteWelcomeOfferSource()).load(),
        const PhoneSignInRepositoryImpl(RemotePhoneSignInSource()).requestOtp(
          IdentifierClassifier.classify('09123456789') as Phone,
          rememberDevice: false,
        ),
        const EmailSignInRepositoryImpl(RemoteEmailSignInSource()).checkEmail(
          IdentifierClassifier.classify('user@example.com') as Email,
        ),
      ]);
      for (final result in results) {
        expect(
          (result as Failure).error,
          isA<BusinessFailure>().having(
            (e) => e.code,
            'code',
            'backend_not_configured',
          ),
        );
      }
      expect(
        await const SocialSignInRepositoryImpl(RemoteSocialSignInSource())
            .start(SocialProvider.google),
        isA<Failure<void>>(),
      );
    },
  );
}
