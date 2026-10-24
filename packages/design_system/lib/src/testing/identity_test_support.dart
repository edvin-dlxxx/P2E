import 'package:flutter/widgets.dart';

import '../identity/element_identity.dart';

/// Shared test-only traversal. Includes Offstage and inactive mounted elements.
/// Not exported from the production library and retains no registration state.
List<ElementIdentity> mountedIdentities(Element root) {
  final result = <ElementIdentity>[];
  void visit(Element element) {
    if (element.widget case final ElementIdentity identity) {
      result.add(identity);
    }
    element.visitChildren(visit);
  }

  visit(root);
  return result;
}

Map<String, int> identityCollisions(Iterable<ElementIdentity> identities) {
  final counts = <String, int>{};
  for (final identity in identities) {
    counts.update(
      identity.effectiveKey,
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  return {
    for (final entry in counts.entries)
      if (entry.value > 1) entry.key: entry.value,
  };
}

void expectUniqueIdentities(Element root) {
  final duplicates = identityCollisions(mountedIdentities(root));
  if (duplicates.isNotEmpty) {
    throw StateError('UI identity collision: $duplicates');
  }
}
