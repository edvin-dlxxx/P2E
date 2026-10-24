// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_flow.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auto-dispose: only auth controller/routes listen; no global keepAlive or extra.

@ProviderFor(AuthFlow)
final authFlowProvider = AuthFlowProvider._();

/// Auto-dispose: only auth controller/routes listen; no global keepAlive or extra.
final class AuthFlowProvider
    extends $NotifierProvider<AuthFlow, AuthFlowResult?> {
  /// Auto-dispose: only auth controller/routes listen; no global keepAlive or extra.
  AuthFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authFlowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authFlowHash();

  @$internal
  @override
  AuthFlow create() => AuthFlow();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthFlowResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthFlowResult?>(value),
    );
  }
}

String _$authFlowHash() => r'58ff6c501fc81475353adebbd93be7708e9c1227';

/// Auto-dispose: only auth controller/routes listen; no global keepAlive or extra.

abstract class _$AuthFlow extends $Notifier<AuthFlowResult?> {
  AuthFlowResult? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthFlowResult?, AuthFlowResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthFlowResult?, AuthFlowResult?>,
              AuthFlowResult?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
