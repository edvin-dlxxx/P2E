import 'generated/icon_registry.g.dart';

import 'package:flutter/painting.dart';

export 'generated/icon_registry.g.dart' show AppIconId;

enum AppIconStyle { fill, outline }

class MissingIconArtwork implements Exception {
  const MissingIconArtwork(this.key, [this.style]);
  final String key;
  final AppIconStyle? style;
  @override
  String toString() =>
      'MissingIconArtwork: $key / ${style?.name ?? "unknown key"}';
}

class IconArtwork {
  const IconArtwork(this.data);
  final Map<String, dynamic> data;
  String get logicalKey => data['logicalKey'] as String;
  AppIconStyle get style => AppIconStyle.values.byName(data['style'] as String);
  String get nodeId => data['nodeId'] as String;
  String get assetPath => data['assetPath'] as String;
  String get sha256 => data['sha256'] as String;
  bool get monochrome => data['monochrome'] as bool;
  double get width => (data['width'] as num).toDouble();
  double get height => (data['height'] as num).toDouble();
  String get viewBox => data['viewBox'] as String;
  ColorFilter? tintFilter(Color? color) => monochrome && color != null
      ? ColorFilter.mode(color, BlendMode.srcIn)
      : null;
}

class IconDefinition {
  const IconDefinition(this.id, this.data);
  final AppIconId id;
  final Map<String, dynamic> data;
  String get key => data['key'] as String;
  String get rawName => data['rawName'] as String;
  bool get mirrorInRtl => data['mirrorInRtl'] as bool;
  Map<String, dynamic> get _artworks =>
      data['artworks'] as Map<String, dynamic>;
  List<AppIconStyle> get styles => [
    for (final style in AppIconStyle.values)
      if (_artworks.containsKey(style.name)) style,
  ];
  IconArtwork artwork(AppIconStyle style) {
    final value = _artworks[style.name];
    if (value == null) throw MissingIconArtwork(key, style);
    return IconArtwork(value as Map<String, dynamic>);
  }
}

abstract final class AppIconRegistry {
  static final List<IconDefinition> all = List.unmodifiable([
    for (final id in AppIconId.values)
      IconDefinition(id, iconRegistryData[appIconKeys[id]]!),
  ]);
  static IconDefinition definition(AppIconId id) =>
      all.firstWhere((icon) => icon.id == id);
  static IconDefinition byKey(String key) => all.firstWhere(
    (icon) => icon.key == key || (icon.data['aliases'] as List).contains(key),
    orElse: () => throw MissingIconArtwork(key),
  );

  /// Master links select a concept; the requested real style must exist.
  static IconDefinition buttonArtwork(String variantId, AppIconStyle style) {
    final source = buttonIconSourceKeys[variantId];
    if (source == null || source.isEmpty) {
      throw MissingIconArtwork(variantId, style);
    }
    final concepts = source.values.toSet();
    final key =
        source[style.name] ?? (concepts.length == 1 ? concepts.single : null);
    if (key == null) throw MissingIconArtwork(variantId, style);
    final icon = byKey(key);
    icon.artwork(style);
    return icon;
  }
}
