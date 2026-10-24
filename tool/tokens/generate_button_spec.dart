import 'dart:convert';
import 'dart:io';

import 'generate_buttons.dart' as helpers;

const source = helpers.snapshotDefault;
const marker = 'GENERATED – do not edit';

Future<void> main(List<String> args) async {
  final check = args.contains('--check');
  // Verify fallback evidence before using it. Node is already used by extraction.
  final integrity = await Process.run(Platform.environment['NODE'] ?? 'node', [
    '-e',
    '''const fs=require('node:fs'),c=require('node:crypto'),p=process.argv[1]+'/';
for(const index of ['artifacts.sha256.json','raw-inputs.sha256.json'])
 for(const x of JSON.parse(fs.readFileSync(p+index)).files)
  if(c.createHash('sha256').update(fs.readFileSync(p+x.file)).digest('hex')!==x.sha256)throw Error('Source hash mismatch: '+x.file);''',
    source,
  ]);
  if (integrity.exitCode != 0) throw StateError('${integrity.stderr}');
  final manifest = helpers.readJson('$source/manifest.json');
  final files = (manifest['artifacts']['components'] as List).cast<String>();
  final lint = helpers.readJson('$source/lint.json');
  final variableData = helpers.readJson('$source/variables.json');
  final variables = {for (final v in variableData['vars'] as List) v['id']: v};
  List<Map<String, dynamic>> paintSources(List paints) => [
    for (final p in paints)
      if (p['boundVariables']?['color']?['id'] case final String id)
        {
          'origin': 'variable',
          'variableId': id,
          'variableName': variables[id]?['name'],
          'resolvedValuesByMode': variables[id]?['valuesByMode'],
          'paintOpacity': p['opacity'],
        }
      else
        {'origin': 'unbound', 'raw': p},
  ];
  final knownWrappers = <String, dynamic>{
    for (final p in lint['unboundPaint']['examples'] as List)
      p['id'] as String: p['paint'],
  };
  // Raw output is a fallback only; no live calls and no source edits.
  for (final file in Directory('$source/raw').listSync().whereType<File>()) {
    if (!file.path.endsWith('.response-0.txt')) continue;
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map) continue;
    if (decoded['unboundPaint'] is Map) {
      for (final p in decoded['unboundPaint']['examples'] as List) {
        knownWrappers[p['id'] as String] = p['paint'];
      }
    }
  }
  final entries = <Map<String, dynamic>>[];
  final unresolved = <Map<String, dynamic>>[];
  for (final file in files) {
    final component = helpers.readJson('$source/$file');
    final set = component['set'] as Map;
    final name = set['name'] as String;
    final family = name.contains('Icon Button')
        ? 'icon'
        : name.contains('Fill Button')
        ? 'fill'
        : 'hug';
    final size = name.split(' ').first.toLowerCase();
    final mode = name.contains('Light Mode') ? 'light' : 'dark';
    final wrapper = knownWrappers[set['id']];
    if (wrapper == null) {
      unresolved.add({
        'componentSetId': set['id'],
        'componentSetName': name,
        'variantIds': [for (final v in component['variants'] as List) v['id']],
        'nodeId': set['id'],
        'property': 'set-wrapper.strokes.raw',
        'scope': 'canvas set decoration; not a Variant border',
        'reason': 'Not exported by components or hash-verified raw responses.',
      });
    }
    for (final variant in helpers.objects(component['variants'])) {
      final children = helpers.objects(variant['children']);
      final text = children.where((n) => n['type'] == 'TEXT').firstOrNull;
      final icon = children
          .where(
            (n) =>
                n['type'] == 'FRAME' &&
                (n['name'] as String).startsWith('Icon'),
          )
          .firstOrNull;
      final vector = children
          .where(
            (n) =>
                n['type'] == 'VECTOR' && (n['fills']['raw'] as List).isNotEmpty,
          )
          .firstOrNull;
      final rawType = variant['variantProperties']['Button'] as String;
      final type = rawType == 'Disable' ? 'disabled' : rawType.toLowerCase();
      final g = variant['geometry'] as Map;
      final lineHeight = text?['typography']['lineHeight'];
      final contentHeight = text == null
          ? icon!['geometry']['height'] as num
          : (lineHeight['unit'] == 'PIXELS'
                ? lineHeight['value'] as num
                : text['geometry']['height'] as num);
      // Geometry conflicts remain recorded, but do not enlarge fixed frames.
      final minimumHeight = g['height']; // D-059: rendered frame wins.
      entries.add({
        'componentSetId': set['id'],
        'componentSetName': name,
        'variantId': variant['id'],
        'rawName': variant['name'],
        'rawAxes': variant['variantProperties'],
        'family': family,
        'size': size,
        'mode': mode,
        'type': type,
        'logicalKey': '$family.$size.$type',
        'geometry': g,
        'runtimeGeometry': {
          'minimumVisualHeight': minimumHeight,
          'origin': 'D-059: fixed Figma frame; conflicting vertical padding is metadata only',
        },
        'paintSources': {
          'background': paintSources(variant['fills']['raw'] as List),
          'border': paintSources(variant['strokes']['raw'] as List),
          'text': paintSources(text?['fills']['raw'] as List? ?? []),
          'icon': paintSources(vector?['fills']['raw'] as List? ?? []),
        },
        'opacity': variant['opacity'],
        'fills': variant['fills']['raw'],
        'strokes': variant['strokes']['raw'],
        'effects': variant['effects'],
        'reactions': variant['reactions'],
        'text': text,
        'icon': icon,
        'iconPaints': vector?['fills']['raw'] ?? [],
        'outlineIconPaints': children
            .where(
              (n) =>
                  n['type'] == 'VECTOR' &&
                  (n['fills']['raw'] as List).isNotEmpty,
            )
            .last['fills']['raw'],
        'iconPaintNodeId': vector?['id'],
        'iconInstances': children
            .where((n) => n['type'] == 'INSTANCE')
            .toList(),
        'setProperties': set['properties'],
        'setWrapperPaint': wrapper == null
            ? {'status': 'unresolved'}
            : {'status': 'unbound', 'raw': wrapper},
        'heightPaddingConflict':
            g['height'] <
            contentHeight +
                (g['paddingTop'] as num) +
                (g['paddingBottom'] as num),
        'unresolved': [
          if (family == 'icon')
            {
              'nodeId': icon!['id'],
              'property': 'icon.asset',
              'reason': 'Source-specific icon-only artwork is not yet wired; text buttons support the scoped Edit Square pair.',
            },
        ],
      });
    }
  }
  entries.sort(
    (a, b) => (a['variantId'] as String).compareTo(b['variantId'] as String),
  );
  for (final e in entries) {
    final twin = entries
        .where(
          (v) => v['logicalKey'] == e['logicalKey'] && v['mode'] != e['mode'],
        )
        .single;
    e['counterpartId'] = twin['variantId'];
  }
  final data = {
    'generated': marker,
    'schemaVersion': '1.0.0',
    'component': 'AppButton',
    'source': source,
    'fileKey': manifest['fileKey'],
    'status': 'DEVELOPMENT',
    'technicalVersionLock': 'unverified',
    'variants': entries,
    'axes': {
      'family': ['hug', 'fill', 'icon'],
      'size': ['small', 'medium', 'large'],
      'type': ['filled', 'tonal', 'outlined', 'text', 'disabled'],
      'mode': ['light', 'dark'],
    },
    'stateCoverage': {
      'observed': ['enabled', 'disabled'],
      'notDesigned': ['pressed', 'hovered', 'focused', 'loading'],
      'runtime': 'D-021 adds engineering-defined press scale only. No added state tint, splash or shadow. Disabled uses the actual Disable variant.',
    },
    'unresolvedSetProperties': unresolved,
  };
  final pretty = '${const JsonEncoder.withIndent('  ').convert(data)}\n';
  final report = StringBuffer('''# AppButton DEVELOPMENT implementation

$marker

Runtime: packages/design_system. Viewer: apps/design_system_viewer.
Source: $source; 90 source variants / 45 logical combinations.
The source evidence and token values are unchanged. Runtime data is projected
from the contract; viewer diagnostics are not imported into the package.
ButtonIconMode.none omits both slot and gap and uses content-based Hug width.
Fill and Outline are independent of appearance; the scoped Edit Square pair
is copied unchanged from the completed snapshot by generate_button_icons.dart.
Icon-only source examples remain explicitly unfinished in the viewer.
The existing fixed-height/padding conflict remains provisional; visual and
tap-target measurements are reported separately. Shared D-021 engineering press motion is not Figma motion. No golden approval is claimed.

Run from apps/design_system_viewer:
flutter run -d windows --debug -t lib/main.dart
''');
  final outputs = <String, String>{
    'docs/design-system/contracts/app_button.report.md': report.toString(),
    'docs/design-system/contracts/app_button.spec.json': pretty,
    'apps/design_system_viewer/lib/specs/generated/app_button.spec.json':
        pretty,
    'packages/design_system/lib/src/tokens/specs/generated/app_button_spec.g.dart':
        await helpers.format('''
// $marker
// Source: $source. Component geometry, not new design tokens.
// dart run tool/tokens/generate_button_spec.dart
const Map<String, dynamic> appButtonSpecData = ${helpers.literal({
          for (final key in ['schemaVersion', 'source', 'fileKey', 'status']) key: data[key],
          'variants': [
            for (final row in entries) {
                for (final key in ['componentSetId', 'componentSetName', 'variantId', 'rawName', 'rawAxes', 'family', 'size', 'mode', 'type', 'logicalKey', 'geometry', 'runtimeGeometry', 'opacity', 'fills', 'strokes', 'text', 'icon', 'iconPaints', 'outlineIconPaints', 'heightPaddingConflict']) key: row[key],
              },
          ],
        })};
'''),
  };
  for (final entry in outputs.entries) {
    final file = File(entry.key);
    if (check) {
      if (!file.existsSync() || file.readAsStringSync() != entry.value) {
        throw StateError('Stale generated file: ${entry.key}');
      }
    } else {
      if (file.existsSync() && !file.readAsStringSync().contains(marker)) {
        throw StateError('Unmanaged output: ${entry.key}');
      }
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(entry.value);
    }
  }
  stdout.writeln(
    '${check ? 'Verified' : 'Generated'} ${entries.length} variants; ${unresolved.length} missing set-wrapper paints.',
  );
}
