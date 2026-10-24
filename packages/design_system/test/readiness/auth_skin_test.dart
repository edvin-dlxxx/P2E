import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';

// D-056: only these original brand paints/artwork bypass semantic skins.
const brandPaintExclusions = ['Blue/700', 'Green/600', 'Alpha/White'];

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'Auth test-skin leak guard $brightness with explicit brand exclusions',
      (tester) async {
        tester.view.physicalSize = const Size(402, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        expect(brandPaintExclusions, ['Blue/700', 'Green/600', 'Alpha/White']);
        await tester.pumpWidget(
          MaterialApp(
            theme: AppThemeFactory.build(
              brightness: brightness,
              skin: testSkin,
            ),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: Scaffold(
              body: UiIdentityScope(
                routeName: 'test.auth',
                child: RepaintBoundary(
                  key: const ValueKey('skin'),
                  child: AuthPrimitivesFixture(
                    label: 'Continue',
                    divider: 'or continue with',
                    remember: 'Remember',
                    terms: 'Terms',
                    privacy: 'Privacy',
                    playStation: 'PlayStation',
                    xbox: 'Xbox',
                    google: 'Google',
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => precacheImage(
            const AssetImage(
              'assets/images/auth/entry_illustration.png',
              package: 'p2e_design_system',
            ),
            tester.element(find.byType(HeroBanner)),
          ),
        );
        await tester.pumpAndSettle();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('skin')),
        );
        final origin = boundary.localToGlobal(Offset.zero);
        final excluded = <Rect>[
          tester.getRect(find.byType(HeroBanner)).shift(-origin),
        ];
        for (final element in find.byType(SocialAuthTile).evaluate()) {
          final box = element.renderObject as RenderBox;
          final rect = (box.localToGlobal(Offset.zero) - origin) & box.size;
          final bleed =
              (AuthEntryTokens.brandSize - AuthEntryTokens.socialHeight) / 2;
          // Exclude the source tile and its40px decorative logo, not its label.
          excluded.add(
            Rect.fromLTWH(
              rect.left,
              rect.top - bleed,
              rect.width,
              AuthEntryTokens.socialHeight + 2 * bleed,
            ),
          );
        }
        final forbidden =
            productSkin
                .valuesFor(brightness)
                .byName
                .values
                .map((c) => c.toARGB32())
                .toSet()
              ..removeAll(
                testSkin
                    .valuesFor(brightness)
                    .byName
                    .values
                    .map((c) => c.toARGB32()),
              );
        final result = await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final data = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!.buffer.asUint8List();
          final width = image.width;
          image.dispose();
          return (data, width);
        });
        final (bytes, width) = result!;
        final leaks = <int, int>{};
        for (var i = 0; i < bytes.length; i += 4) {
          final point = Offset(
            (i ~/ 4 % width).toDouble(),
            (i ~/ 4 ~/ width).toDouble(),
          );
          if (excluded.any((r) => r.contains(point))) continue;
          final color =
              bytes[i + 3] << 24 |
              bytes[i] << 16 |
              bytes[i + 1] << 8 |
              bytes[i + 2];
          if (forbidden.contains(color)) {
            leaks.update(color, (v) => v + 1, ifAbsent: () => 1);
          }
        }
        expect(leaks, isEmpty);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
      },
    );
  }
}
