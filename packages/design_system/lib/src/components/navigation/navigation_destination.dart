import 'package:flutter/foundation.dart';

import '../../icons/app_icon.dart';
import '../../tokens/navigation_spec.dart';

@immutable
class AppNavigationBadge {
  AppNavigationBadge({required this.label, required this.semanticLabel}) {
    if (label.trim().isEmpty || semanticLabel.trim().isEmpty) {
      throw ArgumentError('Badge needs nonblank display and semantic copy');
    }
  }
  final String label, semanticLabel;
}

@immutable
class AppNavigationDestination {
  AppNavigationDestination({
    required this.id,
    required this.label,
    required this.icon,
    this.badge,
    this.semanticLabel,
  }) {
    if (id.trim().isEmpty ||
        label.trim().isEmpty ||
        semanticLabel?.trim() == '') {
      throw ArgumentError(
        'Navigation destination needs a stable ID and nonblank labels',
      );
    }
    // Fail honestly for a missing real paired style, even in release builds.
    for (final style in AppIconStyle.values) {
      AppIconRegistry.definition(icon).artwork(style);
    }
  }
  final String id, label;
  final String? semanticLabel;
  final AppIconId icon;
  final AppNavigationBadge? badge;
  Map<String, Object?> toJson() => {
    'id': id,
    'label': label,
    'semanticLabel': semanticLabel ?? label,
    'icon': AppIconRegistry.definition(icon).key,
    'badge': badge == null
        ? null
        : {'label': badge!.label, 'semanticLabel': badge!.semanticLabel},
  };
}

void validateNavigationDestinations(
  List<AppNavigationDestination> destinations,
  String selectedId,
) {
  final count = NavigationSourceSpec.engineering['destinationCount'] as int;
  if (destinations.length != count) {
    throw ArgumentError(
      'Source Navigator Bar requires exactly $count destinations',
    );
  }
  final ids = destinations.map((d) => d.id).toSet();
  if (ids.length != destinations.length) {
    throw ArgumentError('Duplicate navigation destination IDs');
  }
  if (!ids.contains(selectedId)) {
    throw ArgumentError.value(
      selectedId,
      'selectedDestinationId',
      'No matching destination',
    );
  }
}
