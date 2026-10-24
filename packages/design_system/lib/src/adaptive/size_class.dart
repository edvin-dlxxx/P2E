import 'package:flutter/widgets.dart';

import '../tokens/generated/adaptive_tokens.g.dart';

/// Architecture §16: available width only, never height or device type.
enum SizeClass {
  compact,
  medium,
  expanded;

  static SizeClass fromWidth(double width) => width < AdaptiveTokens.mediumWidth
      ? compact
      : width < AdaptiveTokens.expandedWidth
      ? medium
      : expanded;
  static SizeClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}
