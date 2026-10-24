import 'package:flutter/foundation.dart';

enum InspectionGroup { identity, configuration, visuals, geometry, interaction }

enum InspectionFieldId {
  family,
  setName,
  setId,
  variantName,
  variantId,
  fileKey,
  runtimeIdentity,
  status,
  size,
  theme,
  appearance,
  enabled,
  label,
  iconMode,
  artwork,
  direction,
  scale,
  constraints,
  background,
  foreground,
  borderColor,
  borderWidth,
  radius,
  padding,
  gap,
  iconSize,
  fontFamily,
  fontSize,
  fontWeight,
  lineHeight,
  letterSpacing,
  sourceDimensions,
  minimum,
  visual,
  outer,
  content,
  comparison,
  pressedScale,
  pressDuration,
  releaseDuration,
  curve,
  motionOrigin,
  currentState,
  artworkSource,
  logicalKey,
  displayName,
  rawName,
  style,
  availableStyles,
  viewBox,
  assetPath,
  assetHash,
  sourceColors,
  bindings,
  previewSize,
  tint,
  semanticLabel,
  decorative,
  extractionStatus,
  renderStatus,
  issue,
  validation,
  requirement,
  supporting,
  supportingIcon,
  passwordVisible,
  codeLength,
  complete,
  radioSelection,
  resolvedStyles,
  motion,
  sourceCovered,
}

@immutable
class InspectionField {
  const InspectionField(this.id, this.value);
  final InspectionFieldId id;
  final Object? value;
}

/// Component-neutral data contract for the persistent inspector.
@immutable
class InspectionRecord {
  const InspectionRecord({required this.sampleId, required this.groups});
  final String sampleId;
  final Map<InspectionGroup, List<InspectionField>> groups;
}
