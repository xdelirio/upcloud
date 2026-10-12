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
     "fileUrlTemplate": "https://myhost.example/{id}.html",
     "limits": { "maxFileSizeMb": 4096 }
   }
   ```

   `fileUrlTemplate` is the public link of a file: `{id}` is replaced by
   the file id (the file code for `xvs` and `byse`, the quickkey for
   `mediafire`). It is used when the API does not return the link; open
   an uploaded file on the website to find it.

2. Bump `updatedAt` at the top of the file.
3. Bundle the registry into the app and run the tests:

   ```sh
   dart run tool/sync_registry.dart
   flutter test test/registry
   ```

Apps pick up the new entry from the remote registry on their next refresh;
the bundled copy ships with the next app release.

Rules:

- `id` is permanent: saved accounts reference it.
- Only `https` URLs: the registry decides where API keys are sent.
- Use `disabledCapabilities` for features the host turned off.
- `fileUrlTemplate` must be an `https` URL that contains `{id}`.
- Document limits you could verify (upload page, FAQ, premium page).

## Adding a driver

A driver is needed when an API differs from the existing ones.

1. Create `lib/src/drivers/<name>/`.
2. Implement a `CloudProvider` with the capability interfaces the API
   supports (`FolderBrowsing`, `FileUploading`...). Use `createDio`,
   `guardRequest` and the lenient readers in `core/http`. Mark read-only
   requests as retryable with `retryableExtraKey`; never retry writes.
3. Uploads never send bytes from the driver: an `UploadExecutor` does
   (`BackgroundUploadExecutor` in the app).
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
   `defaultCredentials`, `defaultFileUrlTemplate`, `settings`, `create`).
   Files get the link returned by the API in `CloudFile.pageUrl`, or
   `definition.fileUrl(id)` (the `fileUrlTemplate` of the entry, else the
   default of the driver) when there is none. Providers created from code
   without a registry entry must still work.
5. Add it to `builtInDrivers` and export it from `lib/upcloud.dart`.
6. Add tests with recorded JSON fixtures under `test/fixtures/<name>/` using
   `http_mock_adapter` for API calls. Test uploads by checking the request
   returned by `prepareUpload` and by passing fixture responses to
   `completeUpload`. Tests must not hit the network.
7. Add the provider entries to `registry/providers.json`.

## Live tests

The normal tests never hit the network. Tests tagged `live` call the real
APIs of the bundled providers with your accounts, to check that the
drivers still match them. They are skipped by default
(`dart_test.yaml`).

1. Put the credentials in a `.env` file at the root of the repository.
   It is git-ignored: never commit it, paste it or print it. Providers
   without credentials are skipped. Environment variables win over the
   file.

   ```sh
   STREAMHG_API_KEY=<StreamHG API key>
   EARNVIDS_API_KEY=<EarnVids API key>
   BYSE_API_KEY=<Byse API key>
   MEDIAFIRE_EMAIL=<MediaFire account email>
   MEDIAFIRE_PASSWORD=<MediaFire account password>
   # Optional: your own MediaFire application instead of the public one.
   MEDIAFIRE_APPLICATION_ID=<application id>
   MEDIAFIRE_API_KEY=<application secret key>
   ```

2. Run them one file at a time (`-j 1`: the tests share the accounts
   and folders):

   ```sh
   flutter test test/live --run-skipped -j 1    # every provider with credentials
   UPCLOUD_LIVE_PROVIDERS=streamhg,byse flutter test test/live --run-skipped -j 1
   UPCLOUD_LIVE_VERBOSE=1 flutter test test/live --run-skipped -j 1    # log HTTP requests
   ```

`test/live/live_providers_test.dart` checks, for each provider, the
account info, the root listing, error mapping (invalid API key, unknown
file), `resolveFolderPath('upcloud-live-test/<run id>')` (created once,
found again by a new session without duplicates) and an upload of
`test/fixtures/live/sample.mp4` through `UpCloud.upload` with the
`dart:io` executor of `test/support` (returned file, `fileInfo`, listing).
Then it uploads 2 files to 2 providers with `uploadBatch` into the same
path, preferring providers that can delete them. Every copy of the sample
gets a unique trailing MP4 `free` box, as hosts may deduplicate identical
files. The sample lasts 10 seconds: XVS hosts reject shorter videos
("video is too short").

Cleanup deletes what the run created where the API allows it (MediaFire
moves it to its trash). StreamHG, EarnVids and Byse cannot delete files
or folders through their APIs: every run leaves its folder
`upcloud-live-test/<run id>` with the uploaded files (named
`upcloud-live-<run id>-...`), listed at the end of the output. Delete
them from the websites.

MediaFire signs in once per run, without retries: repeated failed
sign-ins can lock the account. When the sign-in fails, the test reports
the MediaFire error code and skips the rest of the MediaFire tests.

The output never contains credentials: the tests scrub every value of
the `.env` file from their logs and errors, and URLs are logged with
`redactUri`. Keep it that way when you add tests.

### Background executor

`integration_test/live_upload_test.dart` uploads a small embedded video through `BackgroundUploadExecutor` to the
first provider with credentials (StreamHG, EarnVids, Byse, then
MediaFire; `UPCLOUD_LIVE_PROVIDERS` restricts the choice), and deletes it
when the API allows it. It is tagged `live` and skipped by
`dart_test.yaml`, so `flutter test integration_test` does not even launch
it (macOS cannot start the app twice in one run). Run it on its own, with
the credentials passed as defines:

```sh
flutter test integration_test/live_upload_test.dart -d macos \
  --run-skipped --dart-define-from-file=.env
flutter clean
```

Defines are compiled into the app: `flutter clean` removes the build
artifacts that contain them (`build/`, `.dart_tool/`,
`macos/Flutter/ephemeral/`). Without defines the test skips itself.

## Code style

- Everything in the repository is written in English.
- `very_good_analysis` lints; run `flutter analyze`.
- `dart format` before committing.
- Generated code (`*.freezed.dart`, `*.g.dart`) is committed: run
  `tool/gen.sh` after changing freezed or json_serializable
  classes.
