import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../l10n/generated/app_localizations.dart';
import '../../features/auth/auth.dart';
import '../startup/startup_controller.dart';
part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final gate = ValueNotifier(ref.read(startupControllerProvider));
  ref.listen(startupControllerProvider, (_, next) => gate.value = next);
  final router = GoRouter(
    initialLocation: '/startup',
    refreshListenable: gate,
    redirect: (_, state) {
      if (gate.value == StartupState.entry &&
          state.uri.path.startsWith('/entry/')) {
        final flow = ref.read(authFlowProvider);
        if (flow == null) return '/entry';
        final required = switch (flow.step) {
          AuthStep.otp => '/entry/otp',
          AuthStep.password => '/entry/password',
          AuthStep.createPassword => '/entry/create-password',
        };
        return state.uri.path == required ||
                state.uri.path == '/entry/forgot-password'
            ? null
            : required;
      }
      final location = switch (gate.value) {
        StartupState.initializing || StartupState.sessionCheck => '/startup',
        StartupState.entry => '/entry',
        StartupState.ready => '/home',
      };
      return state.uri.path == location ? null : location;
    },
    routes: [
      GoRoute(
        path: '/entry',
        pageBuilder: (_, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const UiIdentityScope(
            routeName: 'auth.entry',
            child: AuthEntryScreen(),
          ),
        ),
        routes: [
          for (final step in [
            'otp',
            'password',
            'create-password',
            'forgot-password',
          ])
            GoRoute(
              path: step,
              pageBuilder: (_, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: UiIdentityScope(
                  routeName: 'auth.${step.replaceAll('-', '.')}',
                  child: _AuthPlaceholder(step: step),
                ),
              ),
            ),
        ],
      ),
      for (final destination in ['startup', 'home', 'ready'])
        GoRoute(
          path: '/$destination',
          pageBuilder: (_, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: UiIdentityScope(
              routeName: destination,
              child: _Placeholder(destination: destination),
            ),
          ),
        ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    gate.dispose();
  });
  return router;
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.destination});
  final String destination;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return PageScaffold(
      elementId: '$destination.page',
      child: destination == 'startup'
          ? const SizedBox.shrink()
          : Text(strings.authHomePlaceholder),
    );
  }
}

class _AuthPlaceholder extends StatelessWidget {
  const _AuthPlaceholder({required this.step});
  final String step;
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return PageScaffold(
      elementId: 'auth.placeholder.page',
      child: Column(
        children: [
          Text(switch (step) {
            'otp' => strings.authOtpPlaceholder,
            'password' => strings.authPasswordPlaceholder,
            'create-password' => strings.authCreatePasswordPlaceholder,
            _ => strings.authForgotPlaceholder,
          }),
          AppButton(
            elementId: 'auth.placeholder.back',
            label: strings.authBack,
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
