import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../core/diagnostics/app_logger.dart';
import 'app.dart';
import 'auth_bindings.dart';
import 'config/app_config.dart';

/// Neutral composition seams. Production main uses neither hook.
ProviderScope composeApp({
  required AppConfig config,
  Widget Function(Widget root)? rootWrapper,
  List<Override> providerOverrides = const [],
}) => ProviderScope(
  overrides: [
    appConfigProvider.overrideWithValue(config),
    ...authBindings(config),
    ...providerOverrides,
  ],
  child: rootWrapper?.call(const P2EApp()) ?? const P2EApp(),
);

void bootstrap({
  Widget Function(Widget root)? rootWrapper,
  List<Override> providerOverrides = const [],
}) {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  AppLogger().log(
    LogLevel.info,
    'Application bootstrap',
    fields: {'environment': config.environment.name},
  );
  runApp(
    composeApp(
      config: config,
      rootWrapper: rootWrapper,
      providerOverrides: providerOverrides,
    ),
  );
}
