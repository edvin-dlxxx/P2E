import 'dart:io';

import '../tokens/generate_buttons.dart' as helpers;

Future<void> main(List<String> args) async {
  const evidence =
      'docs/design-system/evidence/2026-10-20-text-only-examples.json';
  final rows = helpers.readJson(evidence)['examples'] as List;
  final code = await helpers.format('''
// GENERATED – do not edit
// Read-only instance evidence: $evidence
const textOnlyExamples = ${helpers.literal(rows)};
''');
  final file = File(
    'apps/design_system_viewer/lib/verification/generated/text_only_examples.g.dart',
  );
  if (args.contains('--check')) {
    if (!file.existsSync() || file.readAsStringSync() != code) {
      throw StateError('Stale text-only examples');
    }
  } else {
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(code);
  }
}
