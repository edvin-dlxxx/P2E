import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_config.g.dart';

enum AppEnvironment { dev, stage, prod }

enum BackendMode { fake, remote }

/// Compile-time environment selection; never contains secrets.
final class AppConfig {
  const AppConfig({
    required this.environment,
    BackendMode? backendMode,
    this.termsUrl = '',
    this.privacyUrl = '',
  }) : backendMode =
           backendMode ??
           (environment == AppEnvironment.dev
               ? BackendMode.fake
               : BackendMode.remote);
  final AppEnvironment environment;
  final BackendMode backendMode;
  final String termsUrl, privacyUrl;

  factory AppConfig.fromValues(Map<String, String> values) {
    final environment = AppEnvironment.values.firstWhere(
      (e) => e.name == (values['APP_ENV'] ?? 'dev'),
      orElse: () => throw const FormatException('Invalid APP_ENV'),
    );
    final mode = BackendMode.values.firstWhere(
      (e) =>
          e.name ==
          (values['BACKEND_MODE'] ??
              (environment == AppEnvironment.dev ? 'fake' : 'remote')),
      orElse: () => throw const FormatException('Invalid BACKEND_MODE'),
    );
    if (environment == AppEnvironment.prod && mode == BackendMode.fake) {
      throw const FormatException('Production cannot use fake backend');
    }
    for (final key in ['TERMS_URL', 'PRIVACY_URL']) {
      final url = values[key] ?? '';
      if (url.isNotEmpty) {
        final uri = Uri.tryParse(url);
        if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
          throw FormatException('Invalid $key');
        }
      }
    }
    return AppConfig(
      environment: environment,
      backendMode: mode,
      termsUrl: values['TERMS_URL'] ?? '',
      privacyUrl: values['PRIVACY_URL'] ?? '',
    );
  }
  factory AppConfig.fromEnvironment() => AppConfig.fromValues({
    'APP_ENV': const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
    'BACKEND_MODE': const String.fromEnvironment(
      'BACKEND_MODE',
      defaultValue:
          String.fromEnvironment('APP_ENV', defaultValue: 'dev') == 'dev'
          ? 'fake'
          : 'remote',
    ),
    'TERMS_URL': const String.fromEnvironment('TERMS_URL'),
    'PRIVACY_URL': const String.fromEnvironment('PRIVACY_URL'),
  });
}

@Riverpod(keepAlive: true, dependencies: [])
AppConfig appConfig(Ref ref) =>
    throw StateError('AppConfig must be supplied by bootstrap');
