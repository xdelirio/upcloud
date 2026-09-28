import 'dart:async';

import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/ids.dart';
import 'package:upcloud/src/core/models/paging.dart';

/// Resolves the provider connected to an account.
typedef ProviderResolver = CloudProvider Function(String accountId);

/// Normalizes a folder [path]: trims every segment, drops empty ones and
/// joins them with a single `/`. The root folder is the empty string.
///
/// ```dart
/// normalizeFolderPath(' Movies// 2026 /'); // 'Movies/2026'
/// ```
String normalizeFolderPath(String path) => _segments(path).join('/');

List<String> _segments(String path) => [
  for (final segment in path.split('/'))
    if (segment.trim() case final name when name.isNotEmpty) name,
];

/// Finds folders by path (e.g. `Movies/2026`) and creates the missing ones.
///
/// Each segment is looked up by name in its parent, starting at the root,
/// with a case-insensitive exact match. Results are cached per account and
/// path for the lifetime of the resolver, and concurrent resolutions of the
/// same folder share one lookup, so uploading many files to the same path
/// lists and creates each folder once.
final class FolderPathResolver {
  /// Creates a resolver that gets the provider of each account from the
  /// given function.
  FolderPathResolver(this._resolveProvider);

  /// Pages read from a folder before giving up on finding a subfolder.
  static const _maxPages = 1000;

  final ProviderResolver _resolveProvider;
  final _cache = <(String, String), Future<FolderId?>>{};

  /// Id of the folder at [path] in account [accountId]; `null` for the root
  /// (an empty path).
  ///
  /// Missing folders are created when [create] is true; otherwise a
  /// [NotFoundException] is thrown. Throws [UnsupportedOperationException]
  /// when the provider cannot browse folders, or cannot create a missing
  /// one.
  Future<FolderId?> resolve(
    String accountId,
    String path, {
    bool create = true,
  }) => _resolve(accountId, _segments(path), create: create);

  /// Forgets the cached folder at [path] of [accountId], its parents and
  /// its subfolders, or every folder of the account when [path] is `null`.
  ///
  /// Call it when a cached folder turns out to be gone.
  void invalidate(String accountId, [String? path]) {
    if (path == null) {
      _cache.removeWhere((key, _) => key.$1 == accountId);
      return;
    }
    final target = _key(accountId, _segments(path)).$2;
    _cache.removeWhere(
      (key, _) =>
          key.$1 == accountId &&
          (key.$2 == target ||
              key.$2.startsWith('$target/') ||
              target.startsWith('${key.$2}/')),
    );
  }

  Future<FolderId?> _resolve(
    String accountId,
    List<String> segments, {
    required bool create,
  }) {
    if (segments.isEmpty) return Future.value();
    final key = _key(accountId, segments);
    final cached = _cache[key];
    if (cached != null) return cached;

    final future = _lookup(accountId, segments, create: create);
    if (!create) {
      // Not shared while running: a concurrent call that may create the
      // folder must not fail because of it.
      return future.then((id) {
        _cache.putIfAbsent(key, () => Future.value(id));
        return id;
      });
    }
    _cache[key] = future;
    unawaited(
      future.then<void>(
        (_) {},
        onError: (Object _) => _cache.removeWhere(
          (k, cached) => k == key && identical(cached, future),
        ),
      ),
    );
    return future;
  }

  Future<FolderId?> _lookup(
    String accountId,
    List<String> segments, {
    required bool create,
  }) async {
    final parentId = await _resolve(
      accountId,
      segments.sublist(0, segments.length - 1),
      create: create,
    );
    final provider = _resolveProvider(accountId);
    final name = segments.last;
    final path = segments.join('/');
    final existing = await _find(provider, parentId, name, path);
    if (existing != null) return existing;
    if (!create) {
      throw NotFoundException('The folder "$path" does not exist');
    }
    final manager = provider.capability<FolderManaging>();
    if (manager == null || !provider.supports(Capability.createFolder)) {
      throw UnsupportedOperationException(
        '${provider.info.name} cannot create folders: create "$path" in '
        'the account first',
      );
    }
    return (await manager.createFolder(name, parentId: parentId)).id;
  }

  /// Subfolder of [parentId] called [name] (case-insensitive), or `null`.
  static Future<FolderId?> _find(
    CloudProvider provider,
    FolderId? parentId,
    String name,
    String path,
  ) async {
    final browser = provider.capability<FolderBrowsing>();
    if (browser == null || !provider.supports(Capability.browseFolders)) {
      throw UnsupportedOperationException(
        '${provider.info.name} cannot browse folders, so the folder "$path" '
        'cannot be found',
      );
    }
    final wanted = name.toLowerCase();
    var page = const PageRequest(perPage: 100);
    for (var i = 0; i < _maxPages; i++) {
      final result = await browser.listFolder(parentId, page: page);
      var hasFolders = false;
      var hasFiles = false;
      for (final entry in result.items) {
        switch (entry) {
          case CloudFolder(:final id, name: final folderName):
            hasFolders = true;
            if (folderName.trim().toLowerCase() == wanted) return id;
          case CloudFile():
            hasFiles = true;
        }
      }
      // Folders are listed first (some providers only on the first page):
      // once a page has files or no folders, there are no more folders.
      if (hasFiles || !hasFolders || !result.hasMore) return null;
      page = page.next;
    }
    return null;
  }

  static (String, String) _key(String accountId, List<String> segments) =>
      (accountId, segments.join('/').toLowerCase());
}
