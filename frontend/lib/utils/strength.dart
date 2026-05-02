enum Strength { strong, fair, weak }

Strength passwordStrength(String password) {
  if (password.isEmpty) return Strength.weak;
  final hasUpper = password.contains(RegExp(r'[A-Z]'));
  final hasDigit = password.contains(RegExp(r'[0-9]'));
  final hasSymbol = password.contains(RegExp(r'[^A-Za-z0-9]'));
  final variety = (hasUpper ? 1 : 0) + (hasDigit ? 1 : 0) + (hasSymbol ? 1 : 0);
  if (password.length >= 16 && variety >= 2) return Strength.strong;
  if (password.length >= 12 && variety >= 1) return Strength.fair;
  return Strength.weak;
}

String strengthLabel(Strength s) {
  switch (s) {
    case Strength.strong: return 'Strong';
    case Strength.fair:   return 'Fair';
    case Strength.weak:   return 'Weak';
  }
}
