/// Persists small pieces of data on the device: registry downloads, user
/// edits of providers, upload settings...
///
/// It is a plain key/value store so apps can back it with anything
/// (shared_preferences, drift, files...). Values are JSON strings.
abstract interface class KeyValueStore {
  /// Value saved under [key], or `null`.
  Future<String?> read(String key);

  /// Saves [value] under [key]; `null` deletes it.
  Future<void> write(String key, String? value);
}

/// Keeps values in memory only. Useful for tests.
final class InMemoryKeyValueStore implements KeyValueStore {
  /// Creates a store with optional [initial] values.
  InMemoryKeyValueStore([Map<String, String> initial = const {}])
    : _values = {...initial};

  final Map<String, String> _values;

  /// Current values, for assertions in tests.
  Map<String, String> get values => Map.unmodifiable(_values);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }
}
