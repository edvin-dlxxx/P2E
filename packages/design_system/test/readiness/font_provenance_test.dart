import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  for (final weight in [
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
  ]) {
    testWidgets(
      'Outfit${weight.value} matches its real static reference pixels',
      (tester) async {
        final reference = 'Outfit-reference-${weight.value}';
        await tester.runAsync(() async {
          final manifest = jsonDecode(
            await rootBundle.loadString('FontManifest.json'),
          ) as List;
          final outfit =
              manifest.singleWhere((f) => f['family'] == 'Outfit') as Map;
          final face = (outfit['fonts'] as List).singleWhere(
            (f) => f['weight'] == weight.value,
          );
          await (FontLoader(
            reference,
          )..addFont(rootBundle.load(face['asset'] as String))).load();
        });
        const sample = 'Play. Earn. Win. +3,500 Welcome bonus @ 0123456789';
        final keys = [GlobalKey(), GlobalKey()];
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                for (final (i, family) in [
                  BundledTypography.outfitFamily,
                  reference,
                ].indexed)
                  RepaintBoundary(
                    key: keys[i],
                    child: Text(
                      sample,
                      style: TextStyle(
                        fontFamily: family,
                        fontWeight: weight,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
        await tester.pump();
        Future<List<int>> pixels(GlobalKey key) async {
          final render =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await render.toImage();
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          image.dispose();
          return data!.buffer.asUint8List();
        }

        final pair = await tester.runAsync(
          () async => [await pixels(keys[0]), await pixels(keys[1])],
        );
        expect(pair![0], pair[1]);
        expect(
          tester.getSize(find.byKey(keys[0])),
          tester.getSize(find.byKey(keys[1])),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
