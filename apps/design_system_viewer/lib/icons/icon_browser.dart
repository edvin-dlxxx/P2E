import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../inspection/inspection_record.dart';
import '../inspection/viewer_selection_frame.dart';
import '../l10n/generated/viewer_localizations.dart';
import '../viewer_style.dart';

class IconBrowser extends StatefulWidget {
  const IconBrowser({
    super.key,
    required this.selected,
    required this.onInspect,
  });
  final String? selected;
  final ValueChanged<InspectionRecord?> onInspect;
  @override
  State<IconBrowser> createState() => _IconBrowserState();
}

class _IconBrowserState extends State<IconBrowser> {
  String query = '', style = 'all', tint = 'original';
  double size = 32;
  Brightness brightness = Brightness.dark;
  String? locale;
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Localizations.localeOf(context).languageCode;
    if (locale != next) {
      locale = next;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) refresh();
      });
    }
  }

  List<({IconDefinition icon, AppIconStyle style})> entries(
    ViewerLocalizations l,
  ) => [
    for (final icon in AppIconRegistry.all)
      if ('${icon.key} ${icon.rawName} ${l.iconLabel(icon.data['id'] as String)}'
          .toLowerCase()
          .contains(query.toLowerCase().trim()))
        for (final version in icon.styles)
          if (style == 'all' || style == version.name)
            (icon: icon, style: version),
  ];
  String identity(IconDefinition icon, AppIconStyle version) =>
      '${icon.key}:${version.name}';
  Color? previewTint(BuildContext context) => switch (tint) {
    'theme' => AppThemeFactory.build(
      skin: SkinTheme.of(context),
      brightness: brightness,
    ).extension<ButtonThemeTokens>()!.color('On Surface/Emphasis'),
    'accent' => Theme.of(context).colorScheme.primary,
    _ => null,
  };
  String styleLabel(ViewerLocalizations l, AppIconStyle version) =>
      version == AppIconStyle.fill ? l.fillIcon : l.outlineIcon;
  InspectionRecord record(IconDefinition icon, AppIconStyle version) {
    final l = ViewerLocalizations.of(context),
        a = icon.artwork(version),
        color = previewTint(context);
    InspectionField f(InspectionFieldId id, Object? value) =>
        InspectionField(id, value);
    return InspectionRecord(
      sampleId: identity(icon, version),
      groups: {
        InspectionGroup.identity: [
          f(InspectionFieldId.logicalKey, icon.key),
          f(
            InspectionFieldId.displayName,
            l.iconLabel(icon.data['id'] as String),
          ),
          f(InspectionFieldId.rawName, a.data['rawName']),
          f(InspectionFieldId.fileKey, a.data['fileKey']),
          f(InspectionFieldId.variantId, a.nodeId),
          f(InspectionFieldId.setId, a.data['setId']),
          f(InspectionFieldId.setName, a.data['setName']),
          f(InspectionFieldId.status, l.provisional),
        ],
        InspectionGroup.configuration: [
          f(InspectionFieldId.style, styleLabel(l, version)),
          f(
            InspectionFieldId.availableStyles,
            icon.styles.map((s) => styleLabel(l, s)).join(' / '),
          ),
          f(InspectionFieldId.previewSize, Size(size, size)),
          f(
            InspectionFieldId.tint,
            a.monochrome ? color ?? l.originalArtwork : l.originalArtwork,
          ),
          f(
            InspectionFieldId.theme,
            brightness == Brightness.dark ? l.dark : l.light,
          ),
          f(InspectionFieldId.decorative, true),
          f(InspectionFieldId.semanticLabel, null),
        ],
        InspectionGroup.geometry: [
          f(InspectionFieldId.sourceDimensions, Size(a.width, a.height)),
          f(InspectionFieldId.viewBox, a.viewBox),
        ],
        InspectionGroup.visuals: [
          f(
            InspectionFieldId.assetPath,
            'packages/p2e_design_system/${a.assetPath}',
          ),
          f(InspectionFieldId.assetHash, a.sha256),
          f(InspectionFieldId.sourceColors, a.data['originalColors']),
          f(InspectionFieldId.bindings, a.data['originalPaints']),
          f(InspectionFieldId.extractionStatus, l.iconExported),
          f(
            InspectionFieldId.renderStatus,
            a.data['renderStatus'] == 'renderer-validated'
                ? l.iconRendered
                : l.iconRenderPending,
          ),
          f(InspectionFieldId.issue, a.data['issue']),
        ],
      },
    );
  }

  void refresh() {
    if (widget.selected == null) return;
    final l = ViewerLocalizations.of(context);
    final found = entries(l)
        .where((e) => identity(e.icon, e.style) == widget.selected);
    widget.onInspect(
      found.isEmpty ? null : record(found.single.icon, found.single.style),
    );
  }

  void change(VoidCallback fn) {
    setState(fn);
    refresh();
  }

  Widget control(
    String key,
    String label,
    String value,
    Map<String, String> choices,
    ValueChanged<String> onChanged,
  ) => SizedBox(
    width: 190,
    child: DropdownButtonFormField<String>(
      key: ValueKey('icons-$key-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      icon: ExcludeSemantics(
        child: Text(ViewerLocalizations.of(context).dropdownMark),
      ),
      items: choices.entries
          .map(
            (e) => DropdownMenuItem(
              value: e.key,
              child: Text(
                e.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
  @override
  Widget build(BuildContext context) {
    final l = ViewerLocalizations.of(context), rows = entries(l);
    final colors = AppThemeFactory.build(
      skin: SkinTheme.of(context),
      brightness: brightness,
    ).extension<ButtonThemeTokens>()!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: ViewerPanel(
            color: ViewerStyle.panelRaised,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        key: const ValueKey('icons-search'),
                        controller: search,
                        decoration: InputDecoration(labelText: l.iconSearch),
                        onChanged: (v) => change(() => query = v),
                      ),
                    ),
                    control('style', l.fieldLabel('style'), style, {
                      'all': l.all,
                      'fill': l.fillIcon,
                      'outline': l.outlineIcon,
                    }, (v) => change(() => style = v)),
                    control(
                      'theme',
                      l.theme,
                      brightness.name,
                      {'dark': l.dark, 'light': l.light},
                      (v) => change(
                        () => brightness = Brightness.values.byName(v),
                      ),
                    ),
                    control('size', l.iconSizePreview, size.toString(), {
                      for (final s in [16.0, 24.0, 32.0, 48.0, 64.0])
                        s.toString(): s.toInt().toString(),
                    }, (v) => change(() => size = double.parse(v))),
                    control('tint', l.iconTint, tint, {
                      'original': l.originalArtwork,
                      'theme': l.themeTint,
                      'accent': l.accentTint,
                    }, (v) => change(() => tint = v)),
                    TextButton(
                      key: const ValueKey('icons-reset'),
                      onPressed: () => change(() {
                        query = '';
                        search.clear();
                        style = 'all';
                        tint = 'original';
                        size = 32;
                        brightness = Brightness.dark;
                      }),
                      child: Text(l.reset),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l.iconLibraryCounts(
                    rows.map((e) => e.icon.key).toSet().length,
                    rows.length,
                  ),
                  key: const ValueKey('icons-count'),
                ),
                Text(l.iconLibraryStatus),
              ],
            ),
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? Center(child: Text(l.emptyState))
              : LayoutBuilder(
                  builder: (context, constraints) => GridView.builder(
                    key: const ValueKey('icons-grid'),
                    padding: const EdgeInsetsDirectional.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (constraints.maxWidth / 210)
                          .floor()
                          .clamp(1, 10),
                      mainAxisExtent: 190,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index],
                          icon = row.icon,
                          version = row.style,
                          id = identity(icon, version);
                      return ElementIdentity(
                        elementId:
                            'viewer.icon.${(icon.data['id'] as String).replaceAll('_', '-')}.${version.name}',
                        runtimeLocator: UiIdentityScope.resolve(context),
                        componentId: 'icon.preview',
                        structureRef: 'icon.preview.base',
                        fileKey:
                            icon.artwork(version).data['fileKey'] as String,
                        variantId: null,
                        componentSetId: null,
                        rawSetName: 'engineering-derived',
                        rawVariantName: 'viewer artwork host',
                        variants: {'style': version.name},
                        declared: const {},
                        resolved: {
                          'artwork': {
                            'value': {
                              'logicalKey': icon.key,
                              'style': version.name,
                              'fileKey': icon.artwork(version).data['fileKey'],
                              'nodeId': icon.artwork(version).nodeId,
                              'assetPath': icon.artwork(version).assetPath,
                            },
                            'origin': 'icon-registry',
                          },
                        },
                        child: ViewerSelectionFrame(
                          key: ValueKey('icon-card-$id'),
                          selected: widget.selected == id,
                          child: Material(
                            color: colors.color('Surface/Base'),
                            child: InkWell(
                              onTap: () =>
                                  widget.onInspect(record(icon, version)),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.all(12),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: AssetAppIcon(
                                          icon.id,
                                          style: version,
                                          size: size,
                                          color: previewTint(context),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      l.iconLabel(icon.data['id'] as String),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.color(
                                          'On Surface/Emphasis',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      icon.key,
                                      textDirection: TextDirection.ltr,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colors.color(
                                          'On Surface/Emphasis',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      styleLabel(l, version),
                                      style: TextStyle(
                                        color: colors.color(
                                          'On Surface/Emphasis',
                                        ),
                                      ),
                                    ),
                                    for (final missing
                                        in AppIconStyle.values.where(
                                          (s) => !icon.styles.contains(s),
                                        ))
                                      Text(
                                        l.missingCounterpart(
                                          styleLabel(l, missing),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
