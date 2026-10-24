import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/device.dart';
import '../core/problems.dart';
import 'tool_copy.dart';

class DeviceToolbar extends StatelessWidget {
  const DeviceToolbar({super.key, required this.device});
  final SimulatedDevice device;
  @override
  Widget build(BuildContext context) {
    final s = device.settings;
    Widget seg<T>(String key, List<T> all, T value, ValueChanged<T> change) =>
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(toolCopy(key)),
            SegmentedButton<T>(
              segments: [
                for (final v in all)
                  ButtonSegment(
                    value: v,
                    label: Text(
                      key == 'zoomMode'
                          ? (v == true ? '100%' : toolCopy('fitZoom'))
                          : key == 'frameMode'
                          ? toolCopy(
                              v == FrameMode.free
                                  ? 'freeMode'
                                  : 'fitWindowMode',
                            )
                          : v.toString().split('.').last,
                    ),
                  ),
              ],
              selected: {value},
              onSelectionChanged: (v) => change(v.first),
            ),
          ],
        );
    Widget flag(String key, bool value, ValueChanged<bool> change) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(toolCopy(key)),
        Switch(value: value, onChanged: change),
      ],
    );
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(toolCopy('deviceGroup')),
        seg('frameMode', FrameMode.values, device.mode, device.setMode),
        DimensionInput(
          id: 'frame-width',
          value: s.size.width,
          onChange: (v) => device.resize(v, s.size.height),
        ),
        DimensionInput(
          id: 'frame-height',
          value: s.size.height,
          onChange: (v) => device.resize(s.size.width, v),
        ),
        DropdownButton<Size>(
          key: const ValueKey('presets'),
          hint: Text(toolCopy('presets')),
          items: [
            for (final p in SimulatedDevice.presets)
              DropdownMenuItem(
                value: p,
                child: Text('${p.width.toInt()} x ${p.height.toInt()}'),
              ),
          ],
          onChanged: (v) {
            if (v != null) device.preset(v);
          },
        ),
        TextButton(
          key: const ValueKey('rotate'),
          onPressed: device.rotate,
          child: Text(
            '${toolCopy('rotate')} (${s.size.width > s.size.height ? toolCopy('landscape') : toolCopy('portrait')})',
          ),
        ),
        seg('zoomMode', [false, true], device.actualSize, (v) {
          device.actualSize = v;
          device.apply(s);
        }),
        seg(
          'deviceLocales',
          ['fa-IR', 'en-US', 'de-DE', 'fa-IR,en-US', 'en-US,fa-IR'],
          s.locales.map((l) => l.toLanguageTag()).join(','),
          (v) => device.apply(
            s.copyWith(
              locales: v.split(',').map((l) {
                final p = l.split('-');
                return Locale(p[0], p[1]);
              }).toList(),
            ),
          ),
        ),
        seg(
          'systemBrightness',
          Brightness.values,
          s.brightness,
          (v) => device.apply(s.copyWith(brightness: v)),
        ),
        Text('${toolCopy('systemScale')}: ${s.scale.toStringAsFixed(2)}'),
        SizedBox(
          width: 180,
          child: Slider(
            key: const ValueKey('device-scale'),
            min: .85,
            max: 3,
            value: s.scale,
            onChanged: (v) => device.apply(s.copyWith(scale: v)),
          ),
        ),
        for (final v in [1.0, 1.3, 2.0])
          ChoiceChip(
            label: Text('$v'),
            selected: s.scale == v,
            onSelected: (_) => device.apply(s.copyWith(scale: v)),
          ),
        for (final edge in ['top', 'bottom', 'start', 'end'])
          DimensionInput(
            id: 'inset-$edge',
            value: switch (edge) {
              'top' => s.insets.top,
              'bottom' => s.insets.bottom,
              'start' =>
                s.locale.languageCode == 'fa' ? s.insets.right : s.insets.left,
              _ =>
                s.locale.languageCode == 'fa' ? s.insets.left : s.insets.right,
            },
            onChange: (v) {
              final rtl = s.locale.languageCode == 'fa';
              device.apply(
                s.copyWith(
                  insets: s.insets.copyWith(
                    top: edge == 'top' ? v : null,
                    bottom: edge == 'bottom' ? v : null,
                    // PHYSICAL: directional control mapped to simulated display edges.
                    left: (edge == 'start' && !rtl || edge == 'end' && rtl)
                        ? v
                        : null,
                    right: (edge == 'end' && !rtl || edge == 'start' && rtl)
                        ? v
                        : null,
                  ),
                ),
              );
            },
          ),
        flag(
          'keyboard',
          s.keyboard,
          (v) => device.apply(s.copyWith(keyboard: v)),
        ),
        DimensionInput(
          id: 'keyboard-height',
          value: s.keyboardHeight,
          onChange: (v) =>
              device.apply(s.copyWith(keyboardHeight: v.clamp(0, 1400))),
        ),
        flag(
          'reduceMotion',
          s.disableAnimations,
          (v) => device.apply(s.copyWith(disableAnimations: v)),
        ),
        flag(
          'boldText',
          s.boldText,
          (v) => device.apply(s.copyWith(boldText: v)),
        ),
        flag(
          'highContrast',
          s.highContrast,
          (v) => device.apply(s.copyWith(highContrast: v)),
        ),
        seg(
          'platform',
          [TargetPlatform.android, TargetPlatform.iOS],
          s.platform,
          (v) => device.apply(s.copyWith(platform: v)),
        ),
        Text(toolCopy('devGroup')),
        ChoiceChip(
          label: Text(toolCopy('productSkin')),
          selected: !s.testSkin,
          onSelected: (_) => device.apply(s.copyWith(testSkin: false)),
        ),
        ChoiceChip(
          label: Text(toolCopy('testSkin')),
          selected: s.testSkin,
          onSelected: (_) => device.apply(s.copyWith(testSkin: true)),
        ),
      ],
    );
  }
}

class DimensionInput extends StatefulWidget {
  const DimensionInput({
    super.key,
    required this.id,
    required this.value,
    required this.onChange,
  });
  final String id;
  final double value;
  final ValueChanged<double> onChange;
  @override
  State<DimensionInput> createState() => _DimensionInputState();
}

class _DimensionInputState extends State<DimensionInput> {
  late final text = TextEditingController(
    text: widget.value.toStringAsFixed(0),
  );
  @override
  void didUpdateWidget(DimensionInput old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) text.text = widget.value.toStringAsFixed(0);
  }

  @override
  void dispose() {
    text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 110,
    child: Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            [
              LogicalKeyboardKey.arrowUp,
              LogicalKeyboardKey.arrowDown,
            ].contains(event.logicalKey)) {
          widget.onChange(
            widget.value +
                (event.logicalKey == LogicalKeyboardKey.arrowUp ? 1 : -1) *
                    (HardwareKeyboard.instance.isShiftPressed ? 10 : 1),
          );
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        key: ValueKey(widget.id),
        controller: text,
        decoration: InputDecoration(labelText: toolCopy(widget.id)),
        keyboardType: TextInputType.number,
        onSubmitted: (v) {
          final n = double.tryParse(v);
          if (n != null && n.isFinite) widget.onChange(n);
        },
      ),
    ),
  );
}

class SweepControls extends StatefulWidget {
  const SweepControls({
    super.key,
    required this.device,
    required this.runner,
    required this.frame,
    required this.onJump,
  });
  final SimulatedDevice device;
  final SweepRunner runner;
  final Future<void> Function() frame;
  final ValueChanged<Map<String, Object?>> onJump;
  @override
  State<SweepControls> createState() => _SweepControlsState();
}

class _SweepControlsState extends State<SweepControls> {
  SweepAxis axis = SweepAxis.width;
  double minW = 200, maxW = 1400, minH = 300, maxH = 1400, stepW = 4, stepH = 8;
  bool matrix = false;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.runner,
    builder: (context, _) => ListView(
      padding: const EdgeInsetsDirectional.all(12),
      children: [
        SegmentedButton<SweepAxis>(
          segments: [
            for (final v in SweepAxis.values)
              ButtonSegment(value: v, label: Text(v.name)),
          ],
          selected: {axis},
          onSelectionChanged: (v) => setState(() => axis = v.first),
        ),
        for (final row in [
          ('min-width', minW),
          ('max-width', maxW),
          ('min-height', minH),
          ('max-height', maxH),
          ('width-step', stepW),
          ('height-step', stepH),
        ])
          DimensionInput(
            id: row.$1,
            value: row.$2,
            onChange: (v) => setState(() {
              switch (row.$1) {
                case 'min-width':
                  minW = v;
                case 'max-width':
                  maxW = v;
                case 'min-height':
                  minH = v;
                case 'max-height':
                  maxH = v;
                case 'width-step':
                  stepW = v.clamp(1, 1400);
                case 'height-step':
                  stepH = v.clamp(1, 1400);
              }
            }),
          ),
        CheckboxListTile(
          title: Text(toolCopy('sweepMatrix')),
          value: matrix,
          onChanged: (v) => setState(() => matrix = v!),
        ),
        TextButton(
          onPressed: widget.runner.running
              ? () => widget.runner.cancelled = true
              : () => widget.runner.run(
                  SweepPlan(
                    axis: axis,
                    minWidth: minW,
                    maxWidth: maxW,
                    minHeight: minH,
                    maxHeight: maxH,
                    widthStep: stepW,
                    heightStep: stepH,
                    scales: matrix ? [1, 1.3, 2] : [],
                    locales: matrix
                        ? [
                            [const Locale('fa', 'IR')],
                            [const Locale('en', 'US')],
                          ]
                        : [],
                  ),
                  widget.frame,
                ),
          child: Text(toolCopy(widget.runner.running ? 'cancel' : 'runSweep')),
        ),
        Text('${toolCopy('sweepSamples')}: ${widget.runner.completed}'),
        TextButton(
          onPressed: () => Clipboard.setData(
            ClipboardData(text: widget.runner.exportJson()),
          ),
          child: Text(toolCopy('copyJson')),
        ),
        for (final r in widget.runner.ranges)
          ListTile(
            title: Text(
              '${r['kind']} / ${r['elementId'] ?? toolCopy('unavailable')}',
            ),
            subtitle: Text(
              '${r['firstWidth']}..${r['lastWidth']} x ${r['firstHeight']}..${r['lastHeight']}',
            ),
            onTap: () => widget.onJump(r),
          ),
      ],
    ),
  );
}
