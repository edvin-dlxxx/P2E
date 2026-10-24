import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../inspection/inspection_record.dart';
import '../inspection/viewer_selection_frame.dart';
import '../l10n/generated/viewer_localizations.dart';
import '../verification/measurement.dart';
import '../viewer_style.dart';

String appBarCategoryName(ViewerLocalizations l, AppBarCategory category) =>
    switch (category) {
      AppBarCategory.home => l.appBarHome,
      AppBarCategory.downloadableGame => l.appBarGame,
      AppBarCategory.back => l.appBarBack,
    };

class AppBarBrowser extends StatefulWidget {
  const AppBarBrowser({
    super.key,
    required this.selected,
    required this.onInspect,
  });
  final String? selected;
  final ValueChanged<InspectionRecord?> onInspect;
  @override
  State<AppBarBrowser> createState() => _AppBarBrowserState();
}

class _AppBarBrowserState extends State<AppBarBrowser> {
  String category = 'all', theme = 'all', direction = 'auto';
  bool reference = true,
      notification = true,
      compact = false,
      longValues = false,
      unavailable = false;
  double width = 402, scale = 1;
  final avatar = TextEditingController(text: 'A'),
      points = TextEditingController(text: '5,325'),
      coins = TextEditingController(text: '150'),
      compactPoints = TextEditingController(text: '5.3k'),
      compactCoins = TextEditingController(text: '150'),
      unit = TextEditingController();
  final counts = ValueNotifier<Map<String, int>>({});
  ViewerLocalizations get l => ViewerLocalizations.of(context);
  List<AppBarSpec> get rows => AppBarSpec.all
      .where(
        (s) =>
            (category == 'all' || s.category.name == category) &&
            (theme == 'all' || s.brightness.name == theme),
      )
      .toList();
  @override
  void dispose() {
    for (final c in [
      avatar,
      points,
      coins,
      unit,
      compactPoints,
      compactCoins,
    ]) {
      c.dispose();
    }
    counts.dispose();
    super.dispose();
  }

  void change(VoidCallback fn) {
    setState(fn);
    if (widget.selected != null && !rows.any((s) => s.id == widget.selected)) {
      widget.onInspect(null);
    }
  }

  Widget select(
    String id,
    String label,
    String current,
    Map<String, String> choices,
    ValueChanged<String> update,
  ) => SizedBox(
    width: 190,
    child: DropdownButtonFormField<String>(
      key: ValueKey('app-bar-$id-$current'),
      initialValue: current,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      icon: ExcludeSemantics(child: Text(l.dropdownMark)),
      items: [
        for (final e in choices.entries)
          DropdownMenuItem(
            value: e.key,
            child: Text(e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (v) {
        if (v != null) change(() => update(v));
      },
    ),
  );
  Widget toggle(
    String id,
    String label,
    bool value,
    ValueChanged<bool> update,
  ) => FilterChip(
    key: ValueKey('app-bar-$id'),
    label: Text(label),
    selected: value,
    onSelected: (v) => change(() => update(v)),
    showCheckmark: false,
  );
  AppBarConfiguration configuration(AppBarSpec s) {
    final local = reference ? lookupViewerLocalizations(const Locale('en')) : l;
    AppBarAction action(String role, String label) => AppBarAction(
      label: label,
      onPressed: unavailable
          ? null
          : () {
              counts.value = {
                ...counts.value,
                role: (counts.value[role] ?? 0) + 1,
              };
            },
    );
    final av = AppBarAvatar(text: avatar.text.isEmpty ? 'A' : avatar.text);
    final p = longValues ? '12,345,678,901' : points.text,
        c = longValues ? '987,654,321' : coins.text;
    final u = unit.text.isEmpty ? local.appBarUnitSample : unit.text;
    return switch (s.category) {
      AppBarCategory.home => HomeAppBar(
        avatar: av,
        profile: action('profile', local.appBarProfile),
        help: action('help', local.appBarHelp),
        addCoins: action('addCoins', local.appBarAddCoins),
        wallet: AppBarWallet(
          points: p,
          unit: u,
          coins: c,
          pointsSemanticLabel: local.appBarPointsMeaning(p, u),
          coinsSemanticLabel: local.appBarCoinsMeaning(c),
          compact: compact
              ? CompactAppBarWallet(
                  points: compactPoints.text,
                  coins: compactCoins.text,
                  showUnit: false,
                )
              : null,
        ),
      ),
      AppBarCategory.downloadableGame => DownloadableGameAppBar(
        avatar: av,
        back: action('back', local.appBarBack),
        downloads: action('downloads', local.appBarDownloads),
        bookmark: action('bookmark', local.appBarBookmark),
        profile: action('profile', local.appBarProfile),
        showNotification: notification,
        notificationLabel: local.appBarNotificationLabel,
      ),
      AppBarCategory.back => BackAppBar(
        back: action('back', local.appBarBack),
        help: action('help', local.appBarHelp),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final previewDirection = reference
        ? TextDirection.ltr
        : direction == 'auto'
        ? Directionality.of(context)
        : direction == 'rtl'
        ? TextDirection.rtl
        : TextDirection.ltr;
    return SingleChildScrollView(
      key: const ValueKey('app-bars-scroll'),
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewerPanel(
            color: ViewerStyle.panelRaised,
            padding: const EdgeInsetsDirectional.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.appBarTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    select('category', l.appBarCategory, category, {
                      'all': l.all,
                      for (final c in AppBarCategory.values)
                        c.name: appBarCategoryName(l, c),
                    }, (v) => category = v),
                    select('theme', l.theme, theme, {
                      'all': l.all,
                      'dark': l.dark,
                      'light': l.light,
                    }, (v) => theme = v),
                    select(
                      'mode',
                      l.previewLabel,
                      reference ? 'source' : 'localized',
                      {
                        'source': l.appBarSource,
                        'localized': l.appBarLocalized,
                      },
                      (v) => reference = v == 'source',
                    ),
                    select(
                      'direction',
                      l.previewDirection,
                      direction,
                      {'auto': l.followLanguage, 'ltr': l.ltr, 'rtl': l.rtl},
                      (v) {
                        direction = v;
                        reference = false;
                      },
                    ),
                    select('scale', l.textScale, scale.toString(), {
                      '1.0': '1.0',
                      '1.3': '1.3',
                    }, (v) => scale = double.parse(v)),
                    select('width', l.appBarPreviewWidth, width.toString(), {
                      for (final w in [280, 320, 360, 390, 402, 600, 900])
                        w.toDouble().toString(): w.toString(),
                    }, (v) => width = double.parse(v)),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  children: [
                    toggle(
                      'notification',
                      l.appBarNotification,
                      notification,
                      (v) => notification = v,
                    ),
                    toggle(
                      'compact',
                      l.appBarCompact,
                      compact,
                      (v) => compact = v,
                    ),
                    toggle('long', l.appBarLong, longValues, (v) {
                      longValues = v;
                      compactPoints.text = v ? '12.3B' : '5.3k';
                      compactCoins.text = v ? '987.7M' : '150';
                    }),
                    toggle(
                      'unavailable',
                      l.appBarUnavailableActions,
                      unavailable,
                      (v) => unavailable = v,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final item in [
                      (avatar, l.appBarAvatar, 'avatar'),
                      (points, l.appBarPoints, 'points'),
                      (unit, l.appBarUnit, 'unit'),
                      (coins, l.appBarCoins, 'coins'),
                      if (compact)
                        (
                          compactPoints,
                          l.appBarCompactPoints,
                          'compact-points',
                        ),
                      if (compact)
                        (compactCoins, l.appBarCompactCoins, 'compact-coins'),
                    ])
                      SizedBox(
                        width: 180,
                        child: TextField(
                          key: ValueKey('app-bar-data-${item.$3}'),
                          controller: item.$1,
                          decoration: InputDecoration(labelText: item.$2),
                          onChanged: (_) => change(() => reference = false),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l.appBarCount(rows.length)),
                Text(l.appBarMissing),
                Text(l.appBarPolicy),
                ValueListenableBuilder<Map<String, int>>(
                  valueListenable: counts,
                  builder: (context, value, _) => Text(
                    l.appBarFeedback(
                      value.entries
                          .map(
                            (e) =>
                                '${switch (e.key) {
                                  'profile' => l.appBarProfile,
                                  'help' => l.appBarHelp,
                                  'back' => l.appBarBack,
                                  'downloads' => l.appBarDownloads,
                                  'bookmark' => l.appBarBookmark,
                                  _ => l.appBarAddCoins,
                                }}: ${e.value}',
                          )
                          .join(' · '),
                    ),
                    key: const ValueKey('app-bar-feedback'),
                  ),
                ),
              ],
            ),
          ),
          for (final cat in AppBarCategory.values)
            if (rows.any((s) => s.category == cat)) ...[
              Padding(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 16),
                child: Text(
                  appBarCategoryName(l, cat),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final spec in rows.where((s) => s.category == cat))
                Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: AppBarSample(
                      key: ValueKey(spec.id),
                      spec: spec,
                      width: width,
                      scale: scale,
                      direction: previewDirection,
                      locale: reference
                          ? const Locale('en')
                          : Localizations.localeOf(context),
                      configuration: configuration(spec),
                      selected: widget.selected == spec.id,
                      onInspect: widget.onInspect,
                    ),
                  ),
                ),
            ],
        ],
      ),
    );
  }
}

class AppBarSample extends StatefulWidget {
  const AppBarSample({
    super.key,
    required this.spec,
    required this.width,
    required this.scale,
    required this.direction,
    required this.locale,
    required this.configuration,
    required this.selected,
    required this.onInspect,
  });
  final AppBarSpec spec;
  final double width, scale;
  final TextDirection direction;
  final Locale locale;
  final AppBarConfiguration configuration;
  final bool selected;
  final ValueChanged<InspectionRecord?> onInspect;
  @override
  State<AppBarSample> createState() => _AppBarSampleState();
}

class _AppBarSampleState extends State<AppBarSample> {
  final anchor = GlobalKey();
  Size? measured;
  @override
  void didUpdateWidget(AppBarSample old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.selected) publish();
    });
  }

  void publish() {
    final s = widget.spec,
        ids = <String, Object?>{},
        bounds = <String, Object?>{},
        icons = <String, Object?>{};
    final root = anchor.currentContext?.findRenderObject();
    void visit(Element e) {
      if (e.widget case final ElementIdentity identity) {
        ids[identity.elementId] = identity.descriptor();
      }
      if (e.widget.key case final ValueKey<String> key) {
        final box = e.findRenderObject();
        if (box is RenderBox && box.hasSize && root is RenderBox) {
          bounds[key.value] = {
            'size': box.size.toString(),
            'origin': box.localToGlobal(Offset.zero, ancestor: root).toString(),
          };
        }
      }
      if (e.widget case final AssetAppIcon icon) {
        final box = e.findRenderObject();
        icons[icon.key.toString()] = {
          'key': icon.logicalKey,
          'style': icon.style.name,
          'sourceId': icon.sourceNodeId,
          'tint': icon.color?.toARGB32(),
          'asset': icon.artwork.assetPath,
          'measured': box is RenderBox ? box.size.toString() : null,
        };
      }
      e.visitChildren(visit);
    }

    anchor.currentContext?.visitChildElements(visit);
    InspectionField f(InspectionFieldId id, Object? value) =>
        InspectionField(id, value);
    widget.onInspect(
      InspectionRecord(
        sampleId: s.id,
        groups: {
          InspectionGroup.identity: [
            f(
              InspectionFieldId.family,
              appBarCategoryName(ViewerLocalizations.of(context), s.category),
            ),
            f(InspectionFieldId.fileKey, s.fileKey),
            f(InspectionFieldId.setId, s.setId),
            f(InspectionFieldId.setName, s.setName),
            f(InspectionFieldId.variantId, s.id),
            f(InspectionFieldId.variantName, s.rawName),
            f(InspectionFieldId.sourceCovered, true),
            f(InspectionFieldId.runtimeIdentity, ids),
          ],
          InspectionGroup.configuration: [
            // This catalog contains editable synthetic data only. Do not collect
            // product user data into the Viewer inspection contract.
            f(InspectionFieldId.label, switch (widget.configuration) {
              final HomeAppBar home => {
                'avatar': home.avatar.text,
                'customAvatarContent': home.avatar.content != null,
                'points': home.wallet.points,
                'unit': home.wallet.unit,
                'coins': home.wallet.coins,
                'pointsSemanticLabel': home.wallet.pointsSemanticLabel,
                'coinsSemanticLabel': home.wallet.coinsSemanticLabel,
                'compact': home.wallet.compact == null
                    ? null
                    : {
                        'points': home.wallet.compact!.points,
                        'coins': home.wallet.compact!.coins,
                        'showUnit': home.wallet.compact!.showUnit,
                      },
              },
              final DownloadableGameAppBar game => {
                'avatar': game.avatar.text,
                'customAvatarContent': game.avatar.content != null,
                'notification': game.showNotification,
                'notificationLabel': game.notificationLabel,
              },
              BackAppBar() => const <String, Object?>{},
            }),
            f(InspectionFieldId.theme, s.brightness.name),
            f(InspectionFieldId.direction, widget.direction.name),
            f(InspectionFieldId.scale, widget.scale),
            f(InspectionFieldId.enabled, {
              for (final e in widget.configuration.actions.entries)
                e.key: e.value.onPressed != null,
            }),
          ],
          InspectionGroup.visuals: [
            f(
              InspectionFieldId.resolvedStyles,
              s.resolved(persian: widget.locale.languageCode == 'fa'),
            ),
            f(InspectionFieldId.artwork, icons),
          ],
          InspectionGroup.geometry: [
            f(InspectionFieldId.sourceDimensions, s.sourceSize),
            f(InspectionFieldId.content, measured),
            f(InspectionFieldId.visual, bounds),
            f(InspectionFieldId.comparison, {
              'contentBoundsMatch': measured == s.sourceSize,
              'scope': 'contentBounds',
              'sourceWidth': s.sourceSize.width,
              'sourceHeight': s.sourceSize.height,
            }),
          ],
          InspectionGroup.interaction: [
            f(InspectionFieldId.motion, AppBarSpec.engineering),
          ],
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.spec, l = ViewerLocalizations.of(context);
    final content = Localizations.override(
      context: context,
      locale: widget.locale,
      child: Directionality(
        textDirection: widget.direction,
        child: MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(widget.scale)),
          child: MeasureBox(
            onSize: (size) {
              measured = size;
              if (widget.selected) publish();
            },
            child: KeyedSubtree(
              key: anchor,
              child: AppBarContent(
                elementId: 'viewer.app-bar.${s.identityKey}',
                configuration: widget.configuration,
              ),
            ),
          ),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${s.rawName} · ${s.id}'),
        TextButton(
          key: ValueKey('inspect-app-bar-${s.id}'),
          onPressed: publish,
          child: Text(l.inspector),
        ),
        ViewerSelectionFrame(
          selected: widget.selected,
          child: Listener(
            onPointerDown: (_) => publish(),
            child: SizedBox(
              width: widget.width,
              child: Theme(
                data: AppThemeFactory.build(
                  skin: SkinTheme.of(context),
                  brightness: s.brightness,
                ),
                child: Builder(
                  builder: (context) =>
                      ColoredBox(color: s.previewBackground!, child: content),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
