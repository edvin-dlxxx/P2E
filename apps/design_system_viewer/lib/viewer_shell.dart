import 'package:p2e_design_system/testing.dart';
import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import 'badges/badge_browser.dart';
import 'components/components_browser.dart';
import 'board/button_board.dart';
import 'board/button_sample.dart';
import 'board/preview_settings.dart';
import 'catalog/button_catalog.dart';
import 'fields/field_browser.dart';
import 'icons/icon_browser.dart';
import 'inspection/component_inspector.dart';
import 'inspection/inspection_record.dart';
import 'l10n/generated/viewer_localizations.dart';
import 'verification/generated/text_only_examples.g.dart';
import 'viewer_style.dart';

class ViewerShell extends StatefulWidget {
  const ViewerShell({
    super.key,
    required this.locale,
    required this.onLocale,
    this.skin = productSkin,
    this.onSkin,
  });
  final SkinDefinition skin;
  final ValueChanged<SkinDefinition>? onSkin;
  final Locale locale;
  final ValueChanged<Locale> onLocale;
  @override
  State<ViewerShell> createState() => _ViewerShellState();
}

class _ViewerShellState extends State<ViewerShell> {
  final catalog = ButtonCatalog();
  final search = TextEditingController();
  final records = <String, InspectionRecord>{};
  // Inspector updates must not invalidate the animated catalog subtree.
  final currentInspection = ValueNotifier<InspectionRecord?>(null);
  int tab = 0, revision = 0;
  String theme = 'all', family = 'all', size = 'all', direction = 'auto';
  String appearance = 'all';
  ButtonIconMode iconMode = ButtonIconMode.fill;
  double scale = 1, fillWidth = 330;
  bool loading = false;
  bool reference = true,
      longLabel = false,
      measurements = false,
      references = false;
  String? selected;
  @override
  void dispose() {
    search.dispose();
    currentInspection.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ViewerShell old) {
    super.didUpdateWidget(old);
    if (old.locale != widget.locale) {
      revision++;
      records.clear();
      currentInspection.value = null;
    }
  }

  TextDirection get uiDirection => widget.locale.languageCode == 'fa'
      ? TextDirection.rtl
      : TextDirection.ltr;
  List<ButtonSpec> get rows => catalog.filter(
    theme: theme,
    family: family,
    size: size,
    appearance: appearance,
    query: search.text,
  );
  PreviewSettings get settings => PreviewSettings(
    loading: loading,
    iconMode: iconMode,
    scale: scale,
    direction: direction == 'auto'
        ? uiDirection
        : direction == 'rtl'
        ? TextDirection.rtl
        : TextDirection.ltr,
    reference: reference,
    longLabel: longLabel,
    fillWidth: fillWidth,
    measurements: measurements,
    revision: revision,
  );
  void change(VoidCallback fn, {bool filter = false}) => setState(() {
    fn();
    revision++;
    records.clear();
    currentInspection.value = null;
    if (filter &&
        selected != null &&
        !rows.any((s) => s.id == selected) &&
        !(references && textOnlyExamples.any((e) => e['id'] == selected))) {
      selected = null;
    }
  });
  void observe(InspectionRecord record) {
    records[record.sampleId] = record;
    if (selected == record.sampleId && mounted) {
      currentInspection.value = record;
    }
  }

  void selectSample(String? id) {
    if (selected != id) setState(() => selected = id);
    currentInspection.value = id == null ? null : records[id];
  }

  void inspectRecord(InspectionRecord? record) {
    if (record != null) records[record.sampleId] = record;
    selectSample(record?.sampleId);
  }

  Widget inspector() => Directionality(
    textDirection: uiDirection,
    child: ValueListenableBuilder<InspectionRecord?>(
      valueListenable: currentInspection,
      builder: (context, record, child) => ComponentInspector(record: record),
    ),
  );
  Widget dropdown(
    String key,
    String label,
    String value,
    Map<String, String> choices,
    ValueChanged<String> onChanged,
  ) => SizedBox(
    width: ViewerStyle.fieldWidth,
    child: DropdownButtonFormField<String>(
      isExpanded: true,
      key: ValueKey('control-$key-$value'),
      initialValue: value,
      decoration: InputDecoration(labelText: label),
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
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    ),
  );

  /// Horizontal band that groups the transport controls of a browser.
  Widget toolbar() => ViewerPanel(
    color: ViewerStyle.panelRaised,
    padding: const EdgeInsetsDirectional.all(ViewerStyle.spaceL),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ViewerLocalizations.of(context).filters,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: ViewerStyle.spaceM),
        Wrap(
          spacing: ViewerStyle.spaceM,
          runSpacing: ViewerStyle.spaceM,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            dropdown('theme', l.theme, theme, {
              'all': l.all,
              'dark': l.dark,
              'light': l.light,
            }, (v) => change(() => theme = v, filter: true)),
            dropdown(
              'skin',
              l.skin,
              widget.skin.id,
              {'product': l.productSkin, 'test': l.testSkin},
              (v) {
                change(() {});
                widget.onSkin?.call(v == 'test' ? testSkin : productSkin);
              },
            ),
            dropdown('family', l.family, family, {
              'all': l.all,
              'fill': l.fillFamily,
              'hug': l.hugFamily,
              'icon': l.iconFamily,
            }, (v) => change(() => family = v, filter: true)),
            dropdown('size', l.size, size, {
              'all': l.all,
              'small': l.small,
              'medium': l.medium,
              'large': l.large,
            }, (v) => change(() => size = v, filter: true)),
            dropdown('icon', l.iconMode, iconMode.name, {
              'none': l.none,
              'fill': l.fillIcon,
              'outline': l.outlineIcon,
            }, (v) => change(() => iconMode = ButtonIconMode.values.byName(v))),
            dropdown('appearance', l.fieldLabel('appearance'), appearance, {
              'all': l.all,
              for (final type in AppButtonType.values)
                type.name: appearanceName(l, type),
            }, (v) => change(() => appearance = v, filter: true)),
            dropdown('scale', l.textScale, scale.toString(), {
              '1.0': '1.0',
              '1.3': '1.3',
              '2.0': '2.0',
            }, (v) => change(() => scale = double.parse(v))),
            dropdown('direction', l.previewDirection, direction, {
              'auto': l.followLanguage,
              'ltr': l.ltr,
              'rtl': l.rtl,
            }, (v) => change(() => direction = v)),
            dropdown(
              'text',
              l.labelMode,
              reference ? 'reference' : 'localized',
              {'reference': l.referenceText, 'localized': l.localizedText},
              (v) => change(() => reference = v == 'reference'),
            ),
            TextButton(
              key: const ValueKey('reset-filters'),
              onPressed: () => change(() {
                theme = family = size = appearance = 'all';
                search.clear();
              }, filter: true),
              child: Text(l.reset),
            ),
          ],
        ),
        const SizedBox(height: ViewerStyle.spaceS),
        Wrap(
          spacing: ViewerStyle.spaceL,
          runSpacing: ViewerStyle.spaceS,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: ViewerStyle.searchWidth,
              child: TextField(
                key: const ValueKey('source-search'),
                controller: search,
                decoration: InputDecoration(labelText: l.search),
                onChanged: (_) => change(() {}, filter: true),
              ),
            ),
            if (!reference)
              TextButton(
                onPressed: () => change(() => longLabel = !longLabel),
                child: Text(longLabel ? l.longLabel : l.shortLabel),
              ),
            TextButton(
              key: const ValueKey('verification-toggle'),
              onPressed: () => change(() => measurements = !measurements),
              child: Text(measurements ? l.gallery : l.verification),
            ),
            FilterChip(
              key: const ValueKey('loading-toggle'),
              label: Text(l.buttonLoading),
              selected: loading,
              onSelected: (v) => change(() => loading = v),
            ),
            FilterChip(
              label: Text(l.showReferences),
              selected: references,
              onSelected: (v) => change(() {
                references = v;
                if (!v && textOnlyExamples.any((e) => e['id'] == selected)) {
                  selected = null;
                }
              }),
            ),
            if (!reference)
              SizedBox(
                width: 250,
                child: Column(
                  children: [
                    Text('${l.previewWidth}: ${fillWidth.toStringAsFixed(0)}'),
                    Slider(
                      value: fillWidth,
                      min: 200,
                      max: 480,
                      onChanged: (v) => change(() => fillWidth = v),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: ViewerStyle.spaceS),
        Text(
          l.sourceCount(displayed.length),
          key: const ValueKey('source-count'),
        ),
        Text(l.referenceModeHint, style: Theme.of(context).textTheme.bodySmall),
        if (measurements) Text(l.measureNotice),
      ],
    ),
  );

  Widget buttonsTab() => Directionality(
    textDirection: uiDirection,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.all(ViewerStyle.spaceL),
          child: toolbar(),
        ),
        if (displayed.isEmpty)
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(ViewerStyle.spaceXl),
              child: ViewerEmptyState(message: l.emptyState),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              key: const ValueKey('buttons-scroll'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ButtonBoard(
                    rows: displayed,
                    settings: settings,
                    selected: selected,
                    onSelect: selectSample,
                    onObserve: observe,
                  ),
                  if (references) ...[
                    Padding(
                      padding: const EdgeInsetsDirectional.all(
                        ViewerStyle.spaceL,
                      ),
                      child: Text(l.referenceExamples),
                    ),
                    Wrap(
                      spacing: ViewerStyle.spaceL,
                      runSpacing: ViewerStyle.spaceM,
                      children: [
                        for (final instance in textOnlyExamples)
                          ButtonSample(
                            key: ValueKey(
                              'reference-${instance['id']}-${settings.revision}-${widget.locale.languageCode}',
                            ),
                            spec: catalog.variants.singleWhere(
                              (s) => s.id == instance['masterId'],
                            ),
                            settings: settings,
                            selected: selected == instance['id'],
                            onSelect: () =>
                                selectSample(instance['id'] as String),
                            onObserve: observe,
                            referenceInstance: instance,
                          ),
                      ],
                    ),
                    const SizedBox(height: ViewerStyle.spaceXl),
                  ],
                ],
              ),
            ),
          ),
      ],
    ),
  );

  Widget body() => UiIdentityScope(
    key: ValueKey('identity-route-$tab'),
    routeName:
        'viewer.${["buttons", "badges", "text-fields", "password", "otp", "radio", "icons", "colors", "components"][tab]}',
    child: browserBody(),
  );
  Widget browserBody() => tab == 1
      ? BadgeBrowser(selected: selected, onInspect: inspectRecord)
      : tab >= 2 && tab <= 5
      ? FieldBrowser(
          key: ValueKey('field-tab-$tab'),
          family: switch (tab) {
            2 => FieldFamily.textField,
            3 => FieldFamily.password,
            4 => FieldFamily.otp,
            _ => FieldFamily.radio,
          },
          selected: selected,
          onInspect: inspectRecord,
        )
      : tab == 6
      ? IconBrowser(selected: selected, onInspect: inspectRecord)
      : tab == 8
      ? ComponentsBrowser(selected: selected, onInspect: inspectRecord)
      : tab != 0
      ? Center(key: ValueKey('future-section-$tab'), child: Text(l.notAddedYet))
      : buttonsTab();
  @override
  Widget build(BuildContext context) {
    final l = ViewerLocalizations.of(context);
    final tabs = [
      l.buttons,
      l.badges,
      l.textFields,
      l.fieldPassword,
      l.fieldOtp,
      l.fieldRadio,
      l.icons,
      l.colors,
      l.components,
    ];
    List<Widget> railItems() => [
      for (var i = 0; i < tabs.length; i++)
        Directionality(
          textDirection: uiDirection,
          child: ViewerNavItem(
            key: ValueKey('section-$i'),
            label: tabs[i],
            selected: tab == i,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                tab = i;
                selected = null;
                currentInspection.value = null;
              });
            },
          ),
        ),
    ];
    // PHYSICAL: the desktop inspector stays on the extreme physical left in
    // both languages, and the section rail is pinned to the extreme physical
    // right. Only the content column changes direction.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        drawer: desktop
            ? null
            : Drawer(
                child: SafeArea(
                  child: Column(
                    children: [
                      Directionality(
                        textDirection: uiDirection,
                        child: Builder(
                          builder: (context) => TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l.close),
                          ),
                        ),
                      ),
                      ...railItems(),
                      Expanded(child: inspector()),
                    ],
                  ),
                ),
              ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Directionality(
            textDirection: uiDirection,
            child: Text(l.title),
          ),
          leading: desktop
              ? null
              : Builder(
                  builder: (context) => TextButton(
                    key: const ValueKey('open-inspector'),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    child: Text(
                      l.inspector,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
          leadingWidth: 110,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: ViewerStyle.spaceL,
              ),
              child: DropdownButton<String>(
                key: const ValueKey('language-control'),
                value: widget.locale.languageCode,
                icon: ExcludeSemantics(child: Text(l.dropdownMark)),
                items: [
                  DropdownMenuItem(value: 'fa', child: Text(l.persian)),
                  DropdownMenuItem(value: 'en', child: Text(l.english)),
                ],
                onChanged: (v) {
                  if (v != null) widget.onLocale(Locale(v));
                },
              ),
            ),
          ],
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (desktop) ...[
              SizedBox(
                key: const ValueKey('physical-left-inspector'),
                width: 320,
                child: inspector(),
              ),
              const VerticalDivider(width: 1),
            ],
            Expanded(
              child: Directionality(textDirection: uiDirection, child: body()),
            ),
            if (desktop) const VerticalDivider(width: 1),
            if (desktop) ViewerSectionRail(items: railItems()),
          ],
        ),
      ),
    );
  }

  bool get desktop => MediaQuery.of(context).size.width >= 1100;
  List<ButtonSpec> get displayed => rows;
  ViewerLocalizations get l => ViewerLocalizations.of(context);
}
