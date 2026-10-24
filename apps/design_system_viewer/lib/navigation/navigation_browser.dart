import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import '../inspection/inspection_record.dart';
import '../inspection/viewer_selection_frame.dart';
import '../l10n/generated/viewer_localizations.dart';
import '../verification/measurement.dart';
import '../viewer_style.dart';

String navigationLabel(ViewerLocalizations l, String id) => switch (id) {
  'home' => l.navHome,
  'mission' => l.navMission,
  'games' => l.navGames,
  'leaderboard' => l.navLeaderboard,
  _ => l.navShop,
};

class NavigationBrowser extends StatefulWidget {
  const NavigationBrowser({
    super.key,
    required this.selected,
    required this.onInspect,
  });
  final String? selected;
  final ValueChanged<InspectionRecord?> onInspect;
  @override
  State<NavigationBrowser> createState() => _NavigationBrowserState();
}

class _NavigationBrowserState extends State<NavigationBrowser> {
  String theme = 'all', selectedId = 'home', direction = 'auto', lastId = '';
  double width = 402, scale = 1, inset = 0;
  bool unavailable = false, longValues = false;
  int activations = 0;
  final labels = <String, TextEditingController>{},
      badges = <String, TextEditingController>{},
      badgeVisible = <String, bool>{};
  ViewerLocalizations get l => ViewerLocalizations.of(context);
  @override
  void initState() {
    super.initState();
    for (final d in NavigationBarSpec.all.first.referenceDestinations) {
      labels[d.id] = TextEditingController();
      badges[d.id] = TextEditingController(text: d.badge ?? '1');
      badgeVisible[d.id] = d.badge != null;
    }
  }

  @override
  void dispose() {
    for (final c in [...labels.values, ...badges.values]) {
      c.dispose();
    }
    super.dispose();
  }

  List<NavigationBarSpec> get bars => NavigationBarSpec.all
      .where((s) => theme == 'all' || s.brightness.name == theme)
      .toList();
  List<NavigationItemSpec> get items => NavigationItemSpec.all
      .where((s) => theme == 'all' || s.brightness.name == theme)
      .toList();
  void change(VoidCallback fn) {
    setState(fn);
    if (widget.selected != null && !visibleIds.contains(widget.selected)) {
      widget.onInspect(null);
    }
  }

  Set<String> get visibleIds => {
    'navigation.live',
    for (final s in bars) 'navigation.source.${s.brightness.name}',
    for (final s in items)
      'navigation.item.${s.brightness.name}.${s.state.name}',
  };
  Widget choice(
    String id,
    String label,
    String value,
    Map<String, String> options,
    ValueChanged<String> update,
  ) => SizedBox(
    width: 190,
    child: DropdownButtonFormField<String>(
      key: ValueKey('nav-$id-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      icon: ExcludeSemantics(child: Text(l.dropdownMark)),
      items: [
        for (final e in options.entries)
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
  void emit(String id, {bool live = false}) => change(() {
    lastId = id;
    activations++;
    if (live) selectedId = id;
  });
  List<AppNavigationDestination> reference(NavigationBarSpec s) => [
    for (final d in s.referenceDestinations)
      AppNavigationDestination(
        id: d.id,
        label: d.label,
        icon: d.icon,
        badge: d.badge == null
            ? null
            : AppNavigationBadge(
                label: d.badge!,
                semanticLabel: lookupViewerLocalizations(const Locale('en'))
                    .navBadgeMeaning(d.label, d.badge!),
              ),
      ),
  ];
  List<AppNavigationDestination> runtime(NavigationBarSpec s) => [
    for (final d in s.referenceDestinations)
      AppNavigationDestination(
        id: d.id,
        label: longValues
            ? l.navLongLabel
            : (labels[d.id]!.text.trim().isEmpty
                  ? navigationLabel(l, d.id)
                  : labels[d.id]!.text),
        icon: d.icon,
        badge:
            badgeVisible[d.id] != true ||
                (!longValues && badges[d.id]!.text.trim().isEmpty)
            ? null
            : AppNavigationBadge(
                label: longValues ? '12345678901234567890' : badges[d.id]!.text,
                semanticLabel: l.navBadgeMeaning(
                  navigationLabel(l, d.id),
                  longValues ? '12345678901234567890' : badges[d.id]!.text,
                ),
              ),
      ),
  ];
  Widget barSample(NavigationBarSpec s, {bool live = false}) {
    final id = live
            ? 'navigation.live'
            : 'navigation.source.${s.brightness.name}',
        d = live ? runtime(s) : reference(s);
    final chosen = live ? selectedId : s.referenceSelectedId;
    final dir = live
        ? (direction == 'auto'
              ? Directionality.of(context)
              : direction == 'rtl'
              ? TextDirection.rtl
              : TextDirection.ltr)
        : TextDirection.ltr;
    return NavigationSample(
      key: ValueKey(id),
      sampleId: id,
      spec: s,
      selected: widget.selected == id,
      onInspect: widget.onInspect,
      width: live ? width : s.sourceSize.width,
      scale: live ? scale : 1,
      locale: live ? Localizations.localeOf(context) : const Locale('en'),
      direction: dir,
      inset: live ? inset : 0,
      configuration: {
        'selectedDestinationId': chosen,
        'destinations': d.map((d) => d.toJson()).toList(),
        'available': !unavailable,
        'hostAdapter': true,
      },
      child: AppNavigationBarHost(
        bar: AppNavigationBar(
          elementId: id,

          destinations: d,
          selectedDestinationId: chosen,
          onDestinationSelected: unavailable
              ? null
              : (value) => emit(value, live: live),
        ),
      ),
    );
  }

  Widget itemSample(NavigationItemSpec s) {
    final id = 'navigation.item.${s.brightness.name}.${s.state.name}',
        label = s.part('label')['characters'] as String,
        badge = s.part('badgeLabel')['characters'] as String;
    final destination = AppNavigationDestination(
      id: 'home',
      label: label,
      icon: AppIconId.home,
      badge: AppNavigationBadge(
        label: badge,
        semanticLabel: lookupViewerLocalizations(const Locale('en'))
            .navBadgeMeaning(label, badge),
      ),
    );
    return NavigationSample(
      key: ValueKey(id),
      sampleId: id,
      spec: s,
      selected: widget.selected == id,
      onInspect: widget.onInspect,
      width: s.sourceSize.width,
      scale: 1,
      locale: const Locale('en'),
      direction: TextDirection.ltr,
      inset: 0,
      configuration: {
        'state': s.state.name,
        'destination': destination.toJson(),
        'hostAdapter': false,
      },
      child: AppNavigationItem(
        elementId: id,

        destination: destination,
        state: s.state,
        onPressed: () => emit('home'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: const ValueKey('navigation-browser-scroll'),
    padding: const EdgeInsetsDirectional.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.navTitle, style: Theme.of(context).textTheme.titleLarge),
        Text(l.navNotice),
        Text(l.navTypography),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            choice('theme', l.theme, theme, {
              'all': l.all,
              'dark': l.dark,
              'light': l.light,
            }, (v) => theme = v),
          ],
        ),
        Text(
          l.navCount(bars.length, items.length),
          key: const ValueKey('navigation-source-count'),
        ),
        Text(l.navSources, style: Theme.of(context).textTheme.titleMedium),
        for (final s in bars)
          Padding(
            padding: const EdgeInsetsDirectional.only(bottom: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: barSample(s),
            ),
          ),
        Text(l.navItems, style: Theme.of(context).textTheme.titleMedium),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [for (final s in items) itemSample(s)],
        ),
        const SizedBox(height: 24),
        Text(l.navLive, style: Theme.of(context).textTheme.titleLarge),
        ViewerPanel(
          color: ViewerStyle.panelRaised,
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  choice('selected', l.navSelected, selectedId, {
                    for (final d
                        in NavigationBarSpec.all.first.referenceDestinations)
                      d.id: navigationLabel(l, d.id),
                  }, (v) => selectedId = v),
                  choice('width', l.navWidth, width.toString(), {
                    for (final w in [252, 280, 320, 360, 402, 600, 900])
                      w.toDouble().toString(): w.toString(),
                  }, (v) => width = double.parse(v)),
                  choice('scale', l.textScale, scale.toString(), {
                    '1.0': '1.0',
                    '1.3': '1.3',
                  }, (v) => scale = double.parse(v)),
                  choice('direction', l.previewDirection, direction, {
                    'auto': l.followLanguage,
                    'ltr': l.ltr,
                    'rtl': l.rtl,
                  }, (v) => direction = v),
                  choice('inset', l.navInset, inset.toString(), {
                    for (final i in [0, 12, 24, 34])
                      i.toDouble().toString(): i.toString(),
                  }, (v) => inset = double.parse(v)),
                  FilterChip(
                    key: const ValueKey('nav-unavailable'),
                    label: Text(l.navUnavailable),
                    selected: unavailable,
                    showCheckmark: false,
                    onSelected: (v) => change(() => unavailable = v),
                  ),
                  FilterChip(
                    key: const ValueKey('nav-long'),
                    label: Text(l.navLong),
                    selected: longValues,
                    showCheckmark: false,
                    onSelected: (v) => change(() => longValues = v),
                  ),
                ],
              ),
              for (final d in NavigationBarSpec.all.first.referenceDestinations)
                Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 190,
                      child: TextField(
                        key: ValueKey('nav-label-${d.id}'),
                        controller: labels[d.id],
                        decoration: InputDecoration(
                          labelText: navigationLabel(l, d.id),
                          hintText: navigationLabel(l, d.id),
                        ),
                        onChanged: (_) => change(() {}),
                      ),
                    ),
                    FilterChip(
                      key: ValueKey('nav-badge-visible-${d.id}'),
                      label: Text(l.navBadge),
                      selected: badgeVisible[d.id]!,
                      showCheckmark: false,
                      onSelected: (v) => change(() => badgeVisible[d.id] = v),
                    ),
                    if (badgeVisible[d.id]!)
                      SizedBox(
                        width: 140,
                        child: TextField(
                          key: ValueKey('nav-badge-${d.id}'),
                          controller: badges[d.id],
                          decoration: InputDecoration(
                            labelText: l.navBadgeText,
                            errorText:
                                !longValues && badges[d.id]!.text.trim().isEmpty
                                ? l.navBadgeEmpty
                                : null,
                          ),
                          onChanged: (_) => change(() {}),
                        ),
                      ),
                  ],
                ),
              Text(l.navPolicy),
              Text(
                l.navFeedback(
                  lastId.isEmpty ? l.navNoAction : lastId,
                  activations,
                ),
                key: const ValueKey('nav-feedback'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: barSample(
            NavigationBarSpec.lookup(
              theme == 'light' ? Brightness.light : Brightness.dark,
            ),
            live: true,
          ),
        ),
      ],
    ),
  );
}

class NavigationSample extends StatefulWidget {
  const NavigationSample({
    super.key,
    required this.sampleId,
    required this.spec,
    required this.selected,
    required this.onInspect,
    required this.width,
    required this.scale,
    required this.locale,
    required this.direction,
    required this.inset,
    required this.configuration,
    required this.child,
  });
  final String sampleId;
  final NavigationSourceSpec spec;
  final bool selected;
  final ValueChanged<InspectionRecord?> onInspect;
  final double width, scale, inset;
  final Locale locale;
  final TextDirection direction;
  final Map<String, Object?> configuration;
  final Widget child;
  @override
  State<NavigationSample> createState() => _NavigationSampleState();
}

class _NavigationSampleState extends State<NavigationSample> {
  final anchor = GlobalKey();
  Size? hostSize;
  @override
  void didUpdateWidget(NavigationSample old) {
    super.didUpdateWidget(old);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.selected) publish();
    });
  }

  void publish() {
    final identities = <String, Object?>{},
        bounds = <String, Object?>{},
        artwork = <String, Object?>{};
    final root = anchor.currentContext?.findRenderObject();
    void visit(Element e) {
      if (e.widget case final ElementIdentity identity) {
        identities[identity.elementId] = identity.descriptor();
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
        artwork[icon.key.toString()] = {
          'key': icon.logicalKey,
          'style': icon.style.name,
          'sourceId': icon.sourceNodeId,
          'asset': icon.artwork.assetPath,
          'tint': icon.color?.toARGB32(),
          'size': box is RenderBox ? box.size.toString() : null,
        };
      }
      e.visitChildren(visit);
    }

    anchor.currentContext?.visitChildElements(visit);
    final w = widget, s = w.spec;
    InspectionField f(InspectionFieldId id, Object? value) =>
        InspectionField(id, value);
    w.onInspect(
      InspectionRecord(
        sampleId: w.sampleId,
        groups: {
          InspectionGroup.identity: [
            f(InspectionFieldId.fileKey, s.fileKey),
            f(InspectionFieldId.setId, s.setId),
            f(InspectionFieldId.setName, s.setName),
            f(InspectionFieldId.variantId, s.id),
            f(InspectionFieldId.variantName, s.rawName),
            f(InspectionFieldId.sourceCovered, {
              'bars': NavigationBarSpec.all.length,
              'nestedItems': NavigationItemSpec.all.length,
            }),
            f(InspectionFieldId.runtimeIdentity, identities),
          ],
          InspectionGroup.configuration: [
            f(InspectionFieldId.theme, s.brightness.name),
            f(InspectionFieldId.direction, w.direction.name),
            f(InspectionFieldId.scale, w.scale),
            f(InspectionFieldId.label, w.configuration),
          ],
          InspectionGroup.visuals: [
            f(InspectionFieldId.resolvedStyles, s.resolved()),
            f(InspectionFieldId.artwork, artwork),
          ],
          InspectionGroup.geometry: [
            f(InspectionFieldId.sourceDimensions, s.sourceSize),
            f(InspectionFieldId.outer, hostSize),
            f(InspectionFieldId.content, bounds),
            f(InspectionFieldId.constraints, {
              'width': w.width,
              'bottomInset': w.inset,
              'totalHostHeight': hostSize?.height,
              'policy': NavigationSourceSpec.engineering['safeArea'],
            }),
          ],
          InspectionGroup.interaction: [
            f(InspectionFieldId.motion, s.resolved()['motion']),
            f(InspectionFieldId.issue, s.resolved()['unresolved']),
          ],
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final content = MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: EdgeInsets.only(bottom: w.inset),
        viewPadding: EdgeInsets.only(bottom: w.inset),
        textScaler: TextScaler.linear(w.scale),
      ),
      child: MeasureBox(
        onSize: (size) {
          hostSize = size;
          if (w.selected) publish();
        },
        child: KeyedSubtree(key: anchor, child: w.child),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${w.spec.rawName} · ${w.spec.id}'),
        TextButton(
          key: ValueKey('inspect-${w.sampleId}'),
          onPressed: publish,
          child: Text(ViewerLocalizations.of(context).inspector),
        ),
        ViewerSelectionFrame(
          selected: w.selected,
          child: Listener(
            onPointerDown: (_) => publish(),
            child: SizedBox(
              width: w.width,
              child: Theme(
                data: AppThemeFactory.build(
                  skin: SkinTheme.of(context),
                  brightness: w.spec.brightness,
                ),
                child: ColoredBox(
                  color: NavigationBarSpec.lookup(w.spec.brightness)
                      .color('body')!,
                  child: Localizations.override(
                    context: context,
                    locale: w.locale,
                    child: Directionality(
                      textDirection: w.direction,
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
