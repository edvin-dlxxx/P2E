import 'dart:convert';

import 'package:flutter/services.dart';

abstract final class ViewerFonts {
  static bool loaded = false;
  static Future<void>? _loading;
  static Future<void> ensureLoaded() => _loading ??= _load();
  static Future<void> _load() async {
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
    loaded = true;
  }
}
