import 'package:flutter/widgets.dart';

import '../../tokens/app_bar_spec.dart';

/// Consumer-localized action metadata; null callback is honestly unavailable.
@immutable
class AppBarAction {
  const AppBarAction({required this.label, required this.onPressed})
    : assert(label != '');
  final String label;
  final VoidCallback? onPressed;
}

/// Caller supplies localized initials (1–2 graphemes), not a full name.
/// Text/custom content is clipped to the circular avatar at every chrome scale.
@immutable
class AppBarAvatar {
  const AppBarAvatar({this.text = '', this.content})
    : assert(content != null || text != '');
  final String text;
  final Widget? content;
}

@immutable
class CompactAppBarWallet {
  const CompactAppBarWallet({
    required this.points,
    required this.coins,
    this.showUnit = true,
  });
  final String points, coins;
  final bool showUnit;
}

/// Caller-localized wallet strings; the bar never invents number formatting.
/// D-044: all chrome text caps at 1.3. Six-digit values plus units exceed a
/// 402 viewport (489 en / 474 fa); provide [compact] for simultaneous visibility.
/// Otherwise the existing horizontal canvas scrolls, without extra shrinking or
/// silent ellipsis. Semantic labels must always include the full value + unit,
/// even when the visual [compact] strings abbreviate them, like Badge counts.
@immutable
class AppBarWallet {
  const AppBarWallet({
    required this.points,
    required this.unit,
    required this.coins,
    required this.pointsSemanticLabel,
    required this.coinsSemanticLabel,
    this.compact,
  });
  final String points, unit, coins, pointsSemanticLabel, coinsSemanticLabel;
  final CompactAppBarWallet? compact;
}

sealed class AppBarConfiguration {
  const AppBarConfiguration();
  AppBarCategory get category;
  Map<String, AppBarAction> get actions;
}

class HomeAppBar extends AppBarConfiguration {
  const HomeAppBar({
    required this.avatar,
    required this.wallet,
    required this.profile,
    required this.help,
    required this.addCoins,
  });
  final AppBarAvatar avatar;
  final AppBarWallet wallet;
  final AppBarAction profile, help, addCoins;
  @override
  AppBarCategory get category => AppBarCategory.home;
  @override
  Map<String, AppBarAction> get actions => {
    'profile': profile,
    'addCoins': addCoins,
    'help': help,
  };
}

class DownloadableGameAppBar extends AppBarConfiguration {
  const DownloadableGameAppBar({
    required this.avatar,
    required this.back,
    required this.downloads,
    required this.bookmark,
    required this.profile,
    this.showNotification = false,
    this.notificationLabel,
  }) : assert(
         !showNotification ||
             (notificationLabel != null && notificationLabel != ''),
       );
  final AppBarAvatar avatar;
  final AppBarAction back, downloads, bookmark, profile;
  final bool showNotification;
  final String? notificationLabel;
  @override
  AppBarCategory get category => AppBarCategory.downloadableGame;
  @override
  Map<String, AppBarAction> get actions => {
    'back': back,
    'downloads': downloads,
    'bookmark': bookmark,
    'profile': profile,
  };
}

class BackAppBar extends AppBarConfiguration {
  const BackAppBar({required this.back, required this.help});
  final AppBarAction back, help;
  @override
  AppBarCategory get category => AppBarCategory.back;
  @override
  Map<String, AppBarAction> get actions => {'back': back, 'help': help};
}
