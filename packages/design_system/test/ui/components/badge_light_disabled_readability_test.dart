import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

void main() {
  test('D-029 preserves source paints and remaps only Light disabled Badge foreground/icons', () {
    const lightFillArgb = 0xFFD4D4D4;
    final emphasis = ButtonThemeTokens.forBrightness(Brightness.light)
        .color('On Surface/Emphasis');
    expect(emphasis.toARGB32(), isNot(lightFillArgb));
    for (final size in BadgeSize.values) {
      final s = BadgeSpec.lookup(
        size,
        BadgeAppearance.disabled,
        Brightness.light,
      );
      expect(s.readabilityOverride, isTrue, reason: s.id);
      // Source bug (errata E-014): label color equals the background fill.
      expect(s.sourceForegroundColor?.toARGB32(), lightFillArgb, reason: s.id);
      expect(
        s.effectiveForegroundColor?.toARGB32(),
        emphasis.toARGB32(),
        reason: s.id,
      );
      for (final mode in [BadgeIconMode.fill, BadgeIconMode.outline]) {
        expect(s.iconColor(mode), isNotNull, reason: '${s.id}/$mode');
        expect(
          s.effectiveIconColor(mode)?.toARGB32(),
          emphasis.toARGB32(),
          reason: '${s.id}/$mode',
        );
      }
      final filled = BadgeSpec.lookup(
        size,
        BadgeAppearance.filled,
        Brightness.light,
      );
      expect(filled.readabilityOverride, isFalse, reason: filled.id);
      expect(
        filled.effectiveForegroundColor?.toARGB32(),
        filled.sourceForegroundColor?.toARGB32(),
      );
    }
    // Dark disabled keeps its source separation and is never remapped.
    final dark = BadgeSpec.lookup(
      BadgeSize.medium,
      BadgeAppearance.disabled,
      Brightness.dark,
    );
    expect(dark.readabilityOverride, isFalse);
    expect(
      dark.effectiveForegroundColor?.toARGB32(),
      dark.sourceForegroundColor?.toARGB32(),
    );
    final resolved = dark.resolved(iconMode: BadgeIconMode.fill);
    expect(resolved['engineeringOverride'], isNull);
    final lightResolved = BadgeSpec.lookup(
      BadgeSize.large,
      BadgeAppearance.disabled,
      Brightness.light,
    ).resolved(iconMode: BadgeIconMode.fill);
    final override =
        lightResolved['engineeringOverride'] as Map<String, Object?>?;
    expect(override?['decision'], 'D-029');
    expect(override?['sourceForeground'], lightFillArgb);
    expect(override?['effectiveForeground'], emphasis.toARGB32());
  });
}
