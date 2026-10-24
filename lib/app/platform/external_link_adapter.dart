import 'package:url_launcher/url_launcher.dart';

import '../../core/errors/app_failure.dart';
import '../../shared/platform/external_links.dart';
import '../config/app_config.dart';

/// One platform adapter for both native targets. url_launcher is used only to
/// hand configured HTTPS legal URLs to the system browser; no network client.
final class SystemExternalLinks implements ExternalLinkPort {
  const SystemExternalLinks(this.config);
  final AppConfig config;
  @override
  Future<Result<void>> open(ExternalLink link) async {
    final raw = link == ExternalLink.terms
        ? config.termsUrl
        : config.privacyUrl;
    if (raw.isEmpty) return const Failure(BusinessFailure('url_missing'));
    final uri = Uri.tryParse(raw);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return const Failure(BusinessFailure('url_failed'));
    }
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication)
          ? const Success(null)
          : const Failure(BusinessFailure('url_failed'));
    } catch (_) {
      return const Failure(BusinessFailure('url_failed'));
    }
  }
}
