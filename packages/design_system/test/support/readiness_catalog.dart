import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../navigation/navigation_bar_test.dart' as navigation;

/// Caller-side display conversion only; DS widgets preserve supplied text.
String fixtureDigits(String value, String language) => language != 'fa'
    ? value
    : value.replaceAllMapped(
        RegExp('[0-9]'),
        (m) => '۰۱۲۳۴۵۶۷۸۹'[int.parse(m[0]!)],
      );

List<AppNavigationDestination> fixtureDestinations(
  String language,
  Brightness brightness,
) => [
  for (final d in navigation.destinations(
    brightness: brightness,
    persian: language == 'fa',
  ))
    AppNavigationDestination(
      id: d.id,
      label: d.label,
      icon: d.icon,
      semanticLabel: d.semanticLabel,
      badge: d.badge == null
          ? null
          : AppNavigationBadge(
              label: fixtureDigits(d.badge!.label, language),
              semanticLabel: fixtureDigits(d.badge!.semanticLabel, language),
            ),
    ),
];

Map<String, Widget> readinessCases(String language, Brightness brightness) {
  final label = language == 'fa' ? 'ادامه' : 'Continue';
  final input = TextEditingController(
    text: language == 'fa' ? '۱۲۳۴۵۶' : '123456',
  );
  final cases = <String, Widget>{
    for (final spec in ButtonSpec.all.where((s) => s.brightness == brightness))
      for (final mode in ButtonIconMode.values.where(
        (mode) =>
            spec.family != AppButtonFamily.icon || mode != ButtonIconMode.none,
      ))
        'Button/${spec.family.name}/${spec.size.name}/${spec.type.name}/${mode.name}':
            AppButton(
              elementId: 'audit.button',
              label: label,
              onPressed: () {},
              family: spec.family,
              size: spec.size,
              type: spec.type,
              iconMode: mode,
              icon: mode != ButtonIconMode.none
                  ? const AssetAppIcon(AppIconId.home)
                  : null,
            ),
    for (final spec in BadgeSpec.all.where((s) => s.brightness == brightness))
      for (final mode in BadgeIconMode.values)
        'Badge/${spec.size.name}/${spec.appearance.name}/${mode.name}':
            AppBadge(
              elementId: 'audit.badge',
              label: language == 'fa' ? fixtureDigits('12', language) : label,
              size: spec.size,
              appearance: spec.appearance,
              iconMode: mode,
            ),
    'TextField': AppTextField(
      elementId: 'audit.field',
      label: label,
      options: FieldInputOptions(controller: input, supportingText: label),
    ),
    'Password': AppPasswordField(
      elementId: 'audit.password',
      label: label,
      showPasswordLabel: label,
      hidePasswordLabel: label,
      options: FieldInputOptions(controller: input, supportingText: label),
    ),
    'OTP': AppOtpField(
      elementId: 'audit.otp',
      label: label,
      controller: input,
      supportingText: label,
    ),
    'Radio': AppRadioGroup<int>(
      value: 1,
      onChanged: (_) {},
      child: AppRadio<int>(elementId: 'audit.radio', value: 1, label: label),
    ),
    for (final id in AppIconId.values)
      for (final style in AppIconStyle.values)
        'AppIcon/${id.name}/${style.name}': AssetAppIcon(id, style: style),
    for (final configuration in <AppBarConfiguration>[
      HomeAppBar(
        avatar: AppBarAvatar(text: language == 'fa' ? 'سم' : 'CM'),
        wallet: AppBarWallet(
          points: fixtureDigits('150', language),
          unit: label,
          coins: fixtureDigits('25', language),
          pointsSemanticLabel: label,
          coinsSemanticLabel: label,
        ),
        profile: AppBarAction(label: label, onPressed: () {}),
        help: AppBarAction(label: label, onPressed: () {}),
        addCoins: AppBarAction(label: label, onPressed: () {}),
      ),
      DownloadableGameAppBar(
        avatar: AppBarAvatar(text: language == 'fa' ? 'سم' : 'CM'),
        back: AppBarAction(label: label, onPressed: () {}),
        downloads: AppBarAction(label: label, onPressed: () {}),
        bookmark: AppBarAction(label: label, onPressed: () {}),
        profile: AppBarAction(label: label, onPressed: () {}),
      ),
      if (brightness == Brightness.dark)
        BackAppBar(
          back: AppBarAction(label: label, onPressed: () {}),
          help: AppBarAction(label: label, onPressed: () {}),
        ),
    ])
      'AppBar/${configuration.category.name}': AppBarScaffoldAdapter(
        content: AppBarContent(
          elementId: 'audit.app-bar',
          configuration: configuration,
        ),
      ),
    for (final selected in ['home', 'mission', 'games', 'leaderboard', 'shop'])
      'Navigation/$selected': AppNavigationBarHost(
        bar: AppNavigationBar(
          elementId: 'audit.navigation',
          destinations: fixtureDestinations(language, brightness),
          selectedDestinationId: selected,
          onDestinationSelected: (_) {},
        ),
      ),
    for (final state in AppNavigationItemState.values)
      'NavigationItem/${state.name}': AppNavigationItem(
        elementId: 'audit.item',
        destination: fixtureDestinations(language, brightness).first,
        state: state,
        onPressed: () {},
      ),
  };

  for (final spec in ButtonSpec.all.where((s) => s.brightness == brightness)) {
    cases['Button/loading/${spec.family.name}/${spec.size.name}/${spec.type.name}'] =
        AppButton(
          elementId: 'sheet.loading',
          label: label,
          onPressed: () {},
          loading: true,
          loadingSemanticsLabel: language == 'fa' ? 'در حال انجام' : 'Loading',
          family: spec.family,
          size: spec.size,
          type: spec.type,
          iconMode: ButtonIconMode.fill,
          icon: const AssetAppIcon(AppIconId.home),
        );
  }
  for (final spec in FieldSpec.all.where((s) => s.brightness == brightness)) {
    final family = switch (spec.family) {
      FieldFamily.textField => 'TextField',
      FieldFamily.password => 'Password',
      FieldFamily.otp => 'OTP',
      FieldFamily.radio => 'Radio',
    };
    cases['$family/source/${spec.basisId}'] = switch (spec.family) {
      FieldFamily.radio => AppRadioPresentation(spec: spec, label: label),
      FieldFamily.otp => AppOtpCell(
        spec: spec,
        value: fixtureDigits('1', language),
      ),
      _ => AppFieldSurface(
        spec: spec,
        label: label,
        supportingText: label,
        input: Builder(
          builder: (context) => Text(
            fixtureDigits('123456', language),
            style: spec
                .withSkin(SkinTheme.of(context))
                .textStyle('input', persian: language == 'fa'),
          ),
        ),
      ),
    };
  }
  cases['PageScaffold'] = PageScaffold(
    elementId: 'sheet.page',
    child: Column(
      children: [
        Builder(
          builder: (context) => Text(
            label,
            style: ButtonThemeTokens.forBrightness(brightness)
                .textStyles
                .values
                .first
                .copyWith(
                  color: identical(SkinTheme.of(context), productSkin)
                      ? null
                      : SkinTheme.of(context)
                            .valuesFor(brightness)
                            .color('On Surface/Emphasis'),
                ),
          ),
        ),
        AppTextField(elementId: 'sheet.page.field', label: label),
        AppButton(
          elementId: 'sheet.page.button',
          label: label,
          onPressed: () {},
        ),
      ],
    ),
  );
  return cases;
}
