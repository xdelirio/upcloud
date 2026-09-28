# upcloud

Browse and upload files across many cloud and video hosting
providers from Dart and Flutter.

| Package | Description |
| --- | --- |
| [`upcloud`](packages/upcloud) | Pure Dart core: drivers, provider registry, transfers, accounts, encrypted backups. |
| [`upcloud_flutter`](packages/upcloud_flutter) | Flutter widgets and `ChangeNotifier` controllers: background uploads, batch upload composer, upload settings, backups, file browser, transfer queue, account and provider management. |
| [`example`](packages/upcloud_flutter/example) | A complete multi-provider file manager built with both packages. |

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
  Apps download it, so a domain change or a new host does not need a
  package release.
- Users can edit providers (domains, mirrors, limits) and add their own,
  based on any available driver.

## Repository layout

```
packages/upcloud/            Dart core
packages/upcloud_flutter/    Flutter UI (+ example app)
registry/providers.json      Provider registry (source of truth)
registry/providers.schema.json
tool/gen.sh                  build_runner for a package
tool/sync_registry.dart      Bundles the registry into packages/upcloud
```

## Development

```sh
dart pub get                       # resolves the whole workspace
tool/gen.sh upcloud                # code generation (freezed/json)
tool/gen.sh upcloud_flutter
(cd packages/upcloud && dart test)
(cd packages/upcloud_flutter && flutter test)
(cd packages/upcloud_flutter/example && flutter test integration_test -d macos)
(cd packages/upcloud_flutter/example && flutter run)
```

See [CONTRIBUTING.md](CONTRIBUTING.md) to add providers or drivers.

## License

[MIT](LICENSE)
