import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import 'tool_copy.dart';

/// Host-only composition of real controls; no product routes or fake services.
class InspectionFixtures extends StatefulWidget {
  const InspectionFixtures({super.key});
  @override
  State<InspectionFixtures> createState() => _InspectionFixturesState();
}

class _InspectionFixturesState extends State<InspectionFixtures> {
  bool loading = false, show = true;
  String selected = 'home';
  int? radio = 1;
  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    String copy(String key, {Map<String, Object> arguments = const {}}) =>
        toolCopy(key, locale: language, arguments: arguments);
    final action = AppBarAction(label: copy('sampleHelp'), onPressed: () {});
    final label = copy('sampleContinue');
    return UiIdentityScope(
      routeName: 'fixtures',
      instanceKey: 'fixtures-v1',
      child: PageScaffold(
        elementId: 'fixtures.page',
        child: Column(
          children: [
            TextButton(
              onPressed: () => setState(() => loading = !loading),
              child: Text(toolCopy('sampleToggleLoading')),
            ),
            TextButton(
              onPressed: () => setState(() => show = !show),
              child: Text(toolCopy('sampleToggleMount')),
            ),
            if (show)
              AppButton(
                elementId: 'fixtures.primary',
                label: label,
                loading: loading,
                loadingSemanticsLabel: copy('sampleLoading'),
                onPressed: () {},
                iconMode: ButtonIconMode.fill,
                icon: const AssetAppIcon(AppIconId.home),
              ),
            AppButton(
              elementId: 'fixtures.disabled',
              label: label,
              type: AppButtonType.disabled,
              onPressed: null,
            ),
            AppBadge(elementId: 'fixtures.badge', label: copy('sampleBadge')),
            AppTextField(elementId: 'fixtures.field', label: label),
            AppPasswordField(
              elementId: 'fixtures.password',
              label: copy('samplePassword'),
              showPasswordLabel: copy('sampleShow'),
              hidePasswordLabel: copy('sampleHide'),
            ),
            AppOtpField(elementId: 'fixtures.otp', label: copy('sampleOtp')),
            AppRadioGroup<int>(
              value: radio,
              onChanged: (v) => setState(() => radio = v),
              child: AppRadio<int>(
                elementId: 'fixtures.radio',
                value: 1,
                label: label,
              ),
            ),
            const AssetAppIcon(AppIconId.home),
            AppBarContent(
              elementId: 'fixtures.bar',
              configuration: HomeAppBar(
                avatar: AppBarAvatar(text: copy('sampleAvatar')),
                wallet: AppBarWallet(
                  points: copy('samplePoints'),
                  unit: copy('samplePointsUnit'),
                  coins: copy('sampleCoins'),
                  pointsSemanticLabel: copy(
                    'samplePointSemantics',
                    arguments: {
                      'value': copy('samplePoints'),
                      'unit': copy('samplePointsUnit'),
                    },
                  ),
                  coinsSemanticLabel: copy(
                    'sampleCoinSemantics',
                    arguments: {'value': copy('sampleCoins')},
                  ),
                ),
                profile: action,
                help: action,
                addCoins: action,
              ),
            ),
            AppNavigationBar(
              elementId: 'fixtures.navigation',
              destinations: [
                for (final d in NavigationBarSpec.lookup(
                  Theme.of(context).brightness,
                ).referenceDestinations)
                  AppNavigationDestination(
                    id: d.id,
                    label: copy(switch (d.id) {
                      'home' => 'sampleNavHome',
                      'mission' => 'sampleNavMission',
                      'games' => 'sampleNavGames',
                      'leaderboard' => 'sampleNavLeaderboard',
                      _ => 'sampleNavShop',
                    }),
                    icon: d.icon,
                  ),
              ],
              selectedDestinationId: selected,
              onDestinationSelected: (v) => setState(() => selected = v),
            ),
          ],
        ),
      ),
    );
  }
}
