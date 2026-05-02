import 'dart:math';

class PasswordGenerator {
  static const _lower = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _digits = '0123456789';
  static const _symbols = r'!@#$%^&*()-_=+[]{}|;:,.<>?';

  static String generate({
    int length = 16,
    bool uppercase = true,
    bool numbers = true,
    bool symbols = true,
  }) {
    final pool = StringBuffer(_lower);
    if (uppercase) pool.write(_upper);
    if (numbers) pool.write(_digits);
    if (symbols) pool.write(_symbols);
    final chars = pool.toString();
    final rng = Random.secure();
    return List.generate(length, (_) => chars[rng.nextInt(chars.length)]).join();
  }
}
