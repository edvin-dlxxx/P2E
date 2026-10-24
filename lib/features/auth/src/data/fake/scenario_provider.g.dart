// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scenario_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fakeAuthScenario)
final fakeAuthScenarioProvider = FakeAuthScenarioProvider._();

final class FakeAuthScenarioProvider
    extends
        $FunctionalProvider<
          FakeAuthScenario,
          FakeAuthScenario,
          FakeAuthScenario
        >
    with $Provider<FakeAuthScenario> {
  FakeAuthScenarioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fakeAuthScenarioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fakeAuthScenarioHash();

  @$internal
  @override
  $ProviderElement<FakeAuthScenario> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FakeAuthScenario create(Ref ref) {
    return fakeAuthScenario(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FakeAuthScenario value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FakeAuthScenario>(value),
    );
  }
}

String _$fakeAuthScenarioHash() => r'd86275d3bb94bbf60457dffaa893467c8cd35074';
