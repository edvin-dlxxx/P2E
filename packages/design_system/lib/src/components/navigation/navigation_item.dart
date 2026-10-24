import '../../theme/skin_theme.dart';

import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show OrdinalSortKey;

import '../../icons/app_icon.dart';
import '../../identity/element_identity.dart';
import '../../interaction/press_action.dart';
import '../../tokens/button_motion.dart';
import '../../tokens/navigation_spec.dart';
import '../../tokens/generated/readiness_tokens.g.dart';
import 'navigation_destination.dart';
import 'navigation_layout.dart';

/// Standalone source item; the bar uses this same internal presentation.
class AppNavigationItem extends StatelessWidget {
  const AppNavigationItem({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.destination,
    required this.state,
    required this.onPressed,
  });
  final String elementId;
  final UiRuntimeLocator? runtimeLocator;
  final AppNavigationDestination destination;
  final AppNavigationItemState state;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final spec = NavigationItemSpec.lookup(
        Theme.of(context).brightness,
        state,
      ).withSkin(SkinTheme.of(context));
      final persian =
          Localizations.maybeLocaleOf(context)?.languageCode == 'fa';
      final scaler = MediaQuery.textScalerOf(context)
          .clamp(maxScaleFactor: chromeTextScaleCap);
      final layout = NavigationLayout.forItems(
        spec: spec,
        destinations: [destination],
        itemWidth: constraints.maxWidth,
        scaler: scaler,
        persian: persian,
      );
      return MediaQuery.withClampedTextScaling(
        maxScaleFactor: chromeTextScaleCap,
        child: NavigationItemPresentation(
          elementId: elementId,
          runtimeLocator: runtimeLocator,
          destination: destination,
          spec: spec,
          layout: layout,
          persian: persian,
          onPressed: onPressed,
          position: 0,
        ),
      );
    },
  );
}

/// Package-internal presentation and native interaction. Not exported publicly.
class NavigationItemPresentation extends StatefulWidget {
  const NavigationItemPresentation({
    super.key,
    required this.elementId,
    this.runtimeLocator,
    required this.destination,
    required this.spec,
    required this.layout,
    required this.persian,
    required this.onPressed,
    required this.position,
  });
  final String elementId;
  final UiRuntimeLocator? runtimeLocator;
  final AppNavigationDestination destination;
  final NavigationItemSpec spec;
  final NavigationLayout layout;
  final bool persian;
  final VoidCallback? onPressed;
  final int position;
  @override
  State<NavigationItemPresentation> createState() =>
      _NavigationItemPresentationState();
}

class _NavigationItemPresentationState
    extends State<NavigationItemPresentation> {
  final states = WidgetStatesController();
  bool focused = false;
  @override
  void initState() {
    super.initState();
    states.addListener(observe);
  }

  void observe() {
    final next = states.value.contains(WidgetState.focused);
    if (next != focused && mounted) setState(() => focused = next);
  }

  @override
  void dispose() {
    states.removeListener(observe);
    states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget,
        s = w.spec,
        l = w.layout,
        d = w.destination,
        id = w.elementId;
    final active = s.state == AppNavigationItemState.active;
    final icon = AppIconRegistry.definition(d.icon),
        art = icon.artwork(s.iconStyle),
        badge = l.badges[d.id];
    final reduced = MediaQuery.disableAnimationsOf(context);
    final clear = s.iconTint.withValues(alpha: 0);
    final style = ButtonStyle(
      padding: const WidgetStatePropertyAll(EdgeInsetsDirectional.zero),
      minimumSize: WidgetStatePropertyAll(Size(l.itemWidth, l.contentHeight)),
      maximumSize: WidgetStatePropertyAll(Size(l.itemWidth, l.contentHeight)),
      backgroundColor: WidgetStatePropertyAll(clear),
      surfaceTintColor: WidgetStatePropertyAll(clear),
      shadowColor: WidgetStatePropertyAll(clear),
      elevation: const WidgetStatePropertyAll(0),
      animationDuration: Duration.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.zero),
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? BorderSide(
                color: s.iconTint,
                width: NavigationSourceSpec.engineeringMetric('focusWidth'),
              )
            : BorderSide.none,
      ),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => s.iconTint.withValues(
          alpha: states.contains(WidgetState.hovered)
              ? NavigationSourceSpec.engineeringMetric('overlayAlpha')
              : 0,
        ),
      ),
      splashFactory: NoSplash.splashFactory,
    );
    final indicator = ConstrainedBox(
      constraints: BoxConstraints.tightFor(
        width: l.indicatorWidth,
        height: l.indicatorHeight,
      ),
      child: AnimatedContainer(
        key: ValueKey('$id.indicator'),
        duration: reduced ? Duration.zero : ButtonMotion.releaseDuration,
        curve: ButtonMotion.curve,
        decoration: BoxDecoration(
          color: s.color('indicator'),
          borderRadius: BorderRadiusDirectional.all(
            Radius.circular(s.metric('indicator', 'cornerRadius')),
          ),
        ),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            AssetAppIcon(
              d.icon,
              key: ValueKey('$id.icon'),
              style: s.iconStyle,
              size: s.metric('icon', 'width'),
              color: s.iconTint,
            ),
            if (d.badge != null && badge != null)
              PositionedDirectional(
                start: badge.start,
                top: s.metric('badge', 'y'),
                width: badge.width,
                height: badge.wrapperHeight,
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: _NavigationBadge(
                      key: ValueKey('$id.badge'),
                      label: d.badge!.label,
                      spec: s,
                      layout: badge,
                      persian: w.persian,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    final content = Padding(
      padding: s.padding('body'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(height: s.metric('body', 'itemSpacing')),
          SizedBox(
            key: ValueKey('$id.label'),
            height: l.labelHeight,
            width: l.itemWidth,
            child: Center(
              child: Text(
                d.label,
                textAlign: TextAlign.center,
                style: s.textStyle('label', persian: w.persian),
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
    return ElementIdentity(
      elementId: id,
      runtimeLocator: UiIdentityScope.resolve(
        context,
        override: w.runtimeLocator,
      ),
      componentId: 'navigation.item',
      structureRef: 'navigation.item',
      fileKey: s.fileKey,
      variantId: s.id,
      componentSetId: s.setId,
      rawSetName: s.setName,
      rawVariantName: s.rawName,
      variants: {
        'state': s.state.name,
        'theme': s.brightness.name,
        'enabled': (w.onPressed != null).toString(),
      },
      declared: {
        'destinationId': d.id,
        'selected': active,
        'position': w.position,
        'destination': d.toJson(),
      },
      resolved: {
        'item': {
          'value': {
            ...s.resolved(),
            'typography': s.typography(persian: w.persian),
            'layout': l.toJson(),
            'icon': {
              'logicalKey': icon.key,
              'style': s.iconStyle.name,
              'sourceId': art.nodeId,
              'assetPath': art.assetPath,
              'tint': s.iconTint.toARGB32(),
              'size': s.metric('icon', 'width'),
            },
            'focused': focused,
            'enabled': w.onPressed != null,
          },
          'origin': 'runtime-resolver',
        },
      },
      child: MergeSemantics(
        child: IndexedSemantics(
          index: w.position,
          child: Semantics(
            container: true,
            excludeSemantics: true,
            role: SemanticsRole.tab,
            label: d.semanticLabel ?? d.label,
            value: d.badge?.semanticLabel,
            selected: active,
            button: true,
            enabled: w.onPressed != null,
            focusable: w.onPressed != null,
            focused: focused,
            onTap: w.onPressed,
            sortKey: OrdinalSortKey(w.position.toDouble()),
            child: Tooltip(
              message: d.semanticLabel ?? d.label,
              excludeFromSemantics: true,
              child: SizedBox(
                key: ValueKey('$id.hit'),
                width: l.itemWidth,
                height: l.contentHeight,
                child: PressAction(
                  onPressed: w.onPressed,
                  style: style,
                  statesController: states,
                  child: IgnorePointer(child: ExcludeSemantics(child: content)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationBadge extends StatelessWidget {
  const _NavigationBadge({
    super.key,
    required this.label,
    required this.spec,
    required this.layout,
    required this.persian,
  });
  final String label;
  final NavigationItemSpec spec;
  final NavigationBadgeLayout layout;
  final bool persian;
  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.bottomCenter,
    child: Container(
      key: ValueKey('${(key as ValueKey<String>).value}.pill'),
      width: layout.width,
      height: layout.pillHeight,
      decoration: BoxDecoration(
        color: spec.color('pill'),
        borderRadius: BorderRadiusDirectional.all(
          Radius.circular(spec.metric('pill', 'cornerRadius')),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: spec.badgeInlineAllowance,
          end: spec.badgeInlineAllowance,
          bottom: spec.metric('badgeLabelFrame', 'paddingBottom'),
        ),
        child: Center(
          child: Text(
            label,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
            style: spec.textStyle('badgeLabel', persian: persian),
          ),
        ),
      ),
    ),
  );
}
