import 'package:upcloud/src/core/http/json_readers.dart';
import 'package:upcloud/src/core/models/account_info.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/models/ids.dart';
import 'package:upcloud/src/core/models/remote_upload.dart';
import 'package:upcloud/src/registry/provider_config.dart';

// Hand written mappers from Byse JSON objects to domain models.
//
// The API inherits its payloads from Filemoon/XVideoSharing and is not
// consistent (`file_code` vs `filecode`, `title` vs `name`, numbers sent as
// strings...), so every field is read with the lenient json readers.

/// Reads a folder id where `0`/empty means the root folder (`null`).
FolderId? byseFolderId(Object? value) {
  final id = readString(value)?.trim();
  return id == null || id.isEmpty || id == '0' ? null : FolderId(id);
}

/// Value sent as `fld_id`/`parent_id` for [id] (`0` is the root folder).
String byseFolderParam(FolderId? id) => id?.value ?? '0';

/// Reads the file code of a file object (`file_code` or `filecode`).
String? byseFileCode(Map<String, Object?> json) {
  final code = readString(json['file_code'] ?? json['filecode'])?.trim();
  return code == null || code.isEmpty || code == 'undef' ? null : code;
}

const _fileKeys = {
  'file_code',
  'filecode',
  'title',
  'file_title',
  'name',
  'fld_id',
  'file_fld_id',
  'size',
  'file_size',
  'uploaded',
  'file_created',
  'thumbnail',
  'player_img',
  'link',
  'length',
  'file_length',
  'views',
  'file_views',
  'public',
  'file_public',
  'canplay',
  'status',
};

/// Converts a file object from `/file/list`, `/file/info` or `/folder/list`.
///
/// `/file/info` prefixes most fields with `file_` (`file_title`,
/// `file_fld_id`, `file_length`...) and names the thumbnail `player_img`;
/// both spellings are accepted.
///
/// [fileUrlTemplate] builds the link (`{id}` is the file code) when the
/// API does not return a `link`. Returns `null` when the object has no file
/// code.
CloudFile? byseFileFromJson(
  Map<String, Object?> json, {
  String? fileUrlTemplate,
}) {
  final code = byseFileCode(json);
  if (code == null) return null;
  Object? read(String key) => json[key] ?? json['file_$key'];
  final size = readInt(read('size'));
  final length = readSecondsDuration(read('length'));
  return CloudFile(
    id: FileId(code),
    name:
        readString(read('title')) ??
        readString(json['name']) ??
        readString(json['file_name']) ??
        code,
    folderId: byseFolderId(read('fld_id')),
    size: size == null || size < 0 ? null : DataSize(size),
    createdAt: readDateTime(json['uploaded'] ?? json['file_created']),
    thumbnailUrl: readUri(json['thumbnail'] ?? json['player_img']),
    pageUrl:
        readUri(json['link']) ??
        ProviderConfig.expandFileUrl(fileUrlTemplate, code),
    duration: length == null || length == Duration.zero ? null : length,
    views: readInt(read('views')),
    isPublic: readBool(read('public')),
    isReady: readBool(json['canplay']),
    extra: _extra(json, _fileKeys),
  );
}

const _folderKeys = {'fld_id', 'name', 'parent_id'};

/// Converts a folder object from `/folder/list`.
///
/// [parentId] is used when the object does not report its parent. Returns
/// `null` when the object has no id.
CloudFolder? byseFolderFromJson(
  Map<String, Object?> json, {
  FolderId? parentId,
}) {
  final id = byseFolderId(json['fld_id']);
  if (id == null) return null;
  return CloudFolder(
    id: id,
    name: readString(json['name']) ?? id.value,
    parentId: json.containsKey('parent_id')
        ? byseFolderId(json['parent_id'])
        : parentId,
    extra: _extra(json, _folderKeys),
  );
}

/// A page of `/file/list`.
typedef ByseFilePage = ({
  List<Map<String, Object?>> files,
  int? totalItems,
  int? totalPages,
});

/// Reads the `result` of `/file/list`.
///
/// The documentation shows a plain list, while the XVS-style API returns
/// `{"files": [...], "results_total": "9", "pages": 1}`. Both are accepted.
/// Entries with an error `status` (e.g. `404`) are skipped.
ByseFilePage byseFilePageFromJson(Object? result) {
  final map = readMap(result);
  final items = map == null ? readList(result) : readList(map['files']);
  return (
    files: [
      for (final item in items)
        if (readMap(item) case final file?)
          if (readInt(file['status']) case null || 200) file,
    ],
    totalItems: map == null
        ? null
        : readInt(map['results_total'] ?? map['total']),
    totalPages: map == null ? null : readInt(map['pages']),
  );
}

const _accountKeys = {
  'login',
  'email',
  'balance',
  'storage_used',
  'storage_left',
  'premium_expire',
  'premim_expire',
  'premium',
  'files_total',
};

/// Converts the `result` of `/account/info`.
///
/// The account is premium when `premium_expire` (spelled `premim_expire` in
/// the documentation) is after [now].
AccountInfo byseAccountFromJson(Map<String, Object?> json, {DateTime? now}) {
  final premiumUntil = readDateTime(
    json['premium_expire'] ?? json['premim_expire'],
  );
  final used = readInt(json['storage_used']);
  final left = readInt(json['storage_left']);
  return AccountInfo(
    login: readString(json['login']),
    email: readString(json['email']),
    storageUsed: used == null || used < 0 ? null : DataSize(used),
    storageLeft: left == null || left < 0 ? null : DataSize(left),
    filesTotal: readInt(json['files_total']),
    isPremium:
        readBool(json['premium']) ??
        (premiumUntil?.isAfter(now ?? DateTime.now()) ?? false),
    premiumUntil: premiumUntil,
    balance: readString(json['balance']),
    extra: _extra(json, _accountKeys),
  );
}

const _remoteKeys = {'url', 'progress', 'status', 'error_msg', 'file_code'};

/// Converts the `result` of `/remote/status` for job [id].
///
/// Byse identifies remote uploads by the code of the future file, so [id]
/// is also the resulting file id.
RemoteUploadJob byseRemoteJobFromJson(String id, Map<String, Object?> json) {
  final error = readString(json['error_msg'])?.trim();
  final code = byseFileCode(json) ?? id;
  return RemoteUploadJob(
    id: id,
    status: byseRemoteStatus(readString(json['status'])),
    fileId: FileId(code),
    sourceUrl: readUri(json['url']),
    progress: bysePercent(json['progress']),
    error: error == null || error.isEmpty ? null : error,
    extra: _extra(json, _remoteKeys),
  );
}

/// Maps a remote upload status text (e.g. `WORKING`) to
/// [RemoteUploadStatus].
RemoteUploadStatus byseRemoteStatus(String? status) =>
    switch (status?.trim().toUpperCase()) {
      'PENDING' || 'QUEUED' || 'NEW' || 'WAITING' => RemoteUploadStatus.pending,
      'WORKING' ||
      'DOWNLOADING' ||
      'PROCESSING' ||
      'UPLOADING' => RemoteUploadStatus.working,
      'OK' ||
      'DONE' ||
      'COMPLETED' ||
      'FINISHED' ||
      'SUCCESS' => RemoteUploadStatus.completed,
      'ERROR' || 'FAILED' || 'FAIL' || 'BROKEN' => RemoteUploadStatus.failed,
      _ => RemoteUploadStatus.unknown,
    };

/// Reads a percentage (`55`, `"55"`, `"55%"`) as a fraction between 0 and 1.
double? bysePercent(Object? value) {
  final text = readString(value)?.replaceAll('%', '');
  final percent = readDouble(text);
  if (percent == null) return null;
  return (percent / 100).clamp(0, 1).toDouble();
}

Map<String, Object?> _extra(Map<String, Object?> json, Set<String> known) => {
  for (final MapEntry(:key, :value) in json.entries)
    if (!known.contains(key) && value != null) key: value,
};
