import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/app/app.dart';
import 'package:mygame_p2e/core/platform/device_inputs.dart';

void main() {
  testWidgets(
    'neutral device locales observe OS changes; app policy remains fa',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final subscription = container.listen(deviceLocalesProvider, (_, _) {});
      addTearDown(subscription.close);
      tester.platformDispatcher.localesTestValue = [
        const Locale('en', 'US'),
        const Locale('de', 'DE'),
      ];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await tester.pump();
      expect(container.read(deviceLocalesProvider), [
        const Locale('en', 'US'),
        const Locale('de', 'DE'),
      ]);
      expect(container.read(appLocaleProvider), const Locale('fa'));
      tester.platformDispatcher.localesTestValue = [const Locale('de', 'DE')];
      await tester.pump();
      expect(container.read(deviceLocalesProvider), [const Locale('de', 'DE')]);
      expect(container.read(appLocaleProvider), const Locale('fa'));
    },
  );
}
