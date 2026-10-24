import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

import 'generated/button_reference_labels.g.dart';

class ButtonCatalog {
  ButtonCatalog() : variants = List.unmodifiable(ButtonSpec.all);
  final List<ButtonSpec> variants;
  List<ButtonSpec> filter({
    String theme = 'all',
    String family = 'all',
    String size = 'all',
    String appearance = 'all',
    String query = '',
  }) => variants
      .where(
        (s) =>
            (theme == 'all' || s.brightness.name == theme) &&
            (family == 'all' || s.family.name == family) &&
            (size == 'all' || s.size.name == size) &&
            (appearance == 'all' || s.type.name == appearance) &&
            (query.isEmpty ||
                '${s.id} ${s.setId} ${s.rawName} ${s.setName}'
                    .toLowerCase()
                    .contains(query.toLowerCase())),
      )
      .toList();
  static String referenceLabel(ButtonSpec spec) =>
      buttonReferenceLabels[spec.id] ?? '';
  static String get fileKey => buttonCatalogFileKey;
  static const families = [
    AppButtonFamily.fill,
    AppButtonFamily.hug,
    AppButtonFamily.icon,
  ];
  static const themes = [Brightness.dark, Brightness.light];
  static List<ButtonSpec> set(
    List<ButtonSpec> rows,
    AppButtonFamily family,
    AppButtonSize size,
    Brightness theme,
  ) =>
      rows
          .where(
            (s) =>
                s.family == family && s.size == size && s.brightness == theme,
          )
          .toList()
        ..sort((a, b) => a.type.index.compareTo(b.type.index));
}
