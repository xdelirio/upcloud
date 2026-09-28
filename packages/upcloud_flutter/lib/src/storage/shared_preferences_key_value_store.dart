import 'package:shared_preferences/shared_preferences.dart';
import 'package:upcloud/upcloud.dart';

/// A [KeyValueStore] backed by
/// [shared_preferences](https://pub.dev/packages/shared_preferences).
///
/// Keeps the provider registry data (downloads and user edits), the upload
/// settings and the recent folder paths. None of them contain secrets, but
/// shared preferences are stored in plain text: never use it for accounts.
///
/// ```dart
/// final store = SharedPreferencesKeyValueStore();
/// final upcloud = UpCloud(
///   uploadExecutor: BackgroundUploadExecutor(),
///   registry: ProviderRegistry(store: store),
///   settingsStore: store,
/// );
/// ```
final class SharedPreferencesKeyValueStore implements KeyValueStore {
  /// Creates a store. [keyPrefix] is prepended to every key.
  SharedPreferencesKeyValueStore({
    SharedPreferencesAsync? preferences,
    this.keyPrefix = '',
  }) : _preferences = preferences ?? SharedPreferencesAsync();

  /// Prefix added to the keys in shared preferences.
  final String keyPrefix;

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) => _preferences.getString('$keyPrefix$key');

  @override
  Future<void> write(String key, String? value) => value == null
      ? _preferences.remove('$keyPrefix$key')
      : _preferences.setString('$keyPrefix$key', value);
}
