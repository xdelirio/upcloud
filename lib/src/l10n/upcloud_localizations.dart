import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:upcloud/src/l10n/upcloud_localizations_en.dart';
import 'package:upcloud/src/l10n/upcloud_localizations_es.dart';
import 'package:upcloud/src/utils/password_strength.dart';
import 'package:upcloud/upcloud.dart';

/// Localized strings used by the upcloud widgets.
///
/// Register [delegate] in your app to follow the app locale:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: const [
///     UpCloudLocalizations.delegate,
///     // GlobalMaterialLocalizations.delegate, ...
///   ],
///   supportedLocales: UpCloudLocalizations.supportedLocales,
/// );
/// ```
///
/// When the delegate is not registered, [of] still works: it picks the
/// strings for the ambient locale and falls back to English.
abstract class UpCloudLocalizations {
  /// Base constructor for subclasses.
  const UpCloudLocalizations();

  /// Strings for [locale], English when the language is not supported.
  factory UpCloudLocalizations.forLocale(Locale? locale) =>
      switch (locale?.languageCode) {
        'es' => const UpCloudLocalizationsEs(),
        _ => const UpCloudLocalizationsEn(),
      };

  /// Delegate to add to `MaterialApp.localizationsDelegates`.
  static const LocalizationsDelegate<UpCloudLocalizations> delegate =
      _UpCloudLocalizationsDelegate();

  /// Locales with translations.
  static const List<Locale> supportedLocales = [Locale('en'), Locale('es')];

  /// Strings for the closest [Localizations] ancestor.
  ///
  /// Never fails: without a registered [delegate] the ambient locale is used
  /// and English is the fallback.
  static UpCloudLocalizations of(BuildContext context) =>
      Localizations.of<UpCloudLocalizations>(context, UpCloudLocalizations) ??
      _fallback(Localizations.maybeLocaleOf(context));

  /// Character used as decimal separator in sizes.
  String get decimalSeparator;

  // ---------------------------------------------------------------------------
  // Common
  // ---------------------------------------------------------------------------

  /// Label of cancel buttons.
  String get cancel;

  /// Label of create buttons.
  String get create;

  /// Label of rename actions.
  String get rename;

  /// Label of delete actions.
  String get delete;

  /// Label of remove actions.
  String get remove;

  /// Label of retry actions.
  String get retry;

  /// Label of close buttons.
  String get close;

  /// Label of open actions.
  String get open;

  /// Label of refresh actions.
  String get refresh;

  /// Label of copy actions.
  String get copy;

  // ---------------------------------------------------------------------------
  // Browser
  // ---------------------------------------------------------------------------

  /// Name of the root folder in breadcrumbs.
  String get rootFolder;

  /// Tooltip of the button that opens the parent folder.
  String get goUp;

  /// Title shown when a folder has no items.
  String get emptyFolder;

  /// Hint shown below [emptyFolder].
  String get emptyFolderHint;

  /// Message shown when a search has no results.
  String noSearchResults(String query);

  /// Hint of the search field.
  String get searchHint;

  /// Tooltip of the search button.
  String get search;

  /// Tooltip of the button that closes the search.
  String get closeSearch;

  /// Title shown when a folder could not be loaded.
  String get loadFolderFailed;

  /// Message shown when the next page could not be loaded.
  String get loadMoreFailed;

  /// Label of the button that loads the next page.
  String get loadMore;

  /// Label of the create folder action.
  String get newFolder;

  /// Label of the folder name field.
  String get folderName;

  /// Label of name fields.
  String get name;

  /// Validation message of empty name fields.
  String get nameRequired;

  /// Title of the delete confirmation dialog.
  String deleteConfirmTitle(int count);

  /// Body of the delete confirmation dialog for one item.
  String deleteConfirmMessage(String name);

  /// Body of the delete confirmation dialog for [count] items.
  String deleteManyConfirmMessage(int count);

  /// Tooltip of the menu with create/upload actions.
  String get add;

  /// Tooltip of overflow menus.
  String get moreActions;

  /// Label of upload buttons.
  String get upload;

  /// Label of the upload files action.
  String get uploadFiles;

  /// Label of the remote upload action.
  String get uploadFromUrl;

  /// Label of URL fields.
  String get url;

  /// Label of the optional file name field of remote uploads.
  String get fileNameOptional;

  /// Validation message of invalid URLs.
  String get invalidUrl;

  /// Feedback after starting a remote upload.
  String get remoteUploadStarted;

  /// Feedback after queueing [count] uploads.
  String uploadsQueued(int count);

  /// Label of the copy link action.
  String get copyLink;

  /// Feedback after copying a link.
  String get linkCopied;

  /// Message shown when a file has no links.
  String get noLinks;

  /// Label of the move action.
  String get move;

  /// Title of the destination folder picker.
  String get moveTo;

  /// Label of the button that confirms the destination folder.
  String get moveHere;

  /// Label of the select all action.
  String get selectAll;

  /// Tooltip of the button that leaves selection mode.
  String get clearSelection;

  /// Title of the selection toolbar.
  String selectedCount(int count);

  /// Tooltip of the list layout button.
  String get listView;

  /// Tooltip of the grid layout button.
  String get gridView;

  /// Number of files inside a folder.
  String fileCount(int count);

  // ---------------------------------------------------------------------------
  // Transfers
  // ---------------------------------------------------------------------------

  /// Title shown when there are no transfers.
  String get noTransfers;

  /// Status of queued transfers.
  String get transferQueued;

  /// Status of running uploads.
  String get transferUploading;

  /// Status of completed transfers.
  String get transferCompleted;

  /// Status of cancelled transfers.
  String get transferCancelled;

  /// Status of failed transfers.
  String get transferFailed;

  /// Progress of a transfer, e.g. `12 MB of 48 MB`.
  String transferProgress(String transferred, String total);

  /// Label of the clear finished transfers action.
  String get clearFinished;

  /// Label of the cancel all transfers action.
  String get cancelAll;

  /// Status of an upload running again after a failure: automatic retry
  /// [retry] of [maxRetries] (`null` when unknown).
  String transferRetrying(int retry, int? maxRetries);

  /// Title of a batch of uploads, e.g. `3 files → 2 accounts`.
  String batchTitle(int files, int accounts);

  /// Uploads of a batch that reached a final state, e.g. `4 of 6 done`.
  String batchDone(int done, int total);

  /// Failed uploads of a batch.
  String batchFailedCount(int count);

  /// Cancelled uploads of a batch.
  String batchCancelledCount(int count);

  /// Label of the action that queues the failed uploads of a batch again.
  String get retryFailed;

  /// Label of the action that removes the finished uploads of a batch.
  String get clear;

  // ---------------------------------------------------------------------------
  // Upload notifications
  // ---------------------------------------------------------------------------
  //
  // Texts of system notifications. Keep the background_downloader tokens:
  // {displayName} (file name), {progress}, {numFinished}, {numFailed} and
  // {numTotal}.

  /// Title of the notification of a running upload.
  String get uploadNotificationRunningTitle;

  /// Body of the notification of a running upload.
  String get uploadNotificationRunningBody;

  /// Title of the notification of a completed upload.
  String get uploadNotificationCompleteTitle;

  /// Body of the notification of a completed upload.
  String get uploadNotificationCompleteBody;

  /// Title of the notification of a failed upload.
  String get uploadNotificationErrorTitle;

  /// Body of the notification of a failed upload.
  String get uploadNotificationErrorBody;

  /// Title of the grouped notification while uploads run.
  String get uploadGroupNotificationRunningTitle;

  /// Body of the grouped notification while uploads run.
  String get uploadGroupNotificationRunningBody;

  /// Title of the grouped notification when every upload completed.
  String get uploadGroupNotificationCompleteTitle;

  /// Body of the grouped notification when every upload completed.
  String get uploadGroupNotificationCompleteBody;

  /// Title of the grouped notification when some upload failed.
  String get uploadGroupNotificationErrorTitle;

  /// Body of the grouped notification when some upload failed.
  String get uploadGroupNotificationErrorBody;

  // ---------------------------------------------------------------------------
  // Upload settings
  // ---------------------------------------------------------------------------

  /// Title of the section with concurrency, retries and storage checks.
  String get uploadQueueSection;

  /// Title of the section about finished uploads.
  String get finishedUploadsSection;

  /// Title of the section with the default folder and visibility.
  String get uploadDefaultsSection;

  /// Label of the maximum number of simultaneous uploads.
  String get maxConcurrentUploads;

  /// Helper text of [maxConcurrentUploads].
  String get maxConcurrentUploadsHelper;

  /// Label of the number of automatic retries.
  String get automaticRetries;

  /// Helper text of [automaticRetries].
  String get automaticRetriesHelper;

  /// Value shown when automatic retries are disabled.
  String get off;

  /// Label of the free storage check switch.
  String get checkStorage;

  /// Helper text of [checkStorage].
  String get checkStorageHelper;

  /// Label of the auto-clear choices.
  String get autoClear;

  /// Helper text of [autoClear].
  String get autoClearHelper;

  /// Auto-clear choice that keeps completed uploads.
  String get autoClearNever;

  /// Auto-clear choice that removes completed uploads right away.
  String get autoClearImmediately;

  /// Auto-clear choice that removes completed uploads after [delay].
  String autoClearAfter(Duration delay);

  /// Label of the default folder field.
  String get defaultFolder;

  /// Helper text of [defaultFolder].
  String get defaultFolderHelper;

  /// Hint of folder path fields.
  String get folderPathHint;

  /// Label of visibility selectors.
  String get visibilityLabel;

  /// Label of [visibility].
  String visibility(UploadVisibility visibility);

  // ---------------------------------------------------------------------------
  // Upload composer
  // ---------------------------------------------------------------------------

  /// Title of the list of files to upload.
  String get filesSection;

  /// Label of the add files action.
  String get addFiles;

  /// Title shown when no file was added yet.
  String get noFilesSelected;

  /// Hint shown below [noFilesSelected].
  String get noFilesSelectedHint;

  /// Number and total size of the files to upload, e.g. `3 files · 1.2 GB`.
  String filesSummary(int count, String size);

  /// Label of the action that deselects every account.
  String get selectNone;

  /// Compact maximum upload size, e.g. `Up to 2.0 GB`.
  String upToSize(String size);

  /// Selected accounts, e.g. `2 of 5 selected`.
  String accountsSelected(int selected, int total);

  /// Title shown when no account supports uploads.
  String get noUploadAccounts;

  /// Hint shown below [noUploadAccounts].
  String get noUploadAccountsHint;

  /// Title of the section with the destination folder and visibility.
  String get destinationSection;

  /// Label of the destination folder field.
  String get destinationFolder;

  /// Helper text of [destinationFolder].
  String get destinationFolderHelper;

  /// Title of the pre-flight warnings: [count] uploads will be skipped.
  String uploadsSkipped(int count);

  /// Explanation below [uploadsSkipped].
  String get uploadsSkippedHint;

  /// One skipped upload: [file] to [account] because of [reason].
  String skippedUpload(String file, String account, String reason);

  /// More skipped uploads that are not listed.
  String andMore(int count);

  /// Note on a file skipped for some accounts, e.g. `Skipped for Main`.
  String skippedFor(String accounts);

  /// Label of the button that starts [count] uploads.
  String startUploads(int count);

  // ---------------------------------------------------------------------------
  // Errors
  // ---------------------------------------------------------------------------

  /// Message of [AuthenticationException].
  String get errorAuthentication;

  /// Message of [NotFoundException].
  String get errorNotFound;

  /// Message of [QuotaExceededException].
  String get errorQuota;

  /// Message of [RateLimitedException].
  String errorRateLimited(Duration? retryAfter);

  /// Message of [NetworkException].
  String get errorNetwork;

  /// Message of [CancelledException].
  String get errorCancelled;

  /// Message of [UnsupportedOperationException].
  String get errorUnsupported;

  /// Message of [ProviderException].
  String errorProvider(String message);

  /// Message of [FileTooLarge].
  String rejectionFileTooLarge(String size, String maxSize);

  /// Message of [ExtensionNotAllowed].
  String rejectionExtensionNotAllowed(String extension);

  /// Message of [NotEnoughStorage].
  String rejectionNotEnoughStorage(String size, String available);

  // ---------------------------------------------------------------------------
  // Accounts and providers
  // ---------------------------------------------------------------------------

  /// Title of account lists.
  String get accounts;

  /// Label of the add account action.
  String get addAccount;

  /// Title shown when there are no accounts.
  String get noAccounts;

  /// Hint shown below [noAccounts].
  String get noAccountsHint;

  /// Label of the remove account action.
  String get removeAccount;

  /// Body of the remove account confirmation dialog.
  String removeAccountMessage(String label);

  /// Label of the check connection action.
  String get checkConnection;

  /// Status of accounts that accepted their credentials.
  String get accountConnected;

  /// Status of accounts being checked.
  String get accountChecking;

  /// Status of accounts that failed the connection check.
  String get accountConnectionFailed;

  /// Used storage, e.g. `1.2 GB used`.
  String storageUsed(String used);

  /// Free storage, e.g. `8.8 GB free`.
  String storageFree(String free);

  /// Label of the account name field.
  String get accountName;

  /// Helper text of optional fields.
  String get optional;

  /// Label of the connect button.
  String get connect;

  /// Validation message of empty required fields.
  String fieldRequired(String label);

  /// Validation message of invalid emails.
  String get invalidEmail;

  /// Text of help links next to credential fields.
  String get whereToFind;

  /// Tooltip of the button that reveals secrets.
  String get showSecret;

  /// Tooltip of the button that hides secrets.
  String get hideSecret;

  /// Title of the advanced settings section.
  String get advanced;

  /// Label of the API base URL field.
  String get baseUrl;

  /// Helper text of the API base URL field.
  String get baseUrlHelper;

  /// Label of API key fields.
  String get apiKey;

  /// Label of email fields.
  String get email;

  /// Label of password fields.
  String get password;

  /// Title of the provider picker.
  String get chooseProvider;

  /// Message shown when no provider is registered.
  String get noProviders;

  /// Label of the provider dropdown of the account form.
  String get provider;

  /// Maximum upload size of a provider.
  String maxFileSize(String size);

  /// Short label of [capability].
  String capability(Capability capability);

  /// Label of the chip grouping folder management operations.
  String get manageFoldersCapability;

  /// Label of the chip grouping file management operations.
  String get manageFilesCapability;

  /// Translated description of a provider config [problem].
  String configProblem(ConfigProblem problem);

  // ---------------------------------------------------------------------------
  // Provider registry
  // ---------------------------------------------------------------------------

  /// Title of provider management screens.
  String get providers;

  /// Label of the add provider action.
  String get addProvider;

  /// Title of the provider editor.
  String get editProvider;

  /// Label of edit actions.
  String get edit;

  /// Label of save buttons.
  String get save;

  /// Feedback after saving a provider.
  String get providerSaved;

  /// Badge of providers added by the user.
  String get customBadge;

  /// Badge of providers edited by the user.
  String get modifiedBadge;

  /// Badge of disabled providers.
  String get disabledBadge;

  /// Label of the reset to default action.
  String get resetToDefault;

  /// Body of the reset confirmation dialog.
  String resetProviderMessage(String name);

  /// Body of the delete custom provider confirmation dialog.
  String deleteProviderMessage(String name);

  /// Label of the check for updates action.
  String get checkForUpdates;

  /// Feedback when the registry was updated.
  String get registryUpdated;

  /// Feedback when the registry did not change.
  String get registryUpToDate;

  /// Feedback when remote updates are disabled.
  String get registryDisabled;

  /// Feedback when checking for updates failed.
  String registryUpdateFailed(String error);

  /// When the registry was last checked.
  String lastChecked(String date);

  /// Title of the list of registry issues.
  String get registryIssues;

  /// Title of the section with name, description and website.
  String get general;

  /// Title of the section with API URLs and the file link template.
  String get connection;

  /// Title of the limits section.
  String get limits;

  /// Title of the driver settings section.
  String get driverSettings;

  /// Label of the driver selector.
  String get driver;

  /// Label of the provider id field.
  String get providerId;

  /// Helper text of the provider id field.
  String get providerIdHelper;

  /// Validation message of malformed provider ids.
  String get invalidProviderId;

  /// Validation message of provider ids already in use.
  String get duplicateProviderId;

  /// Label of description fields.
  String get description;

  /// Label of website fields.
  String get website;

  /// Label of the mirrors list.
  String get mirrors;

  /// Helper text of the mirrors list.
  String get mirrorsHelper;

  /// Label of the add mirror button.
  String get addMirror;

  /// Label of the file link template field of a provider.
  String get fileUrlTemplate;

  /// Helper text of the file link template field.
  String get fileUrlTemplateHelper;

  /// Validation message of invalid file link templates.
  String get invalidFileUrlTemplate;

  /// Label of the maximum file size field.
  String get maxFileSizeMb;

  /// Helper text of the maximum file size field.
  String get maxFileSizeHelper;

  /// Label of the allowed extensions field.
  String get allowedExtensions;

  /// Helper text of the allowed extensions field.
  String get allowedExtensionsHelper;

  /// Validation message of invalid numbers.
  String get invalidNumber;

  /// Label of enabled switches.
  String get enabled;

  /// Helper text of the provider enabled switch.
  String get providerEnabledHelper;

  /// Title of the error shown when a provider config is rejected.
  String get invalidProviderConfig;

  /// Message of registry entries whose driver is not available.
  String unknownDriver(String id);

  // ---------------------------------------------------------------------------
  // Backups
  // ---------------------------------------------------------------------------

  /// Title of the backup section.
  String get backupSection;

  /// Label of the export backup action.
  String get exportBackup;

  /// Helper text of the export backup action.
  String get exportBackupHelper;

  /// Label of the import backup action.
  String get importBackup;

  /// Helper text of the import backup action.
  String get importBackupHelper;

  /// Title of the dialog asking for the password of a new backup.
  String get exportBackupTitle;

  /// Explanation of the export dialog.
  String get exportBackupMessage;

  /// Label of the field repeating a new password.
  String get confirmPassword;

  /// Validation message of passwords shorter than [minLength].
  String passwordTooShort(int minLength);

  /// Validation message of a confirmation that differs from the password.
  String get passwordsDoNotMatch;

  /// Name of a password [strength].
  String passwordStrength(PasswordStrength strength);

  /// Warning shown when choosing the password of a backup.
  String get backupPasswordWarning;

  /// Label of the button that exports a backup.
  String get exportAction;

  /// Shown while a backup is being encrypted.
  String get encryptingBackup;

  /// Feedback after saving a backup file.
  String get backupSaved;

  /// Message shown when a backup file could not be saved.
  String get saveBackupFailed;

  /// Message shown when a backup file could not be opened.
  String get openBackupFailed;

  /// Title of the dialog shown when a file cannot be restored.
  String get invalidBackupTitle;

  /// Why a backup file cannot be restored.
  String invalidBackup(InvalidBackupReason reason);

  /// Title of the dialog that restores a backup.
  String get importBackupTitle;

  /// When the backup being restored was made.
  String backupCreatedAt(String date);

  /// Helper text of the password field of the import dialog.
  String get backupPasswordHelper;

  /// Label of the import mode choice.
  String get importModeLabel;

  /// Name of [BackupImportMode.merge].
  String get importMerge;

  /// Description of [BackupImportMode.merge].
  String get importMergeHelper;

  /// Name of [BackupImportMode.replace].
  String get importReplace;

  /// Description of [BackupImportMode.replace].
  String get importReplaceHelper;

  /// Label of the button that imports a backup.
  String get importAction;

  /// Shown while a backup is being decrypted.
  String get decryptingBackup;

  /// Title of the confirmation of [BackupImportMode.replace].
  String get replaceConfirmTitle;

  /// Body of the confirmation of [BackupImportMode.replace].
  String get replaceConfirmMessage;

  /// Label of the button that confirms [BackupImportMode.replace].
  String get replaceAction;

  /// Error shown when the password of a backup is wrong.
  String get wrongBackupPassword;

  /// Title of the summary shown after restoring a backup.
  String get backupRestored;

  /// Summary line: accounts added by a backup.
  String accountsAdded(int count);

  /// Summary line: accounts updated by a backup.
  String accountsUpdated(int count);

  /// Summary line: accounts removed by a backup.
  String accountsRemoved(int count);

  /// Summary line: provider changes imported from a backup.
  String providersImported(int count);

  /// Summary line: provider entries of a backup that were skipped.
  String providersSkipped(int count);

  /// Summary line: upload settings restored from a backup.
  String get uploadSettingsRestored;

  /// Summary shown when a backup changed nothing.
  String get backupUpToDate;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Human readable [size] using the local decimal separator.
  String formatSize(DataSize size) {
    final text = size.toString();
    return decimalSeparator == '.' ? text : text.replaceAll('.', ',');
  }

  /// Human readable [bytes].
  String formatBytes(int bytes) => formatSize(DataSize(bytes < 0 ? 0 : bytes));

  /// Transfer speed, e.g. `1.5 MB/s`.
  String formatSpeed(double bytesPerSecond) =>
      '${formatBytes(bytesPerSecond.round())}/s';

  /// Label of [field], translated for well-known credential ids.
  String credentialLabel(CredentialField field) => switch (field.id) {
    CredentialField.apiKeyId => apiKey,
    'email' => email,
    'password' => password,
    _ => field.label,
  };

  /// Message describing why an upload was rejected.
  String rejection(UploadRejection reason) => switch (reason) {
    FileTooLarge(:final size, :final maxSize) => rejectionFileTooLarge(
      formatSize(size),
      formatSize(maxSize),
    ),
    ExtensionNotAllowed(:final extension) => rejectionExtensionNotAllowed(
      extension,
    ),
    NotEnoughStorage(:final size, :final available) =>
      rejectionNotEnoughStorage(formatSize(size), formatSize(available)),
  };

  /// A user friendly message for [error].
  ///
  /// [UpCloudException]s are translated; other errors use their
  /// `toString()`.
  String errorMessage(Object error) => switch (error) {
    AuthenticationException() => errorAuthentication,
    NotFoundException() => errorNotFound,
    QuotaExceededException() => errorQuota,
    RateLimitedException(:final retryAfter) => errorRateLimited(retryAfter),
    UploadRejectedException(:final reason) => rejection(reason),
    NetworkException() => errorNetwork,
    CancelledException() => errorCancelled,
    UnsupportedOperationException() => errorUnsupported,
    ProviderException(:final message) => errorProvider(message),
    InvalidBackupException(:final reason) => invalidBackup(reason),
    WrongBackupPasswordException() => wrongBackupPassword,
    WeakBackupPasswordException(:final minLength) => passwordTooShort(
      minLength,
    ),
    _ => '$error',
  };
}

UpCloudLocalizations _fallback(Locale? locale) =>
    UpCloudLocalizations.forLocale(locale);

class _UpCloudLocalizationsDelegate
    extends LocalizationsDelegate<UpCloudLocalizations> {
  const _UpCloudLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => UpCloudLocalizations.supportedLocales.any(
    (l) => l.languageCode == locale.languageCode,
  );

  @override
  Future<UpCloudLocalizations> load(Locale locale) =>
      SynchronousFuture(UpCloudLocalizations.forLocale(locale));

  @override
  bool shouldReload(_UpCloudLocalizationsDelegate old) => false;
}
