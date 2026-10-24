import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/features/auth/auth.dart';
import 'package:mygame_p2e/core/errors/app_failure.dart';
import 'package:p2e_design_system/design_system.dart';

import '../../support/auth_harness.dart';

class CountingRepositories extends ImmediateRepositories {
  int calls = 0;
  @override
  Future<Result<OtpChallenge>> requestOtp(
    Phone phone, {
    required bool rememberDevice,
    AuthCancellation? cancellation,
  }) async {
    calls++;
    return const Failure(OfflineFailure());
  }

  @override
  Future<Result<EmailAccountStatus>> checkEmail(
    Email email, {
    AuthCancellation? cancellation,
  }) async {
    calls++;
    return const Failure(OfflineFailure());
  }
}

void main() {
  for (final locale in ['en', 'fa']) {
    for (final raw in ['09123456789', 'user@example.com']) {
      for (final keyboard in [false, true]) {
        testWidgets('real Auth envelope $locale $raw keyboard=$keyboard', (
          tester,
        ) async {
          addTearDown(tester.view.reset);
          final repos = CountingRepositories();
          for (var edge = 0; edge < 4; edge++) {
            // A failed submission shows a toast over the footer. Use a fresh
            // real route per tap so that overlay is not mistaken for a miss.
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
            await pumpAuth(
              tester,
              locale: locale,
              raw: raw,
              keyboard: keyboard,
              repositories: repos,
            );
            final finder = find.byType(AppButton);
            expect(finder, findsOneWidget);
            final visual = tester.getRect(finder);
            expect(visual.height, 46);
            // One dp inside48 is the edge of46. Also test points strictly
            // outside the visual frame (0.5dp inside the expanded envelope).
            final dy = [
              visual.top - .5,
              visual.bottom + .5,
              visual.top,
              visual.bottom,
            ][edge];
            await tester.tapAt(Offset(visual.center.dx, dy));
            await tester.pumpAndSettle();
            expect(repos.calls, edge + 1, reason: 'edge $edge');
            expect(tester.getRect(finder), visual);
          }
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
