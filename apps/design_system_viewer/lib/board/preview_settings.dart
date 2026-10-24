import 'package:flutter/widgets.dart';
import 'package:p2e_design_system/design_system.dart';

@immutable
class PreviewSettings {
  const PreviewSettings({
    required this.iconMode,
    required this.scale,
    required this.direction,
    required this.reference,
    required this.longLabel,
    required this.fillWidth,
    required this.measurements,
    required this.revision,
    this.loading = false,
  });
  final ButtonIconMode iconMode;
  final double scale, fillWidth;
  final TextDirection direction;
  final bool reference, longLabel, measurements;
  final bool loading;
  final int revision;
}
