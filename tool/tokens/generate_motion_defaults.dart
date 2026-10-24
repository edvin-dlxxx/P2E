import 'dart:io';

import 'generate_buttons.dart' as helpers;

Future<void> main(List<String> args) async {
  const source = 'design/engineering/button_motion.json';
  final data = helpers.readJson(source);
  if (data['curve'] != 'easeOut' ||
      data['restScale'] != 1 ||
      data['pressedScale'] >= 1 ||
      data['pressedScale'] <= 0) {
    throw StateError('Unsupported engineering motion defaults');
  }
  final text = await helpers.format('''
// GENERATED – do not edit
// Source: $source. D-021; engineering-defined, NOT Figma-extracted.
import 'package:flutter/animation.dart';
abstract final class ButtonMotion {
  static const pressedScale = ${data['pressedScale']};
  static const restScale = ${data['restScale']};
  static const pressDuration = Duration(milliseconds: ${data['pressMilliseconds']});
  static const releaseDuration = Duration(milliseconds: ${data['releaseMilliseconds']});
  static const curve = Curves.${data['curve']};
}
''');
  final file = File(
    'packages/design_system/lib/src/tokens/generated/button_motion.g.dart',
  );
  if (args.contains('--check')) {
    if (!file.existsSync() || file.readAsStringSync() != text) {
      throw StateError('Stale engineering motion tokens');
    }
  } else {
    file.writeAsStringSync(text);
  }
}
