import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/app/app.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:mygame_p2e/features/auth/auth.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_dev_inspector/inspector.dart';

import '../../../../../test/support/auth_harness.dart'
    show ImmediateRepositories;

void main() {
  testWidgets(
    'Auth Entry scripted Inspector width/height matrix',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1900, 1800);
      addTearDown(tester.view.reset);
      final reports = <String, Object?>{};
      final acceptanceProblems = <Object?>[];
      var samples = 0;
      for (final entryState in ['idle', 'focused', 'phone', 'email']) {
        final raw = switch (entryState) {
          'phone' => '09123456789',
          'email' => 'User12@example.com',
          _ => '',
        };
        final device = SimulatedDevice();
        final repos = ImmediateRepositories();
        device.apply(
          device.settings.copyWith(
            disableAnimations: true,
            insets: const EdgeInsets.only(top: 55),
            keyboardHeight: 300,
          ),
        );
        await tester.pumpWidget(
          InspectorHost(
            device: device,
            appBuilder: (settings, appKey) => ProviderScope(
              overrides: [
                appConfigProvider.overrideWithValue(
                  const AppConfig(environment: AppEnvironment.stage),
                ),
                // Test composition only: normal product_host retains D-041/D-052 fa policy.
                appLocaleProvider.overrideWithValue(
                  Locale(settings.locale.languageCode),
                ),
                welcomeOfferRepositoryProvider.overrideWithValue(repos),
                phoneSignInRepositoryProvider.overrideWithValue(repos),
                emailSignInRepositoryProvider.overrideWithValue(repos),
                socialSignInRepositoryProvider.overrideWithValue(repos),
              ],
              child: MediaQuery(
                data: settings.media,
                child: SizedBox.expand(key: appKey, child: const P2EApp()),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final host = tester.state<InspectorHostState>(
          find.byType(InspectorHost),
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage(
              'assets/images/auth/entry_illustration.png',
              package: 'p2e_design_system',
            ),
            tester.element(find.byType(P2EApp)),
          ),
        );
        if (entryState != 'idle') {
          tester
              .widget<AppTextField>(find.byType(AppTextField))
              .options
              .focusNode!
              .requestFocus();
          await tester.pumpAndSettle();
          await tester.enterText(
            find.descendant(
              of: find.byType(AppTextField),
              matching: find.byType(EditableText),
            ),
            raw,
          );
          await tester.pumpAndSettle();
        }
        Future<void> frame() async {
          await tester.pump(const Duration(milliseconds: 16));
          // The recorder chains the real handler and retains each problem. Test
          // exceptions below the acceptance area are drained only after recording.
          while (tester.takeException() != null) {}
          samples++;
          if (samples % 1000 == 0) {
            stdout.writeln('Auth sweep samples: $samples');
          }
        }

        for (final keyboard in [false, true]) {
          device.apply(device.settings.copyWith(keyboard: keyboard));
          for (final height in [300.0, 480.0, 874.0, 1200.0]) {
            device.resize(402, height);
            await frame();
            host.problems.clear();
            // Complete 4px width sweep at the reference height, plus a coarse
            // height grid. The exact coverage is retained in every plan/range.
            await host.sweep.run(
              SweepPlan(
                widthStep: height == 874 ? 4 : 200,
                scales: const [1, 2],
                locales: const [
                  [Locale('fa')],
                  [Locale('en')],
                ],
              ),
              frame,
            );
            final report = jsonDecode(host.sweep.exportJson()) as Map;
            reports['$entryState-keyboard$keyboard-height$height'] = report;
            final partial = Directory('../../../../build/auth-entry-preflight')
              ..createSync(recursive: true);
            File('${partial.path}/inspector-auth-sweep.json').writeAsStringSync(
              const JsonEncoder.withIndent('  ')
                  .convert({'samples': samples, 'reports': reports}),
            );
            final supported = (report['ranges'] as List)
                .where(
                  (r) =>
                      (r['lastWidth'] as num) >= 320 &&
                      (r['lastHeight'] as num) >= 480,
                )
                .toList();
            // Preserve the complete sweep evidence before failing acceptance.
            acceptanceProblems.addAll(supported);
            expect(
              tester
                  .widget<AppTextField>(find.byType(AppTextField))
                  .options
                  .controller!
                  .text,
              raw,
            );
          }
          for (final width in [320.0, 402.0]) {
            device.resize(width, 874);
            await frame();
            host.problems.clear();
            await host.sweep.run(
              const SweepPlan(
                axis: SweepAxis.height,
                minHeight: 300,
                maxHeight: 1200,
                heightStep: 180,
                scales: [1, 2],
                locales: [
                  [Locale('fa')],
                  [Locale('en')],
                ],
              ),
              frame,
            );
            final report = jsonDecode(host.sweep.exportJson()) as Map;
            reports['$entryState-keyboard$keyboard-width$width-heights'] =
                report;
            acceptanceProblems.addAll(
              (report['ranges'] as List).where(
                (r) => (r['lastHeight'] as num) >= 480,
              ),
            );
          }
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pump();
        device.dispose();
      }
      final dir = Directory('../../../../build/auth-entry-preflight')
        ..createSync(recursive: true);
      File('${dir.path}/inspector-auth-sweep.json').writeAsStringSync(
        const JsonEncoder.withIndent('  ')
            .convert({'samples': samples, 'reports': reports}),
      );
      expect(
        acceptanceProblems,
        isEmpty,
        reason: 'Complete supported-area sweep',
      );
    },
    skip: Platform.environment['RUN_AUTH_SWEEP'] != '1',
    timeout: const Timeout(Duration(minutes: 60)),
  );
}
