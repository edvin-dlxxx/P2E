import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'icon_registry.dart';
export 'icon_registry.dart';

/// Artwork identity input, separate from Button appearance and icon mode.
/// Concrete implementations must supply the requested real local source style.
abstract class AppIcon extends StatelessWidget {
  const AppIcon({super.key});
  String get iconId;
  AppIcon withStyle(AppIconStyle style);
  AppIcon forControl(AppIconStyle style) => withStyle(style);
}

/// Exact local Figma artwork; tint is opt-in and restricted to monochrome SVGs.
class AssetAppIcon extends AppIcon {
  const AssetAppIcon(
    this.id, {
    super.key,
    this.style = AppIconStyle.fill,
    this.size,
    this.color,
    this.useThemeColor = false,
    this.semanticLabel,
    bool? decorative,
  }) : decorative = decorative ?? semanticLabel == null,
       assert(size == null || size > 0),
       assert(
         decorative != false || (semanticLabel != null && semanticLabel != ''),
       );
  final AppIconId id;
  final AppIconStyle style;
  final double? size;
  final Color? color;
  final bool useThemeColor;
  final String? semanticLabel;
  final bool decorative;
  IconDefinition get definition => AppIconRegistry.definition(id);
  IconArtwork get artwork => definition.artwork(style);
  String get logicalKey => definition.key;
  @override
  String get iconId => definition.data['id'] as String;
  String get sourceNodeId => artwork.nodeId;
  @override
  AssetAppIcon withStyle(AppIconStyle style) => AssetAppIcon(
    id,
    style: style,
    size: size,
    color: color,
    useThemeColor: useThemeColor,
    semanticLabel: semanticLabel,
    decorative: decorative,
  );
  @override
  AssetAppIcon forControl(AppIconStyle style) =>
      AssetAppIcon(id, style: style, useThemeColor: true, decorative: true);
  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final source = artwork;
    final tint = color ?? (useThemeColor ? theme.color : null);
    final extent = size ?? theme.size ?? source.width;
    return SvgPicture.asset(
      source.assetPath,
      package: 'p2e_design_system',
      width: extent,
      height: extent,
      fit: BoxFit.contain,
      matchTextDirection: definition.mirrorInRtl,
      colorFilter: source.tintFilter(tint),
      semanticsLabel: decorative ? null : semanticLabel,
      excludeFromSemantics: decorative,
    );
  }
}
