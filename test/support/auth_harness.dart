import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mygame_p2e/app/app.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:mygame_p2e/core/errors/app_failure.dart';
import 'package:mygame_p2e/features/auth/auth.dart';
import 'package:p2e_design_system/design_system.dart';

class ImmediateRepositories
    implements
        WelcomeOfferRepository,
        PhoneSignInRepository,
        EmailSignInRepository,
        SocialSignInRepository {
  @override
  Future<Result<WelcomeOffer>> load({AuthCancellation? cancellation}) async =>
      const Success(WelcomeOffer(3500));
  @override
  Future<Result<OtpChallenge>> requestOtp(
    Phone phone, {
    required bool rememberDevice,
    AuthCancellation? cancellation,
  }) async => Success(
    OtpChallenge(
      challengeId: 'test-challenge',
      codeLength: 6,
      resendAfter: const Duration(seconds: 60),
      expiresAt: DateTime.utc(2026, 10, 23),
      maskedDestination: '••••',
    ),
  );
  @override
  Future<Result<EmailAccountStatus>> checkEmail(
    Email email, {
    AuthCancellation? cancellation,
  }) async => Success(
    email.normalized.startsWith('new')
        ? EmailAccountStatus.notRegistered
        : EmailAccountStatus.registered,
  );
  @override
  Future<Result<void>> start(
    SocialProvider provider, {
    AuthCancellation? cancellation,
  }) async => const Failure(BusinessFailure('social_unavailable'));
}

Future<void> pumpAuth(
  WidgetTester tester, {
  double width = 402,
  double height = 874,
  String locale = 'en',
  Brightness brightness = Brightness.dark,
  double scale = 1,
  bool keyboard = false,
  String raw = '',
  bool focused = false,
  ImmediateRepositories? repositories,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, height);
  final repos = repositories ?? ImmediateRepositories();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(
          const AppConfig(environment: AppEnvironment.stage),
        ),
        appLocaleProvider.overrideWithValue(Locale(locale)),
        welcomeOfferRepositoryProvider.overrideWith((_) => repos),
        phoneSignInRepositoryProvider.overrideWith((_) => repos),
        emailSignInRepositoryProvider.overrideWith((_) => repos),
        socialSignInRepositoryProvider.overrideWith((_) => repos),
      ],
      child: RepaintBoundary(
        key: const ValueKey('auth-boundary'),
        child: MediaQuery(
          data: MediaQueryData(
            size: Size(width, height),
            padding: const EdgeInsets.only(top: 55),
            viewPadding: const EdgeInsets.only(top: 55),
            viewInsets: EdgeInsets.only(bottom: keyboard ? 331 : 0),
            platformBrightness: brightness,
            textScaler: TextScaler.linear(scale),
            disableAnimations: true,
          ),
          child: const P2EApp(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => precacheImage(
      const AssetImage(
        'assets/images/auth/entry_illustration.png',
        package: 'p2e_design_system',
      ),
      tester.element(find.byType(P2EApp)),
    ),
  );
  await tester.pumpAndSettle();
  if (focused || raw.isNotEmpty) {
    final field = tester.widget<AppTextField>(find.byType(AppTextField));
    field.options.focusNode!.requestFocus();
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), raw);
    await tester.pumpAndSettle();
  }
}
