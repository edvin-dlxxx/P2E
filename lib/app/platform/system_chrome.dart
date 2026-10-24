import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2e_design_system/design_system.dart';

/// One shared OS overlay policy. The hero paints under real system chrome;
/// no fake status-bar widget or platform branch is introduced.
class AppSystemChrome extends StatelessWidget {
  const AppSystemChrome({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AuthHeroMaskTokens.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      ),
      child: child,
    );
  }
}
