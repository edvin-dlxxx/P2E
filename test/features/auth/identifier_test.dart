import 'package:flutter_test/flutter_test.dart';
import 'package:mygame_p2e/features/auth/auth.dart';

void main() {
  for (final raw in [
    '09123456789',
    '9123456789',
    '+989123456789',
    '00989123456789',
    ' ۰۹۱۲ ۳۴۵ ۶۷۸۹ ',
    '٠٩١٢-٣٤٥-٦٧٨٩',
    '+98 912-345-6789',
    '+98 912–345–6789',
    '09351234567',
  ]) {
    test('Iranian mobile normalization: $raw', () {
      final value = IdentifierClassifier.classify(raw);
      expect(value, isA<Phone>());
      expect(
        (value as Phone).e164,
        raw.contains('0935') ? '+989351234567' : '+989123456789',
      );
    });
  }
  for (final raw in ['', ' ', '\n\t']) {
    test('empty identifier: ${raw.length}', () {
      expect(IdentifierClassifier.classify(raw), isA<Empty>());
    });
  }
  for (final raw in [
    '0912',
    '08123456789',
    '+9719123456789',
    '091234567890',
    '912345678x',
    '98 9123456789',
  ]) {
    test('invalid phone: $raw', () {
      expect(IdentifierClassifier.classify(raw), isA<Invalid>());
    });
  }
  for (final input in {
    ' USER+tag@EXAMPLE.COM ': 'USER+tag@example.com',
    'new.person@example.co.ir': 'new.person@example.co.ir',
    'u12@example.com': 'u12@example.com',
    "O'Connor@EXAMPLE.COM": "O'Connor@example.com",
    'u۱۲@EXAMPLE.COM': 'u12@example.com',
  }.entries) {
    test('email practical normalization: ${input.key}', () {
      expect(
        (IdentifierClassifier.classify(input.key) as Email).normalized,
        input.value,
      );
    });
  }
  for (final raw in [
    'a@',
    '@example.com',
    'a@@example.com',
    'a@localhost',
    '.a@example.com',
    'a..b@example.com',
    'a b@example.com',
    'a@-example.com',
    'a@example-.com',
  ]) {
    test('invalid email: $raw', () {
      expect(IdentifierClassifier.classify(raw), isA<Invalid>());
    });
  }
}
