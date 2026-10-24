import 'dart:convert';

import 'package:flutter/widgets.dart';

abstract final class UiIdentitySyntax {
  static void check(String field, String value, String pattern, int limit) {
    if (value.trim() != value ||
        value.length > limit ||
        !RegExp(pattern).hasMatch(value)) {
      throw ArgumentError.value(
        value,
        field,
        'Invalid v1.1 UI identity syntax',
      );
    }
  }

  static void element(String value) => check(
    'elementId',
    value,
    r'^[a-z][a-z0-9-]*(?:\.(?:[a-z][a-z0-9-]*|[a-z][a-z0-9-]*:[a-z0-9_-]+)){1,}$',
    200,
  );
  static void definition(String field, String value) =>
      check(field, value, r'^[a-z][a-z0-9-]*(?:\.[a-z][a-z0-9-]*)+$', 128);
}

@immutable
class UiRuntimeLocator {
  const UiRuntimeLocator({
    required this.routeName,
    required this.routeInstanceId,
    this.entityKey,
    this.slotPath,
  });
  final String routeName, routeInstanceId;
  final String? entityKey, slotPath;
  void validate() {
    UiIdentitySyntax.check(
      'routeName',
      routeName,
      r'^[a-z][a-z0-9-]*(?:\.[a-z][a-z0-9-]*)*$',
      128,
    );
    if (routeInstanceId.trim().isEmpty || routeInstanceId.length > 128) {
      throw ArgumentError.value(
        routeInstanceId,
        'routeInstanceId',
        'Expected a nonblank instance ID',
      );
    }
    if (entityKey != null) {
      UiIdentitySyntax.check('entityKey', entityKey!, r'^[a-z0-9_-]+$', 128);
    }
    if (slotPath != null) {
      UiIdentitySyntax.check(
        'slotPath',
        slotPath!,
        r'^[a-z][A-Za-z0-9]*(?:\.[a-z][A-Za-z0-9]*)*$',
        128,
      );
    }
  }

  UiRuntimeLocator slot(String role) => UiRuntimeLocator(
    routeName: routeName,
    routeInstanceId: routeInstanceId,
    entityKey: entityKey,
    slotPath: slotPath == null ? role : '$slotPath.$role',
  );
  Map<String, Object> toJson() => {
    'routeName': routeName,
    'routeInstanceId': routeInstanceId,
    'entityKey': ?entityKey,
    'slotPath': ?slotPath,
  };
}

/// D-033: allocation happens once per route state, never during build.
class UiIdentityScope extends StatefulWidget {
  const UiIdentityScope({
    super.key,
    required this.routeName,
    this.instanceKey,
    required this.child,
  });
  final String routeName;
  final String? instanceKey;
  final Widget child;
  static UiRuntimeLocator? resolve(
    BuildContext context, {
    UiRuntimeLocator? override,
  }) {
    final locator =
        override ??
        context.dependOnInheritedWidgetOfExactType<_RouteIdentity>()?.locator;
    assert(
      locator != null,
      'Missing UiIdentityScope: mount a route scope or supply runtimeLocator.',
    );
    locator?.validate();
    return locator;
  }

  @override
  State<UiIdentityScope> createState() => _UiIdentityScopeState();
}

class _UiIdentityScopeState extends State<UiIdentityScope> {
  static int nextInstance = 0;
  late final String instance;
  @override
  void initState() {
    super.initState();
    instance = widget.instanceKey ?? 'screen-${++nextInstance}';
  }

  @override
  Widget build(BuildContext context) {
    final locator = UiRuntimeLocator(
      routeName: widget.routeName,
      routeInstanceId: instance,
    );
    locator.validate();
    return _RouteIdentity(locator: locator, child: widget.child);
  }
}

class _RouteIdentity extends InheritedWidget {
  const _RouteIdentity({required this.locator, required super.child});
  final UiRuntimeLocator locator;
  @override
  bool updateShouldNotify(_RouteIdentity old) =>
      !identityValueEquals(locator.toJson(), old.locator.toJson());
}

bool identityValueEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    return a.length == b.length &&
        a.keys.every(
          (k) => b.containsKey(k) && identityValueEquals(a[k], b[k]),
        );
  }
  if (a is List && b is List) {
    return a.length == b.length &&
        List.generate(
          a.length,
          (i) => i,
        ).every((i) => identityValueEquals(a[i], b[i]));
  }
  return a == b;
}

Object? _freeze(Object? value) {
  if (value is Map) {
    return Map<String, Object?>.unmodifiable(
      value.map((k, v) => MapEntry(k.toString(), _freeze(v))),
    );
  }
  if (value is List) return List<Object?>.unmodifiable(value.map(_freeze));
  return value;
}

/// Safe production metadata. No lookup, registration, overlay or captured input.
class ElementIdentity extends InheritedWidget {
  ElementIdentity({
    super.key,
    required this.elementId,
    required this.runtimeLocator,
    required this.componentId,
    required this.structureRef,
    required this.fileKey,
    required this.variantId,
    required this.componentSetId,
    required this.rawSetName,
    required this.rawVariantName,
    required Map<String, String> variants,
    required Map<String, Object?> resolved,
    required Map<String, Object?> declared,
    required super.child,
  }) : assert(
         runtimeLocator != null,
         'Missing UiIdentityScope: identity metadata needs a route locator.',
       ),
       variants = Map.unmodifiable(variants),
       resolved = _freeze(resolved)! as Map<String, Object?>,
       declared = _freeze(declared)! as Map<String, Object?> {
    UiIdentitySyntax.element(elementId);
    UiIdentitySyntax.definition('componentId', componentId);
    UiIdentitySyntax.definition('structureRef', structureRef);
    runtimeLocator?.validate();
    if (variantId != null) {
      UiIdentitySyntax.check('fileKey', fileKey, r'^[A-Za-z0-9]{15,40}$', 40);
      UiIdentitySyntax.check('nodeId', variantId!, r'^\d+:\d+$', 128);
    }
  }
  final String elementId,
      componentId,
      structureRef,
      fileKey,
      rawSetName,
      rawVariantName;
  final UiRuntimeLocator? runtimeLocator;
  final String? variantId, componentSetId;
  final Map<String, String> variants;
  final Map<String, Object?> resolved, declared;
  String get status => 'provisional';
  String get _sourceOrigin =>
      variantId == null ? 'runtime-resolver' : 'figma-reference';
  String get effectiveKey => jsonEncode([
    runtimeLocator?.routeName,
    runtimeLocator?.routeInstanceId,
    elementId,
    runtimeLocator?.entityKey,
    runtimeLocator?.slotPath,
  ]);
  static Map<String, Object?> _properties(
    Map<String, Object?> data,
    String defaultOrigin,
  ) => {
    for (final entry in data.entries)
      entry.key:
          entry.value is Map && (entry.value as Map).containsKey('origin')
          ? _property(entry.value as Map)
          : {'value': entry.value, 'origin': defaultOrigin},
  };
  static Map<String, Object?> _property(Map value) {
    const origins = {
      'usage',
      'component-default',
      'component-state',
      'typography-registry',
      'color-registry',
      'icon-registry',
      'motion-registry',
      'figma-reference',
      'runtime-resolver',
      'unknown',
    };
    final origin = value['origin'];
    return {
      for (final entry in value.entries) entry.key as String: entry.value,
      if (!origins.contains(origin)) 'origin': 'runtime-resolver',
      if (!origins.contains(origin)) 'note': origin.toString(),
    };
  }

  Map<String, Object?> descriptor() {
    if (runtimeLocator == null) {
      throw StateError(
        'Descriptor unavailable without UiIdentityScope; release rendering remains unaffected.',
      );
    }
    return {
      'schemaVersion': '1.1.0',
      'identity': {
        'elementId': elementId,
        'componentId': componentId,
        'structureRef': structureRef,
        'componentSpecVersion': '1.0.0',
        if (variantId != null)
          'designRef': {'fileKey': fileKey, 'nodeId': variantId},
        'runtimeLocator': runtimeLocator!.toJson(),
      },
      'state': {
        'loading': declared['loading'] == true,
        'enabled':
            variants['enabled'] != 'false' && variants['type'] != 'disabled',
      },
      'declared': _properties(declared, 'usage'),
      'resolved': {
        ..._properties(resolved, 'runtime-resolver'),
        'figmaComponentSetId': {
          'value': componentSetId,
          'origin': _sourceOrigin,
        },
        'figmaRawSetName': {'value': rawSetName, 'origin': _sourceOrigin},
        'figmaRawVariantName': {
          'value': rawVariantName,
          'origin': _sourceOrigin,
        },
        'status': {
          'value': status,
          'origin': 'component-default',
          'decisionStatus': 'provisional',
        },
      },
      'warnings': [
        {
          'code': 'DEVELOPMENT_SOURCE',
          'severity': 'warning',
          'message': 'DEVELOPMENT source; design approval and geometry conflicts remain provisional.',
        },
      ],
    };
  }

  @override
  bool updateShouldNotify(ElementIdentity old) =>
      elementId != old.elementId ||
      componentId != old.componentId ||
      structureRef != old.structureRef ||
      fileKey != old.fileKey ||
      variantId != old.variantId ||
      componentSetId != old.componentSetId ||
      rawSetName != old.rawSetName ||
      rawVariantName != old.rawVariantName ||
      !identityValueEquals(
        runtimeLocator?.toJson(),
        old.runtimeLocator?.toJson(),
      ) ||
      !identityValueEquals(variants, old.variants) ||
      !identityValueEquals(declared, old.declared) ||
      !identityValueEquals(resolved, old.resolved);
}
