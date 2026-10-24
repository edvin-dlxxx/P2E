import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in ['Outfit', 'Vazirmatn']) {
    final name = 'packages/p2e_design_system/$family';
    final record = manifest.singleWhere((r) => r['family'] == name);
    final loader = FontLoader(name);
    for (final face in record['fonts'] as List) {
      loader.addFont(rootBundle.load(face['asset'] as String));
    }
    await loader.load();
  }
  await testMain();
}
