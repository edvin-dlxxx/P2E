import 'package:flutter/material.dart';
import 'package:mygame_p2e/app/app.dart';
import 'package:mygame_p2e/core/platform/device_inputs.dart';
import 'package:mygame_p2e/app/bootstrap.dart';
import 'package:mygame_p2e/app/config/app_config.dart';
import 'package:mygame_p2e/l10n/generated/app_localizations.dart';
import 'package:mygame_p2e/features/auth/auth_data.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/inspection.dart';
import 'package:p2e_dev_inspector/inspector.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProductInspectionHost());
}

class ProductInspectionHost extends StatefulWidget {
  const ProductInspectionHost({super.key, this.fixtures = false, this.device});
  final bool fixtures;
  final SimulatedDevice? device;
  @override
  State<ProductInspectionHost> createState() => _ProductInspectionHostState();
}

class _ProductInspectionHostState extends State<ProductInspectionHost> {
  late bool fixtures = widget.fixtures;
  FakeAuthScenario scenario = FakeAuthScenario.success;
  @override
  Widget build(BuildContext context) => InspectorHost(
    device: widget.device,
    controls: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => setState(() => fixtures = !fixtures),
          child: Text(
            fixtures ? toolCopy('productMode') : toolCopy('fixtureMode'),
          ),
        ),
        DropdownButton<FakeAuthScenario>(
          value: scenario,
          items: [
            for (final value in FakeAuthScenario.values)
              DropdownMenuItem(value: value, child: Text(value.name)),
          ],
          onChanged: (value) {
            if (value != null) setState(() => scenario = value);
          },
        ),
      ],
    ),
    appBuilder: (settings, appKey) => composeApp(
      config: AppConfig.fromEnvironment(),
      providerOverrides: [
        fakeAuthScenarioProvider.overrideWith((_) => scenario),
        deviceLocalesProvider.overrideWithBuild(
          (ref, notifier) => settings.locales,
        ),
        deviceTargetPlatformProvider.overrideWithValue(settings.platform),
        appSkinProvider.overrideWithValue(
          settings.testSkin ? testSkin : productSkin,
        ),
      ],
      rootWrapper: (root) => MediaQuery(
        data: settings.media,
        child: SizedBox.expand(
          key: appKey,
          child: fixtures
              ? MaterialApp(
                  debugShowCheckedModeBanner: false,
                  locale: settings.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  theme: AppThemeFactory.build(
                    brightness: settings.brightness,
                    skin: settings.testSkin ? testSkin : productSkin,
                  ).copyWith(platform: settings.platform),
                  builder: (context, child) => MediaQuery(
                    data: settings.media.copyWith(
                      textScaler: settings.media.textScaler.clamp(
                        maxScaleFactor: contentTextScaleCap,
                      ),
                    ),
                    child: child!,
                  ),
                  home: const InspectionFixtures(),
                )
              : root,
        ),
      ),
    ),
  );
}
