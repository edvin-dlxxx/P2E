import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system_viewer/viewer_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await ViewerFonts.ensureLoaded();
  await testMain();
}
