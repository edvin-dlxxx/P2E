final class WelcomeOffer {
  const WelcomeOffer(this.points);
  final int points;
}

final class OtpChallenge {
  const OtpChallenge({
    required this.challengeId,
    required this.codeLength,
    required this.resendAfter,
    required this.expiresAt,
    required this.maskedDestination,
  });
  final String challengeId, maskedDestination;
  final int codeLength;
  final Duration resendAfter;
  final DateTime expiresAt;
}

enum EmailAccountStatus { registered, notRegistered }

enum SocialProvider { playStation, xbox, google }

/// Per-operation cancellation, not a singleton or transport dependency.
final class AuthCancellation {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  final List<void Function()> _listeners = [];
  void onCancel(void Function() listener) {
    if (_cancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }

  void removeListener(void Function() listener) => _listeners.remove(listener);
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final listener in List<void Function()>.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }
}
