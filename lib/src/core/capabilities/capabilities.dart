import 'package:upcloud/src/core/cancellation.dart';
import 'package:upcloud/src/core/models/account_info.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/ids.dart';
import 'package:upcloud/src/core/models/paging.dart';
import 'package:upcloud/src/core/models/remote_upload.dart';
import 'package:upcloud/src/core/models/upload.dart';
import 'package:upcloud/src/core/models/upload_request.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';

/// Operations a provider may support.
///
/// Providers declare the operations they support in
/// [CloudProvider.capabilities]. Use it (or
/// [CloudProviderCapabilities.supports]) to decide which actions to offer:
/// a provider may implement an interface only partially, e.g. Byse can
/// create folders but not rename them.
enum Capability {
  /// [FolderBrowsing.listFolder].
  browseFolders,

  /// [FolderManaging.createFolder].
  createFolder,

  /// [FolderManaging.renameFolder].
  renameFolder,

  /// [FolderManaging.moveFolder].
  moveFolder,

  /// [FolderManaging.deleteFolder].
  deleteFolder,

  /// [FileManaging.fileInfo].
  fileInfo,

  /// [FileManaging.renameFile].
  renameFile,

  /// [FileManaging.moveFile].
  moveFile,

  /// [FileManaging.deleteFile].
  deleteFile,

  /// [FileSearching.searchFiles].
  search,

  /// [FileUploading.prepareUpload] and [FileUploading.completeUpload].
  upload,

  /// [RemoteUploading].
  remoteUpload,

  /// [AccountInfoProviding.accountInfo].
  accountInfo;

  /// Every folder management operation.
  static const Set<Capability> folderManagement = {
    createFolder,
    renameFolder,
    moveFolder,
    deleteFolder,
  };

  /// Every file management operation.
  static const Set<Capability> fileManagement = {
    fileInfo,
    renameFile,
    moveFile,
    deleteFile,
  };
}

/// A connection to one account of a storage provider.
///
/// A provider implements the capability interfaces of its API
/// ([FolderBrowsing], [FileUploading], ...) and lists the operations it
/// actually supports in [capabilities]; the other methods throw
/// `UnsupportedOperationException`. Check them with
/// [CloudProviderCapabilities.supports] and get the interface with
/// [CloudProviderCapabilities.capability]:
///
/// ```dart
/// if (provider case final RemoteUploading remote) {
///   await remote.uploadFromUrl(Uri.parse('https://example.com/video.mp4'));
/// }
/// ```
abstract interface class CloudProvider {
  /// Static description of the provider.
  ProviderInfo get info;

  /// Operations this provider supports.
  ///
  /// Use [interfaceCapabilities] for providers that support every
  /// operation of the interfaces they implement.
  Set<Capability> get capabilities;

  /// Limits applied to uploads and requests.
  ProviderLimits get limits;

  /// Releases network resources. The provider cannot be used afterwards.
  void close();
}

/// Lists the content of folders.
abstract interface class FolderBrowsing implements CloudProvider {
  /// Lists folders and files inside [folderId] (`null` is the root).
  ///
  /// Folders are returned before files on the first page.
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  });
}

/// Creates, renames, moves and deletes folders.
abstract interface class FolderManaging implements CloudProvider {
  /// Creates a folder called [name] inside [parentId] (`null` is the root).
  Future<CloudFolder> createFolder(String name, {FolderId? parentId});

  /// Renames the folder [id] to [name].
  Future<void> renameFolder(FolderId id, String name);

  /// Moves the folder [id] into [parentId] (`null` is the root).
  Future<void> moveFolder(FolderId id, FolderId? parentId);

  /// Deletes the folder [id]. Some providers require it to be empty.
  Future<void> deleteFolder(FolderId id);
}

/// Reads, renames, moves and deletes files.
abstract interface class FileManaging implements CloudProvider {
  /// Details of file [id]. Throws `NotFoundException` if it does not exist.
  Future<CloudFile> fileInfo(FileId id);

  /// Renames the file [id] to [name].
  Future<void> renameFile(FileId id, String name);

  /// Moves the file [id] into [folderId] (`null` is the root).
  Future<void> moveFile(FileId id, FolderId? folderId);

  /// Deletes the file [id].
  Future<void> deleteFile(FileId id);
}

/// Searches files by name.
abstract interface class FileSearching implements CloudProvider {
  /// Files whose name contains [query], optionally limited to [folderId].
  Future<PagedResult<CloudFile>> searchFiles(
    String query, {
    FolderId? folderId,
    PageRequest page = PageRequest.first,
  });
}

/// Uploads local content in three steps.
///
/// Providers do not send the file themselves: they describe the HTTP
/// request and interpret its response, while an `UploadExecutor` (a
/// background upload in Flutter apps) sends the bytes:
///
/// ```dart
/// final request = await uploader.prepareUpload(
///   await source.resolveInfo(),
///   options: const UploadOptions(title: 'Trailer'),
/// );
/// final response = await executor.execute(request, source);
/// final file = await uploader.completeUpload(request, response);
/// ```
///
/// `TransferManager` runs these steps, with validation, retries and
/// progress.
abstract interface class FileUploading implements CloudProvider {
  /// Prepares the HTTP request that uploads [file] with [options].
  ///
  /// May call the API (e.g. to get an upload server or a session token).
  /// Throws `UploadRejectedException` when the provider knows the file will
  /// be refused.
  Future<UploadRequest> prepareUpload(
    UploadFileInfo file, {
    UploadOptions options = const UploadOptions(),
  });

  /// Reads the server [response] to [request] (as returned by
  /// [prepareUpload]) and returns the uploaded file.
  ///
  /// May call the API (e.g. to wait until the file is processed); a long
  /// wait stops with a `CancelledException` when [cancelToken] is
  /// cancelled. Throws the matching `UpCloudException` when the upload
  /// failed.
  Future<CloudFile> completeUpload(
    UploadRequest request,
    UploadResponse response, {
    CancellationToken? cancelToken,
  });
}

/// Asks the provider to download a file from a URL ("remote upload").
abstract interface class RemoteUploading implements CloudProvider {
  /// Queues the download of [url] on the provider's servers.
  Future<RemoteUploadJob> uploadFromUrl(
    Uri url, {
    UploadOptions options = const UploadOptions(),
  });

  /// Current remote upload jobs of the account.
  ///
  /// Some APIs cannot list jobs; they return the jobs queued through this
  /// instance.
  Future<List<RemoteUploadJob>> remoteUploads();

  /// Current state of job [jobId]. Throws `NotFoundException` if unknown.
  Future<RemoteUploadJob> remoteUploadStatus(String jobId);

  /// Cancels/removes the remote upload [jobId].
  Future<void> cancelRemoteUpload(String jobId);
}

/// Reports information about the account.
abstract interface class AccountInfoProviding implements CloudProvider {
  /// Storage, premium status and other account details.
  Future<AccountInfo> accountInfo();
}

/// Every operation of the capability interfaces [provider] implements.
///
/// Convenient for providers that support their interfaces completely:
///
/// ```dart
/// @override
/// late final Set<Capability> capabilities = interfaceCapabilities(this);
/// ```
Set<Capability> interfaceCapabilities(CloudProvider provider) => {
  if (provider is FolderBrowsing) Capability.browseFolders,
  if (provider is FolderManaging) ...Capability.folderManagement,
  if (provider is FileManaging) ...Capability.fileManagement,
  if (provider is FileSearching) Capability.search,
  if (provider is FileUploading) Capability.upload,
  if (provider is RemoteUploading) Capability.remoteUpload,
  if (provider is AccountInfoProviding) Capability.accountInfo,
};

/// Helpers to inspect the capabilities of a [CloudProvider].
extension CloudProviderCapabilities on CloudProvider {
  /// Whether this provider supports [capability].
  bool supports(Capability capability) => capabilities.contains(capability);

  /// This provider as [T], or `null` if it does not implement it.
  ///
  /// Implementing an interface does not mean every operation is supported:
  /// check [supports] too.
  ///
  /// ```dart
  /// final uploader = provider.capability<FileUploading>();
  /// ```
  T? capability<T extends CloudProvider>() {
    final self = this;
    return self is T ? self : null;
  }
}
