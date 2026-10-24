/// Converts Persian and Arabic-Indic input digits without changing other text.
String normalizeDigits(String value) => String.fromCharCodes(
  value.runes.map((r) {
    if (r >= 0x06f0 && r <= 0x06f9) return r - 0x06f0 + 0x30;
    if (r >= 0x0660 && r <= 0x0669) return r - 0x0660 + 0x30;
    return r;
  }),
);

String localizedDigits(String value, {required String languageCode}) {
  final ascii = normalizeDigits(value);
  if (languageCode != 'fa') return ascii;
  return String.fromCharCodes(
    ascii.runes.map((r) => r >= 0x30 && r <= 0x39 ? r - 0x30 + 0x06f0 : r),
  );
}
