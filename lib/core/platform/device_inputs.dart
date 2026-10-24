import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// D-052: neutral OS inputs, independent of app locale/preferences policy.
final deviceLocalesProvider = NotifierProvider<DeviceLocales, List<Locale>>(
  DeviceLocales.new,
);

class DeviceLocales extends Notifier<List<Locale>> with WidgetsBindingObserver {
  @override
  List<Locale> build() {
    WidgetsBinding.instance.addObserver(this);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(this));
    return List.unmodifiable(
      WidgetsBinding.instance.platformDispatcher.locales,
    );
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    state = List.unmodifiable(locales ?? const <Locale>[]);
  }
}

/// Device platform is an input, not an alternate product behavior policy.
final deviceTargetPlatformProvider = Provider<TargetPlatform>(
  (ref) => defaultTargetPlatform,
);
