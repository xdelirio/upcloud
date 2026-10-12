import 'package:upcloud/src/core/http/json_readers.dart';
import 'package:upcloud/src/core/models/account_info.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/models/ids.dart';
import 'package:upcloud/src/core/models/remote_upload.dart';
import 'package:upcloud/src/drivers/xvs/xvs_dtos.dart';
import 'package:upcloud/src/registry/provider_config.dart';

/// Converts XVS API objects into upcloud models.
final class XvsMapper {
  /// Creates a mapper that builds the links the API does not return with
  /// [fileUrlTemplate] (see `ProviderConfig.fileUrlTemplate`).
  const XvsMapper({this.fileUrlTemplate});

  /// Public link of a file, `{id}` is the file code.
  final String? fileUrlTemplate;

  /// Link of the file [code] built from [fileUrlTemplate], or `null`.
  Uri? fileUrl(String code) =>
      ProviderConfig.expandFileUrl(fileUrlTemplate, code);

  /// Id of the root folder in the XVS API.
  static const rootFolderId = '0';

  /// Converts an API folder id: `0` (the root) and empty values become
  /// `null`.
  static FolderId? folderId(String? raw) =>
      raw == null || raw.isEmpty || raw == rootFolderId ? null : FolderId(raw);

  /// API value for [id] (`0` for the root).
  static String folderParam(FolderId? id) => id?.value ?? rootFolderId;

  /// Size of [bytes], ignoring unknown or negative values.
  static DataSize? size(int? bytes) =>
      bytes == null || bytes < 0 ? null : DataSize(bytes);

  /// Converts a `file/list`, `folder/list` or `file/info` entry.
  ///
  /// [folderId] is used when the entry does not say where it lives.
  /// Returns `null` for entries without a file code.
  CloudFile? file(Map<String, Object?> json, {FolderId? folderId}) {
    final dto = XvsFileDto.fromJson(json);
    final code = dto.code;
    if (code == null) return null;
    final duration = dto.length;
    return CloudFile(
      id: FileId(code),
      name: dto.title ?? code,
      folderId: dto.folderId == null
          ? folderId
          : XvsMapper.folderId(dto.folderId),
      size: size(dto.size) ?? _largestVersion(dto.sizes),
      createdAt: dto.createdAt,
      thumbnailUrl: dto.thumbnail,
      pageUrl: dto.link ?? fileUrl(code),
      duration: duration == null || duration == Duration.zero ? null : duration,
      views: dto.views,
      isPublic: dto.isPublic,
      isReady: dto.canPlay,
      extra: readExtra(json, XvsFileDto.knownKeys),
    );
  }

  /// Converts a `folder/list` entry. Returns `null` for entries without id.
  CloudFolder? folder(Map<String, Object?> json, {FolderId? parentId}) {
    final dto = XvsFolderDto.fromJson(json);
    final id = dto.id;
    if (id == null) return null;
    return CloudFolder(
      id: FolderId(id),
      name: dto.name ?? id,
      parentId: dto.parentId == null
          ? parentId
          : XvsMapper.folderId(dto.parentId),
      fileCount: dto.fileCount,
      extra: readExtra(json, XvsFolderDto.knownKeys),
    );
  }

  /// Converts the result of `account/info`.
  AccountInfo account(Map<String, Object?> json) {
    final dto = XvsAccountDto.fromJson(json);
    final expires = dto.premiumExpire;
    return AccountInfo(
      login: dto.login,
      email: dto.email,
      storageUsed: size(dto.storageUsed),
      storageLeft: size(dto.storageLeft),
      filesTotal: dto.filesTotal,
      isPremium:
          dto.premium ?? (expires != null && expires.isAfter(DateTime.now())),
      premiumUntil: expires,
      balance: dto.balance,
      extra: readExtra(json, XvsAccountDto.knownKeys),
    );
  }

  /// Converts a `file/url_uploads` entry.
  ///
  /// The job id is the future file code, or the source URL while the
  /// provider has not assigned one.
  RemoteUploadJob remoteUpload(Map<String, Object?> json) {
    final dto = XvsRemoteUploadDto.fromJson(json);
    final code = dto.code;
    final status = remoteStatus(dto.status);
    return RemoteUploadJob(
      id: code ?? dto.url?.toString() ?? '',
      status: status,
      fileId: code == null ? null : FileId(code),
      sourceUrl: dto.url,
      folderId: folderId(dto.folderId),
      progress: readPercent(dto.progress),
      error:
          dto.error ??
          (status == RemoteUploadStatus.failed ? dto.status : null),
      extra: readExtra(json, XvsRemoteUploadDto.knownKeys),
    );
  }

  /// Maps the raw status of a remote upload.
  static RemoteUploadStatus remoteStatus(String? raw) {
    final status = raw?.trim().toUpperCase() ?? '';
    if (status.isEmpty) return RemoteUploadStatus.unknown;
    if (status.startsWith('ERR') || status.startsWith('FAIL')) {
      return RemoteUploadStatus.failed;
    }
    return switch (status) {
      'PENDING' || 'QUEUED' || 'NEW' || 'WAITING' => RemoteUploadStatus.pending,
      'WORKING' ||
      'DOWNLOADING' ||
      'PROCESSING' ||
      'UPLOADING' ||
      'STARTED' ||
      'RUNNING' => RemoteUploadStatus.working,
      'OK' ||
      'DONE' ||
      'COMPLETE' ||
      'COMPLETED' ||
      'FINISHED' ||
      'SUCCESS' => RemoteUploadStatus.completed,
      'BROKEN' || 'CANCELLED' || 'CANCELED' => RemoteUploadStatus.failed,
      _ => RemoteUploadStatus.unknown,
    };
  }

  /// Size of the original version, or of the largest one.
  static DataSize? _largestVersion(List<XvsVersionDto> versions) {
    int? largest;
    for (final version in versions) {
      final bytes = version.size;
      if (bytes == null) continue;
      if (version.name == 'o') return size(bytes);
      if (largest == null || bytes > largest) largest = bytes;
    }
    return size(largest);
  }
}

/// Objects of the list [value]; a single object is wrapped in a list.
List<Map<String, Object?>> xvsObjects(Object? value) {
  if (value is Map) return [value.cast<String, Object?>()];
  return [
    for (final item in readList(value))
      if (item is Map) item.cast<String, Object?>(),
  ];
}
