import 'package:mygame_p2e/core/errors/app_failure.dart';

import '../domain/identifier.dart';
import '../domain/models.dart';
import '../domain/repositories.dart';
import 'sources.dart';

Future<Result<T>> _map<T, D>(
  Future<D> Function() request,
  T Function(D) map,
) async {
  try {
    return Success(map(await request()));
  } on AuthDataException catch (e) {
    return Failure(switch (e.fault) {
      AuthDataFault.blocked => ValidationFailure({'identifier': 'blocked'}),
      AuthDataFault.rateLimited => ValidationFailure({
        'identifier': 'rate_limited',
      }),
      AuthDataFault.offline => const OfflineFailure(),
      AuthDataFault.server => const ServerFailure(),
      AuthDataFault.notConfigured => const BusinessFailure(
        'backend_not_configured',
      ),
      AuthDataFault.unavailable => const BusinessFailure('social_unavailable'),
      AuthDataFault.cancelled => const BusinessFailure('cancelled'),
    });
  } catch (_) {
    return const Failure(UnknownFailure());
  }
}

final class WelcomeOfferRepositoryImpl implements WelcomeOfferRepository {
  const WelcomeOfferRepositoryImpl(this.source);
  final WelcomeOfferSource source;
  @override
  Future<Result<WelcomeOffer>> load({AuthCancellation? cancellation}) =>
      _map(() => source.load(cancellation), (dto) => dto.toDomain());
}

final class PhoneSignInRepositoryImpl implements PhoneSignInRepository {
  const PhoneSignInRepositoryImpl(this.source);
  final PhoneSignInSource source;
  @override
  Future<Result<OtpChallenge>> requestOtp(
    Phone phone, {
    required bool rememberDevice,
    AuthCancellation? cancellation,
  }) => _map(
    () => source.requestOtp(phone.e164, rememberDevice, cancellation),
    (dto) => dto.toDomain(),
  );
}

final class EmailSignInRepositoryImpl implements EmailSignInRepository {
  const EmailSignInRepositoryImpl(this.source);
  final EmailSignInSource source;
  @override
  Future<Result<EmailAccountStatus>> checkEmail(
    Email email, {
    AuthCancellation? cancellation,
  }) => _map(
    () => source.checkEmail(email.normalized, cancellation),
    (dto) => dto.toDomain(),
  );
}

final class SocialSignInRepositoryImpl implements SocialSignInRepository {
  const SocialSignInRepositoryImpl(this.source);
  final SocialSignInSource source;
  @override
  Future<Result<void>> start(
    SocialProvider provider, {
    AuthCancellation? cancellation,
  }) => _map<void, SocialStartDto>(
    () => source.start(provider, cancellation),
    (_) {},
  );
}
