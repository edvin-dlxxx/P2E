// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appLocale)
final appLocaleProvider = AppLocaleProvider._();

final class AppLocaleProvider
    extends $FunctionalProvider<Locale, Locale, Locale>
    with $Provider<Locale> {
  AppLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLocaleHash();

  @$internal
  @override
  $ProviderElement<Locale> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Locale create(Ref ref) {
    return appLocale(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Locale value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Locale>(value),
    );
  }
}

String _$appLocaleHash() => r'c9eaf52ce4cfc33cc9788a8f6634db56e87f7d1e';

@ProviderFor(appSkin)
final appSkinProvider = AppSkinProvider._();

final class AppSkinProvider
    extends $FunctionalProvider<SkinDefinition, SkinDefinition, SkinDefinition>
    with $Provider<SkinDefinition> {
  AppSkinProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSkinProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSkinHash();

  @$internal
  @override
  $ProviderElement<SkinDefinition> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SkinDefinition create(Ref ref) {
    return appSkin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SkinDefinition value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SkinDefinition>(value),
    );
  }
}

String _$appSkinHash() => r'69dd0925201cf108de14600a41df35169ef85648';
