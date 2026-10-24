import 'generated/tool_copy.g.dart';

/// Chrome is English-only; fixture callers explicitly select en/fa.
String toolCopy(
  String key, {
  String locale = 'en',
  Map<String, Object> arguments = const {},
}) {
  final template = toolCopyData[locale]?[key] ?? toolCopyData['en']![key];
  if (template == null) throw ArgumentError.value(key, 'key');
  var value = template;
  for (final argument in arguments.entries) {
    value = value.replaceAll('{${argument.key}}', argument.value.toString());
  }
  return value;
}
