import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system_viewer/main.dart';

void main() {
  for (final language in ['en', 'fa']) {
    testWidgets(
      '$language adaptive catalog has three distinct width fixtures',
      (tester) async {
        tester.view.physicalSize = const Size(2400, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          DevelopmentViewer(initialLocale: Locale(language)),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('section-8')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('components-adaptive')));
        await tester.pumpAndSettle();
        expect(find.byType(PageScaffold), findsNWidgets(3));
        final identities = tester
            .widgetList<ElementIdentity>(find.byType(ElementIdentity))
            .where((identity) => identity.componentId == 'layout.page-scaffold')
            .toList();
        expect(identities.map((i) => i.variants['sizeClass']).toSet(), {
          'compact',
          'medium',
          'expanded',
        });
        expect(identities.map((i) => i.effectiveKey).toSet(), hasLength(3));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
