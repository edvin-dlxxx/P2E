import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  testWidgets('representative originals and theme tints at 16, 24 and 64', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 480);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: RepaintBoundary(
          key: boundaryKey,
          child: Column(
            children: [
              for (final brightness in [Brightness.dark, Brightness.light])
                Builder(
                  builder: (context) {
                    final colors = ButtonThemeTokens.forBrightness(brightness);
                    return ColoredBox(
                      color: colors.color('Surface/Base'),
                      child: SizedBox(
                        height: 240,
                        child: Row(
                          children: [
                            for (final id in [
                              AppIconId.crown,
                              AppIconId.editSquare,
                            ])
                              for (final style in AppIconStyle.values)
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${id.name} / ${style.name}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'packages/p2e_design_system/Outfit',
                                          color: colors.color(
                                            'On Surface/Emphasis',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          for (final size in [16.0, 24.0, 64.0])
                                            AssetAppIcon(
                                              id,
                                              style: style,
                                              size: size,
                                              color:
                                                  brightness == Brightness.light
                                                  ? colors.color(
                                                      'On Surface/Emphasis',
                                                    )
                                                  : null,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        brightness == Brightness.dark
                                            ? 'Original paint · 16 / 24 / 64'
                                            : 'Theme tint · 16 / 24 / 64',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'packages/p2e_design_system/Outfit',
                                          color: colors.color(
                                            'On Surface/Emphasis',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final boundary =
        boundaryKey.currentContext!.findRenderObject()!
            as RenderRepaintBoundary;
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final output = File('build/representative-icons.png');
      output.parent.createSync(recursive: true);
      output.writeAsBytesSync(bytes!.buffer.asUint8List());
      image.dispose();
    });
  });
}
