import 'package:upcloud/upcloud.dart';
import 'package:upcloud_flutter/src/l10n/upcloud_localizations.dart';
import 'package:upcloud_flutter/src/utils/password_strength.dart';

/// English strings.
class UpCloudLocalizationsEn extends UpCloudLocalizations {
  /// Creates the English strings.
  const UpCloudLocalizationsEn();

  String _plural(int count, String one, String other) =>
      count == 1 ? one : other;

  @override
  String get decimalSeparator => '.';

  @override
  String get cancel => 'Cancel';

  @override
  String get create => 'Create';

  @override
  String get rename => 'Rename';

  @override
  String get delete => 'Delete';

  @override
  String get remove => 'Remove';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get open => 'Open';

  @override
  String get refresh => 'Refresh';

  @override
  String get copy => 'Copy';

  @override
  String get rootFolder => 'My files';

  @override
  String get goUp => 'Parent folder';

  @override
  String get emptyFolder => 'This folder is empty';

  @override
  String get emptyFolderHint =>
      'Upload files or create a folder to get started.';

  @override
  String noSearchResults(String query) => 'No files match "$query"';

  @override
  String get searchHint => 'Search files';

  @override
  String get search => 'Search';

  @override
  String get closeSearch => 'Close search';

  @override
  String get loadFolderFailed => "Couldn't load this folder";

  @override
  String get loadMoreFailed => "Couldn't load more items";

  @override
  String get loadMore => 'Load more';

  @override
  String get newFolder => 'New folder';

  @override
  String get folderName => 'Folder name';

  @override
  String get name => 'Name';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String deleteConfirmTitle(int count) =>
      _plural(count, 'Delete item?', 'Delete $count items?');

  @override
  String deleteConfirmMessage(String name) =>
      '"$name" will be deleted. This cannot be undone.';

  @override
  String deleteManyConfirmMessage(int count) =>
      '$count items will be deleted. This cannot be undone.';

  @override
  String get add => 'New';

  @override
  String get moreActions => 'More actions';

  @override
  String get upload => 'Upload';

  @override
  String get uploadFiles => 'Upload files';

  @override
  String get uploadFromUrl => 'Upload from URL';

  @override
  String get url => 'URL';

  @override
  String get fileNameOptional => 'File name (optional)';

  @override
  String get invalidUrl => 'Enter a valid http(s) URL';

  @override
  String get remoteUploadStarted => 'Remote upload started';

  @override
  String uploadsQueued(int count) =>
      _plural(count, '1 upload queued', '$count uploads queued');

  @override
  String get copyLink => 'Copy link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get noLinks => 'No links available';

  @override
  String get move => 'Move';

  @override
  String get moveTo => 'Move to';

  @override
  String get moveHere => 'Move here';

  @override
  String get selectAll => 'Select all';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String selectedCount(int count) => '$count selected';

  @override
  String get listView => 'List view';

  @override
  String get gridView => 'Grid view';

  @override
  String fileCount(int count) => _plural(count, '1 file', '$count files');

  @override
  String get noTransfers => 'No transfers';

  @override
  String get transferQueued => 'Queued';

  @override
  String get transferUploading => 'Uploading';

  @override
  String get transferCompleted => 'Completed';

  @override
  String get transferCancelled => 'Cancelled';

  @override
  String get transferFailed => 'Failed';

  @override
  String transferProgress(String transferred, String total) =>
      '$transferred of $total';

  @override
  String get clearFinished => 'Clear finished';

  @override
  String get cancelAll => 'Cancel all';

  @override
  String get errorAuthentication =>
      'The provider rejected the credentials. Check them and try again.';

  @override
  String get errorNotFound => 'The file or folder no longer exists.';

  @override
  String get errorQuota =>
      'The account ran out of storage, bandwidth or requests.';

  @override
  String errorRateLimited(Duration? retryAfter) => retryAfter == null
      ? 'Too many requests. Try again later.'
      : 'Too many requests. Try again in ${retryAfter.inSeconds} s.';

  @override
  String get errorNetwork => 'Network error. Check your connection.';

  @override
  String get errorCancelled => 'Cancelled';

  @override
  String get errorUnsupported => 'This provider does not support this action.';

  @override
  String errorProvider(String message) => 'The provider said: $message';

  @override
  String rejectionFileTooLarge(String size, String maxSize) =>
      'File is too large ($size, max. $maxSize)';

  @override
  String rejectionExtensionNotAllowed(String extension) => extension.isEmpty
      ? 'Files without extension are not allowed'
      : 'Files of type .$extension are not allowed';

  @override
  String rejectionNotEnoughStorage(String size, String available) =>
      'Not enough storage ($size needed, $available free)';

  @override
  String get accounts => 'Accounts';

  @override
  String get addAccount => 'Add account';

  @override
  String get noAccounts => 'No accounts yet';

  @override
  String get noAccountsHint => 'Add an account to start managing your files.';

  @override
  String get removeAccount => 'Remove account';

  @override
  String removeAccountMessage(String label) =>
      '"$label" will be removed from this device and its transfers '
      'cancelled.';

  @override
  String get checkConnection => 'Check connection';

  @override
  String get accountConnected => 'Connected';

  @override
  String get accountChecking => 'Checking…';

  @override
  String get accountConnectionFailed => 'Connection failed';

  @override
  String storageUsed(String used) => '$used used';

  @override
  String storageFree(String free) => '$free free';

  @override
  String get accountName => 'Account name';

  @override
  String get optional => 'Optional';

  @override
  String get connect => 'Connect';

  @override
  String fieldRequired(String label) => '$label is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get whereToFind => 'Where do I find it?';

  @override
  String get showSecret => 'Show';

  @override
  String get hideSecret => 'Hide';

  @override
  String get advanced => 'Advanced';

  @override
  String get baseUrl => 'API base URL';

  @override
  String get baseUrlHelper =>
      'Only change it if the provider moved to a new domain.';

  @override
  String get apiKey => 'API key';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get chooseProvider => 'Choose a provider';

  @override
  String get noProviders => 'No providers available';

  @override
  String get provider => 'Provider';

  @override
  String maxFileSize(String size) => 'Max. file size: $size';

  @override
  String capability(Capability capability) => switch (capability) {
    Capability.browseFolders => 'Browse',
    Capability.createFolder => 'Create folders',
    Capability.renameFolder => 'Rename folders',
    Capability.moveFolder => 'Move folders',
    Capability.deleteFolder => 'Delete folders',
    Capability.fileInfo => 'File details',
    Capability.renameFile => 'Rename files',
    Capability.moveFile => 'Move files',
    Capability.deleteFile => 'Delete files',
    Capability.search => 'Search',
    Capability.upload => 'Upload',
    Capability.remoteUpload => 'Remote upload',
    Capability.accountInfo => 'Account info',
  };

  @override
  String get manageFoldersCapability => 'Folders';

  @override
  String get manageFilesCapability => 'Manage files';

  @override
  String configProblem(ConfigProblem problem) => switch (problem.code) {
    ConfigProblemCode.wrongDriver => 'The driver does not match.',
    ConfigProblemCode.unknownDriver => 'This driver is not available.',
    ConfigProblemCode.invalidId =>
      'The id can only use lowercase letters, digits, "_" and "-".',
    ConfigProblemCode.missingName => 'The name is required.',
    ConfigProblemCode.missingApiBase => 'The API URL is required.',
    ConfigProblemCode.invalidUrl => 'Enter a complete URL (https://...).',
    ConfigProblemCode.insecureUrl =>
      'URLs must use https so credentials are not sent in clear text.',
    ConfigProblemCode.other => problem.message,
  };

  @override
  String get providers => 'Providers';

  @override
  String get addProvider => 'Add provider';

  @override
  String get editProvider => 'Edit provider';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get providerSaved => 'Provider saved';

  @override
  String get customBadge => 'Custom';

  @override
  String get modifiedBadge => 'Modified';

  @override
  String get disabledBadge => 'Disabled';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get registryUpdated => 'Provider list updated';

  @override
  String get registryUpToDate => 'The provider list is up to date';

  @override
  String get registryDisabled => 'Remote updates are disabled';

  @override
  String get registryIssues => 'Some providers could not be loaded';

  @override
  String get general => 'General';

  @override
  String get connection => 'Connection';

  @override
  String get limits => 'Limits';

  @override
  String get driverSettings => 'Driver settings';

  @override
  String get driver => 'Driver';

  @override
  String get providerId => 'ID';

  @override
  String get providerIdHelper =>
      'Lowercase letters, numbers, "-" and "_". It cannot be changed later.';

  @override
  String get invalidProviderId => 'Use lowercase letters, numbers, "-" and "_"';

  @override
  String get duplicateProviderId => 'This ID is already in use';

  @override
  String get description => 'Description';

  @override
  String get website => 'Website';

  @override
  String get mirrors => 'Mirrors';

  @override
  String get mirrorsHelper =>
      'Alternative API URLs, tried when the main one cannot be reached.';

  @override
  String get addMirror => 'Add mirror';

  @override
  String get maxFileSizeMb => 'Max. file size (MB)';

  @override
  String get maxFileSizeHelper => 'Empty: driver default. 0: no limit.';

  @override
  String get allowedExtensions => 'Allowed extensions';

  @override
  String get allowedExtensionsHelper =>
      'Comma separated, e.g. mp4, mkv. Empty: driver default. "*": any file.';

  @override
  String get invalidNumber => 'Enter a valid number';

  @override
  String get enabled => 'Enabled';

  @override
  String get providerEnabledHelper =>
      'Disabled providers are hidden when adding accounts.';

  @override
  String get invalidProviderConfig => 'The configuration is not valid';

  @override
  String resetProviderMessage(String name) =>
      'Your changes to "$name" will be discarded.';

  @override
  String deleteProviderMessage(String name) =>
      'The custom provider "$name" will be deleted.';

  @override
  String registryUpdateFailed(String error) =>
      "Couldn't check for updates: $error";

  @override
  String lastChecked(String date) => 'Last checked: $date';

  @override
  String unknownDriver(String id) => 'Unknown driver "$id"';

  @override
  String transferRetrying(int retry, int? maxRetries) => maxRetries == null
      ? 'Retrying ($retry)'
      : 'Retrying ($retry/$maxRetries)';

  @override
  String batchTitle(int files, int accounts) =>
      '${fileCount(files)} → '
      '${_plural(accounts, '1 account', '$accounts accounts')}';

  @override
  String batchDone(int done, int total) => '$done of $total done';

  @override
  String batchFailedCount(int count) => '$count failed';

  @override
  String batchCancelledCount(int count) => '$count cancelled';

  @override
  String get retryFailed => 'Retry failed';

  @override
  String get clear => 'Clear';

  @override
  String get uploadNotificationRunningTitle => 'Uploading {displayName}';

  @override
  String get uploadNotificationRunningBody => '{progress}';

  @override
  String get uploadNotificationCompleteTitle => 'Upload complete';

  @override
  String get uploadNotificationCompleteBody => '{displayName}';

  @override
  String get uploadNotificationErrorTitle => 'Upload failed';

  @override
  String get uploadNotificationErrorBody => '{displayName}';

  @override
  String get uploadGroupNotificationRunningTitle => 'Uploading files';

  @override
  String get uploadGroupNotificationRunningBody =>
      '{numFinished} of {numTotal} done';

  @override
  String get uploadGroupNotificationCompleteTitle => 'Uploads complete';

  @override
  String get uploadGroupNotificationCompleteBody => '{numTotal} files uploaded';

  @override
  String get uploadGroupNotificationErrorTitle => 'Some uploads failed';

  @override
  String get uploadGroupNotificationErrorBody =>
      '{numFailed} of {numTotal} failed';

  @override
  String get uploadQueueSection => 'Queue';

  @override
  String get finishedUploadsSection => 'Finished uploads';

  @override
  String get uploadDefaultsSection => 'Defaults';

  @override
  String get maxConcurrentUploads => 'Simultaneous uploads';

  @override
  String get maxConcurrentUploadsHelper =>
      'Across all accounts. Each provider may allow fewer at a time.';

  @override
  String get automaticRetries => 'Automatic retries';

  @override
  String get automaticRetriesHelper =>
      'After network errors, rate limits and server errors.';

  @override
  String get off => 'Off';

  @override
  String get checkStorage => 'Check free storage';

  @override
  String get checkStorageHelper =>
      'Skip files that do not fit in the account. Costs one extra request '
      'per upload.';

  @override
  String get autoClear => 'Remove completed uploads';

  @override
  String get autoClearHelper =>
      'Failed and cancelled uploads always stay in the list.';

  @override
  String get autoClearNever => 'Never';

  @override
  String get autoClearImmediately => 'Immediately';

  @override
  String autoClearAfter(Duration delay) => 'After ${_duration(delay)}';

  @override
  String get defaultFolder => 'Default folder';

  @override
  String get defaultFolderHelper =>
      'Used when uploading to several accounts. Leave it empty for the root '
      'folder.';

  @override
  String get folderPathHint => 'e.g. Movies/2026';

  @override
  String get visibilityLabel => 'Visibility';

  @override
  String visibility(UploadVisibility visibility) => switch (visibility) {
    UploadVisibility.providerDefault => 'Provider default',
    UploadVisibility.public => 'Public',
    UploadVisibility.private => 'Private',
  };

  @override
  String get filesSection => 'Files';

  @override
  String get addFiles => 'Add files';

  @override
  String get noFilesSelected => 'No files yet';

  @override
  String get noFilesSelectedHint => 'Add the files you want to upload.';

  @override
  String filesSummary(int count, String size) => '${fileCount(count)} · $size';

  @override
  String get selectNone => 'Select none';

  @override
  String upToSize(String size) => 'Up to $size';

  @override
  String accountsSelected(int selected, int total) =>
      '$selected of $total selected';

  @override
  String get noUploadAccounts => 'No account can receive uploads';

  @override
  String get noUploadAccountsHint =>
      'Connect an account of a provider that supports uploads.';

  @override
  String get destinationSection => 'Destination';

  @override
  String get destinationFolder => 'Destination folder';

  @override
  String get destinationFolderHelper =>
      'Found by name in every selected account and created when missing. '
      'Leave it empty for the root folder.';

  @override
  String uploadsSkipped(int count) => _plural(
    count,
    '1 upload will be skipped',
    '$count uploads will be skipped',
  );

  @override
  String get uploadsSkippedHint =>
      'These files break the limits of the provider. The other uploads '
      'start normally.';

  @override
  String skippedUpload(String file, String account, String reason) =>
      '$file → $account: $reason';

  @override
  String andMore(int count) => 'and $count more';

  @override
  String skippedFor(String accounts) => 'Skipped for $accounts';

  @override
  String startUploads(int count) =>
      _plural(count, 'Start 1 upload', 'Start $count uploads');

  @override
  String get backupSection => 'Backup';

  @override
  String get exportBackup => 'Export configuration';

  @override
  String get exportBackupHelper =>
      'Accounts, providers and settings in an encrypted file';

  @override
  String get importBackup => 'Import configuration';

  @override
  String get importBackupHelper => 'Restore a backup file on this device';

  @override
  String get exportBackupTitle => 'Encrypt the backup';

  @override
  String get exportBackupMessage =>
      'The backup contains API keys and passwords. Choose a password to '
      'encrypt it; you will need it to restore the backup.';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String passwordTooShort(int minLength) =>
      'Use at least $minLength characters';

  @override
  String get passwordsDoNotMatch => "Passwords don't match";

  @override
  String passwordStrength(PasswordStrength strength) => switch (strength) {
    PasswordStrength.tooShort => 'Too short',
    PasswordStrength.weak => 'Weak',
    PasswordStrength.fair => 'Fair',
    PasswordStrength.good => 'Good',
    PasswordStrength.strong => 'Strong',
  };

  @override
  String get backupPasswordWarning =>
      "If you lose this password, the backup can't be restored. Nobody can "
      'recover it.';

  @override
  String get exportAction => 'Export';

  @override
  String get encryptingBackup => 'Encrypting…';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get saveBackupFailed => "Couldn't save the backup";

  @override
  String get openBackupFailed => "Couldn't open the file";

  @override
  String get invalidBackupTitle => "Can't restore this file";

  @override
  String invalidBackup(InvalidBackupReason reason) => switch (reason) {
    InvalidBackupReason.notABackup => "This file isn't a configuration backup.",
    InvalidBackupReason.corrupted => 'The backup file is damaged.',
    InvalidBackupReason.unsupported =>
      'This backup was made by a newer version of the app. Update the app '
          'to restore it.',
  };

  @override
  String get importBackupTitle => 'Restore a backup';

  @override
  String backupCreatedAt(String date) => 'Made on $date';

  @override
  String get backupPasswordHelper =>
      'The password chosen when the backup was exported';

  @override
  String get importModeLabel => 'How to import';

  @override
  String get importMerge => 'Merge';

  @override
  String get importMergeHelper =>
      'Adds new accounts and providers and updates the existing ones. '
      'Nothing is removed.';

  @override
  String get importReplace => 'Replace everything';

  @override
  String get importReplaceHelper =>
      'Removes the accounts and provider changes that are not in the backup.';

  @override
  String get importAction => 'Import';

  @override
  String get decryptingBackup => 'Decrypting…';

  @override
  String get replaceConfirmTitle => 'Replace your configuration?';

  @override
  String get replaceConfirmMessage =>
      'Accounts that are not in the backup will be removed and their '
      'uploads cancelled. Provider changes, upload settings and recent '
      "folders will be replaced. This can't be undone.";

  @override
  String get replaceAction => 'Replace';

  @override
  String get wrongBackupPassword => 'Wrong password, or the file was modified.';

  @override
  String get backupRestored => 'Backup restored';

  @override
  String accountsAdded(int count) =>
      _plural(count, '1 account added', '$count accounts added');

  @override
  String accountsUpdated(int count) =>
      _plural(count, '1 account updated', '$count accounts updated');

  @override
  String accountsRemoved(int count) =>
      _plural(count, '1 account removed', '$count accounts removed');

  @override
  String providersImported(int count) => _plural(
    count,
    '1 provider change imported',
    '$count provider changes imported',
  );

  @override
  String providersSkipped(int count) => _plural(
    count,
    '1 provider skipped: it needs a newer version',
    '$count providers skipped: they need a newer version',
  );

  @override
  String get uploadSettingsRestored => 'Upload settings restored';

  @override
  String get backupUpToDate => 'Everything was already up to date';

  String _duration(Duration delay) {
    if (delay.inHours > 0 && delay.inMinutes % 60 == 0) {
      return '${delay.inHours} h';
    }
    if (delay.inMinutes > 0 && delay.inSeconds % 60 == 0) {
      return '${delay.inMinutes} min';
    }
    return '${delay.inSeconds} s';
  }
}
