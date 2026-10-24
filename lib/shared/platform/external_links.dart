import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_failure.dart';

enum ExternalLink { terms, privacy }

abstract interface class ExternalLinkPort {
  Future<Result<void>> open(ExternalLink link);
}

final externalLinkPortProvider = Provider<ExternalLinkPort>(
  (_) => throw StateError('ExternalLinkPort must be supplied by app/'),
);
