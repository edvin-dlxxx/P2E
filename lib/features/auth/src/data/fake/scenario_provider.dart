import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'fake_sources.dart';
part 'scenario_provider.g.dart';

@riverpod
FakeAuthScenario fakeAuthScenario(Ref ref) => FakeAuthScenario.values.byName(
  const String.fromEnvironment('FAKE_SCENARIO', defaultValue: 'success'),
);
