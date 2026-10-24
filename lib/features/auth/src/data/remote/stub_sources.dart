import '../../domain/models.dart';
import '../sources.dart';

/// OD-2: no endpoint/SDK/network is invented. Repositories map this typed fault.
Never _unconfigured() =>
    throw const AuthDataException(AuthDataFault.notConfigured);

final class RemoteWelcomeOfferSource implements WelcomeOfferSource {
  const RemoteWelcomeOfferSource();
  @override
  Future<WelcomeOfferDto> load(AuthCancellation? cancellation) async =>
      _unconfigured();
}

final class RemotePhoneSignInSource implements PhoneSignInSource {
  const RemotePhoneSignInSource();
  @override
  Future<OtpChallengeDto> requestOtp(
    String e164,
    bool rememberDevice,
    AuthCancellation? cancellation,
  ) async => _unconfigured();
}

final class RemoteEmailSignInSource implements EmailSignInSource {
  const RemoteEmailSignInSource();
  @override
  Future<EmailStatusDto> checkEmail(
    String email,
    AuthCancellation? cancellation,
  ) async => _unconfigured();
}

final class RemoteSocialSignInSource implements SocialSignInSource {
  const RemoteSocialSignInSource();
  @override
  Future<SocialStartDto> start(
    SocialProvider provider,
    AuthCancellation? cancellation,
  ) async => _unconfigured();
}
