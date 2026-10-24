import 'package:flutter/material.dart';

import 'dart:async';

import 'dart:ui' show CheckedState, Tristate;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:mygame_p2e/app/platform/external_link_adapter.dart';
import 'package:mygame_p2e/app/router/app_router.dart';
import 'package:mygame_p2e/core/diagnostics/app_logger.dart';
import 'package:mygame_p2e/core/errors/app_failure.dart';
import 'package:mygame_p2e/features/auth/auth.dart';
import 'package:mygame_p2e/shared/formatting/rewards.dart';
import 'package:mygame_p2e/shared/platform/external_links.dart';
import 'package:mygame_p2e/shared/session/session.dart';
import 'package:p2e_design_system/design_system.dart';

import '../../support/auth_harness.dart';

class PendingPhoneRepositories extends ImmediateRepositories {
  final response = Completer<Result<OtpChallenge>>();
  int calls = 0;
  @override
  Future<Result<OtpChallenge>> requestOtp(
    Phone phone, {
    required bool rememberDevice,
    AuthCancellation? cancellation,
  }) {
    calls++;
    return response.future;
  }
}

void main() {
  testWidgets('loading disables every action and failure creates a toast', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    final repos = PendingPhoneRepositories();
    await pumpAuth(
      tester,
      raw: '09123456789',
      focused: true,
      repositories: repos,
    );
    await tester.tap(find.byKey(const ValueKey('auth.continue')));
    await tester.pump();
    expect(
      tester
          .widget<AppButton>(find.byKey(const ValueKey('auth.continue')))
          .loading,
      true,
    );
    expect(
      tester.widget<AppTextField>(find.byType(AppTextField)).options.enabled,
      false,
    );
    expect(tester.widget<AppToggle>(find.byType(AppToggle)).onChanged, isNull);
    expect(tester.widget<LinkText>(find.byType(LinkText)).enabled, false);
    expect(
      tester
          .widgetList<SocialAuthTile>(find.byType(SocialAuthTile))
          .every((w) => w.onPressed == null),
      true,
    );
    await tester.tap(find.byKey(const ValueKey('auth.continue')));
    await tester.pump();
    expect(repos.calls, 1);
    repos.response.complete(const Failure(OfflineFailure()));
    await tester.pumpAndSettle();
    expect(find.byType(AppToast), findsOneWidget);
    expect(
      tester.widget<AppTextField>(find.byType(AppTextField)).options.enabled,
      true,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
  testWidgets('ready gate exposes only the Home placeholder', (tester) async {
    addTearDown(tester.view.reset);
    await pumpAuth(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AuthEntryScreen)),
    );
    container
        .read(sessionControllerProvider.notifier)
        .update(SessionStatus.signedIn);
    await tester.pumpAndSettle();
    expect(find.text('Home — screen coming next'), findsOneWidget);
    expect(
      container.read(appRouterProvider).routeInformationProvider.value.uri.path,
      '/home',
    );
  });
  for (final locale in ['en', 'fa']) {
    testWidgets('logical keyboard focus order $locale', (tester) async {
      addTearDown(tester.view.reset);
      await pumpAuth(
        tester,
        locale: locale,
        raw: 'user@example.com',
        focused: true,
      );
      bool within(Finder owner) {
        final target = tester.element(owner);
        var found = false;
        FocusManager.instance.primaryFocus!.context!.visitAncestorElements((
          element,
        ) {
          if (element == target) {
            found = true;
            return false;
          }
          return true;
        });
        return found;
      }

      for (final owner in [
        find.byType(AppToggle),
        find.byKey(const ValueKey('auth.continue')),
        for (final brand in SocialAuthBrand.values)
          find.byWidgetPredicate(
            (w) => w is SocialAuthTile && w.brand == brand,
          ),
        find.widgetWithText(
          TextButton,
          locale == 'fa' ? 'شرایط و قوانین' : 'Terms & Conditions',
        ),
        find.widgetWithText(
          TextButton,
          locale == 'fa' ? 'سیاست حریم خصوصی' : 'Privacy Policy',
        ),
      ]) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(within(owner), true);
      }
    });
  }
  test('production fake and unsafe legal URLs reject at config boundary', () {
    expect(
      () => AppConfig.fromValues({'APP_ENV': 'prod', 'BACKEND_MODE': 'fake'}),
      throwsFormatException,
    );
    expect(
      () => AppConfig.fromValues({'TERMS_URL': 'javascript:alert(1)'}),
      throwsFormatException,
    );
    expect(
      AppConfig.fromValues({'APP_ENV': 'prod', 'BACKEND_MODE': 'remote'})
          .backendMode,
      BackendMode.remote,
    );
  });
  test(
    'unconfigured legal port is typed and never invokes a system channel',
    () async {
      const adapter = SystemExternalLinks(
        AppConfig(environment: AppEnvironment.dev),
      );
      for (final link in ExternalLink.values) {
        final result = await adapter.open(link);
        expect(
          (result as Failure<void>).error,
          isA<BusinessFailure>().having((e) => e.code, 'code', 'url_missing'),
        );
      }
    },
  );
  test('display-only reward digits and separators', () {
    expect(formatWelcomeBonus(3500, languageCode: 'en'), '+3,500');
    expect(formatWelcomeBonus(3500, languageCode: 'fa'), '+۳٬۵۰۰');
  });
  test('email and identifier-key logging are redacted', () {
    expect(
      PiiRedactor.text('Contact private.person123@example.com'),
      isNot(contains('private.person123')),
    );
    expect(
      PiiRedactor.value({
        'identifier': 'private.person123@example.com',
        'email': 'x@example.com',
      }),
      {'identifier': '[REDACTED]', 'email': '[REDACTED]'},
    );
  });
  for (final scenario in {
    '09123456789': 'OTP — screen coming next',
    'user@example.com': 'Password — screen coming next',
    'new.person@example.com': 'Create password — screen coming next',
  }.entries) {
    testWidgets(
      'keyboard go routes ${scenario.key.contains('@') ? 'email' : 'phone'} through flow',
      (tester) async {
        addTearDown(tester.view.reset);
        await pumpAuth(
          tester,
          raw: scenario.key,
          focused: true,
          keyboard: true,
        );
        await tester.testTextInput.receiveAction(TextInputAction.go);
        await tester.pumpAndSettle();
        expect(find.text(scenario.value), findsOneWidget);
        final scope = ProviderScope.containerOf(
          tester.element(find.byType(PageScaffold).last),
        );
        expect(scope.read(authFlowProvider), isNotNull);
      },
    );
  }
  testWidgets('restored auth destination with missing flow redirects Entry', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    await pumpAuth(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(AuthEntryScreen)),
    );
    container.read(appRouterProvider).go('/entry/otp');
    await tester.pumpAndSettle();
    expect(find.byType(AuthEntryScreen), findsOneWidget);
    expect(find.text('OTP — screen coming next'), findsNothing);
  });
  testWidgets('checkbox/links/CTA semantics and real OS status style', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(tester.view.reset);
    await pumpAuth(tester);
    final toggle = tester
        .getSemantics(find.byType(AppToggle))
        .getSemanticsData();
    expect(toggle.flagsCollection.isChecked, isNot(CheckedState.none));
    expect(toggle.flagsCollection.isInMutuallyExclusiveGroup, false);
    await tester.ensureVisible(find.byKey(const ValueKey('auth.continue')));
    await tester.pumpAndSettle();
    final button = tester
        .getSemantics(find.bySemanticsLabel('Continue').first)
        .getSemanticsData();
    expect(button.label, 'Continue');
    expect(button.flagsCollection.isEnabled, Tristate.isFalse);
    await tester.ensureVisible(find.byType(LinkText));
    final link = find
        .descendant(
          of: find.byType(LinkText),
          matching: find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.link == true,
          ),
        )
        .first;
    expect(
      tester.getSemantics(link).getSemanticsData().flagsCollection.isLink,
      true,
    );
    final overlay = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(overlay.value.statusBarIconBrightness, Brightness.light);
    semantics.dispose();
  });
}
