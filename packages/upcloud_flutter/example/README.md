# upcloud_flutter example

A multi-cloud file manager built with `upcloud_flutter`:

- **Accounts**: saved accounts with status and storage; add one with
  `AccountForm` (provider dropdown and credentials on one screen).
- **Files**: `CloudBrowser` for the selected account; the floating upload
  button sends files (picked with `file_picker`) to the open folder.
- **Upload**: `UploadComposer` sends several files to several accounts at
  once, into a folder path such as `Movies/2026`, and warns about files a
  provider would reject. Starting the uploads opens the transfers.
- **Transfers**: `TransferList`, with the uploads of each batch grouped
  under a header, cancel all and clear finished.
- **Providers**: `ProviderList` to enable, edit, reset and add providers
  and check for registry updates.
- **Settings** (glass button in the app bar): `UploadSettingsForm` for the
  upload queue, the theme and language of the app, and a `BackupSection`
  that exports and imports an encrypted backup of everything with
  `file_picker` (the theme and language travel as `extra` data).

`UpCloud` is built with `UpCloudFlutter.create` (`lib/main.dart`): uploads
run with a `BackgroundUploadExecutor` (background_downloader) whose system
notifications follow the app language (`LocalizedUploadNotifications` in
`lib/src/app.dart`), and the provider registry and upload settings are
saved with `SharedPreferencesKeyValueStore`. Accounts are saved with
`SharedPreferencesAccountStore` (`lib/src/account_store.dart`), which
stores credentials in plain text to keep the example short: use secure
storage in production apps.

The UI is Material 3 with a few
[liquid_glass_widgets](https://pub.dev/packages/liquid_glass_widgets) accents:
a floating glass tab bar on phones (a glass side rail on tablets and
desktops), primary-tinted glass action buttons and a glass settings
button, over a subtle, slowly drifting backdrop
(`lib/src/ambient_background.dart`). Content stays on regular Material
panels.

```sh
flutter run -d macos
```

Platform setup for background uploads and their notifications:

- Android: Kotlin 2.1+ (the example uses 2.4), the notification, foreground
  service and user-initiated job permissions and services in
  `android/app/src/main/AndroidManifest.xml`, and the translated Cancel
  button and channel name in `res/values*/strings.xml`.
- iOS: the notification delegate in `ios/Runner/AppDelegate.swift`.
- macOS: the network client entitlement (Debug/Profile also allow a local
  server for the integration test).

## Tests

```sh
flutter test                                  # widget tests
flutter test integration_test -d macos        # BackgroundUploadExecutor
```

The integration test starts a local `HttpServer` and checks multipart and
binary requests, error responses with their body, progress, cancellation
and network errors.
