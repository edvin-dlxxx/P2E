import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final row
      in jsonDecode(await rootBundle.loadString('FontManifest.json')) as List) {
    final family = row['family'] as String;
    if (!family.endsWith('Outfit') && !family.endsWith('Vazirmatn')) {
      continue;
    }
    final loader = FontLoader(
      family.startsWith('packages/')
          ? family
          : 'packages/p2e_design_system/$family',
    );
    for (final face in row['fonts'] as List) {
      loader.addFont(rootBundle.load(face['asset'] as String));
    }
    await loader.load();
  }
  await testMain();
}
