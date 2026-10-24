import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_design_system_viewer/inspection/component_inspector.dart';
import 'package:p2e_design_system_viewer/inspection/inspection_record.dart';
import 'package:p2e_design_system_viewer/l10n/generated/viewer_localizations.dart';

void main() {
  for (final language in ['en', 'fa']) {
    testWidgets(
      '$language Inspector copies a single value and the complete formatted report',
      (tester) async {
        final copied = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'Clipboard.setData') {
              copied.add((call.arguments as Map)['text'] as String);
            }
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            SystemChannels.platform,
            null,
          ),
        );
        const record = InspectionRecord(
          sampleId: 'live.otp',
          groups: {
            InspectionGroup.identity: [
              InspectionField(InspectionFieldId.variantId, null),
            ],
            InspectionGroup.configuration: [
              InspectionField(InspectionFieldId.complete, true),
            ],
            InspectionGroup.visuals: [
              InspectionField(InspectionFieldId.resolvedStyles, {
                'radius': 16,
                'derived': true,
              }),
            ],
          },
        );
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            localizationsDelegates: ViewerLocalizations.localizationsDelegates,
            supportedLocales: ViewerLocalizations.supportedLocales,
            home: const Scaffold(body: ComponentInspector(record: record)),
          ),
        );
        await tester.pumpAndSettle();
        final l = ViewerLocalizations.of(
          tester.element(find.byType(ComponentInspector)),
        );
        await tester.tap(find.byKey(const ValueKey('copy-inspector')));
        await tester.pumpAndSettle();
        expect(copied.single, ComponentInspector.report(record, l));
        expect(copied.single, contains(l.fieldLabel('resolvedStyles')));
        expect(copied.single, contains('"derived": true'));
        final button = find.byKey(const ValueKey('copy-inspector-variantId'));
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(copied.last, l.unavailable);
        expect(find.text(l.inspectorCopied), findsWidgets);
      },
    );
  }
}
