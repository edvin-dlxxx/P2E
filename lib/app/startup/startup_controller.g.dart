// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Architecture §11.3: gates derive only from shared read models.

@ProviderFor(StartupController)
final startupControllerProvider = StartupControllerProvider._();

/// Architecture §11.3: gates derive only from shared read models.
final class StartupControllerProvider
    extends $NotifierProvider<StartupController, StartupState> {
  /// Architecture §11.3: gates derive only from shared read models.
  StartupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupControllerHash();

  @$internal
  @override
  StartupController create() => StartupController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartupState>(value),
    );
  }
}

String _$startupControllerHash() => r'ec18a967e268ccaa4624bda2a08b930e3ae6ecb3';

/// Architecture §11.3: gates derive only from shared read models.

abstract class _$StartupController extends $Notifier<StartupState> {
  StartupState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<StartupState, StartupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<StartupState, StartupState>,
              StartupState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
