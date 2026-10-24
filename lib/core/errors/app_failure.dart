/// Architecture §14.1. These are frontend failures, not transport DTOs.
sealed class AppFailure {
  const AppFailure({this.reference});
  final String? reference;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({super.reference});
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure({super.reference});
}

final class OfflineFailure extends AppFailure {
  const OfflineFailure({super.reference});
}

final class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({super.reference});
}

final class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure({super.reference});
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure({super.reference});
}

final class VersionUnsupportedFailure extends AppFailure {
  const VersionUnsupportedFailure({super.reference});
}

final class MaintenanceFailure extends AppFailure {
  const MaintenanceFailure({super.reference});
}

final class ValidationFailure extends AppFailure {
  ValidationFailure(Map<String, String> fields, {super.reference})
    : fields = Map.unmodifiable(fields);

  /// Frontend field IDs to localization/error codes, never input values.
  final Map<String, String> fields;
}

final class BusinessFailure extends AppFailure {
  const BusinessFailure(this.code, {super.reference});
  final String code;
}

final class ServerFailure extends AppFailure {
  const ServerFailure({super.reference});
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure({super.reference});
}

enum ErrorScope { section, screen, global }

sealed class Result<T> {
  const Result();
  R fold<R>(
    R Function(T value) success,
    R Function(AppFailure failure) failure,
  ) => switch (this) {
    Success<T>(:final value) => success(value),
    Failure<T>(:final error) => failure(error),
  };
  Result<R> map<R>(R Function(T value) transform) =>
      fold((value) => Success(transform(value)), (error) => Failure(error));
  Result<R> flatMap<R>(Result<R> Function(T value) transform) =>
      fold(transform, (error) => Failure(error));
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppFailure error;
}
