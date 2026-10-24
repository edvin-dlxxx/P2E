# Temporary Windows development viewer

Debug only, target lib/main_dev.dart only. This is not a product release platform.
Created with Flutter 3.47.7 after doctor confirmed Visual Studio Build Tools 2022
and Windows SDK. No toolchain installation or SDK changes were performed.

    flutter run -d windows --debug -t lib/main_dev.dart
    flutter build windows --debug -t lib/main_dev.dart --no-pub

The CMake guards reject other configurations/entrypoints. Template Windows
company metadata is development scaffolding, not an approved product identity.
The architecture checker deliberately scans Dart application sources, not this
native runner. Existing release lib/main.dart and pubspec dependencies are intact.
