import '../domain/models.dart';

enum AuthDataFault {
  blocked,
  rateLimited,
  offline,
  server,
  notConfigured,
  unavailable,
  cancelled,
}

final class AuthDataException implements Exception {
  const AuthDataException(this.fault);
  final AuthDataFault fault;
}

final class WelcomeOfferDto {
  const WelcomeOfferDto(this.points);
  final int points;
  WelcomeOffer toDomain() => WelcomeOffer(points);
}

final class OtpChallengeDto {
  const OtpChallengeDto({
    required this.id,
    required this.length,
    required this.resendSeconds,
    required this.expires,
    required this.destination,
  });
  final String id, destination;
  final int length, resendSeconds;
  final DateTime expires;
  OtpChallenge toDomain() => OtpChallenge(
    challengeId: id,
    codeLength: length,
    resendAfter: Duration(seconds: resendSeconds),
    expiresAt: expires,
    maskedDestination: destination,
  );
}

final class EmailStatusDto {
  const EmailStatusDto(this.registered);
  final bool registered;
  EmailAccountStatus toDomain() => registered
      ? EmailAccountStatus.registered
      : EmailAccountStatus.notRegistered;
}

final class SocialStartDto {
  const SocialStartDto();
}

abstract interface class WelcomeOfferSource {
  Future<WelcomeOfferDto> load(AuthCancellation? cancellation);
}

abstract interface class PhoneSignInSource {
  Future<OtpChallengeDto> requestOtp(
    String e164,
    bool rememberDevice,
    AuthCancellation? cancellation,
  );
}

abstract interface class EmailSignInSource {
  Future<EmailStatusDto> checkEmail(
    String email,
    AuthCancellation? cancellation,
  );
}

abstract interface class SocialSignInSource {
  Future<SocialStartDto> start(
    SocialProvider provider,
    AuthCancellation? cancellation,
  );
}
