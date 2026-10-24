import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system/design_system.dart';

import 'viewer_shell_test.dart' as shell;

void main() {
  testWidgets('Viewer-visible Persian paragraphs use one bundled family prefix', (
    tester,
  ) async {
    await shell.open(tester, language: 'fa');
    var checked = 0;
    for (final paragraph in tester.renderObjectList<RenderParagraph>(
      find.byType(RichText),
    )) {
      if (!RegExp(r'[\u0600-\u06ff]').hasMatch(paragraph.text.toPlainText())) {
        continue;
      }
      final style = (paragraph.text as TextSpan).style!;
      final chain = [
        if (style.fontFamily != null) style.fontFamily!,
        ...?style.fontFamilyFallback,
      ];
      expect(
        chain,
        contains(BundledTypography.persianFamily),
        reason: '${paragraph.text}: $style',
      );
      expect(
        chain.any(
          (f) => f.contains(
            '${BundledTypography.packagePrefix}${BundledTypography.packagePrefix}',
          ),
        ),
        isFalse,
      );
      checked++;
    }
    expect(checked, greaterThan(90));
    expect(tester.takeException(), isNull);
  });
}
