import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../catalog/button_catalog.dart';
import '../inspection/inspection_record.dart';
import '../l10n/generated/viewer_localizations.dart';
import 'button_sample.dart';
import 'preview_settings.dart';

class ButtonBoard extends StatelessWidget {
  const ButtonBoard({
    super.key,
    required this.rows,
    required this.settings,
    required this.selected,
    required this.onSelect,
    required this.onObserve,
  });
  final List<ButtonSpec> rows;
  final PreviewSettings settings;
  final String? selected;
  final ValueChanged<String> onSelect;
  final ValueChanged<InspectionRecord> onObserve;
  @override
  Widget build(BuildContext context) {
    final l = ViewerLocalizations.of(context);
    final families = ButtonCatalog.families
        .where((f) => rows.any((s) => s.family == f))
        .toList();
    final themes = ButtonCatalog.themes
        .where((t) => rows.any((s) => s.brightness == t))
        .length;
    double bandWidth(AppButtonFamily family) => family == AppButtonFamily.icon
        ? 432
        : themes *
              ((family == AppButtonFamily.fill
                      ? (settings.reference
                            ? rows.firstWhere((s) => s.family == family).width
                            : settings.fillWidth)
                      : settings.reference
                      ? 170
                      : settings.fillWidth) +
                  40);
    final width = families.fold<double>(0, (sum, f) => sum + bandWidth(f) + 24);
    return LayoutBuilder(
      // PHYSICAL: horizontal scrolling starts at the physical left in either language.
      builder: (context, constraints) => Directionality(
        textDirection: TextDirection.ltr,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Align(
              alignment: Alignment.topCenter,
              // PHYSICAL: screenshot family/theme order never reverses with the UI language.
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: SizedBox(
                  width: width,
                  child: Column(
                    key: const ValueKey('buttons-board'),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          for (final family in families)
                            Padding(
                              padding: const EdgeInsetsDirectional.symmetric(
                                horizontal: 12,
                              ),
                              child: SizedBox(
                                width: bandWidth(family),
                                child: Text(
                                  familyName(l, family),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final size in AppButtonSize.values)
                        if (rows.any((s) => s.size == size))
                          Padding(
                            key: ValueKey('size-row-${size.name}'),
                            padding: const EdgeInsetsDirectional.only(
                              bottom: 24,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final family in families)
                                  Padding(
                                    padding:
                                        const EdgeInsetsDirectional.symmetric(
                                          horizontal: 12,
                                        ),
                                    child: SizedBox(
                                      key: ValueKey(
                                        'band-${family.name}-${size.name}',
                                      ),
                                      width: bandWidth(family),
                                      child: family == AppButtonFamily.icon
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                for (final theme
                                                    in ButtonCatalog.themes)
                                                  if (ButtonCatalog.set(
                                                    rows,
                                                    family,
                                                    size,
                                                    theme,
                                                  ).isNotEmpty)
                                                    sourceSet(
                                                      context,
                                                      ButtonCatalog.set(
                                                        rows,
                                                        family,
                                                        size,
                                                        theme,
                                                      ),
                                                    ),
                                              ],
                                            )
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                for (final theme
                                                    in ButtonCatalog.themes)
                                                  if (ButtonCatalog.set(
                                                    rows,
                                                    family,
                                                    size,
                                                    theme,
                                                  ).isNotEmpty)
                                                    sourceSet(
                                                      context,
                                                      ButtonCatalog.set(
                                                        rows,
                                                        family,
                                                        size,
                                                        theme,
                                                      ),
                                                    ),
                                              ],
                                            ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sourceSet(BuildContext context, List<ButtonSpec> variants) {
    final spec = variants.first;
    final l = ViewerLocalizations.of(context);
    final theme = AppThemeFactory.build(
      skin: SkinTheme.of(context),
      brightness: spec.brightness,
    );
    final children = [
      for (final row in variants)
        ButtonSample(
          key: ValueKey('sample-${row.id}'),
          spec: row,
          settings: settings,
          selected: selected == row.id,
          onSelect: () => onSelect(row.id),
          onObserve: onObserve,
        ),
    ];
    return Padding(
      key: ValueKey('set-${spec.setId}'),
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: spec.family == AppButtonFamily.icon
                ? 400
                : spec.family == AppButtonFamily.fill
                ? (settings.reference ? spec.width : settings.fillWidth) + 24
                : (settings.reference ? 170 : settings.fillWidth) + 24,
            child: Tooltip(
              message: '${spec.setName} / ${spec.setId}',
              child: Text(
                spec.setName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Theme(
            data: theme,
            child: Material(
              color: theme.extension<ButtonThemeTokens>()!.color(
                'Surface/Base',
              ),
              child: Padding(
                padding: const EdgeInsetsDirectional.all(8),
                child: spec.family == AppButtonFamily.icon
                    ? Row(
                        key: ValueKey('icon-row-${spec.setId}'),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: children,
                      )
                    : Column(
                        key: ValueKey('text-column-${spec.setId}'),
                        mainAxisSize: MainAxisSize.min,
                        children: children,
                      ),
              ),
            ),
          ),
          if (spec.family == AppButtonFamily.icon &&
              settings.iconMode == ButtonIconMode.none)
            Text(l.iconStyleRequired, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
