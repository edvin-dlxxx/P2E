import 'dart:convert';
import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

abstract final class PiiRedactor {
  static final _sensitiveKey = RegExp(
    r'phone|mobile|email|identifier|otp|token|authorization|password|secret|رمز|تلفن',
    caseSensitive: false,
  );
  static String text(String value) => value
      .replaceAll(RegExp(r'''[^\s<>@]+@[^\s<>@]+\.[^\s<>@]+'''), '[REDACTED]')
      .replaceAll(
        RegExp(r'Bearer\s+[^\s,;]+', caseSensitive: false),
        'Bearer [REDACTED]',
      )
      .replaceAll(
        RegExp(r'eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+'),
        '[REDACTED]',
      )
      .replaceAll(
        RegExp(
          r'''(?:token|otp|password|secret|authorization)\s*[:=]\s*[^\s,;]+''',
          caseSensitive: false,
        ),
        '[REDACTED]',
      )
      .replaceAll(
        RegExp(r'\+?[0-9۰-۹٠-٩][0-9۰-۹٠-٩ ()-]{2,}[0-9۰-۹٠-٩]'),
        '[REDACTED]',
      );

  static Object? value(Object? input) => switch (input) {
    Map() => {
      for (final entry in input.entries)
        text(entry.key.toString()): _sensitiveKey.hasMatch(entry.key.toString())
            ? '[REDACTED]'
            : value(entry.value),
    },
    Iterable() => input.map(value).toList(),
    String() => text(input),
    num() => text(input.toString()),
    null || bool() => input,
    _ => '[UNSUPPORTED]', // Never invoke arbitrary object's toString on a log path.
  };
}

/// All sinks receive redacted data; no network/crash SDK is installed.
final class AppLogger {
  AppLogger({this.minimumLevel = LogLevel.info, void Function(String)? sink})
    : _sink = sink ?? ((line) => developer.log(line, name: 'p2e'));
  final LogLevel minimumLevel;
  final void Function(String) _sink;
  void log(
    LogLevel level,
    String message, {
    Map<String, Object?> fields = const {},
  }) {
    if (level.index < minimumLevel.index) return;
    _sink(
      jsonEncode({
        'level': level.name,
        'message': PiiRedactor.text(message),
        'fields': PiiRedactor.value(fields),
      }),
    );
  }
}
