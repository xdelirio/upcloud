import 'package:upcloud/src/core/key_value_store.dart';

/// Persists registry data on the device: the last downloaded registry and
/// the user's edits.
///
/// Any [KeyValueStore] works; the same store can also keep the upload
/// settings of `UpCloud`.
typedef RegistryStore = KeyValueStore;

/// Keeps registry data in memory only. Useful for tests.
typedef InMemoryRegistryStore = InMemoryKeyValueStore;
