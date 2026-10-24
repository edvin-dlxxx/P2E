import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2e_dev_inspector/inspector.dart';
import 'package:p2e_design_system_viewer/main.dart';
import 'package:p2e_design_system_viewer/inspection/component_inspector.dart';
import 'package:p2e_design_system_viewer/inspection/inspection_record.dart';
import 'package:p2e_viewer_host/main.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/inspection.dart';
import 'package:p2e_design_system_viewer/viewer_shell.dart';

void main() {
  testWidgets('fa Viewer family matrix matches its existing inspector', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(2400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ViewerInspectionHost());
    await tester.pumpAndSettle();
    final state = tester.state<InspectorHostState>(find.byType(InspectorHost));
    for (final (section, component) in [
      (0, 'button.base'),
      (1, 'badge.base'),
      (2, 'text-field.general'),
      (3, 'text-field.password'),
      (4, 'text-field.otp-group'),
      (5, 'radio.base'),
      (8, 'app-bar.container'),
    ]) {
      await tester.tap(find.byKey(ValueKey('section-$section')));
      await tester.pumpAndSettle();
      state.session.scan();
      var node = state.session.tree.firstWhere(
        (n) =>
            n.identity.componentId == component &&
            (n.identity.variantId != null ||
                component == 'text-field.otp-group') &&
            n.visible,
      );
      final effectiveKey = node.key;
      final root = state.appKey.currentContext!.findRenderObject() as RenderBox;
      await tester.tapAt(root.localToGlobal(node.clipBounds.center));
      await tester.pumpAndSettle();
      state.session.scan();
      node = state.session.tree.firstWhere((n) => n.key == effectiveKey);
      final existing = tester
          .widget<ComponentInspector>(find.byType(ComponentInspector))
          .record;
      expect(existing, isNotNull, reason: component);
      final ids = [
        for (final fields in existing!.groups.values)
          for (final f in fields)
            if (f.id == InspectionFieldId.variantId) f.value,
      ];
      expect(ids, contains(node.identity.variantId), reason: component);
      state.session.choose(node);
      expect(
        (state.session.snapshot!['identity'] as Map)['elementId'],
        node.identity.elementId,
      );
    }
    await tester.tap(find.byKey(const ValueKey('components-navigation')));
    await tester.pumpAndSettle();
    state.session.scan();
    expect(
      state.session.tree.any(
        (n) => n.identity.componentId.startsWith('navigation.'),
      ),
      isTrue,
    );
    final nav = state.session.tree.firstWhere(
      (n) => n.identity.componentId == 'navigation.bar' && n.visible,
    );
    final navRoot =
        state.appKey.currentContext!.findRenderObject() as RenderBox;
    await tester.tapAt(navRoot.localToGlobal(nav.clipBounds.center));
    await tester.pumpAndSettle();
    final navRecord = tester
        .widget<ComponentInspector>(find.byType(ComponentInspector))
        .record!;
    expect([
      for (final fs in navRecord.groups.values)
        for (final f in fs)
          if (f.id == InspectionFieldId.variantId) f.value,
    ], contains(nav.identity.variantId));
    await tester.tap(find.byKey(const ValueKey('section-6')));
    await tester.pumpAndSettle();
    state.session.scan();
    final icon = state.session.tree.firstWhere(
      (n) => n.identity.componentId == 'icon.preview' && n.visible,
    );
    final root = state.appKey.currentContext!.findRenderObject() as RenderBox;
    await tester.tapAt(root.localToGlobal(icon.clipBounds.center));
    await tester.pumpAndSettle();
    final record = tester
        .widget<ComponentInspector>(find.byType(ComponentInspector))
        .record!;
    final source = sourceFor(icon.identity)!;
    final ids = [
      for (final fields in record.groups.values)
        for (final f in fields)
          if (f.id == InspectionFieldId.variantId) f.value,
    ];
    expect(ids, contains(source.data['nodeId']));
    expect(
      icon.identity.variantId,
      isNull,
    ); // Preserve engineering preview identity.
  });
  testWidgets(
    'real Viewer fills honest remaining width; selection reads existing source values',
    (tester) async {
      tester.view.physicalSize = const Size(1600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const ViewerInspectionHost());
      await tester.pumpAndSettle();
      final state = tester.state<InspectorHostState>(
        find.byType(InspectorHost),
      );
      expect(find.byType(DevelopmentViewer), findsOneWidget);
      expect(tester.getSize(find.byKey(state.appKey)).width, 1172);
      state.session.scan();
      expect(state.session.tree, isNotEmpty);
      final button = state.session.tree.firstWhere(
        (n) => n.identity.componentId == 'button.base' && n.visible,
      );
      // The existing Viewer receives its normal tap while external Select is off.
      final root = state.appKey.currentContext!.findRenderObject() as RenderBox;
      await tester.tapAt(root.localToGlobal(button.clipBounds.center));
      await tester.pumpAndSettle();
      final original = tester
          .widget<ComponentInspector>(find.byType(ComponentInspector))
          .record;
      expect(original, isNotNull);
      final ids = [
        for (final fields in original!.groups.values)
          for (final f in fields)
            if (f.id == InspectionFieldId.variantId) f.value,
      ];
      expect(ids, contains(button.identity.variantId));
      state.session.choose(button);
      final identity = state.session.snapshot!['identity'] as Map;
      expect(
        identity['designRef'],
        (button.identity.descriptor()['identity'] as Map)['designRef'],
      );
      final scaleControl = tester.widget<DropdownButtonFormField<String>>(
        find.byKey(const ValueKey('control-scale-1.0')),
      );
      scaleControl.onChanged!('1.3');
      await tester.pumpAndSettle();
      state.session.scan();
      final scaled = state.session.tree.firstWhere(
        (n) => n.identity.componentId == 'button.base' && n.visible,
      );
      state.session.choose(scaled);
      expect(
        (state.session.snapshot!['resolved']
            as Map)['inspectionConfiguration']['value']['requestedScale'],
        1.3,
      );
      await tester.tap(find.byKey(const ValueKey('toggle-panel')));
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byKey(state.appKey)).width, 1400);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Dev skin and existing Viewer selector stay synchronized', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ViewerInspectionHost());
    await tester.pumpAndSettle();
    final host = tester.state<InspectorHostState>(find.byType(InspectorHost));
    host.update(host.settings.copyWith(testSkin: true));
    await tester.pumpAndSettle();
    expect(
      tester.widget<ViewerShell>(find.byType(ViewerShell)).skin.id,
      testSkin.id,
    );
    tester.widget<ViewerShell>(find.byType(ViewerShell)).onSkin!(productSkin);
    await tester.pumpAndSettle();
    expect(host.settings.testSkin, isFalse);
    expect(
      tester.widget<ViewerShell>(find.byType(ViewerShell)).skin.id,
      productSkin.id,
    );
    // Native minimum client size, including the widest optional panel.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    tester.view.physicalSize = const Size(1280, 1000);
    await tester.pumpWidget(const ViewerInspectionHost());
    await tester.pumpAndSettle();
    tester
        .widget<GestureDetector>(find.byKey(const ValueKey('resize-panel')))
        .onPanUpdate!(
      DragUpdateDetails(
        globalPosition: Offset.zero,
        delta: const Offset(-220, 0),
      ),
    );
    await tester.pumpAndSettle();
    final minimumHost = tester.state<InspectorHostState>(
      find.byType(InspectorHost),
    );
    expect(minimumHost.panelWidth, 600);
    expect(minimumHost.device.settings.size.width, greaterThan(452));
    minimumHost.problems.sampleLayout();
    expect(minimumHost.problems.problems, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
