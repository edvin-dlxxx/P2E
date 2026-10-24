// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_entry_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AuthEntryController)
final authEntryControllerProvider = AuthEntryControllerProvider._();

final class AuthEntryControllerProvider
    extends $NotifierProvider<AuthEntryController, AuthEntryState> {
  AuthEntryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authEntryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authEntryControllerHash();

  @$internal
  @override
  AuthEntryController create() => AuthEntryController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthEntryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthEntryState>(value),
    );
  }
}

String _$authEntryControllerHash() =>
    r'e18facbad18c48fadd940b5901d67a5c11e1e8fc';

abstract class _$AuthEntryController extends $Notifier<AuthEntryState> {
  AuthEntryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthEntryState, AuthEntryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthEntryState, AuthEntryState>,
              AuthEntryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
