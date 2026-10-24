import 'package:flutter/material.dart';

import '../../tokens/app_bar_spec.dart';
import 'app_bar_content.dart';

/// Use as Scaffold.appBar with primary:true. Do not wrap in a second SafeArea.
/// Preferred size excludes system insets; Scaffold allocates top + content.
class AppBarScaffoldAdapter extends StatelessWidget
    implements PreferredSizeWidget {
  const AppBarScaffoldAdapter({super.key, required this.content});
  final AppBarContent content;
  @override
  Size get preferredSize => Size.fromHeight(AppBarSpec.all.first.contentHeight);
  @override
  Widget build(BuildContext context) => SafeArea(bottom: false, child: content);
}
