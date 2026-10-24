import 'package:flutter/material.dart';
import 'package:p2e_design_system/design_system.dart';

/// Viewer chrome visual language.
/// Every color is read through the public Design System token API
/// (ButtonThemeTokens, dark set); no raw Material palette colors and no
/// product-facing tokens are introduced by this dev-only viewer.
abstract final class ViewerStyle {
  static final ButtonThemeTokens tokens = ButtonThemeTokens.forBrightness(
    Brightness.dark,
  );
  static Color token(String figmaName) => tokens.color(figmaName);

  /// Chrome canvas is derived from the Design System token (not a new
  /// product value): a slightly lighter step than Surface Container/Base
  /// so specimen surfaces stand apart from the viewer chrome (viewer-only
  /// engineering request, dev tool released from design approval).
  static final Color canvas = Color.lerp(
    token('Surface Container/Base'),
    token('On Surface/Emphasis'),
    .05,
  )!;
  static final Color panel = token('Surface/Base');
  static final Color panelRaised = token('Surface Container/Low');
  static final Color hairline = token('Outline/Variant');
  static final Color ink = token('On Surface/Emphasis');
  static final Color inkDisabled = token('On Surface/Disabled');
  static final Color highlight = token('White/Variant');

  static Color scrim(double alpha) => ink.withValues(alpha: alpha);

  /// Viewer chrome geometry; these numbers belong to the dev tool only.
  static const double spaceXs = 4;
  static const double spaceS = 8;
  static const double spaceM = 12;
  static const double spaceL = 16;
  static const double spaceXl = 24;
  static const double fieldWidth = 190;
  static const double searchWidth = 260;
  static const double radiusField = 8;
  static const double radiusPanel = 14;
  static const double sidebarWidth = 148;
}

class ViewerPanel extends StatelessWidget {
  const ViewerPanel({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.hairlineBorder = true,
  });
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool hairlineBorder;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: color ?? ViewerStyle.panel,
      borderRadius: BorderRadiusDirectional.circular(ViewerStyle.radiusPanel),
      border: hairlineBorder ? Border.all(color: ViewerStyle.hairline) : null,
    ),
    child: Padding(
      padding: padding ?? const EdgeInsetsDirectional.all(ViewerStyle.spaceL),
      child: child,
    ),
  );
}

class ViewerEmptyState extends StatelessWidget {
  const ViewerEmptyState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: ViewerPanel(
      color: ViewerStyle.canvas,
      padding: const EdgeInsetsDirectional.all(ViewerStyle.spaceXl),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: ViewerStyle.inkDisabled),
      ),
    ),
  );
}

class ViewerNavItem extends StatelessWidget {
  const ViewerNavItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    // PHYSICAL: the rail is a fixed vertical column for both languages.
    this.trailing,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: selected,
    button: true,
    child: Material(
      color: null,
      child: InkWell(
        borderRadius: BorderRadius.all(
          Radius.circular(ViewerStyle.radiusField),
        ),
        splashColor: ViewerStyle.scrim(.08),
        hoverColor: ViewerStyle.scrim(.04),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.antiAlias,
          children: [
            if (selected)
              PositionedDirectional(
                start: 0,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: ViewerStyle.ink,
                    borderRadius: const BorderRadiusDirectional.horizontal(
                      start: Radius.circular(3),
                    ),
                  ),
                  child: const SizedBox(width: 3),
                ),
              ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                // start offset leaves room for the selection indicator bar.
                start: ViewerStyle.spaceM,
                end: ViewerStyle.spaceM,
                top: ViewerStyle.spaceS + 2,
                bottom: ViewerStyle.spaceS + 2,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? ViewerStyle.ink
                            : ViewerStyle.scrim(.64),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// FIXED vertical section rail (physical row order is stable for both
/// languages: items stack top to bottom, no direction-dependent order).
class ViewerSectionRail extends StatelessWidget {
  const ViewerSectionRail({
    super.key,
    required this.items,
    this.header,
    this.footer,
  });
  final List<Widget> items;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: ViewerStyle.sidebarWidth,
    child: Container(
      color: ViewerStyle.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          Expanded(
            child: ListView(padding: EdgeInsets.zero, children: items),
          ),
          ?footer,
        ],
      ),
    ),
  );
}
