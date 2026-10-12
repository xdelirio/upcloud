import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:upcloud/ui.dart';

/// Saves the accounts as a JSON list in shared preferences.
///
/// IMPORTANT: accounts contain API keys and passwords, and shared
/// preferences are stored in plain text, in the private storage of the
/// app. Android backups are turned off in the manifest for this reason.
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
    } on Object catch (error) {
      // Fails the start instead of returning nothing: the next save would
      // overwrite every saved account.
      throw FormatException('Saved accounts cannot be read: $error');
    }
  }

  @override
  Future<void> save(List<CloudAccount> accounts) => _preferences.setString(
    key,
    jsonEncode([for (final account in accounts) account.toJson()]),
  );
}
