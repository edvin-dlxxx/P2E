import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:mygame_p2e/app/startup/startup_controller.dart';
import 'package:mygame_p2e/core/errors/app_failure.dart';
import 'package:mygame_p2e/core/diagnostics/app_logger.dart';
import 'package:mygame_p2e/shared/formatting/digits.dart';
import 'package:mygame_p2e/shared/session/session.dart';

void main() {
  test('environment parsing rejects unknown values', () {
    for (final environment in AppEnvironment.values) {
      expect(
        AppConfig.fromValues({'APP_ENV': environment.name}).environment,
        environment,
      );
    }
    expect(AppConfig.fromValues({}).environment, AppEnvironment.dev);
    expect(
      () => AppConfig.fromValues({'APP_ENV': 'secret'}),
      throwsFormatException,
    );
  });
  test(
    'startup reopens session gate on sign-in, expiry and sign-out',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final seen = <StartupState>[];
      container.listen(
        startupControllerProvider,
        (_, next) => seen.add(next),
        fireImmediately: true,
      );
      await Future<void>.delayed(Duration.zero);
      expect(seen, [
        StartupState.initializing,
        StartupState.sessionCheck,
        StartupState.entry,
      ]);
      for (final status in [
        SessionStatus.signedIn,
        SessionStatus.expired,
        SessionStatus.signedIn,
        SessionStatus.signedOut,
      ]) {
        seen.clear();
        container.read(sessionControllerProvider.notifier).update(status);
        await Future<void>.delayed(Duration.zero);
        expect(seen, [
          StartupState.sessionCheck,
          status == SessionStatus.signedIn
              ? StartupState.ready
              : StartupState.entry,
        ]);
      }
    },
  );
  test('startup stale work cannot open a signed-out session', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.listen(startupControllerProvider, (_, _) {});
    container
        .read(sessionControllerProvider.notifier)
        .update(SessionStatus.signedIn);
    container
        .read(sessionControllerProvider.notifier)
        .update(SessionStatus.signedOut);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(startupControllerProvider), StartupState.entry);
  });
  test(
    'Result maps success and preserves failure without executing callbacks',
    () {
      expect(const Success(2).map((n) => n * 3).fold((n) => n, (_) => -1), 6);
      expect(
        const Success(2)
            .flatMap((n) => Success(n + 1))
            .fold((n) => n, (_) => -1),
        3,
      );
      const error = OfflineFailure(reference: 'incident');
      final failed = const Failure<int>(error)
          .map<int>((_) => throw StateError('unreachable'));
      expect(failed.fold((_) => null, (failure) => failure), same(error));
      final fields = {'email': 'invalid'};
      final validation = ValidationFailure(fields);
      fields.clear();
      expect(validation.fields, {'email': 'invalid'});
      expect(() => validation.fields.clear(), throwsUnsupportedError);
    },
  );
  test(
    'Persian, Arabic and mixed input normalize without changing other text',
    () {
      expect(
        normalizeDigits('۰۱۲۳۴۵۶۷۸۹ ٠١٢٣٤٥٦٧٨٩ abc'),
        '0123456789 0123456789 abc',
      );
      expect(localizedDigits('12.٣۴', languageCode: 'fa'), '۱۲.۳۴');
      expect(localizedDigits('۱۲.٣4', languageCode: 'en'), '12.34');
    },
  );
  test('logger redacts nested PII before every sink and filters levels', () {
    final lines = <String>[];
    final logger = AppLogger(sink: lines.add);
    logger.log(LogLevel.debug, 'ignored');
    logger.log(
      LogLevel.info,
      'phone +98 912 123 4567 OTP=123456 Bearer abc-secret',
      fields: {
        'phone': '۰۹۱۲۱۲۳۴۵۶۷',
        'nested': [
          {'accessToken': 'opaque-secret', 'otp': 123456},
        ],
        'message': '٠٩١٢١٢٣٤٥٦٧',
      },
    );
    expect(lines, hasLength(1));
    for (final secret in [
      '123456',
      '912',
      'abc-secret',
      'opaque-secret',
      '۰۹۱۲',
      '٠٩١٢',
    ]) {
      expect(lines.single, isNot(contains(secret)));
    }
    expect(lines.single, contains('[REDACTED]'));
  });
}
