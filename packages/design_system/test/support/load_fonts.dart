import 'dart:convert';

import 'package:flutter/services.dart';

/// Tests measuring layout must load the same bundled faces as the viewer.
Future<void> loadBundledFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    if (!['Outfit', 'Vazirmatn'].contains(family['family'])) continue;
    final loader = FontLoader('packages/p2e_design_system/${family['family']}');
    for (final face in family['fonts'] as List) {
      loader.addFont(rootBundle.load(face['asset'] as String));
    }
    await loader.load();
  }
  if (!manifest.any((f) => f['family'] == 'Outfit')) {
    throw StateError('No bundled Outfit; layout measurements would be invalid');
  }
}
