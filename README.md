# upcloud

A multi-cloud upload manager built with Flutter: browse and upload files
across many cloud and video hosting providers from one app (Android, iOS
and macOS).

- Background uploads with system notifications, retries and a transfer
  queue.
- Batch uploads: several files to several accounts, into one folder path
  that each account finds or creates by name.
- Remote uploads (by URL) where the provider supports them.
- Account and provider management, upload settings and encrypted backups
  of the whole configuration.
- English and Spanish.

## How it works

```
registry/providers.json ──► ProviderRegistry ──► ProviderDefinition ──► CloudProvider
   (data: domains,            (bundled + remote       (per provider)       (per account,
    limits, drivers)           + user edits)                                capabilities)
                                     ▲
                    drivers (code): xvs · byse · mediafire
```

- **Drivers** implement an API once. The `xvs` driver covers every host
  running the XVideoSharing script.
- **Providers** are entries of [`registry/providers.json`](registry/providers.json).
  The app downloads it, so a domain change or a new host does not need an
  app release.
- Users can edit providers (domains, mirrors, file links, limits) and add
  their own, based on any available driver.

## Repository layout

```
lib/main.dart                App entry point
lib/src/app/                 Screens, navigation, app settings
lib/src/widgets/             Reusable widgets (browser, composer, transfers...)
lib/src/controllers/         ChangeNotifier controllers
lib/src/uploads/             Background upload executor and notifications
lib/src/drivers/             Provider APIs: xvs, byse, mediafire
lib/src/registry/            Provider registry (bundled, remote, user edits)
lib/src/transfer/            Transfer manager and batches
lib/src/{accounts,backup,core,settings}/
lib/upcloud.dart             Barrel of the core (no Flutter imports)
lib/ui.dart                  Barrel of the core plus widgets and controllers
registry/providers.json      Provider registry (source of truth)
registry/providers.schema.json
tool/gen.sh                  build_runner (freezed/json_serializable)
tool/sync_registry.dart      Bundles the registry into the app
```

## Development

```sh
flutter pub get
tool/gen.sh                              # code generation (freezed/json)
flutter analyze
flutter test
flutter test integration_test -d macos
flutter run
```

Android release builds are signed with the key described in
`android/key.properties` (git-ignored: `storeFile`, `storePassword`,
`keyAlias`, `keyPassword`); without that file they use the debug key.

Live tests against the real APIs are described in
[CONTRIBUTING.md](CONTRIBUTING.md), which also explains how to add
providers or drivers.

## License

[MIT](LICENSE)
