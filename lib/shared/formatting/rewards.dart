import 'package:intl/intl.dart' show NumberFormat;

import 'digits.dart';

/// Display-only formatting. Wire identifiers are never passed through this.
String formatWelcomeBonus(
  int points, {
  required String languageCode,
}) => localizedDigits(
  '+${NumberFormat.decimalPattern('en').format(points).replaceAll(',', languageCode == 'fa' ? '٬' : ',')}',
  languageCode: languageCode,
);
