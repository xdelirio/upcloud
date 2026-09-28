## 0.1.0-dev.1

Unpublished.

* `BackgroundUploadExecutor`: the `UploadExecutor` of Flutter apps, based
  on background_downloader (multipart and binary requests, progress,
  cancellation, error responses with their body, temporary files for
  bytes and streams). Not available on the web.
* Upload notifications on Android and iOS (`UploadNotifications`,
  `UploadNotificationText`): progress, complete and failed, one per upload
  or grouped, localizable (`UploadNotifications.localized`,
  `LocalizedUploadNotifications`, en/es texts). With notifications,
  Android runs uploads as user-initiated data transfers (14+) or in a
  foreground service, so uploads longer than about 10 minutes survive in
  the background. The notification permission is requested on the first
  upload.
* `UpCloudFlutter.create` (with `notifications`): an `UpCloud` with
  background uploads and the registry data and upload settings saved in a
  `KeyValueStore` (`SharedPreferencesKeyValueStore` by default).
* `UploadComposer` and `UploadComposerController`: batch uploads of
  several files to several accounts into a folder path, with pre-flight
  checks against the provider limits.
* `UploadSettingsForm` (and `VisibilitySelector`): edits and saves the
  upload settings.
* `BackupSection`: exports the configuration as an encrypted backup
  (password dialog with confirmation, strength hint and warning) and
  imports it (file date, password with retry, merge or replace after a
  confirmation, summary), with `exportExtra`/`onImportedExtra` for the
  app's own preferences. Files are read and written by the app
  (`onSave`, `onOpen`). Also `PasswordStrength`.
* `UpCloudSection`: titled group of rows on a card.
* `CloudBrowser` (with optional list `padding`), `CloudEntryTile`,
  `CloudBreadcrumbs` and `showCloudFolderPicker`.
* `TransferList` (uploads of a batch grouped under a
  `TransferBatchHeader`) and `TransferTile` (shows automatic retries).
* `AccountForm`: provider dropdown and the credential fields of the
  selected provider on one screen (or a fixed `provider`).
* `AccountList` with connection status and a storage usage bar.
* Compact `ProviderPicker` (icon and name; `showDetails` for more) and
  `CapabilityChips`. `ProviderAvatar` shows PNG/ICO and SVG provider icons.
* `ProviderList`, `ProviderEditor` and `showProviderEditor` to manage the
  provider registry.
* `CloudBrowserController`, `TransfersController` (with batch actions and
  `TransfersState.batches`), `AccountsController` and
  `ProvidersController`.
* `UpCloudScope`, `UpCloudTheme` (with `warningColor`) and
  `UpCloudLocalizations` (en, es).
