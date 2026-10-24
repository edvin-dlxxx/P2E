import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:p2e_design_system/design_system.dart'
    show BundledTypography, ElementIdentity;

import '../core/device.dart';
import '../core/problems.dart';
import '../core/inspection.dart';
import '../core/selection.dart';
import 'device_toolbar.dart';
import 'tool_copy.dart';
export '../core/device.dart';

typedef HostAppBuilder = Widget Function(
  FrameSettings settings,
  GlobalKey appKey,
);

class InspectorHost extends StatefulWidget {
  const InspectorHost({
    super.key,
    required this.appBuilder,
    this.fill = false,
    this.controls,
    this.initialSettings = const FrameSettings(),
    this.device,
  });
  final HostAppBuilder appBuilder;
  final bool fill;
  final Widget? controls;
  final FrameSettings initialSettings;
  final SimulatedDevice? device;
  @override
  State<InspectorHost> createState() => InspectorHostState();
}

class InspectorHostState extends State<InspectorHost> {
  final appKey = GlobalKey(debugLabel: 'inspected-app');
  late final device = widget.device ?? SimulatedDevice(widget.initialSettings);
  FrameSettings get settings => device.settings;
  late final session = InspectionSession(
    appKey,
    requestedScale: widget.fill ? null : settings.scale,
  );
  late final problems = ProblemRecorder(session, device);
  late final sweep = SweepRunner(device, problems);
  bool panelOpen = true;
  double panelWidth = 380, zoom = 1;
  String appResult = '';
  @override
  void initState() {
    super.initState();
    if (widget.fill && widget.device == null) device.mode = FrameMode.fitWindow;
    session.watchBuilds();
    device.addListener(changed);
    problems.attach();
  }

  void changed() {
    if (mounted) {
      setState(
        () => session.requestedScale = widget.fill ? null : settings.scale,
      );
    }
  }

  @override
  void dispose() {
    device.removeListener(changed);
    problems.dispose();
    sweep.dispose();
    session.dispose();
    if (widget.device == null) device.dispose();
    super.dispose();
  }

  void update(FrameSettings value) => device.apply(value);
  Future<void> frame() async {
    WidgetsBinding.instance.scheduleFrame();
    await WidgetsBinding.instance.endOfFrame;
  }

  void chooseKey(String? key) {
    session.scan();
    final n = session.tree.where((n) => n.key == key).firstOrNull;
    if (n != null) session.choose(n);
  }

  void jump(InspectionProblem p) {
    update(p.device);
    WidgetsBinding.instance.addPostFrameCallback((_) => chooseKey(p.ownerKey));
  }

  void readResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      BuildContext? resolved;
      void visit(Element e) {
        if (resolved != null) return;
        if ((e.widget is ElementIdentity || e.widget is Scaffold) &&
            Localizations.maybeLocaleOf(e) != null) {
          resolved = e;
        }
        e.visitChildren(visit);
      }

      (appKey.currentContext as Element?)?.visitChildren(visit);
      final c = resolved;
      if (c != null) {
        final value = toolCopy(
          'resultValue',
          arguments: {
            'locale':
                Localizations.maybeLocaleOf(c)?.toLanguageTag() ??
                toolCopy('unavailable'),
            'direction': Directionality.of(c).name,
            'brightness': Theme.of(c).brightness.name,
            'device': settings.scale.toStringAsFixed(2),
            'effective': MediaQuery.textScalerOf(c).scale(16) / 16,
            'sizeClass': settings.sizeClass,
          },
        );
        if (value != appResult) setState(() => appResult = value);
      }
    });
  }

  Widget surface() {
    readResult();
    return ListenableBuilder(
      listenable: session,
      child: widget.appBuilder(settings, appKey),
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          child!,
          if (session.selecting)
            Positioned.fill(
              child: ExcludeSemantics(
                child: MouseRegion(
                  opaque: true,
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (e) => session.pick(e.localPosition),
                    child: const ColoredBox(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: CustomPaint(
                  painter: _Highlight(session.selected, session.snapshot),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget viewport() => LayoutBuilder(
    builder: (context, c) {
      final available = Size(
        math.max(1, c.maxWidth - 40),
        math.max(1, c.maxHeight - 42),
      );
      if (device.mode == FrameMode.fitWindow) {
        final size = Size(
          available.width.clamp(200, 1400),
          available.height.clamp(300, 1400),
        );
        if (settings.size != size) {
          // Resolve the frame before mounting/layout, avoiding a transient old
          // narrow frame and spurious initial problems in Fit window mode.
          device.settings = settings.copyWith(size: size);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && device.mode == FrameMode.fitWindow) {
              device.apply(device.settings);
            }
          });
        }
      }
      zoom = device.zoomFor(available);
      final content = SizedBox(
        width: settings.size.width,
        height: settings.size.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(child: surface()),
            Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: _FrameGuides())),
            ),
            // PHYSICAL: handles track physical simulated-device display edges.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 12,
              child: GestureDetector(
                key: const ValueKey('resize-width'),
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (e) => device.resize(
                  settings.size.width + e.delta.dx,
                  settings.size.height,
                ),
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 12,
              child: GestureDetector(
                key: const ValueKey('resize-height'),
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (e) => device.resize(
                  settings.size.width,
                  settings.size.height + e.delta.dy,
                ),
                child: const MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              width: 20,
              height: 20,
              child: GestureDetector(
                key: const ValueKey('resize-both'),
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (e) => device.resize(
                  settings.size.width + e.delta.dx,
                  settings.size.height + e.delta.dy,
                ),
                child: const ColoredBox(color: Colors.teal),
              ),
            ),
          ],
        ),
      );
      final scaled = SizedBox(
        width: settings.size.width * zoom + 16,
        height: settings.size.height * zoom + 16,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: settings.size.width,
            maxWidth: settings.size.width,
            minHeight: settings.size.height,
            maxHeight: settings.size.height,
            child: Transform.scale(
              scale: zoom,
              alignment: Alignment.topLeft,
              child: content,
            ),
          ),
        ),
      );
      return ColoredBox(
        color: Colors.blueGrey.shade900,
        child: Column(
          children: [
            Text(
              '${settings.size.width.toStringAsFixed(0)} x ${settings.size.height.toStringAsFixed(0)} / ${(zoom * 100).toStringAsFixed(0)}% / ${settings.sizeClass}',
              key: const ValueKey('frame-readout'),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, box) => SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: box.maxWidth,
                        minHeight: box.maxHeight,
                      ),
                      child: Center(child: scaled),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  Widget panel() => DefaultTabController(
    length: 3,
    child: Column(
      children: [
        TabBar(
          tabs: [
            Tab(text: toolCopy('inspectTab')),
            Tab(text: toolCopy('problemsTab')),
            Tab(text: toolCopy('sweepTab')),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              InspectionPanel(session: session),
              ListenableBuilder(
                listenable: problems,
                builder: (context, _) => ListView(
                  children: [
                    TextButton(
                      onPressed: sweep.running ? null : problems.clear,
                      child: Text(toolCopy('clear')),
                    ),
                    for (final p in problems.problems)
                      ListTile(
                        title: Text(p.summary),
                        subtitle: Text(
                          '${p.kind} / ${p.elementId ?? toolCopy('unavailable')} / ${p.device.size}',
                        ),
                        onTap: () => jump(p),
                      ),
                  ],
                ),
              ),
              SweepControls(
                device: device,
                runner: sweep,
                frame: frame,
                onJump: (r) {
                  update(
                    FrameSettings.fromJson(r['device'] as Map)
                        .copyWith(testSkin: settings.testSkin),
                  );
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => chooseKey(jsonEncode(r['ownerKey'])),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: inspectorBuildMarker,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: BundledTypography.outfitFamily,
      fontFamilyFallback: BundledTypography.persianFallback,
    ),
    home: CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            session.setSelecting(false),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(toolCopy('inspectionTitle')),
            actions: [
              Text(toolCopy('devGroup')),
              ListenableBuilder(
                listenable: session,
                builder: (context, _) => TextButton(
                  key: const ValueKey('select-mode'),
                  onPressed: () => session.setSelecting(!session.selecting),
                  child: Text(
                    session.selecting
                        ? toolCopy('exitSelect')
                        : toolCopy('select'),
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('toggle-panel'),
                onPressed: () => setState(() => panelOpen = !panelOpen),
                child: Text(toolCopy('panel')),
              ),
              ?widget.controls,
            ],
          ),
          body: Column(
            children: [
              SizedBox(
                height: 180,
                child: SingleChildScrollView(
                  child: DeviceToolbar(device: device),
                ),
              ),
              Text(
                '${toolCopy('appResult')}: $appResult',
                key: const ValueKey('app-result'),
              ),
              Expanded(
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    // PHYSICAL: panel remains physical-right.
                    Expanded(child: viewport()),
                    if (panelOpen)
                      GestureDetector(
                        key: const ValueKey('resize-panel'),
                        onPanUpdate: (e) => setState(
                          () => panelWidth = (panelWidth - e.delta.dx).clamp(
                            280,
                            600,
                          ),
                        ),
                        child: const SizedBox(
                          width: 8,
                          child: ColoredBox(color: Colors.teal),
                        ),
                      ),
                    if (panelOpen)
                      SizedBox(
                        width: math.min(
                          panelWidth,
                          MediaQuery.sizeOf(context).width * .6,
                        ),
                        child: panel(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class InspectionPanel extends StatelessWidget {
  const InspectionPanel({super.key, required this.session});
  final InspectionSession session;
  @override
  Widget build(BuildContext context) => Material(
    child: ListenableBuilder(
      listenable: session,
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: session.refreshTree,
              child: Text(toolCopy('treeRefresh')),
            ),
            if (session.notice != null) Text(session.notice!),
            Text(
              toolCopy(
                'mountedSummary',
                arguments: {
                  'count': session.tree.length,
                  'traversals': session.traversals,
                },
              ),
            ),
            if (session.candidates.length > 1) Text(toolCopy('candidates')),
            for (final n in session.candidates)
              TextButton(
                onPressed: () => session.choose(n),
                child: Text(
                  '${n.identity.componentId} / ${n.identity.runtimeLocator?.slotPath ?? toolCopy('owner')}',
                ),
              ),
            if (session.selected?.owner != null)
              TextButton(
                onPressed: () => session.choose(session.selected!.owner!),
                child: Text(toolCopy('parentOwner')),
              ),
            for (final n in session.tree)
              TextButton(
                onPressed: () => session.choose(n),
                child: Text(
                  '${n.identity.elementId} ${n.identity.runtimeLocator?.slotPath ?? ''}${n.visible ? '' : toolCopy('offstage')}',
                ),
              ),
            if (session.selected?.figmaUrl != null)
              TextButton(
                onPressed: () => Clipboard.setData(
                  ClipboardData(text: session.selected!.figmaUrl!),
                ),
                child: Text(toolCopy('copyFigma')),
              ),
            TextButton(
              key: const ValueKey('copy-json'),
              onPressed: session.snapshot == null
                  ? null
                  : () => Clipboard.setData(
                      ClipboardData(text: exportSnapshot(session.snapshot!)),
                    ),
              child: Text(toolCopy('copyJson')),
            ),
            Text(
              toolCopy('colorNote', arguments: {'tolerance': metricTolerance}),
            ),
            if (session.snapshot != null)
              SelectableText(
                const JsonEncoder.withIndent('  ').convert(session.snapshot),
                style: const TextStyle(
                  fontFamily: BundledTypography.outfitFamily,
                  fontFamilyFallback: BundledTypography.persianFallback,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _Highlight extends CustomPainter {
  _Highlight(this.node, this.snapshot);
  final InspectionNode? node;
  final Map<String, Object?>? snapshot;
  @override
  void paint(Canvas canvas, Size size) {
    if (node == null || !node!.visible) return;
    canvas.drawRect(
      node!.clipBounds,
      Paint()
        ..color = Colors.cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final resolved = snapshot?['resolved'] as Map?;
    final hit =
        ((resolved?['inspectionActual'] as Map?)?['value']
                as Map?)?['hitRegionInApp']
            as Map?;
    if (hit != null) {
      canvas.drawRect(
        Rect.fromLTWH(
          (hit['x'] as num).toDouble(),
          (hit['y'] as num).toDouble(),
          (hit['width'] as num).toDouble(),
          (hit['height'] as num).toDouble(),
        ),
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_Highlight oldDelegate) =>
      oldDelegate.node != node || oldDelegate.snapshot != snapshot;
}

// PHYSICAL: ruler and cap guides use simulated display coordinates.
class _FrameGuides extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white54
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Offset.zero & size, p);
    for (final x in [252.0, 600.0, 840.0]) {
      if (x > size.width) continue;
      canvas.drawLine(Offset(x, 0), Offset(x, 12), p..color = Colors.white54);
      final text = TextPainter(
        text: TextSpan(
          text: x.toInt().toString(),
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x - 24, 2));
    }
    if (size.width >= 600) {
      canvas.drawRect(
        Rect.fromLTWH((size.width - 600) / 2, 0, 600, size.height),
        Paint()
          ..color = Colors.white12
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_FrameGuides oldDelegate) => false;
}
