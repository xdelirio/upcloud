# Contributing

## Adding a provider that uses an existing driver

Most video hosts run the XVideoSharing script (`xvs` driver) and only differ
in their domain. Adding one does not require Dart code:

1. Add an entry to [`registry/providers.json`](registry/providers.json).
   Your editor validates it against
   [`providers.schema.json`](registry/providers.schema.json).

   ```json
   {
     "id": "myhost",
     "name": "MyHost",
     "driver": "xvs",
     "website": "https://myhost.example",
     "apiBase": "https://myhost.example/api",
     "limits": { "maxFileSizeMb": 4096 },
     "settings": {
       "pageUrlTemplate": "https://myhost.example/{code}.html"
     }
   }
   ```

2. Bump `updatedAt` at the top of the file.
3. Bundle the registry into the package and run the tests:

   ```sh
   dart run tool/sync_registry.dart
   (cd packages/upcloud && dart test test/registry)
   ```

Apps pick up the new entry from the remote registry on their next refresh;
the bundled copy ships with the next package release.

Rules:

- `id` is permanent: saved accounts reference it.
- Only `https` URLs: the registry decides where API keys are sent.
- Use `disabledCapabilities` for features the host turned off.
- Document limits you could verify (upload page, FAQ, premium page).

## Adding a driver

A driver is needed when an API differs from the existing ones.

1. Create `packages/upcloud/lib/src/drivers/<name>/`.
2. Implement a `CloudProvider` with the capability interfaces the API
   supports (`FolderBrowsing`, `FileUploading`...). Use `createDio`,
   `guardRequest` and the lenient readers in `core/http`. Mark read-only
   requests as retryable with `retryableExtraKey`; never retry writes.
3. Uploads never send bytes from the driver: an `UploadExecutor` does
   (background uploads in Flutter apps).
   - `prepareUpload(file, options:)` checks `limits`, calls the API if
     needed (upload server, session token...) and returns an
     `UploadRequest`: the URL, `multipart` fields (the executor adds the
     file part last, named `fileField`) or a `binary` body with its
     headers, and a `context` with whatever `completeUpload` needs. It is
     persisted as JSON, so keep `context` small and made of strings.
   - `completeUpload(request, response)` reads the `UploadResponse` (any
     HTTP status: parse the API error of the body first, then fall back to
     `uploadResponseException`) and returns the `CloudFile`. Errors found
     after the server accepted the file should carry the HTTP status of
     the response (`ProviderException.statusCode`) so `TransferManager`
     does not upload the file again.
4. Extend `CloudDriver` (`id`, `capabilities`, `defaultLimits`,
   `defaultCredentials`, `settings`, `create`).
5. Add it to `builtInDrivers` and export it from `lib/upcloud.dart`.
6. Add tests with recorded JSON fixtures under `test/fixtures/<name>/` using
   `http_mock_adapter` for API calls. Test uploads by checking the request
   returned by `prepareUpload` and by passing fixture responses to
   `completeUpload`. Tests must not hit the network.
7. Add the provider entries to `registry/providers.json`.

## Code style

- Everything in the repository is written in English.
- `very_good_analysis` lints; run `dart analyze` / `flutter analyze`.
- `dart format` before committing.
- Generated code (`*.freezed.dart`, `*.g.dart`) is committed: run
  `tool/gen.sh <package>` after changing freezed or json_serializable
  classes.
