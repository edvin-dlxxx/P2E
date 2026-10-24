import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../l10n/generated/app_localizations.dart';
import '../core/platform/device_inputs.dart';
import 'router/app_router.dart';
import 'platform/system_chrome.dart';
part 'app.g.dart';

// D-041: app policy remains independent of neutral OS inputs.
@Riverpod(keepAlive: true)
Locale appLocale(Ref ref) {
  // D-052: observe OS changes while retaining D-041's provisional fa policy.
  ref.watch(deviceLocalesProvider);
  return const Locale('fa');
}

// D-046: neutral hosts may override this; product has no skin picker.
@Riverpod(keepAlive: true)
SkinDefinition appSkin(Ref ref) => productSkin;

class P2EApp extends ConsumerWidget {
  const P2EApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: AppThemeFactory.build(
      brightness: Brightness.light,
      skin: ref.watch(appSkinProvider),
    ).copyWith(platform: ref.watch(deviceTargetPlatformProvider)),
    darkTheme: AppThemeFactory.build(
      brightness: Brightness.dark,
      skin: ref.watch(appSkinProvider),
    ).copyWith(platform: ref.watch(deviceTargetPlatformProvider)),
    themeMode: ThemeMode.system,
    locale: ref.watch(appLocaleProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: ref.watch(appRouterProvider),
    builder: (context, child) => AppSystemChrome(
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(context)
              .clamp(maxScaleFactor: contentTextScaleCap),
        ),
        child: child!,
      ),
    ),
  );
}
