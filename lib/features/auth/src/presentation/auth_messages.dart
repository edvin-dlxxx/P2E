import 'package:mygame_p2e/core/errors/app_failure.dart';

enum AuthMessage {
  offline,
  server,
  notConfigured,
  socialUnavailable,
  blocked,
  rateLimited,
  unknown,
  urlMissing,
  urlFailed,
}

final class AuthFailurePresentation {
  const AuthFailurePresentation({this.field, this.toast});
  final AuthMessage? field, toast;
}

abstract final class AuthFailureMapper {
  static AuthFailurePresentation map(AppFailure failure) => switch (failure) {
    ValidationFailure(:final fields) => AuthFailurePresentation(
      field: fields['identifier'] == 'rate_limited'
          ? AuthMessage.rateLimited
          : AuthMessage.blocked,
    ),
    OfflineFailure() || NetworkFailure() || TimeoutFailure() =>
      const AuthFailurePresentation(toast: AuthMessage.offline),
    BusinessFailure(code: 'backend_not_configured') =>
      const AuthFailurePresentation(toast: AuthMessage.notConfigured),
    BusinessFailure(code: 'social_unavailable') =>
      const AuthFailurePresentation(toast: AuthMessage.socialUnavailable),
    BusinessFailure(code: 'url_missing') => const AuthFailurePresentation(
      toast: AuthMessage.urlMissing,
    ),
    BusinessFailure(code: 'url_failed') => const AuthFailurePresentation(
      toast: AuthMessage.urlFailed,
    ),
    ServerFailure() => const AuthFailurePresentation(toast: AuthMessage.server),
    _ => const AuthFailurePresentation(toast: AuthMessage.unknown),
  };
}
