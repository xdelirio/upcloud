import 'dart:math' as math;

import 'package:upcloud/src/core/models/account_info.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/models/ids.dart';
import 'package:upcloud/src/core/models/remote_upload.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_dtos.dart';
import 'package:upcloud/src/registry/provider_config.dart';

/// Folder key MediaFire accepts as an alias of the root ("My Files").
const mediaFireRootKey = 'myfiles';

/// MediaFire key for [id], using [mediaFireRootKey] for the root.
String mediaFireFolderKey(FolderId? id) {
  final value = id?.value.trim();
  return value == null || value.isEmpty ? mediaFireRootKey : value;
}

/// [FolderId] for a MediaFire folder key; `null` for the root.
FolderId? mediaFireFolderId(String? key) {
  if (key == null || key.isEmpty || key == mediaFireRootKey) return null;
  return FolderId(key);
}

/// Converts MediaFire DTOs into core models.
extension MediaFireFileMapper on MediaFireFileDto {
  /// The file as a [CloudFile].
  ///
  /// [parentKey] (the listed folder) overrides `parent_folderkey`, which
  /// listings do not include. The link is `links.normal_download`, or is
  /// built from [fileUrlTemplate] (`{id}` is the quickkey) when the API
  /// does not return it.
  CloudFile toCloudFile({String? parentKey, String? fileUrlTemplate}) {
    final key = quickkey ?? '';
    final bytes = size;
    return CloudFile(
      id: FileId(key),
      name: filename ?? key,
      folderId: mediaFireFolderId(parentKey ?? parentFolderKey),
      size: bytes == null ? null : DataSize(math.max(0, bytes)),
      createdAt: createdUtc ?? created,
      pageUrl:
          links?.normalDownload ??
          ProviderConfig.expandFileUrl(fileUrlTemplate, key),
      views: views,
      isPublic: switch (privacy) {
        'public' => true,
        'private' => false,
        _ => null,
      },
      isReady: ready,
      extra: {
        'hash': ?hash,
        'mimetype': ?mimetype,
        'filetype': ?filetype,
        'downloads': ?downloads,
        'description': ?_nonEmpty(description),
        'revision': ?revision,
        'passwordProtected': ?passwordProtected,
        'deletedAt': ?deleteDate,
      },
    );
  }
}

/// Converts MediaFire folder DTOs into core models.
extension MediaFireFolderMapper on MediaFireFolderDto {
  /// The folder as a [CloudFolder].
  ///
  /// [parentKey] (the listed folder) overrides `parent_folderkey`, which
  /// listings do not include.
  CloudFolder toCloudFolder({String? parentKey}) {
    final key = folderkey ?? '';
    return CloudFolder(
      id: FolderId(key),
      name: name ?? key,
      parentId: mediaFireFolderId(parentKey ?? parentFolderKey),
      createdAt: createdUtc ?? created,
      fileCount: fileCount,
      extra: {
        'folderCount': ?folderCount,
        'privacy': ?privacy,
        'description': ?_nonEmpty(description),
        'revision': ?revision,
      },
    );
  }
}

/// Converts `user/get_info` into [AccountInfo].
extension MediaFireUserInfoMapper on MediaFireUserInfoDto {
  /// The account information.
  AccountInfo toAccountInfo() {
    final used = usedStorageSize;
    final limit = storageLimit;
    final fullName = [?_nonEmpty(firstName), ?_nonEmpty(lastName)].join(' ');
    return AccountInfo(
      login: _nonEmpty(displayName) ?? _nonEmpty(fullName) ?? email,
      email: email,
      storageUsed: used == null ? null : DataSize(math.max(0, used)),
      storageLeft: limit == null
          ? null
          : DataSize(math.max(0, limit - (used ?? 0))),
      isPremium: premium ?? false,
      extra: {
        'storageLimit': ?limit,
        'baseStorage': ?baseStorage,
        'bonusStorage': ?bonusStorage,
        'storageLimitExceeded': ?storageLimitExceeded,
        'bandwidth': ?bandwidth,
        'validated': ?validated,
        'createdAt': ?created,
        'firstName': ?_nonEmpty(firstName),
        'lastName': ?_nonEmpty(lastName),
      },
    );
  }
}

/// Converts `upload/get_web_uploads` items into [RemoteUploadJob]s.
extension MediaFireWebUploadMapper on MediaFireWebUploadDto {
  /// The web upload as a [RemoteUploadJob].
  RemoteUploadJob toRemoteUploadJob() {
    final errorCode = errorStatus;
    final failed = errorCode != null && errorCode != 0;
    final percent = percentage;
    final key = quickkey;
    return RemoteUploadJob(
      id: uploadkey ?? '',
      status: failed ? RemoteUploadStatus.failed : _status(statusCode),
      fileId: key == null ? null : FileId(key),
      sourceUrl: url,
      progress: percent == null ? null : (percent / 100).clamp(0, 1).toDouble(),
      error: failed ? _webUploadError(errorCode) : null,
      extra: {
        'filename': ?filename,
        'status': ?status,
        'statusCode': ?statusCode,
        'errorStatus': ?errorStatus,
        'eta': ?eta,
        'size': ?size,
        'createdAt': ?created,
      },
    );
  }

  static RemoteUploadStatus _status(int? code) => switch (code) {
    1 => RemoteUploadStatus.pending,
    2 || 3 || 4 || 5 || 6 => RemoteUploadStatus.working,
    99 => RemoteUploadStatus.completed,
    _ => RemoteUploadStatus.unknown,
  };

  static String _webUploadError(int code) => switch (code) {
    9 || 14 => 'Download failed ($code)',
    10 => 'File too big',
    11 => 'File too small',
    15 => 'HTTP error',
    16 => 'Missing file',
    17 => 'Image too big',
    19 => 'Virus detected',
    38 => 'Partial file',
    39 => 'Storage full',
    _ => 'Web upload failed ($code)',
  };
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}
