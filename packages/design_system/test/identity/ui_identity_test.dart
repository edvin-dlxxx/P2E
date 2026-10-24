import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import 'package:p2e_design_system/testing.dart';

ElementIdentity metadata({
  String id = 'test.identity',
  UiRuntimeLocator? locator = const UiRuntimeLocator(
    routeName: 'test',
    routeInstanceId: 'a',
  ),
  Map<String, String> variants = const {},
  Map<String, Object?> resolved = const {},
}) => ElementIdentity(
  elementId: id,
  runtimeLocator: locator,
  componentId: 'button.base',
  structureRef: 'button.hug.base',
  fileKey: '',
  variantId: null,
  componentSetId: null,
  rawSetName: 'engineering-derived',
  rawVariantName: 'engineering-derived',
  variants: variants,
  resolved: resolved,
  declared: const {},
  child: const SizedBox(),
);
void main() {
  test('all identity-relevant changes notify and equal values do not', () {
    final before = metadata();
    expect(metadata().updateShouldNotify(before), isFalse);
    expect(metadata(id: 'test.changed').updateShouldNotify(before), isTrue);
    expect(
      metadata(
        locator: const UiRuntimeLocator(
          routeName: 'test',
          routeInstanceId: 'b',
        ),
      ).updateShouldNotify(before),
      isTrue,
    );
    expect(
      metadata(
        locator: const UiRuntimeLocator(
          routeName: 'test',
          routeInstanceId: 'a',
          slotPath: 'cells.cell1',
        ),
      ).updateShouldNotify(before),
      isTrue,
    );
    expect(
      metadata(variants: const {'enabled': 'false'}).updateShouldNotify(before),
      isTrue,
    );
    final map = <String, Object?>{
      'nested': <String, Object?>{'flag': true},
    };
    final frozen = metadata(resolved: map);
    (map['nested'] as Map)['flag'] = false;
    expect((frozen.resolved['nested'] as Map)['flag'], true);
    expect(
      metadata(
        resolved: const {
          'nested': {'flag': true},
        },
      ).updateShouldNotify(frozen),
      isFalse,
    );
    expect(
      (before.descriptor()['identity'] as Map).containsKey('designRef'),
      isFalse,
    );
    expect(
      ((before.descriptor()['resolved'] as Map)['figmaRawSetName']
          as Map)['origin'],
      'runtime-resolver',
    );
  });
  test('invalid fields fail centrally with named diagnostics', () {
    for (final id in ['', ' ', 'test', 'test.0', 'test.raw:1:2']) {
      expect(
        () => metadata(id: id),
        throwsA(
          isA<ArgumentError>().having((e) => e.name, 'field', 'elementId'),
        ),
      );
    }
    expect(
      () => metadata(
        locator: const UiRuntimeLocator(
          routeName: 'test/path',
          routeInstanceId: 'a',
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => metadata(
        locator: const UiRuntimeLocator(
          routeName: 'test',
          routeInstanceId: ' ',
        ),
      ),
      throwsArgumentError,
    );
    expect(
      () => metadata(
        locator: const UiRuntimeLocator(
          routeName: 'test',
          routeInstanceId: 'a',
          slotPath: 'cells.0',
        ),
      ),
      throwsArgumentError,
    );
  });
  testWidgets('missing scope clearly fails in debug', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: AppThemeFactory.build(brightness: Brightness.dark),
        home: AppBadge(elementId: 'test.badge', label: 'Synthetic'),
      ),
    );
    expect(
      t.takeException(),
      isA<AssertionError>().having(
        (e) => e.toString(),
        'diagnostic',
        contains('Missing UiIdentityScope'),
      ),
    );
  });
  testWidgets(
    'route instance allocation, stability, override and collision controls',
    (t) async {
      Widget control() =>
          const AppBadge(elementId: 'test.badge', label: 'Synthetic');
      Widget screen(Key key) =>
          UiIdentityScope(key: key, routeName: 'test.screen', child: control());
      Future<void> mount(List<Widget> children) async {
        await t.pumpWidget(
          MaterialApp(
            theme: AppThemeFactory.build(brightness: Brightness.dark),
            home: Column(children: children),
          ),
        );
        await t.pumpAndSettle();
      }

      await mount([screen(const ValueKey('a')), screen(const ValueKey('b'))]);
      final before = mountedIdentities(t.binding.rootElement!)
          .map((w) => w.effectiveKey)
          .toList();
      expectUniqueIdentities(t.binding.rootElement!);
      expect(before[0], isNot(before[1]));
      await mount([screen(const ValueKey('a')), screen(const ValueKey('b'))]);
      expect(
        mountedIdentities(t.binding.rootElement!).map((w) => w.effectiveKey),
        before,
      );
      await mount([
        UiIdentityScope(
          routeName: 'test.screen',
          instanceKey: 'repeat',
          child: Column(
            children: [
              control(),
              Offstage(child: control()),
            ],
          ),
        ),
      ]);
      expect(
        () => expectUniqueIdentities(t.binding.rootElement!),
        throwsStateError,
      );
      await mount([
        UiIdentityScope(
          routeName: 'test.screen',
          instanceKey: 'explicit',
          child: Column(
            children: [
              control(),
              const AppBadge(elementId: 'test.other', label: 'Synthetic'),
            ],
          ),
        ),
      ]);
      expectUniqueIdentities(t.binding.rootElement!);
    },
  );
}
