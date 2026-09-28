import 'dart:math' as math;

import 'package:upcloud/upcloud.dart';

/// A rough estimate of how hard a password is to guess, shown while the
/// user chooses the password of a backup.
///
/// It only looks at the length and the kinds of characters: it is a hint,
/// not a guarantee.
enum PasswordStrength {
  /// Shorter than the minimum length.
  tooShort,

  /// Easy to guess.
  weak,

  /// Acceptable.
  fair,

  /// Good.
  good,

  /// Hard to guess.
  strong;

  /// Estimates the strength of [password]: [tooShort] below [minLength]
  /// characters, otherwise from its length and character variety (about
  /// 40, 60 and 80 bits of brute force entropy for fair, good and strong).
  /// Passwords made of fewer than 4 different characters are [weak].
  static PasswordStrength of(
    String password, {
    int minLength = UpCloud.minBackupPasswordLength,
  }) {
    final chars = password.runes.toList();
    if (chars.length < minLength) return tooShort;
    if (chars.toSet().length < 4) return weak;
    var pool = 0;
    if (password.contains(_lower)) pool += 26;
    if (password.contains(_upper)) pool += 26;
    if (password.contains(_digit)) pool += 10;
    if (password.contains(_symbol)) pool += 33;
    if (chars.any((c) => c > 0x7f)) pool += 100;
    final bits = chars.length * math.log(pool) / math.ln2;
    if (bits >= 80) return strong;
    if (bits >= 60) return good;
    if (bits >= 40) return fair;
    return weak;
  }

  static final _lower = RegExp('[a-z]');
  static final _upper = RegExp('[A-Z]');
  static final _digit = RegExp('[0-9]');
  static final _symbol = RegExp(r'[\x20-\x2f\x3a-\x40\x5b-\x60\x7b-\x7e]');
}
