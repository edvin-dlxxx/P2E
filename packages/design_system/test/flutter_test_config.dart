import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'support/load_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadBundledFonts();
  await testMain();
}
