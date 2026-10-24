import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

import '../features/auth/auth.dart';
import '../features/auth/auth_data.dart';
import '../core/diagnostics/app_logger.dart';
import 'config/app_config.dart';
import '../shared/platform/external_links.dart';
import 'platform/external_link_adapter.dart';

/// Compile-time dead branch in remote builds: fake factories/marker are removed.
const _useFake =
    String.fromEnvironment(
      'BACKEND_MODE',
      defaultValue:
          String.fromEnvironment('APP_ENV', defaultValue: 'dev') == 'dev'
          ? 'fake'
          : 'remote',
    ) ==
    'fake';

List<Override> authBindings(AppConfig config) => [
  externalLinkPortProvider.overrideWithValue(SystemExternalLinks(config)),
  welcomeOfferRepositoryProvider.overrideWith((ref) {
    if (_useFake && config.backendMode == BackendMode.fake) {
      final env = FakeAuthEnvironment(
        scenario: () => ref.read(fakeAuthScenarioProvider),
        log: (scenario) => AppLogger().log(
          LogLevel.debug,
          'Auth fake',
          fields: {'scenario': scenario},
        ),
      );
      return WelcomeOfferRepositoryImpl(FakeWelcomeOfferSource(env));
    }
    return const WelcomeOfferRepositoryImpl(RemoteWelcomeOfferSource());
  }),
  phoneSignInRepositoryProvider.overrideWith((ref) {
    if (_useFake && config.backendMode == BackendMode.fake) {
      return PhoneSignInRepositoryImpl(
        FakePhoneSignInSource(
          FakeAuthEnvironment(
            scenario: () => ref.read(fakeAuthScenarioProvider),
          ),
        ),
      );
    }
    return const PhoneSignInRepositoryImpl(RemotePhoneSignInSource());
  }),
  emailSignInRepositoryProvider.overrideWith((ref) {
    if (_useFake && config.backendMode == BackendMode.fake) {
      return EmailSignInRepositoryImpl(
        FakeEmailSignInSource(
          FakeAuthEnvironment(
            scenario: () => ref.read(fakeAuthScenarioProvider),
          ),
        ),
      );
    }
    return const EmailSignInRepositoryImpl(RemoteEmailSignInSource());
  }),
  socialSignInRepositoryProvider.overrideWith((ref) {
    if (_useFake && config.backendMode == BackendMode.fake) {
      return SocialSignInRepositoryImpl(
        FakeSocialSignInSource(
          FakeAuthEnvironment(
            scenario: () => ref.read(fakeAuthScenarioProvider),
          ),
        ),
      );
    }
    return const SocialSignInRepositoryImpl(RemoteSocialSignInSource());
  }),
];
