import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

/// Saves the accounts as a JSON list in shared preferences.
///
/// IMPORTANT: accounts contain API keys and passwords, and shared
/// preferences are stored in plain text. This keeps the example simple;
/// production apps should keep credentials in secure storage (Keychain,
/// Android Keystore...), e.g. with `flutter_secure_storage`.
class SharedPreferencesAccountStore implements AccountStore {
  SharedPreferencesAccountStore({
    SharedPreferencesAsync? preferences,
    this.key = 'upcloud.accounts',
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  /// Preferences key holding the JSON list.
  final String key;

  final SharedPreferencesAsync _preferences;

  @override
  Future<List<CloudAccount>> load() async {
    final raw = await _preferences.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final item in list)
          CloudAccount.fromJson((item as Map).cast<String, dynamic>()),
      ];
    } on Object {
      // Corrupted or saved by an incompatible version: start again.
      return const [];
    }
  }

  @override
  Future<void> save(List<CloudAccount> accounts) => _preferences.setString(
    key,
    jsonEncode([for (final account in accounts) account.toJson()]),
  );
}
