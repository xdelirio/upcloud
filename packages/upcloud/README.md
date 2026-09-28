# upcloud

One Dart API to browse and upload files across many cloud and
video hosting providers.

- **Drivers in code, providers as data.** A driver implements an API
  (for example the XVideoSharing script used by dozens of hosts). Providers
  are entries of a JSON registry that apps download, so new domains, mirrors
  and limits reach users without a package release.
- **Capability based.** Each provider implements only what its API supports
  (folders, uploads, remote uploads, links, cloning...), and your code can
  check it at runtime.
- **Background-ready uploads.** Providers prepare the HTTP request and read
  its response; an `UploadExecutor` sends the bytes. Flutter apps get one
  based on background uploads from `upcloud_flutter`.
- **Transfers included.** A queue with global and per-account concurrency,
  progress, cancellation, automatic retries with backoff and upload
  validation against provider limits and free storage.
- **Multiple accounts** and batch uploads: several files to several
  accounts at once, into a folder path (`Movies/2026`) created on demand.
- **Upload settings** (concurrency, retries, default folder and
  visibility...) applied at runtime and persisted.
- **Share links**: uploaded and listed files carry their public link in
  `CloudFile.pageUrl`.
- **Encrypted backups** of accounts, provider edits and settings
  (Argon2id + AES-256-GCM), to move them to another device.
- Pure Dart. Flutter widgets live in
  [`upcloud_flutter`](../upcloud_flutter).

## Supported providers

| Provider | Driver | Browse | Manage | Upload | Remote upload | Notes |
| --- | --- | :-: | :-: | :-: | :-: | --- |
| StreamHG | `xvs` | ✅ | Partial¹ | ✅ | ✅ | Video files only |
| EarnVids (VidHide) | `xvs` | ✅ | Partial¹ | ✅ | ✅ | Video files only |
| Byse | `byse` | ✅ | Partial² | ✅ | ✅ | 2 GB, video files |
| MediaFire | `mediafire` | ✅ | ✅ | ✅ | ✅ | 5 GB (free plans) |

¹ StreamHG and EarnVids can create, rename and move files and folders, but
their APIs cannot delete them (`deleteFile` and `deleteFolder` are
disabled in the registry).
² Byse can create folders and move files, but not rename or delete them.

Any host running the XVideoSharing script can be added with a registry entry
(see [Adding a provider](#adding-a-provider)).

## Getting started

```sh
dart pub add upcloud
```

```dart
import 'package:upcloud/upcloud.dart';

Future<void> main() async {
  // `executor` is an UploadExecutor: see "Uploads" below.
  final upcloud = UpCloud(uploadExecutor: executor);
  await upcloud.init(); // Loads the registry, accounts and settings.

  final account = await upcloud.addAccount(
    providerId: 'streamhg',
    credentials: Credentials.apiKey('YOUR_API_KEY'),
  ); // Verifies the key with a cheap API call.

  final provider = upcloud.connect(account.id);

  // Browse
  if (provider case final FolderBrowsing browser) {
    final page = await browser.listFolder(null); // null = root folder
    for (final entry in page.items) {
      switch (entry) {
        case CloudFolder(:final name):
          print('📁 $name');
        case CloudFile(:final name, :final size):
          print('🎬 $name ($size)');
      }
    }
  }

  // Upload with progress
  final task = upcloud.upload(
    account.id,
    const UploadSource.file('/videos/intro.mp4'),
  );
  task.changes.listen((state) {
    if (state case TransferRunning(:final progress)) {
      print('${((progress.fraction ?? 0) * 100).toStringAsFixed(0)} %');
    }
  });
  final file = await task.result;
  print('Uploaded ${file.id}');

  await upcloud.dispose();
}
```

## Capabilities

Providers implement the interfaces of their API and declare the operations
they actually support in `provider.capabilities` (a `Set<Capability>`, e.g.
`createFolder`, `renameFile`, `upload`, `remoteUpload`). Always check
`supports` before offering an action: an API may support an interface only
partially.

| Interface | Operations |
| --- | --- |
| `FolderBrowsing` | `listFolder` (paginated, folders first) |
| `FolderManaging` | `createFolder`, `renameFolder`, `moveFolder`, `deleteFolder` |
| `FileManaging` | `fileInfo`, `renameFile`, `moveFile`, `deleteFile` |
| `FileSearching` | `searchFiles` |
| `FileUploading` | `prepareUpload`, `completeUpload` (see [Uploads](#uploads)) |
| `RemoteUploading` | `uploadFromUrl`, `remoteUploads`, `remoteUploadStatus`, `cancelRemoteUpload` |
| `AccountInfoProviding` | `accountInfo` (storage, premium...) |

```dart
final provider = upcloud.connect(accountId);

if (provider.supports(Capability.remoteUpload)) {
  await provider.capability<RemoteUploading>()!.uploadFromUrl(
    Uri.parse('https://example.com/video.mp4'),
  );
}

final canRename = provider.supports(Capability.renameFile);
```

Provider definitions expose `capabilities` too, so the UI can show features
before an account is connected. Registry entries can turn operations off
with `disabledCapabilities`.

## Uploads

An upload runs in three steps:

1. The provider **prepares** the HTTP request (`prepareUpload`): it may call
   its API (upload server, session token...) and returns an
   `UploadRequest` with the URL, the encoding (`multipart` form fields or a
   `binary` body), headers, and a `context` it needs later.
2. An **`UploadExecutor`** sends the request with the file and returns the
   `UploadResponse` (status, body, headers), reporting progress and
   honoring cancellation.
3. The provider **completes** the upload from the response
   (`completeUpload`): it reads the new file, maps errors, and may call its
   API again (e.g. MediaFire waits until the file is processed).

`UploadRequest` and `UploadResponse` convert to JSON, so an upload sent in
the background can be completed after the app restarts. Requests contain
credentials (API keys, session tokens): do not log them.

The core package does not send bytes itself. Flutter apps use the
executor based on
[background_downloader](https://pub.dev/packages/background_downloader)
from [`upcloud_flutter`](../upcloud_flutter), so uploads keep running in
the background. Other apps implement `UploadExecutor` (see
[`example/io_upload_executor.dart`](example/io_upload_executor.dart) for a
`dart:io` version), and tests use `FakeUploadExecutor`.

### The upload queue

`UpCloud.transfers` is a `TransferManager`. Each task is validated
against the provider limits (and the account's free storage), its folder
path is resolved, then it is prepared, executed and completed:

```dart
final task = upcloud.upload(
  account.id,
  const UploadSource.file('/videos/intro.mp4'),
  folderPath: 'Movies/2026', // Optional: found by name or created.
);
task.changes.listen((state) => print('${task.attempt}: $state'));
final file = await task.result;
print(file.pageUrl); // Every uploaded file carries its share link.

upcloud.transfers.cancel(task);
upcloud.transfers.retry(task); // Failed or cancelled tasks.
```

- Files that are too large, have a forbidden extension or do not fit in
  the account fail with `UploadRejectedException` before any byte is
  sent.
- Transient failures (`NetworkException`, `RateLimitedException`, and
  `ProviderException` without status or with a `5xx` status) are retried
  with exponential backoff (1 s, 2 s, 4 s... up to 30 s, or the
  `retryAfter` of the rate limit), running the three steps again.
  Authentication errors, rejected or missing files, quotas and
  cancellations are never retried. `UploadTask.attempt` tells which
  attempt is running.
- Errors reported after the server accepted the file carry the HTTP
  status of the response, so the file is not uploaded twice.

Upload sources: `UploadSource.file(path)`, `UploadSource.bytes(bytes, name:)`
(works on web) and `UploadSource.stream(open, name:, length:)`.

### Batch uploads and folder paths

Upload several files to several accounts at once, into the same folder
path in each of them:

```dart
final batch = upcloud.uploadBatch(
  files: [UploadSource.file(a), UploadSource.file(b)],
  accountIds: [streamHg.id, byse.id, mediaFire.id],
  folderPath: 'Movies/2026',
);
batch.changes.listen((b) {
  print('${(b.progress * 100).round()} % '
      '(${b.completedCount} done, ${b.failedCount} failed)');
});
final files = await batch.results; // Never throws; see batch.failures.
```

Leave out the combinations you already know will fail, and choose the
visibility of the files:

```dart
final batch = upcloud.uploadBatch(
  files: files,
  accountIds: accountIds,
  folderPath: 'Movies/2026',
  // No task, folder lookup or storage check for these pairs.
  skip: (file, accountId) =>
      upcloud.connect(accountId).limits.check(extension: file.extension) !=
      null,
  // Overrides the default of the settings; providerDefault sends nothing.
  visibility: UploadVisibility.providerDefault,
);
```

Every task of the batch shares `batch.id` (`UploadTask.batchId`). In each
account, every segment of the path is looked up by name (ignoring case)
from the root and created when missing, once per account however many
files there are. Results are cached for the session. Without a path (and
without `UploadOptions.folderId`) the default folder of the settings is
used; an empty path is the root. `upcloud.resolveFolderPath(accountId,
path, create: false)` looks a path up directly, and
`upcloud.recentFolderPaths` lists the last paths used, for suggestions.

Providers that cannot browse or create folders fail with
`UnsupportedOperationException` when a folder of the path is missing.

### Settings

```dart
await upcloud.updateSettings(
  upcloud.settings.copyWith(
    maxConcurrentUploads: 5, // 1..10, applied immediately.
    retries: 3, // Automatic retries, 0..10.
    checkStorage: true, // Check the free space before each upload.
    autoClearAfterSeconds: 60, // Remove completed uploads; null keeps them.
    defaultFolderPath: 'Movies/2026',
    defaultVisibility: UploadVisibility.private,
  ),
);
upcloud.settingsChanges.listen(print);
```

`defaultVisibility` applies to uploads that set neither
`UploadOptions.isPublic` nor a `visibility` (`upload`, `uploadBatch` and
`uploadToMany` accept one; `UploadVisibility.providerDefault` keeps the
provider default whatever the settings say). Settings and recent paths
are saved as JSON in the `settingsStore` given to `UpCloud` (see
[Persisting data](#persisting-data)) and loaded by `init()`.

## The provider registry

Providers are described in [`registry/providers.json`](../../registry/providers.json):

```json
{
  "id": "streamhg",
  "name": "StreamHG",
  "driver": "xvs",
  "website": "https://streamhg.com",
  "apiBase": "https://streamhgapi.com/api",
  "mirrors": ["https://streamhg-mirror.example/api"],
  "limits": { "maxFileSizeMb": 2048, "allowedExtensions": ["mp4", "mkv"] },
  "settings": { "pageUrlTemplate": "https://streamhg.com/{code}.html" }
}
```

`ProviderRegistry` combines three layers, later ones winning:

1. The registry **bundled** with the package, so the app works offline.
2. The **remote** registry, downloaded from this repository (with ETag
   caching) when `UpCloud.init()` runs, at most every 6 hours. The newest of
   1 and 2 is used.
3. The **user's edits** and custom providers. Only the fields the user
   changed are stored, so registry updates still reach the other fields.

Entries whose driver is unknown to the installed package version are
skipped and reported in `registry.issues`, so older apps keep working.

### Persisting data

`KeyValueStore` is a key/value interface for the registry data and the
upload settings (`RegistryStore` is an alias). Back it with
shared_preferences, drift, files or anything else:

```dart
final class PrefsStore implements KeyValueStore {
  PrefsStore(this.prefs);

  final SharedPreferences prefs;

  @override
  Future<String?> read(String key) async => prefs.getString(key);

  @override
  Future<void> write(String key, String? value) async => value == null
      ? prefs.remove(key)
      : prefs.setString(key, value);
}

final prefsStore = PrefsStore(prefs);
final upcloud = UpCloud(
  uploadExecutor: executor,
  registry: ProviderRegistry(store: prefsStore),
  disposeRegistry: true, // upcloud.dispose() also disposes the registry.
  settingsStore: prefsStore,
  store: MySecureAccountStore(), // Accounts contain secrets.
);
```

`UpCloud.dispose` disposes the registries it creates; a registry passed
to it is disposed only with `disposeRegistry: true`, so it can be shared.

Invalid configs throw `InvalidProviderConfigException`, whose `problems`
carry a `ConfigProblemCode` so apps can show translated messages; use
`registry.validate(config)` to check a config before saving it.

### Editing providers

```dart
final registry = upcloud.registry;

// Move a provider to a new domain and raise its size limit.
final config = registry.config('streamhg')!;
await registry.save(
  config.copyWith(
    apiBase: Uri.parse('https://new-domain.example/api'),
    limits: const LimitsConfig(maxFileSizeMb: 10240),
  ),
);

await registry.setEnabled('byse', enabled: false);
await registry.reset('streamhg'); // Back to the registry values.

// Force a download of the remote registry.
final result = await registry.refresh(force: true);
```

Accounts connected to an edited provider reconnect automatically.

### Adding a provider

Hosts running an existing driver only need an entry. Add it to
`registry/providers.json` (and open a pull request), or at runtime:

```dart
await upcloud.registry.save(
  ProviderConfig(
    id: 'myhost',
    name: 'MyHost',
    driver: 'xvs',
    website: Uri.parse('https://myhost.example'),
    apiBase: Uri.parse('https://myhost.example/api'),
    settings: const {
      'pageUrlTemplate': 'https://myhost.example/{code}.html',
    },
  ),
);
```

A new API needs a driver: extend `CloudDriver`, implement a `CloudProvider`
with the capability interfaces it supports and register it with
`ProviderRegistry(drivers: [...builtInDrivers, myDriver])`.

## Backups

Export the whole configuration to an encrypted file and restore it, on
the same device or another one:

```dart
// Accounts with their credentials, provider edits and custom providers,
// upload settings, recent folders, and preferences of your app.
final json = await upcloud.exportBackup(
  password: password, // At least 8 characters.
  extra: {'themeMode': 'dark'}, // JSON values only.
);

// Later. The envelope is readable without the password.
final info = UpCloud.inspectBackup(json);
print('Backup made on ${info.createdAt}');
try {
  final result = await upcloud.importBackup(
    json,
    password: password,
    mode: BackupImportMode.merge, // Or BackupImportMode.replace.
  );
  print('${result.accountsAdded} added, ${result.accountsUpdated} updated');
  restoreMyPreferences(result.extra);
} on WrongBackupPasswordException {
  // Wrong password (or modified file): ask again.
} on InvalidBackupException catch (e) {
  // e.reason: notABackup, corrupted or unsupported (made by a newer
  // version of the package).
}
```

| | `merge` (default) | `replace` |
| --- | --- | --- |
| Accounts | Added or updated by id; the others are kept | Only those of the backup, in its order; the others are removed and their uploads cancelled |
| Provider edits and custom providers | Those of the backup are imported; the others are kept | Every edit is reset, then those of the backup are imported |
| Upload settings | Those of the backup | Those of the backup |
| Recent folder paths | Merged (current ones first) | Those of the backup |

Accounts whose data changed reconnect, as with `updateAccount`. Provider
entries whose driver the installed version does not have are skipped
(`result.providersSkipped`). Nothing changes when the file cannot be read
or decrypted. `exportBackup` throws `WeakBackupPasswordException` for
passwords shorter than `UpCloud.minBackupPasswordLength` (8) characters;
a lost password cannot be recovered.

### Backup file format

A backup is a JSON file whose envelope says what it is; only `data` is
encrypted:

```json
{
  "format": "upcloud-backup",
  "version": 1,
  "createdAt": "2026-09-28T10:32:00.000Z",
  "encrypted": true,
  "kdf": {
    "algorithm": "argon2id",
    "memoryKiB": 19456,
    "iterations": 2,
    "parallelism": 1,
    "salt": "<16 random bytes, base64>"
  },
  "cipher": { "algorithm": "aes-256-gcm", "nonce": "<12 random bytes, base64>" },
  "data": "<cipher text followed by the 16 bytes tag, base64>"
}
```

- The 32 bytes key is derived from the UTF-8 password with Argon2id
  (RFC 9106) and a random salt, using the pure Dart implementation of
  [cryptography](https://pub.dev/packages/cryptography). The default cost,
  `Argon2idParams.recommended`, is OWASP's minimum for Argon2id: 19 MiB,
  2 passes, 1 lane (about 70 ms on an Apple M3). It runs in a separate
  isolate (in place on the web). The parameters are saved in every file,
  so future versions can raise them and older backups still open.
- The content is encrypted with AES-256-GCM and a random nonce. The rest
  of the envelope is authenticated as associated data (every field but
  `data`, re-encoded as compact JSON in the order above), so the format,
  version, date and key derivation parameters cannot be changed without
  breaking decryption. GCM cannot tell a wrong password from a modified
  file: both throw `WrongBackupPasswordException`.
- When reading, the key derivation cost is capped (256 MiB, 32 passes, 16
  lanes) so a crafted file cannot exhaust the memory of the device.
- The decrypted content is JSON with its own `version`: `accounts`
  (`CloudAccount.toJson`), `providers` (the `exportUserChanges()`
  document), `settings`, `recentFolderPaths` and `extra`.

Tests can make backups cheaper with
`UpCloud(backupKdf: Argon2idParams(memoryKiB: 64, iterations: 1))`; keep
the default in apps.

## Drivers

| Driver | API | Settings |
| --- | --- | --- |
| `xvs` | [XVideoSharing](https://xvideosharing.com/api.html) script | `pageUrlTemplate` (when the API does not return file links) |
| `byse` | [Byse](https://byse.sx/api-docs) | – |
| `mediafire` | [MediaFire Core API 1.5](https://www.mediafire.com/developers/core_api/1.5/getting_started/) | – |

MediaFire accounts sign in with email and password only (the library
sends MediaFire's public application id that the API requires). Its uploads
(`upload/simple`) send the file as the raw request body, with the name and
size in the `x-filename` and `x-filesize` headers.

## Errors

Every failure is an `UpCloudException`, a sealed class:

```dart
try {
  await provider.capability<AccountInfoProviding>()!.accountInfo();
} on UpCloudException catch (e) {
  final message = switch (e) {
    AuthenticationException() => 'Invalid credentials',
    RateLimitedException(:final retryAfter) => 'Try again in $retryAfter',
    UploadRejectedException(reason: FileTooLarge(:final maxSize)) =>
      'Max size is $maxSize',
    NetworkException() => 'Check your connection',
    _ => e.message,
  };
}
```

## Networking

- API calls go through [dio](https://pub.dev/packages/dio). Pass
  `ProviderOptions(dio: ..., logger: ..., userAgent: ...)` through
  `UpCloud(optionsBuilder: ...)` for proxies, logging or custom adapters.
  Upload bytes are sent by the `UploadExecutor`.
- Read-only requests are retried on network errors, `429` and `5xx`.
  Writes are never retried, because many hosting APIs use `GET` for them.
- When the API base cannot be reached, the provider's `mirrors` are tried
  in order.
- API keys and passwords are redacted from logs, and are only sent over
  HTTPS.

## Testing

`package:upcloud/testing.dart` provides `InMemoryProvider`, which implements
every common capability, `inMemoryDemo`, a ready to use definition, and
`FakeUploadExecutor`, which sends nothing: it simulates progress, answers
`InMemoryProvider` uploads, returns canned responses (`respond`) and can
fail the next attempts (`failNext`) or hold uploads (`pause`/`resume`):

```dart
final executor = FakeUploadExecutor(stepDelay: Duration(milliseconds: 50));
final upcloud = UpCloud(
  uploadExecutor: executor,
  registry: ProviderRegistry(useRemote: false),
  providers: [inMemoryDemo],
);
```

## Security

- Accounts contain API keys and passwords. Implement `AccountStore` with
  secure storage (Keychain/Keystore) in production apps.
- Backups contain the same secrets, so they are always encrypted (see
  [Backups](#backups)). Nobody can restore a backup whose password was
  lost.
- The registry decides where credentials are sent. Remote registries must be
  served over HTTPS; use `ProviderRegistry(remoteUrl: ...)` to point to your
  own copy or `useRemote: false` to disable updates.
