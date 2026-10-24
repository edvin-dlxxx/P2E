import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../l10n/generated/viewer_localizations.dart';

/// Engineering layout examples in the existing catalog, not product screens.
class PageScaffoldGallery extends StatelessWidget {
  const PageScaffoldGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = ViewerLocalizations.of(context);
    return ListView(
      padding: const EdgeInsetsDirectional.all(12),
      children: [
        for (final width in [390.0, 700.0, 1000.0]) ...[
          Text(
            strings.pageScaffoldSize(SizeClass.fromWidth(width).name, width),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              height: 240,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(size: Size(width, 240)),
                child: UiIdentityScope(
                  routeName: 'adaptive-preview',
                  instanceKey: 'width-${width.toInt()}',
                  child: Theme(
                    data: AppThemeFactory.build(
                      skin: SkinTheme.of(context),
                      brightness: Theme.of(context).brightness,
                    ),
                    child: PageScaffold(
                      elementId: 'gallery.page-scaffold',
                      child: Column(
                        children: [
                          Text(strings.pageScaffoldDescription),
                          const SizedBox(height: 240),
                          AppTextField(
                            elementId: 'gallery.page-scaffold.field',
                            label: strings.pageScaffoldField,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
