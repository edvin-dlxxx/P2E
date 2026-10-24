import 'package:p2e_design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'l10n/generated/viewer_localizations.dart';
import 'viewer_fonts.dart';
import 'viewer_shell.dart';
import 'viewer_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DevelopmentViewer());
}

class DevelopmentViewer extends StatefulWidget {
  const DevelopmentViewer({
    super.key,
    this.initialLocale = const Locale('fa'),
    this.devicePlatform,
    this.deviceLocales,
    this.skinOverride,
    this.onSkinChanged,
  });
  final TargetPlatform? devicePlatform;
  final List<Locale>? deviceLocales;
  final Locale initialLocale;
  final SkinDefinition? skinOverride;
  final ValueChanged<SkinDefinition>? onSkinChanged;
  @override
  State<DevelopmentViewer> createState() => _DevelopmentViewerState();
}

class _DevelopmentViewerState extends State<DevelopmentViewer> {
  SkinDefinition skin = productSkin;
  late Locale locale = widget.initialLocale;
  late final fonts = ViewerFonts.ensureLoaded();
  Widget shell() => ViewerShell(
    skin: widget.skinOverride ?? skin,
    onSkin: (value) {
      setState(() => skin = value);
      widget.onSkinChanged?.call(value);
    },
    locale: locale,
    onLocale: (value) => setState(() => locale = value),
  );
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: ViewerLocalizations.supportedLocales,
    // D-052: explicit Viewer language choice still wins over neutral OS inputs.
    localeListResolutionCallback: (osLocales, supported) =>
        basicLocaleListResolution([
          locale,
          ...?widget.deviceLocales,
          ...?osLocales,
        ], supported),
    localizationsDelegates: ViewerLocalizations.localizationsDelegates,
    theme: ViewerTheme.build(persian: locale.languageCode == 'fa').copyWith(
      extensions: [SkinTheme(widget.skinOverride ?? skin)],
      platform: widget.devicePlatform,
    ),
    home: ViewerFonts.loaded
        ? shell()
        : FutureBuilder<void>(
            future: fonts,
            builder: (context, snapshot) {
              final l = ViewerLocalizations.of(context);
              if (snapshot.hasError) {
                return Scaffold(body: Center(child: Text(l.fontError)));
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return Scaffold(body: Center(child: Text(l.loading)));
              }
              return shell();
            },
          ),
  );
}
