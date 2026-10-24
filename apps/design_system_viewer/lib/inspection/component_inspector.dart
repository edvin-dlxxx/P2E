import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/generated/viewer_localizations.dart';
import '../viewer_style.dart';
import 'inspection_record.dart';

class ComponentInspector extends StatelessWidget {
  const ComponentInspector({super.key, required this.record});
  final InspectionRecord? record;
  @override
  Widget build(BuildContext context) {
    final l = ViewerLocalizations.of(context);
    return Material(
      color: ViewerStyle.panel,
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(ViewerStyle.spaceL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.inspector,
                    style: TextStyle(
                      color: ViewerStyle.ink,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                TextButton(
                  key: const ValueKey('copy-inspector'),
                  onPressed: record == null
                      ? null
                      : () => copy(context, report(record!, l), l),
                  child: Text(
                    l.inspectorCopyAll,
                    style: TextStyle(
                      color: record == null
                          ? ViewerStyle.inkDisabled
                          : ViewerStyle.ink,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: ViewerStyle.spaceM),
            if (record == null)
              Text(
                l.selectSample,
                style: TextStyle(color: ViewerStyle.inkDisabled),
              )
            else ...[
              Directionality(
                textDirection: TextDirection.ltr,
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: ViewerStyle.spaceM,
                    vertical: ViewerStyle.spaceS,
                  ),
                  decoration: BoxDecoration(
                    color: ViewerStyle.panelRaised,
                    borderRadius: BorderRadiusDirectional.circular(
                      ViewerStyle.radiusField,
                    ),
                  ),
                  child: SelectableText(
                    record!.sampleId,
                    key: const ValueKey('inspector-sample-id'),
                    style: TextStyle(
                      color: ViewerStyle.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              for (final group in record!.groups.entries) ...[
                const SizedBox(height: ViewerStyle.spaceL),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        switch (group.key) {
                          InspectionGroup.identity => l.identityGroup,
                          InspectionGroup.configuration => l.configurationGroup,
                          InspectionGroup.visuals => l.visualsGroup,
                          InspectionGroup.geometry => l.geometryGroup,
                          InspectionGroup.interaction => l.interactionGroup,
                        },
                        style: TextStyle(
                          color: ViewerStyle.scrim(.64),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(height: 1, color: ViewerStyle.hairline),
                  ],
                ),
                const SizedBox(height: ViewerStyle.spaceS),
                for (final field in group.value)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      top: ViewerStyle.spaceS + 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l.fieldLabel(field.id.name),
                                style: TextStyle(
                                  color: ViewerStyle.scrim(.64),
                                  fontSize: 11.5,
                                ),
                              ),
                            ),
                            TextButton(
                              key: ValueKey('copy-inspector-${field.id.name}'),
                              onPressed: () =>
                                  copy(context, format(field.value, l), l),
                              child: Text(
                                l.inspectorCopyValue,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ViewerStyle.scrim(.55),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: ViewerStyle.spaceM,
                            vertical: ViewerStyle.spaceS + 2,
                          ),
                          decoration: BoxDecoration(
                            color: ViewerStyle.panelRaised,
                            borderRadius: BorderRadiusDirectional.circular(
                              ViewerStyle.radiusField,
                            ),
                          ),
                          child: SelectableText(
                            format(field.value, l),
                            textDirection: technical(field)
                                ? TextDirection.ltr
                                : null,
                            key: ValueKey('inspector-${field.id.name}'),
                            style: TextStyle(
                              color: ViewerStyle.scrim(.96),
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static String groupLabel(InspectionGroup group, ViewerLocalizations l) =>
      switch (group) {
        InspectionGroup.identity => l.identityGroup,
        InspectionGroup.configuration => l.configurationGroup,
        InspectionGroup.visuals => l.visualsGroup,
        InspectionGroup.geometry => l.geometryGroup,
        InspectionGroup.interaction => l.interactionGroup,
      };

  static String report(InspectionRecord record, ViewerLocalizations l) => [
    l.inspector,
    record.sampleId,
    for (final group in record.groups.entries) ...[
      '\n${groupLabel(group.key, l)}',
      for (final field in group.value)
        '${l.fieldLabel(field.id.name)}:\n${format(field.value, l)}',
    ],
  ].join('\n');

  static Future<void> copy(
    BuildContext context,
    String text,
    ViewerLocalizations l,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.inspectorCopied)));
    }
  }

  bool technical(InspectionField field) {
    final value = field.value;
    if (value == null || value is bool) return false;
    if (value is! String) return true;
    return const {
          InspectionFieldId.setName,
          InspectionFieldId.setId,
          InspectionFieldId.variantName,
          InspectionFieldId.variantId,
          InspectionFieldId.fileKey,
          InspectionFieldId.fontFamily,
          InspectionFieldId.logicalKey,
          InspectionFieldId.rawName,
          InspectionFieldId.viewBox,
          InspectionFieldId.assetPath,
          InspectionFieldId.assetHash,
        }.contains(field.id) ||
        (field.id == InspectionFieldId.artwork && value.startsWith('icon.'));
  }

  static String format(Object? value, ViewerLocalizations l) {
    if (value == null) return l.unavailable;
    if (value is bool) return value ? l.yes : l.no;
    if (value is Color) {
      return '#${value.toARGB32().toRadixString(16).padLeft(8, '0')} · RGBA(${value.r.toStringAsFixed(4)}, ${value.g.toStringAsFixed(4)}, ${value.b.toStringAsFixed(4)}, ${value.a.toStringAsFixed(4)})';
    }
    if (value is Size) {
      return '${value.width.toStringAsFixed(2)} × ${value.height.toStringAsFixed(2)}';
    }
    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }
    return value.toString();
  }
}
