import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/storage/shared_preferences_key_value_store.dart';
import 'package:upcloud_flutter/src/uploads/background_upload_executor.dart';
import 'package:upcloud_flutter/src/uploads/upload_notifications.dart';

/// Builds [UpCloud] instances wired for Flutter apps.
abstract final class UpCloudFlutter {
  /// Creates an [UpCloud] that:
  ///
  /// * uploads with a [BackgroundUploadExecutor] showing [notifications]
  ///   (or with [uploadExecutor]; pass your own [BackgroundUploadExecutor]
  ///   to change its notifications later, e.g. with
  ///   `LocalizedUploadNotifications`);
  /// * persists the provider registry (downloads and user edits), the
  ///   upload settings and the recent folder paths in [store], a new
  ///   [SharedPreferencesKeyValueStore] by default;
  /// * saves the [accounts] in the given store. Accounts contain API keys
  ///   and passwords: back it with secure storage.
  ///
  /// [providers] adds definitions written in code, [drivers] replaces the
  /// built-in drivers, [registryUrl] points to another remote registry
  /// (HTTPS) and [useRemoteRegistry] turns remote updates off.
  /// [optionsBuilder] customizes each connection (logging, proxies...).
  ///
  /// Call [UpCloud.init] before using it:
  ///
  /// ```dart
  /// final upcloud = UpCloudFlutter.create(accounts: MySecureAccountStore());
  /// await upcloud.init();
  /// runApp(UpCloudScope(upcloud: upcloud, child: const MyApp()));
  /// ```
  ///
  /// [UpCloud.dispose] also disposes the registry created here.
  static UpCloud create({
    required AccountStore accounts,
    KeyValueStore? store,
    Iterable<ProviderDefinition> providers = const [],
    Iterable<CloudDriver>? drivers,
    Uri? registryUrl,
    bool useRemoteRegistry = true,
    UploadExecutor? uploadExecutor,
    UploadNotifications notifications = const UploadNotifications(),
    ProviderOptionsBuilder? optionsBuilder,
  }) {
    final keyValues = store ?? SharedPreferencesKeyValueStore();
    return UpCloud(
      uploadExecutor:
          uploadExecutor ??
          BackgroundUploadExecutor(notifications: notifications),
      registry: ProviderRegistry(
        drivers: drivers,
        store: keyValues,
        remoteUrl: registryUrl,
        useRemote: useRemoteRegistry,
      ),
      disposeRegistry: true,
      providers: providers,
      store: accounts,
      settingsStore: keyValues,
      optionsBuilder: optionsBuilder,
    );
  }
}
