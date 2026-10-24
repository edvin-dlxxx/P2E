import 'package:flutter/material.dart';

import '../app_bars/app_bar_browser.dart';
import '../navigation/navigation_browser.dart';
import '../inspection/inspection_record.dart';
import '../l10n/generated/viewer_localizations.dart';
import 'page_scaffold_gallery.dart';
import 'auth_primitives_gallery.dart';

enum _Category { appBar, navigation, adaptive, auth }

class ComponentsBrowser extends StatefulWidget {
  const ComponentsBrowser({
    super.key,
    required this.selected,
    required this.onInspect,
  });
  final String? selected;
  final ValueChanged<InspectionRecord?> onInspect;
  @override
  State<ComponentsBrowser> createState() => _ComponentsBrowserState();
}

class _ComponentsBrowserState extends State<ComponentsBrowser> {
  _Category category = _Category.appBar;
  @override
  Widget build(BuildContext context) {
    final l = ViewerLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.all(12),
          child: Wrap(
            spacing: 12,
            children: [
              ChoiceChip(
                key: const ValueKey('components-auth'),
                label: Text(l.authPrimitives),
                selected: category == _Category.auth,
                onSelected: (_) {
                  setState(() => category = _Category.auth);
                  widget.onInspect(null);
                },
              ),
              ChoiceChip(
                key: const ValueKey('components-app-bar'),
                label: Text(l.appBarTitle),
                selected: category == _Category.appBar,
                onSelected: (_) {
                  setState(() => category = _Category.appBar);
                  widget.onInspect(null);
                },
              ),
              ChoiceChip(
                key: const ValueKey('components-navigation'),
                label: Text(l.navTitle),
                selected: category == _Category.navigation,
                onSelected: (_) {
                  setState(() => category = _Category.navigation);
                  widget.onInspect(null);
                },
              ),
              ChoiceChip(
                key: const ValueKey('components-adaptive'),
                label: Text(l.pageScaffoldTitle),
                selected: category == _Category.adaptive,
                onSelected: (_) {
                  setState(() => category = _Category.adaptive);
                  widget.onInspect(null);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (category) {
            _Category.auth => const AuthPrimitivesGallery(),
            _Category.navigation => NavigationBrowser(
              selected: widget.selected,
              onInspect: widget.onInspect,
            ),
            _Category.appBar => AppBarBrowser(
              selected: widget.selected,
              onInspect: widget.onInspect,
            ),
            _Category.adaptive => const PageScaffoldGallery(),
          },
        ),
      ],
    );
  }
}
