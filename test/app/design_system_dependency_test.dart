import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  test(
    'product consumes the shared package and bundled package fonts',
    () async {
      expect(SizeClass.fromWidth(600), SizeClass.medium);
      final manifest =
          jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
      for (final family in ['Outfit', 'Vazirmatn']) {
        final record = manifest.singleWhere(
          (r) => r['family'] == 'packages/p2e_design_system/$family',
        );
        for (final face in record['fonts'] as List) {
          expect(
            (await rootBundle.load(face['asset'] as String)).lengthInBytes,
            greaterThan(0),
          );
        }
      }
    },
  );
}
