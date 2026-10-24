import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/testing.dart';
import 'package:p2e_design_system_viewer/components/components_browser.dart';
import 'package:p2e_design_system_viewer/l10n/generated/viewer_localizations.dart';

void main() {
  testWidgets('Auth primitives Gallery uses the shared golden fixture', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: ViewerLocalizations.localizationsDelegates,
        supportedLocales: ViewerLocalizations.supportedLocales,
        locale: const Locale('en'),
        theme: AppThemeFactory.build(brightness: Brightness.dark),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: UiIdentityScope(routeName: 'viewer.test', child: child!),
        ),
        home: Scaffold(
          body: ComponentsBrowser(selected: null, onInspect: (_) {}),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('components-auth')));
    await tester.pumpAndSettle();
    expect(find.byType(AuthPrimitivesFixture), findsOneWidget);
    expect(find.byType(SocialAuthTile), findsNWidgets(3));
    expect(find.byType(AppToggle), findsOneWidget);
    expect(find.byType(LinkText), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
