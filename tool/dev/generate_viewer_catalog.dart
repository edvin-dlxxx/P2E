import 'dart:io';

import '../tokens/generate_buttons.dart' as helpers;

Future<void> main(List<String> args) async {
  final source = helpers.readJson(
    'docs/design-system/contracts/app_button.spec.json',
  );
  final labels = <String, String>{};
  for (final row in source['variants'] as List) {
    final properties = row['setProperties'] as Map;
    final label = properties.entries
        .where((e) => e.key.toString().startsWith('Label#'))
        .firstOrNull;
    if (label != null) {
      labels[row['variantId'] as String] =
          label.value['defaultValue'] as String;
    }
  }
  final code = await helpers.format('''
// GENERATED – do not edit
// Source: docs/design-system/contracts/app_button.spec.json; source text only.
const buttonReferenceLabels = <String,String>${helpers.literal(labels)};
const buttonCatalogFileKey = ${helpers.literal(source['fileKey'])};
''');
  final output = File(
    'apps/design_system_viewer/lib/catalog/generated/button_reference_labels.g.dart',
  );
  if (args.contains('--check')) {
    if (!output.existsSync() || output.readAsStringSync() != code) {
      throw StateError('Stale viewer source labels');
    }
  } else {
    output.parent.createSync(recursive: true);
    output.writeAsStringSync(code);
  }
}
