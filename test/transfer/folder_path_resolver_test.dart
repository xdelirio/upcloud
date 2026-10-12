import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud/upcloud.dart';

void main() {
  group('normalizeFolderPath', () {
    test('trims segments and collapses slashes', () {
      expect(normalizeFolderPath(' Movies// 2026 /'), 'Movies/2026');
      expect(normalizeFolderPath('/a/b/'), 'a/b');
      expect(normalizeFolderPath('My Videos'), 'My Videos');
    });

    test('the root is an empty path', () {
      expect(normalizeFolderPath(''), '');
      expect(normalizeFolderPath(' / // '), '');
    });
  });

  group('FolderPathResolver', () {
    late InMemoryProvider memory;
    late _CountingProvider provider;
    late FolderPathResolver resolver;

    setUp(() {
      memory = InMemoryProvider(latency: const Duration(milliseconds: 2));
      provider = _CountingProvider(memory);
      resolver = FolderPathResolver(
        (id) => id == 'acc' ? provider : throw NotFoundException(id),
      );
    });

    List<String> names() => [for (final f in memory.folders) f.name];

    test('the root needs no request', () async {
      expect(await resolver.resolve('acc', ' / '), isNull);
      expect(provider.lists, 0);
    });

    test('finds existing folders ignoring case', () async {
      final movies = await memory.createFolder('Movies');
      final year = await memory.createFolder('2026', parentId: movies.id);
      await memory.createFolder('Movies 2');

      expect(await resolver.resolve('acc', 'MOVIES/2026'), year.id);
      expect(provider.creates, 0);
    });

    test('does not match partial names', () async {
      await memory.createFolder('Movies old');

      await resolver.resolve('acc', 'Movies');

      expect(names(), ['Movies old', 'Movies']);
    });

    test('creates the missing segments in the right parents', () async {
      final movies = await memory.createFolder('Movies');

      final id = await resolver.resolve('acc', 'movies/2026/January');

      final year = memory.folders.singleWhere((f) => f.name == '2026');
      final month = memory.folders.singleWhere((f) => f.name == 'January');
      expect(year.parentId, movies.id);
      expect(month.parentId, year.id);
      expect(id, month.id);
      expect(provider.creates, 2);
    });

    test('shares concurrent resolutions and caches the result', () async {
      final ids = await Future.wait([
        for (var i = 0; i < 10; i++) resolver.resolve('acc', 'A/B'),
        for (var i = 0; i < 5; i++) resolver.resolve('acc', 'a/b/C'),
        resolver.resolve('acc', 'A/D'),
      ]);

      expect(names()..sort(), ['A', 'B', 'C', 'D']);
      expect(provider.creates, 4, reason: 'one per missing folder');
      final b = memory.folders.singleWhere((f) => f.name == 'B');
      expect(ids.take(10).toSet(), {b.id});

      final lists = provider.lists;
      expect(await resolver.resolve('acc', 'a/B'), b.id);
      expect(provider.lists, lists, reason: 'cached');
    });

    test('looks up without creating when asked', () async {
      await expectLater(
        resolver.resolve('acc', 'Missing', create: false),
        throwsA(isA<NotFoundException>()),
      );
      expect(memory.folders, isEmpty);

      final created = await resolver.resolve('acc', 'Missing');
      expect(await resolver.resolve('acc', 'missing', create: false), created);
    });

    test('reads later pages until the folders run out', () async {
      for (var i = 0; i < 150; i++) {
        await memory.createFolder('Folder $i');
      }
      await memory.createFolder('Target');

      final id = await resolver.resolve('acc', 'target');

      expect(id, memory.folders.last.id);
      expect(provider.pages, [1, 2]);
      expect(provider.creates, 0);
    });

    test('stops at the first page with files', () async {
      await memory.createFolder('Other');
      final upload = await memory.prepareUpload(
        const UploadFileInfo(name: 'a.mp4', size: 1),
      );
      await memory.completeUpload(
        upload,
        const UploadResponse(statusCode: 200, body: ''),
      );

      await resolver.resolve('acc', 'New');

      expect(provider.pages, [1]);
      expect(names(), ['Other', 'New']);
    });

    test('does not cache failures', () async {
      provider.failNextList = true;

      await expectLater(
        resolver.resolve('acc', 'A'),
        throwsA(isA<NetworkException>()),
      );
      await resolver.resolve('acc', 'A');

      expect(names(), ['A']);
    });

    test('forgets invalidated folders and their parents', () async {
      await resolver.resolve('acc', 'A/B');
      final lists = provider.lists;

      resolver.invalidate('acc', 'a/b');
      await resolver.resolve('acc', 'A/B');

      expect(provider.lists, lists + 2, reason: 'A and B looked up again');
      resolver.invalidate('acc');
      await resolver.resolve('acc', 'A');
      expect(provider.lists, lists + 3);
      expect(names(), ['A', 'B']);
    });

    test('cannot create folders without the capability', () async {
      final readOnly = FolderPathResolver((_) => _BrowseOnlyProvider());

      expect(await readOnly.resolve('acc', 'Existing'), const FolderId('e1'));
      await expectLater(
        readOnly.resolve('acc', 'Existing/New'),
        throwsA(
          isA<UnsupportedOperationException>().having(
            (e) => e.message,
            'message',
            contains('cannot create folders'),
          ),
        ),
      );
    });

    test('cannot find folders without browsing', () async {
      final blind = FolderPathResolver(
        (_) => _CountingProvider(memory, browse: false),
      );

      await expectLater(
        blind.resolve('acc', 'A'),
        throwsA(isA<UnsupportedOperationException>()),
      );
    });
  });
}

/// Delegates to an [InMemoryProvider] and counts the calls.
final class _CountingProvider implements FolderBrowsing, FolderManaging {
  _CountingProvider(this._inner, {bool browse = true})
    : capabilities = {
        if (browse) Capability.browseFolders,
        Capability.createFolder,
      };

  final InMemoryProvider _inner;
  final List<int> pages = [];
  int creates = 0;
  bool failNextList = false;

  int get lists => pages.length;

  @override
  ProviderInfo get info => _inner.info;

  @override
  ProviderLimits get limits => _inner.limits;

  @override
  final Set<Capability> capabilities;

  @override
  void close() {}

  @override
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  }) {
    pages.add(page.page);
    if (failNextList) {
      failNextList = false;
      throw const NetworkException('offline');
    }
    return _inner.listFolder(folderId, page: page);
  }

  @override
  Future<CloudFolder> createFolder(String name, {FolderId? parentId}) {
    creates++;
    return _inner.createFolder(name, parentId: parentId);
  }

  @override
  Future<void> renameFolder(FolderId id, String name) =>
      _inner.renameFolder(id, name);

  @override
  Future<void> moveFolder(FolderId id, FolderId? parentId) =>
      _inner.moveFolder(id, parentId);

  @override
  Future<void> deleteFolder(FolderId id) => _inner.deleteFolder(id);
}

/// A provider with one folder that cannot create folders.
final class _BrowseOnlyProvider implements FolderBrowsing {
  @override
  ProviderInfo get info => const ProviderInfo(id: 'browse', name: 'Browse');

  @override
  ProviderLimits get limits => ProviderLimits.none;

  @override
  Set<Capability> get capabilities => interfaceCapabilities(this);

  @override
  void close() {}

  @override
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  }) async => PagedResult(
    items: [
      if (folderId == null)
        const CloudFolder(id: FolderId('e1'), name: 'Existing'),
    ],
    request: page,
  );
}
