import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:p2e_design_system_viewer/main.dart' show DevelopmentViewer;
import 'package:p2e_dev_inspector/inspector.dart';
import 'package:p2e_design_system/design_system.dart';
import 'package:p2e_design_system/inspection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ViewerInspectionHost());
}

class ViewerInspectionHost extends StatefulWidget {
  const ViewerInspectionHost({super.key, this.device});
  final SimulatedDevice? device;
  @override
  State<ViewerInspectionHost> createState() => _ViewerInspectionHostState();
}

class _ViewerInspectionHostState extends State<ViewerInspectionHost> {
  final hostKey = GlobalKey<InspectorHostState>();
  bool? _testSkin;
  TargetPlatform? _platform;
  List<Locale>? _locales;
  Widget? _viewer;
  Widget viewer(FrameSettings settings) {
    // Retain v1's stable app child: resizing the OS view must not force-rebuild
    // the whole catalog through a new root widget and callback identities.
    if (_viewer == null ||
        _platform != settings.platform ||
        _testSkin != settings.testSkin ||
        !listEquals(_locales, settings.locales)) {
      _platform = settings.platform;
      _testSkin = settings.testSkin;
      _locales = List.unmodifiable(settings.locales);
      _viewer = DevelopmentViewer(
        devicePlatform: _platform,
        deviceLocales: _locales,
        skinOverride: settings.testSkin ? testSkin : productSkin,
        onSkinChanged: (skin) {
          final host = hostKey.currentState;
          if (host != null) {
            host.update(
              host.settings.copyWith(testSkin: skin.id == testSkin.id),
            );
          }
        },
      );
    }
    return _viewer!;
  }

  @override
  Widget build(BuildContext context) => InspectorHost(
    key: hostKey,
    fill: true,
    device: widget.device,
    appBuilder: (settings, appKey) => MediaQuery(
      data: settings.media,
      child: SizedBox.expand(key: appKey, child: viewer(settings)),
    ),
  );
}
