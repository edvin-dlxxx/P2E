// Compatibility entrypoint: the viewer now uses generated Flutter localization.
import 'generate_viewer_localizations.dart' as viewer;

Future<void> main(List<String> args) => viewer.main(args);
