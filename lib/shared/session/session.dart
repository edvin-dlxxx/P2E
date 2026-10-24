import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session.g.dart';

/// Frontend read model only. Token acquisition/storage belongs to future work.
enum SessionStatus { signedOut, signedIn, expired }

@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  @override
  SessionStatus build() => SessionStatus.signedOut;

  void update(SessionStatus status) => state = status;
}
