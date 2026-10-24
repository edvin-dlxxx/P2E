import 'package:mygame_p2e/core/errors/app_failure.dart';

import 'identifier.dart';
import 'models.dart';

abstract interface class WelcomeOfferRepository {
  Future<Result<WelcomeOffer>> load({AuthCancellation? cancellation});
}

abstract interface class PhoneSignInRepository {
  Future<Result<OtpChallenge>> requestOtp(
    Phone phone, {
    required bool rememberDevice,
    AuthCancellation? cancellation,
  });
}

abstract interface class EmailSignInRepository {
  Future<Result<EmailAccountStatus>> checkEmail(
    Email email, {
    AuthCancellation? cancellation,
  });
}

abstract interface class SocialSignInRepository {
  Future<Result<void>> start(
    SocialProvider provider, {
    AuthCancellation? cancellation,
  });
}
