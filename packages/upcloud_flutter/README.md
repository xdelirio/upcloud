# upcloud_flutter

Flutter widgets and controllers for [upcloud](https://pub.dev/packages/upcloud):
build a multi-cloud file manager with a few widgets.

- **Background uploads**: `BackgroundUploadExecutor` sends the bytes with
  [background_downloader](https://pub.dev/packages/background_downloader),
  so uploads keep running while the app is in the background, with
  localized system notifications (progress, complete, failed) that also
  let long uploads survive on Android.
- **`UpCloudFlutter.create`**: an `UpCloud` wired for Flutter in one call
  (background uploads, registry data and upload settings saved with
  shared_preferences).
- **`UploadComposer`**: batch uploads, several files to several accounts
  into the same folder path, with pre-flight checks against the provider
  limits.
- **`UploadSettingsForm`**: simultaneous uploads, automatic retries, free
  storage check, auto-clear, default folder and visibility.
- **`BackupSection`**: export the accounts, providers and settings to an
  encrypted file and import them on another device (merge or replace).
- **`CloudBrowser`**: breadcrumbs, pull-to-refresh, infinite scroll, list and
  grid layouts, multi-selection, search, and actions that only appear when
  the provider supports them (create folder, rename, move, delete, copy
  the file link, upload files, upload from URL).
- **`TransferList` / `TransferTile`**: upload queue with progress, speed,
  automatic retries ("Retrying (1/2)"), cancel/retry/remove, localized
  errors, and batches grouped under a header with their overall progress.
- **`AccountForm`**: provider dropdown plus the credential fields of the
  selected provider (generated from its `CredentialSchema`), in one screen.
  Also **`AccountList`**, **`ProviderPicker`** and **`CapabilityChips`**.
- **`ProviderList`** and **`ProviderEditor`**: manage the provider registry
  (enable, edit domains, file link template, limits and driver settings,
  reset, add custom providers, check for registry updates).
- `ChangeNotifier` controllers with immutable state:
  `CloudBrowserController`, `TransfersController`, `UploadComposerController`,
  `AccountsController`, `ProvidersController`.
- Material 3, customizable with builders and the `UpCloudTheme` extension.
- English and Spanish strings (`UpCloudLocalizations`).

`package:upcloud_flutter/upcloud_flutter.dart` also exports
`package:upcloud/upcloud.dart`.

## Getting started

```dart
import 'package:flutter/material.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final upcloud = UpCloudFlutter.create(
    accounts: MySecureAccountStore(), // Implement AccountStore.
  );
  await upcloud.init(); // Registry, accounts and upload settings.
  runApp(UpCloudScope(upcloud: upcloud, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: const [
      UpCloudLocalizations.delegate,
      // GlobalMaterialLocalizations.delegate, ...
    ],
    supportedLocales: UpCloudLocalizations.supportedLocales,
    home: const AccountsScreen(),
  );
}
```

`UpCloudLocalizations.of` falls back to English when the delegate is not
registered.

### `UpCloudFlutter.create`

```dart
final upcloud = UpCloudFlutter.create(
  accounts: MySecureAccountStore(), // Required: accounts hold secrets.
  store: myKeyValueStore, // Default: SharedPreferencesKeyValueStore().
  providers: [myCustomProvider], // Definitions written in code.
  registryUrl: Uri.parse('https://example.com/providers.json'),
  useRemoteRegistry: true,
  uploadExecutor: myExecutor, // Default: BackgroundUploadExecutor().
  notifications: const UploadNotifications(), // Of the default executor.
  optionsBuilder: (account, provider) => ProviderOptions(logger: log),
);
```

It creates a `ProviderRegistry(store: store)` and passes the same store as
the `settingsStore`, so registry downloads, provider edits, upload
settings and recent folder paths are persisted together. None of them
contain secrets; accounts do, so their store is always explicit (use
secure storage). `upcloud.dispose()` also disposes the registry created
here.

`SharedPreferencesKeyValueStore` is a `KeyValueStore` on
`SharedPreferencesAsync`, with an optional `keyPrefix`.

## Background uploads

`BackgroundUploadExecutor` is the `UploadExecutor` of Flutter apps
(`UpCloudFlutter.create` uses it):

```dart
final upcloud = UpCloud(uploadExecutor: BackgroundUploadExecutor());
```

- `multipart` requests send the form fields, then the file part (named
  `UploadRequest.fileField`, with the `UploadSource.name` as file name)
  last. `binary` requests send the file as the body, with the request
  headers; its `Content-Type` header (or the type guessed from the name)
  is the file type and no `Content-Disposition` header is added unless the
  request has one. The HTTP method and headers of the request are used;
  `UploadRequest.context` is never sent.
- background_downloader never retries (`retries: 0`): the
  `TransferManager` retries by preparing the request again.
- `UploadSource.file` uploads from its path. `UploadSource.bytes` and
  `UploadSource.stream` are written to a temporary file first, deleted
  when the upload ends (success, failure or cancellation). A multipart
  upload whose source name differs from the file name on disk goes through
  a temporary link (or copy) with that name. Leftovers of killed apps
  older than a day are removed on the next upload.
- Every response is returned, including `4xx`/`5xx` ones with their body,
  so providers can read the error message. On Android background_downloader
  reports the error body in the exception description, on iOS and desktop
  in `responseBody`; both are handled. When the server sends an error with
  an empty body, the body may be the HTTP reason phrase instead.
- Progress is reported from the known file size.
- Errors: `CancelledException` right after the cancellation token fires
  (the background task is cancelled too), `NetworkException` when no
  response arrives (including when the device is offline:
  background_downloader would hold the task, so it is cancelled and the
  queue decides whether to retry), `NotFoundException` when the source
  cannot be read.

Limitations:

- **Web is not supported** by background_downloader: the executor throws
  `UnsupportedOperationException`. Use another `UploadExecutor` on the web.
- Uploads survive the app going to the background, not the app being
  killed (the upload queue lives in memory).
- iOS stops background transfers after 4 hours by default. On Android,
  see [Notifications](#notifications) for uploads longer than about
  10 minutes.
- Only `GET`, `POST`, `HEAD`, `PUT`, `DELETE` and `PATCH` requests, and no
  empty `binary` bodies.

See [Platform setup](#platform-setup) for the Android manifest, the iOS
app delegate and the macOS entitlement.

### Notifications

On Android and iOS, uploads show system notifications (desktop platforms
show none): the file name and a progress bar while running (Android; iOS
shows no progress), then "Upload complete" or "Upload failed". Tapping a
notification opens the app. On Android the running notification has a
Cancel button (added by background_downloader): it cancels that upload,
which then shows as cancelled in the transfer queue and can be retried.
There is no pause button, as uploads cannot resume.

```dart
final executor = BackgroundUploadExecutor(
  notifications: const UploadNotifications(
    running: UploadNotificationText('Uploading {displayName}', '{progress}'),
    complete: UploadNotificationText('Done', '{displayName}'),
    error: UploadNotificationText('Failed', '{displayName}'),
    grouped: false, // true: one notification for all uploads.
    allowLongUploads: true,
    requestPermission: true,
  ),
);
executor.notifications = UploadNotifications.disabled; // Any time.
```

- **Texts** use the tokens of background_downloader: `{displayName}` (the
  file name), `{progress}` (Android only), and `{numFinished}`,
  `{numFailed}`, `{numTotal}` for grouped notifications. English by
  default; `UploadNotifications.localized(UpCloudLocalizations.of(context))`
  gives English or Spanish, and `LocalizedUploadNotifications` keeps the
  texts of an executor in the language of the app:

  ```dart
  MaterialApp(
    builder: (context, child) => LocalizedUploadNotifications(
      executor: executor, // The one given to UpCloudFlutter.create.
      child: child!,
    ),
  );
  ```

  Uploads started afterwards use the new texts. The Android Cancel button
  and notification channel use string resources in the device language
  (see [Platform setup](#platform-setup)); on iOS the Cancel label is
  `UploadNotifications.cancelLabel`.
- **Permission**: the first upload asks for the notification permission
  (Android 13+, iOS) when it was not granted (`requestPermission`).
  Uploads work whatever the answer.
- **Long uploads on Android**: Android stops regular background work after
  about 10 minutes, and uploads cannot pause and resume. With notifications
  enabled and allowed (and `allowLongUploads`), uploads run as
  user-initiated data transfers on Android 14+ (task priority 0) and in a
  foreground service before (background_downloader's
  `Config.runInForeground`), which have no such limit. If the user denies
  the notification permission, uploads run as regular background work:
  Android stops the ones that take longer than about 10 minutes, and the
  transfer queue retries them from the start (a `NetworkException`).
- **Uploads must start while the app is visible** to get that protection:
  Android only allows scheduling user-initiated transfers, and starting
  foreground services, from a visible app. Uploads that start while the app
  is in the background (queued uploads waiting for a free slot, automatic
  retries) run as regular background work, limited to about 10 minutes.
  To send many long uploads, raise the simultaneous uploads so they all
  start before the user leaves the app.
- **Grouped** (`grouped: true`): one notification for all the uploads
  running at the same time ("Uploading files", `2 of 5 done`). Its counts
  only include the uploads already handed to the system (the queue starts
  the others as slots free up), its progress bar counts finished uploads
  (no bytes), and its Cancel button cancels the running uploads, not the
  queued ones. One notification per upload is the default.
- Notifications describe the transfer of the bytes: the provider may still
  reject the file when completing the upload; the transfer queue has the
  final state. A failed upload the queue retries shows a new running
  notification.
- `Config.runInForeground` is global in background_downloader: it also
  applies to other tasks of your app that have a running notification.
- Once the file is sent, the executor waits up to `responseTimeout`
  (5 minutes by default) for the server's answer. A slower server causes a
  `NetworkException` and the queue retries the upload, which may upload
  the file twice: raise `BackgroundUploadExecutor(responseTimeout: ...)`
  if your servers need it. It is background_downloader's global
  `Config.requestTimeout`, so it also applies to the app's other tasks.
- On iOS the first upload waits for the answer to the permission prompt
  before it starts.

## Platform setup

**Android** (`android/app/src/main/AndroidManifest.xml`): Kotlin 2.1+ and

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.INTERNET" />
    <!-- Upload notifications (asked at runtime on Android 13+). -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <!-- Long uploads: foreground service (Android 13 and older)... -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission
        android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />
    <!-- ...and user-initiated data transfers (Android 14+). -->
    <uses-permission android:name="android.permission.RUN_USER_INITIATED_JOBS" />
    <application ...>
        <service
            android:name="androidx.work.impl.foreground.SystemForegroundService"
            android:foregroundServiceType="dataSync"
            tools:node="merge" />
        <service
            android:name="com.bbflight.background_downloader.UIDTJobService"
            android:permission="android.permission.BIND_JOB_SERVICE"
            android:exported="true"
            android:foregroundServiceType="dataSync" />
    </application>
</manifest>
```

Without the permissions, uploads still work but Android stops the ones
longer than about 10 minutes. Optionally translate the Cancel button and
the notification channel with string resources, e.g.
`android/app/src/main/res/values-es/strings.xml`:

```xml
<resources>
    <string name="bg_downloader_cancel">Cancelar</string>
    <string name="bg_downloader_notification_channel_name">Subidas</string>
    <string name="bg_downloader_notification_channel_description">Progreso
        de las subidas</string>
</resources>
```

(the default channel name is "Downloads", so set at least
`values/strings.xml`).

**iOS**: nothing is required to upload (HTTPS only, by App Transport
Security). To show notifications and handle taps, set the notification
delegate in `AppDelegate.swift`:

```swift
import UserNotifications

// In application(_:didFinishLaunchingWithOptions:)
UNUserNotificationCenter.current().delegate = self
```

background_downloader can request other permissions (photo library): if
you do not use them, set `BYPASS_PERMISSION_IOSADDTOPHOTOLIBRARY=1` and
`BYPASS_PERMISSION_IOSCHANGEPHOTOLIBRARY=1` when building (see its
documentation) so App Store review does not ask for their `Info.plist`
descriptions.

**macOS**: the `com.apple.security.network.client` entitlement.

## Batch uploads

`UploadComposer` is a complete "Upload" screen: files (added through your
own file picker), accounts grouped by provider, destination folder path
(e.g. `Movies/2026`, prefilled with the default folder of the settings,
recent paths as suggestions) and visibility.

```dart
UploadComposer(
  // The package does not depend on a file picker.
  onPickFiles: () async => [UploadSource.file(path)],
  onSubmitted: (batch) => showTransfers(),
);
```

- The folder is looked up by name in every selected account and created
  when missing; an empty path is the root folder.
- Pre-flight checks use each provider's `limits.check`: files that are
  too large or of a type the provider does not accept are flagged on the
  file and listed before submitting, and never queued for that provider
  (`UpCloud.uploadBatch(skip: ...)`); the other combinations are uploaded.
- The visibility (provider default, public or private) starts with the
  default of the settings and is passed to `uploadBatch` explicitly, so
  "Provider default" really keeps each provider's default.
- The account selection is remembered in memory for the app session.
- Pass an `UploadComposerController` to drive it from outside (e.g. your
  own submit button with `showSubmitButton: false` and
  `submitComposer(controller, onSubmitted: ...)`).

## Upload settings

```dart
SingleChildScrollView(
  padding: const EdgeInsets.all(16),
  child: UploadSettingsForm(), // Uses UpCloudScope.of(context).
);
```

The form reads `upcloud.settings`, saves every change with
`upcloud.updateSettings` (the folder field is debounced) and follows
`upcloud.settingsChanges`. Its sections use `UpCloudSection`, which you
can reuse for your own settings.

## Backups

`BackupSection` exports the configuration of `UpCloud` (accounts with
their credentials, provider edits, upload settings and recent folders) as
an encrypted file, and imports it. See the [Backups section of
upcloud](../upcloud/README.md#backups) for the file format.

```dart
BackupSection(
  // upcloud_flutter reads and writes no files: use your file plugin, e.g.
  // file_picker.
  onSave: (json, suggestedFileName) async =>
      await FilePicker.saveFile(
        fileName: suggestedFileName, // upcloud-backup-2026-09-28.json
        bytes: utf8.encode(json),
      ) !=
      null, // false when the user cancelled.
  onOpen: () async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return null;
    return utf8.decode(await files.first.readAsBytes());
  },
  // Preferences of your app travel in the backup too.
  exportExtra: () => {'themeMode': themeMode.name},
  onImportedExtra: (extra) => restorePreferences(extra),
);
```

- **Export** asks for a password twice (at least 8 characters, with a
  strength hint and a warning that a lost password cannot be recovered),
  encrypts the backup while showing progress and calls `onSave`.
- **Import** shows when the backup was made, asks for its password (a
  wrong one can be retried) and whether to **merge** it with the current
  configuration or **replace** it, which asks for a confirmation. A
  summary lists what changed. Files that are not backups, are damaged or
  come from a newer version get a clear message.

`PasswordStrength.of(password)` is the estimate behind the strength hint.

## Accounts

```dart
// Choose the provider and enter its credentials on one screen. The
// account is verified before saving.
AccountForm(onAdded: (account) => Navigator.pop(context, account));

// Or ask only for the credentials of a given provider.
AccountForm(provider: provider, onAdded: onAdded);

// Saved accounts with connection status and storage.
AccountList(onTap: (account) => openBrowser(account.id));
```

## Browsing files

```dart
CloudBrowser(
  accountId: account.id,
  // Uploads go to the open folder.
  onPickFiles: () async => [UploadSource.file(path)],
)
```

Pass your own controller to drive the browser from the app:

```dart
final controller = CloudBrowserController.forAccount(upcloud, account.id);
await controller.openFolder(folder);
controller.upload([UploadSource.bytes(bytes, name: 'photo.jpg')]);
await controller.createFolder('Reports');
```

Errors are `UpCloudException`s: loading errors live in
`controller.state.error`, and actions throw them (and store them in
`state.actionError`). Use `UpCloudLocalizations.of(context).errorMessage(e)`
to show them.

## Transfers

```dart
TransferList(); // Uses UpCloudScope.of(context).transfers.

final transfers = TransfersController(upcloud.transfers);
transfers.clearFinished();
```

Uploads of the same batch are grouped under a `TransferBatchHeader`: files
and accounts, destination folder, overall progress, done/failed counts
and actions to cancel the batch, retry its failed uploads and clear the
finished ones (`TransfersController.cancelBatch`, `retryFailed`,
`clearBatch`). `TransfersState.batches` exposes the same aggregation.
Set `groupBatches: false` to list every upload on its own.

## Providers

Providers are data in `upcloud.registry`. Let users manage them:

```dart
ProviderList(); // Uses UpCloudScope.of(context).registry.

// Or drive the registry yourself.
final providers = ProvidersController(upcloud.registry);
await providers.setEnabled('byse', enabled: false);
await showProviderEditor(context, controller: providers); // New provider.
```

## Customization

- Builders: `CloudBrowser.entryBuilder`, `emptyBuilder`, `errorBuilder`,
  `loadingBuilder`, `TransferList.itemBuilder`, `AccountList.itemBuilder`,
  `ProviderPicker.itemBuilder`.
- Extra actions: `CloudBrowser.actions` ("New" menu) and
  `CloudBrowser.entryActions` (per entry).
- Theme (sections and batch cards follow the `CardThemeData` too):

```dart
ThemeData(
  extensions: [
    UpCloudTheme.fromColorScheme(scheme).copyWith(folderColor: Colors.amber),
  ],
);
```

## Testing

`package:upcloud/testing.dart` provides `FakeUploadExecutor`, an
in-memory provider and `inMemoryDemo`, so widgets can be tested without
credentials or network:

```dart
final upcloud = UpCloud(
  uploadExecutor: FakeUploadExecutor(),
  registry: ProviderRegistry(useRemote: false),
  providers: [inMemoryDemo],
);
```

## Example

[`example/`](example) is a complete file manager: accounts, browser,
batch uploads, a transfer queue, upload and app settings, backups, and
provider management. Its integration test runs `BackgroundUploadExecutor`
against a local HTTP server:

```sh
cd example && flutter test integration_test -d macos
```
