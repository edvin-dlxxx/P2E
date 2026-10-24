sealed class SignInIdentifier {
  const SignInIdentifier();
}

final class Phone extends SignInIdentifier {
  const Phone._(this.e164);
  final String e164;
}

final class Email extends SignInIdentifier {
  const Email._(this.normalized);
  final String normalized;
}

enum InvalidIdentifierReason { phone, email }

final class Invalid extends SignInIdentifier {
  const Invalid(this.reason);
  final InvalidIdentifierReason reason;
}

final class Empty extends SignInIdentifier {
  const Empty();
}

/// Business normalization stays in this pure domain boundary; raw editing text
/// is never modified. No shared/Flutter formatting dependency enters domain.
abstract final class IdentifierClassifier {
  static SignInIdentifier classify(String raw) {
    final text = String.fromCharCodes(
      raw.trim().runes.map(
        (r) => r >= 0x06f0 && r <= 0x06f9
            ? r - 0x06f0 + 0x30
            : r >= 0x0660 && r <= 0x0669
            ? r - 0x0660 + 0x30
            : r,
      ),
    );
    if (text.isEmpty) return const Empty();
    if (text.contains('@')) {
      final parts = text.split('@');
      if (parts.length != 2 ||
          parts[0].isEmpty ||
          parts[0].startsWith('.') ||
          parts[0].endsWith('.') ||
          parts[0].contains('..') ||
          !RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+$").hasMatch(parts[0]) ||
          !RegExp(
            r'^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?)+$',
          ).hasMatch(parts[1])) {
        return const Invalid(InvalidIdentifierReason.email);
      }
      return Email._('${parts[0]}@${parts[1].toLowerCase()}');
    }
    var number = text.replaceAll(RegExp(r'[\s\u2010-\u2015-]'), '');
    if (number.startsWith('0098')) {
      number = number.substring(4);
    } else if (number.startsWith('+98')) {
      number = number.substring(3);
    } else if (number.startsWith('0')) {
      number = number.substring(1);
    }
    if (RegExp(r'^9[0-9]{9}$').hasMatch(number)) return Phone._('+98$number');
    return const Invalid(InvalidIdentifierReason.phone);
  }
}
