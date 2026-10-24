import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  test(
    'all generated font families are bundled in pubspec/FontManifest',
    () async {
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
      final pubspec = File('pubspec.yaml').readAsStringSync();
      for (final family in {
        ...TypographyTokens.byId.values.map(
          (v) => v.style.fontFamily!.split('/').last,
        ),
        'Vazirmatn',
      }) {
        expect(pubspec, contains('family: $family'));
        final faces =
            manifest.singleWhere((f) => f['family'] == family)['fonts'] as List;
        for (final face in faces) {
          expect(File(face['asset'] as String).existsSync(), isTrue);
          expect(pubspec, contains(face['asset']));
          expect(
            (await rootBundle.load(face['asset'] as String)).lengthInBytes,
            greaterThan(0),
          );
        }
      }
    },
  );
}
