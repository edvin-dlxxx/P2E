import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  test('registry reconciles source inventory, source links and missing styles', () {
    final snapshot = jsonDecode(
      File('../../docs/snapshots/2026-10-20_development-icons/icons.json')
          .readAsStringSync(),
    ) as Map;
    expect(AppIconRegistry.all.length, (snapshot['concepts'] as List).length);
    expect(
      AppIconRegistry.all.map((i) => i.key).toSet().length,
      AppIconId.values.length,
    );
    final ids = <String>{};
    for (final icon in AppIconRegistry.all) {
      expect(AppIconRegistry.byKey(icon.key).id, icon.id);
      expect(AppIconRegistry.byKey(icon.data['id'] as String).id, icon.id);
      for (final style in icon.styles) {
        final a = icon.artwork(style);
        expect(ids.add(a.nodeId), isTrue);
        expect(File(a.assetPath).existsSync(), isTrue);
        final source = (snapshot['versions'] as List).singleWhere(
          (v) => v['nodeId'] == a.nodeId,
        );
        expect(a.data, source);
        expect(
          File(a.assetPath).readAsBytesSync(),
          File(
            '../../docs/snapshots/2026-10-20_development-icons/${source['file']}',
          ).readAsBytesSync(),
        );
      }
    }
    expect(ids.length, (snapshot['versions'] as List).length);
    expect(
      () => AppIconRegistry.byKey('icon.unknown'),
      throwsA(isA<MissingIconArtwork>()),
    );
    const oneStyle = IconDefinition(AppIconId.crown, {
      'key': 'fixture.one',
      'artworks': <String, dynamic>{'fill': <String, dynamic>{}},
    });
    expect(
      () => oneStyle.artwork(AppIconStyle.outline),
      throwsA(isA<MissingIconArtwork>()),
    );
    for (final spec in ButtonSpec.all) {
      for (final style in AppIconStyle.values) {
        expect(
          AppIconRegistry.buttonArtwork(spec.id, style).key,
          snapshot['buttonIcons'][spec.id][style.name],
        );
      }
    }
  });

  testWidgets(
    'every original SVG compiles, paints nonempty pixels and uses the shared renderer',
    (tester) async {
      final rendered = <String, Map<String, Object>>{};
      for (final icon in AppIconRegistry.all) {
        for (final style in icon.styles) {
          final a = icon.artwork(style);
          await tester.runAsync(() async {
            final bytes = await rootBundle.load(
              'packages/p2e_design_system/${a.assetPath}',
            );
            expect(bytes.lengthInBytes, greaterThan(100));
            final picture = await vg.loadPicture(
              SvgAssetLoader(a.assetPath, packageName: 'p2e_design_system'),
              null,
            );
            expect(picture.size, Size(a.width, a.height));
            final image = await picture.picture.toImage(24, 24);
            final pixels = await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            );
            expect(
              [
                for (var i = 3; i < pixels!.lengthInBytes; i += 4)
                  pixels.getUint8(i),
              ].any((a) => a > 0),
              isTrue,
              reason: 'Empty artwork ${a.nodeId}',
            );
            image.dispose();
            picture.picture.dispose();
          });
          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: AssetAppIcon(icon.id, style: style, size: 24),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '${icon.key}/${style.name}',
          );
          expect(tester.getSize(find.byType(SvgPicture)), const Size(24, 24));
          rendered[a.nodeId] = {
            'sha256': a.sha256,
            'rendered': true,
            'nonempty': true,
          };
        }
      }
      final file = File('build/icon-render-validation.json');
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'renderer': 'flutter_svg 2.3.0 / vector_graphics',
          'scope': 'All exported original SVGs; decode, raster paint and shared widget; no golden/design approval.',
          'versions': rendered,
        }),
      );
    },
  );

  testWidgets(
    'original color, explicit tint, size, RTL and semantics remain independent',
    (tester) async {
      final semantics = tester.ensureSemantics();
      for (final direction in TextDirection.values) {
        for (final size in [16.0, 24.0, 64.0]) {
          await tester.pumpWidget(
            Directionality(
              textDirection: direction,
              child: IconTheme(
                data: const IconThemeData(color: Color(0xFF123456)),
                child: Center(child: AssetAppIcon(AppIconId.crown, size: size)),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
          expect(svg.colorFilter, isNull);
          expect(svg.excludeFromSemantics, isTrue);
          expect(svg.fit, BoxFit.contain);
          expect(tester.getSize(find.byType(SvgPicture)), Size(size, size));
        }
      }
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: AssetAppIcon(
              AppIconId.arrowLeft,
              color: Color(0xFF123456),
              size: 32,
              semanticLabel: 'بازگشت',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.colorFilter, isNotNull);
      expect(svg.matchTextDirection, isTrue);
      expect(find.bySemanticsLabel('بازگشت'), findsOneWidget);
      expect(find.bySemanticsLabel('icon.arrow_left'), findsNothing);
      const multicolor = IconArtwork({
        'monochrome': false,
        'originalColors': ['#ff0000', '#0000ff'],
      });
      expect(multicolor.tintFilter(const Color(0xFF123456)), isNull);
      expect(multicolor.data['originalColors'], ['#ff0000', '#0000ff']);
      semantics.dispose();
    },
  );

  testWidgets(
    'icon-only controls use Crown, one label and unchanged disabled/callback behavior',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      for (final mode in [ButtonIconMode.fill, ButtonIconMode.outline]) {
        for (final disabled in [false, true]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: AppThemeFactory.build(brightness: Brightness.dark),
              home: Scaffold(
                body: Center(
                  child: AppButton(
                    elementId: 'test.crown.control',
                    runtimeLocator: const UiRuntimeLocator(
                      routeName: 'test',
                      routeInstanceId: 'icons',
                    ),
                    label: 'Rewards',
                    family: AppButtonFamily.icon,
                    type: disabled
                        ? AppButtonType.disabled
                        : AppButtonType.filled,
                    iconMode: mode,
                    icon: const AssetAppIcon(
                      AppIconId.crown,
                      semanticLabel: 'Duplicate crown',
                    ),
                    onPressed: () => taps++,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final artwork = tester.widget<AssetAppIcon>(
            find.byType(AssetAppIcon),
          );
          expect(artwork.style.name, mode.name);
          expect(artwork.decorative, isTrue);
          expect(find.bySemanticsLabel('Rewards'), findsOneWidget);
          expect(find.bySemanticsLabel('Duplicate crown'), findsNothing);
          final before = taps;
          final gesture = await tester.startGesture(
            tester.getCenter(find.byType(AppButton)),
          );
          await tester.pump(const Duration(milliseconds: 110));
          await tester.pump(ButtonMotion.pressDuration);
          final transform = tester.widget<Transform>(
            find.byKey(const ValueKey('app-button-press-transform')),
          );
          expect(
            transform.transform.storage[0],
            closeTo(disabled ? 1 : .98, .001),
          );
          await gesture.up();
          await tester.pumpAndSettle();
          expect(taps, before + (disabled ? 0 : 1));
        }
      }
      semantics.dispose();
    },
  );
}
