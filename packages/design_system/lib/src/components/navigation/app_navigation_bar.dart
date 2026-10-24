import '../../theme/skin_theme.dart';

import 'dart:ui' show SemanticsRole;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';

import '../../identity/element_identity.dart';
import '../../tokens/navigation_spec.dart';
import '../../tokens/generated/readiness_tokens.g.dart';
import 'navigation_destination.dart';
import 'navigation_item.dart';
import 'navigation_layout.dart';

/// Controlled five-destination navigation content, excluding system bottom inset.
class AppNavigationBar extends StatefulWidget {
  AppNavigationBar({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required List<AppNavigationDestination> destinations,
    required this.selectedDestinationId,
    required this.onDestinationSelected,
  }) : destinations = List.unmodifiable(destinations) {
    validateNavigationDestinations(this.destinations, selectedDestinationId);
  }
  final String elementId, selectedDestinationId;
  final UiRuntimeLocator? runtimeLocator;
  final List<AppNavigationDestination> destinations;
  final ValueChanged<String>? onDestinationSelected;
  @override
  State<AppNavigationBar> createState() => _AppNavigationBarState();
}

class _AppNavigationBarState extends State<AppNavigationBar> {
  final _reportedWidths = <double>{};

  void reportHostWidth(double width, double minimum) {
    // D-036: the layout is identical in all modes. Reporting is development-only
    // and deferred until after rendering, once per width per mounted bar.
    if (kReleaseMode ||
        !width.isFinite ||
        width >= minimum ||
        !_reportedWidths.add(width)) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: FlutterError(
            'Navigator Bar host contract violation: received width $width; '
            'minimum width is $minimum (12 + 5 × 48). Rendering degraded '
            'navigation with undersized, non-compliant touch targets.',
          ),
          library: 'p2e_design_system',
          context: ErrorDescription('while laying out AppNavigationBar'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final elementId = widget.elementId,
        runtimeLocator = widget.runtimeLocator,
        destinations = widget.destinations,
        selectedDestinationId = widget.selectedDestinationId,
        onDestinationSelected = widget.onDestinationSelected;
    final s = NavigationBarSpec.lookup(Theme.of(context).brightness)
            .withSkin(SkinTheme.of(context)),
        persian = Localizations.maybeLocaleOf(context)?.languageCode == 'fa';
    final scaler = MediaQuery.textScalerOf(context)
        .clamp(maxScaleFactor: chromeTextScaleCap);
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: chromeTextScaleCap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          reportHostWidth(
            constraints.maxWidth,
            NavigationLayout.minimumWidth(s),
          );
          final l = NavigationLayout.resolve(
            spec: s,
            destinations: destinations,
            width: constraints.maxWidth,
            scaler: scaler,
            persian: persian,
          );
          return ElementIdentity(
            elementId: elementId,
            runtimeLocator: UiIdentityScope.resolve(
              context,
              override: runtimeLocator,
            ),
            componentId: 'navigation.bar',
            structureRef: 'navigation.bar',
            fileKey: s.fileKey,
            variantId: s.id,
            componentSetId: s.setId,
            rawSetName: s.setName,
            rawVariantName: s.rawName,
            variants: {
              'theme': s.brightness.name,
              'enabled': (onDestinationSelected != null).toString(),
            },
            declared: {
              'selectedDestinationId': selectedDestinationId,
              'destinationIds': destinations.map((d) => d.id).toList(),
            },
            resolved: {
              'bar': {
                'value': {
                  ...s.resolved(),
                  'layout': l.toJson(),
                  'sourceInstances': s.data['destinations'],
                },
                'origin': 'runtime-resolver',
              },
            },
            child: ColoredBox(
              color: s.color('body')!,
              child: SizedBox(
                key: ValueKey('$elementId.content'),
                height: l.contentHeight,
                child: Semantics(
                  container: true,
                  explicitChildNodes: true,
                  // Zero-area children have no semantic nodes; Flutter rejects
                  // an empty tabBar role. Positive-width hosts keep the role.
                  role: l.itemWidth > 0 ? SemanticsRole.tabBar : null,
                  child: FocusTraversalGroup(
                    policy: OrderedTraversalPolicy(),
                    child: Padding(
                      // D-036: even a host narrower than its source padding
                      // must not produce negative child constraints.
                      padding:
                          constraints.maxWidth < s.padding('body').horizontal
                          ? s.padding('body') *
                                (constraints.maxWidth /
                                    s.padding('body').horizontal)
                          : s.padding('body'),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < destinations.length; i++)
                            Expanded(
                              key: ValueKey(destinations[i].id),
                              child: FocusTraversalOrder(
                                order: NumericFocusOrder(i.toDouble()),
                                child: NavigationItemPresentation(
                                  elementId: '$elementId.${destinations[i].id}',
                                  runtimeLocator: runtimeLocator,
                                  destination: destinations[i],
                                  position: i,
                                  persian: persian,
                                  layout: l,
                                  spec: NavigationItemSpec.lookup(
                                    s.brightness,
                                    destinations[i].id == selectedDestinationId
                                        ? AppNavigationItemState.active
                                        : AppNavigationItemState.inactive,
                                  ).withSkin(SkinTheme.of(context)),
                                  onPressed: onDestinationSelected == null
                                      ? null
                                      : () => onDestinationSelected(
                                          destinations[i].id,
                                        ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Owns one actual bottom safe area and extends the source background behind it.
/// Use directly in Scaffold.bottomNavigationBar without an outer SafeArea.
class AppNavigationBarHost extends StatelessWidget {
  const AppNavigationBarHost({super.key, required this.bar});
  final AppNavigationBar bar;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: NavigationBarSpec.lookup(Theme.of(context).brightness)
        .withSkin(SkinTheme.of(context))
        .color('body')!,
    child: SafeArea(top: false, maintainBottomViewPadding: true, child: bar),
  );
}
