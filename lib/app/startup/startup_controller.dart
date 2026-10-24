import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../shared/session/session.dart';

part 'startup_controller.g.dart';

enum StartupState { initializing, sessionCheck, entry, ready }

/// Architecture §11.3: gates derive only from shared read models.
@riverpod
class StartupController extends _$StartupController {
  int _generation = 0;

  @override
  StartupState build() {
    final session = ref.watch(sessionControllerProvider);
    final generation = ++_generation;
    scheduleMicrotask(() {
      if (!ref.mounted || generation != _generation) return;
      state = StartupState.sessionCheck;
      scheduleMicrotask(() {
        if (!ref.mounted || generation != _generation) return;
        state = session == SessionStatus.signedIn
            ? StartupState.ready
            : StartupState.entry;
      });
    });
    return generation == 1
        ? StartupState.initializing
        : StartupState.sessionCheck;
  }
}
