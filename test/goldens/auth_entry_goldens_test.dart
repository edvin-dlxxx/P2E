import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/auth_harness.dart';

void main() {
  final cases = [
    for (final locale in ['en', 'fa'])
      for (final brightness in Brightness.values)
        for (final state in ['idle', 'focused', 'phone', 'email'])
          (locale, brightness, state, 1.0, 402.0),
    ('fa', Brightness.dark, 'email', 2.0, 402.0),
    ('en', Brightness.dark, 'idle', 1.0, 744.0),
  ];
  for (final (locale, brightness, state, scale, width) in cases) {
    final name =
        'auth-$state-$locale-${brightness.name}-$scale-${width.toInt()}';
    testWidgets(
      name,
      (tester) async {
        addTearDown(tester.view.reset);
        await pumpAuth(
          tester,
          width: width,
          locale: locale,
          brightness: brightness,
          scale: scale,
          keyboard: state != 'idle',
          focused: state != 'idle',
          raw: switch (state) {
            'phone' => '+98 912 827 9503',
            'email' => 'me.ardeshir.rashidi@gmail.com',
            _ => '',
          },
        );
        expect(tester.takeException(), isNull);
        await expectLater(
          find.byKey(const ValueKey('auth-boundary')),
          matchesGoldenFile('baselines/windows/$name.png'),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      },
      tags: ['golden'],
      skip: !Platform.isWindows,
    );
  }
}
