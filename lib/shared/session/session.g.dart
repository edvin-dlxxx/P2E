// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SessionController)
final sessionControllerProvider = SessionControllerProvider._();

final class SessionControllerProvider
    extends $NotifierProvider<SessionController, SessionStatus> {
  SessionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionControllerHash();

  @$internal
  @override
  SessionController create() => SessionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionStatus>(value),
    );
  }
}

String _$sessionControllerHash() => r'7a5901fcaec62cc7ed90fe3382411fcc3df18e2b';

abstract class _$SessionController extends $Notifier<SessionStatus> {
  SessionStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SessionStatus, SessionStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SessionStatus, SessionStatus>,
              SessionStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
