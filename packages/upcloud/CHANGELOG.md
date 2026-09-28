## 0.1.0-dev.1

Initial preview.

- Core API: `CloudProvider` with capability interfaces and per-operation
  `Capability` flags declared by each provider, sealed `UpCloudException`
  hierarchy, `ProviderLimits` and upload validation.
- Uploads in three steps: providers prepare the HTTP request
  (`FileUploading.prepareUpload` returns a JSON-serializable
  `UploadRequest`, multipart or binary), an `UploadExecutor` sends the bytes
  and providers complete the upload from the `UploadResponse`
  (`FileUploading.completeUpload`). The core sends no upload bytes: Flutter
  apps use the background executor of `upcloud_flutter`.
- Share links in `CloudFile.pageUrl`; remote uploads with
  `remoteUploadStatus`.
- Provider registry: drivers in code, providers as JSON data. Bundled
  registry, remote updates with ETag caching and user edits stored with a
  pluggable `KeyValueStore` (`RegistryStore`). Typed validation
  (`ConfigProblem`, `InvalidProviderConfigException`) and HTTPS-only URLs.
- Drivers: `xvs` (XVideoSharing script: StreamHG, EarnVids/VidHide...),
  `byse` and `mediafire`.
- `TransferManager`: upload queue with global and per-account concurrency,
  progress, cancellation, automatic retries with exponential backoff for
  transient errors, free storage check and auto-clear of completed uploads.
- `UploadSettings` (concurrency, retries, storage check, auto-clear, default
  folder path and visibility) applied at runtime and persisted by `UpCloud`.
- Batch uploads (`UpCloud.uploadBatch`): several files to several accounts
  into a folder path found by name or created, with aggregated progress and
  results (`UploadBatch`). Folder paths are resolved once per account and
  cached (`FolderPathResolver`, `UpCloud.resolveFolderPath`); recent paths
  are remembered. Batches can skip (file, account) pairs (`skip`) and
  take an explicit `visibility`, also accepted by `upload` and
  `uploadToMany`.
- `UpCloud` facade: multiple accounts, settings and uploads. It can
  dispose a registry it was given (`disposeRegistry`).
- Encrypted backups of the configuration: `UpCloud.exportBackup`
  (accounts with their credentials, provider edits and custom providers,
  upload settings, recent folder paths and `extra` data of the app;
  passwords of at least 8 characters), `UpCloud.importBackup`
  (`BackupImportMode.merge` or `replace`, returning a
  `BackupImportResult`) and `UpCloud.inspectBackup` (`BackupInfo`). The
  file is a JSON envelope (`upcloud-backup`, version 1) with the content
  encrypted with AES-256-GCM, the envelope authenticated as associated
  data and the key derived with Argon2id (`Argon2idParams`, OWASP's
  minimum by default, off the main isolate). New errors:
  `InvalidBackupException` (with an `InvalidBackupReason`),
  `WrongBackupPasswordException` and `WeakBackupPasswordException`.
- `ProviderRegistry.resetAll` discards every user edit.
- HTTP layer on dio for API calls: opt-in retries for read-only requests,
  rate limiting, mirror fallback and redacted logging.
- Testing helpers: `InMemoryProvider` and `FakeUploadExecutor`.
