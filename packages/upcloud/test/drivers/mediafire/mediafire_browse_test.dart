import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:upcloud/upcloud.dart';

import '../../support/bundled_providers.dart';
import 'mediafire_harness.dart';

/// A `folder/get_content` chunk of [count] generated items starting at
/// [first].
Map<String, Object?> contentChunk(
  String type, {
  required int first,
  required int count,
  required bool more,
}) => success({
  'action': 'folder/get_content',
  'folder_content': {
    'chunk_size': '100',
    'content_type': type,
    type: [
      for (var i = first; i < first + count; i++)
        if (type == 'folders')
          {'folderkey': 'folder$i', 'name': 'Folder $i'}
        else
          {'quickkey': 'file$i', 'filename': 'File $i.txt', 'size': '$i'},
    ],
    'more_chunks': more ? 'yes' : 'no',
  },
});

/// Serves [folders] folders and [files] files in chunks of 100.
void serveContent(
  MediaFireHarness mf, {
  required int folders,
  required int files,
}) {
  mf.onCallback('folder/get_content', (options) {
    final data = fields(options);
    final type = data['content_type']! as String;
    final chunk = int.parse(data['chunk']! as String);
    final total = type == 'folders' ? folders : files;
    final first = (chunk - 1) * 100;
    final count = (total - first).clamp(0, 100);
    return contentChunk(
      type,
      first: first,
      count: count,
      more: first + count < total,
    );
  });
}

List<String> ids(PagedResult<CloudEntry> page) => [
  for (final entry in page.items)
    switch (entry) {
      CloudFile(:final id) => id.value,
      CloudFolder(:final id) => id.value,
    },
];

void main() {
  late MediaFireHarness mf;
  late MediaFireProvider provider;

  setUp(() {
    mf = MediaFireHarness()..login();
    provider = mf.provider();
  });

  group('listFolder', () {
    test('lists the root (myfiles): folders, then files', () async {
      mf
        ..on(
          'folder/get_content',
          fixture('folder_content_folders'),
          data: {'content_type': 'folders'},
        )
        ..on(
          'folder/get_content',
          fixture('folder_content_files'),
          data: {'content_type': 'files'},
        );

      final page = await provider.listFolder(null);

      final calls = mf.calls('folder/get_content');
      expect(calls.map(fields), [
        containsPair('folder_key', 'myfiles'),
        containsPair('folder_key', 'myfiles'),
      ]);
      expect(fields(calls[0]), containsPair('content_type', 'folders'));
      expect(fields(calls[0]), containsPair('chunk', '1'));
      expect(fields(calls[0]), containsPair('chunk_size', '100'));
      expect(fields(calls[1]), containsPair('content_type', 'files'));
      expect(fields(calls[1]), containsPair('session_token', loginToken));

      expect(ids(page), [
        '21a1ht4gm4144',
        '1fprh0r43doqa',
        '98dc3nr8e2d3hdp',
        'ppdbpa58mq0lhym',
      ]);
      expect(page.hasMore, isFalse);
      expect(page.totalItems, 4);

      final folder = page.items.first as CloudFolder;
      expect(folder.name, 'Photos');
      expect(folder.parentId, isNull);
      expect(folder.fileCount, 12);
      expect(folder.createdAt, DateTime.utc(2015, 5, 11, 17, 49, 2));
      expect(folder.extra['folderCount'], 1);

      final pdf = page.items[2] as CloudFile;
      expect(pdf.name, 'Getting Started with Images.pdf');
      expect(pdf.folderId, isNull);
      expect(pdf.size, const DataSize(11721254));
      expect(pdf.isPublic, isTrue);
      expect(pdf.views, 7);
      expect(pdf.createdAt, DateTime.utc(2014, 9, 16, 20, 0, 47));
      expect(
        pdf.pageUrl,
        Uri.parse(
          'http://www.mediafire.com/file/98dc3nr8e2d3hdp/Getting_Started_with_Images.pdf',
        ),
      );
      expect(pdf.extra['mimetype'], 'application/pdf');
      expect(pdf.extra['downloads'], 3);

      final video = page.items[3] as CloudFile;
      expect(video.isPublic, isFalse);
      expect(video.extra['description'], 'Music video');
      expect(
        video.pageUrl,
        Uri.parse('https://www.mediafire.com/file/ppdbpa58mq0lhym'),
      );
    });

    test('lists a subfolder by folder key', () async {
      serveContent(mf, folders: 1, files: 1);

      final page = await provider.listFolder(const FolderId('abc123'));

      expect(
        mf.calls('folder/get_content').map((c) => fields(c)['folder_key']),
        ['abc123', 'abc123'],
      );
      expect((page.items[0] as CloudFolder).parentId, const FolderId('abc123'));
      expect((page.items[1] as CloudFile).folderId, const FolderId('abc123'));
    });

    test('an empty folder has no more pages', () async {
      serveContent(mf, folders: 0, files: 0);

      final page = await provider.listFolder(null);

      expect(page.items, isEmpty);
      expect(page.hasMore, isFalse);
    });

    group('pagination (130 folders, 250 files)', () {
      setUp(() => serveContent(mf, folders: 130, files: 250));

      Future<PagedResult<CloudEntry>> list(int page) =>
          provider.listFolder(null, page: PageRequest(page: page));

      List<(String, String)> chunks() => [
        for (final call in mf.calls('folder/get_content'))
          (
            fields(call)['content_type']! as String,
            fields(call)['chunk']! as String,
          ),
      ];

      test('first page only needs the first folder chunk', () async {
        final page = await list(1);

        expect(ids(page), [for (var i = 0; i < 50; i++) 'folder$i']);
        expect(page.hasMore, isTrue);
        expect(chunks(), [('folders', '1')]);
      });

      test('a page spanning folders and files', () async {
        final page = await list(3);

        expect(ids(page), [
          for (var i = 100; i < 130; i++) 'folder$i',
          for (var i = 0; i < 20; i++) 'file$i',
        ]);
        expect(page.hasMore, isTrue);
        expect(chunks(), [('folders', '1'), ('folders', '2'), ('files', '1')]);
      });

      test('a page spanning two file chunks', () async {
        final page = await list(5);

        expect(ids(page), [for (var i = 70; i < 120; i++) 'file$i']);
        expect(page.hasMore, isTrue);
        expect(chunks(), [
          ('folders', '1'),
          ('folders', '2'),
          ('files', '1'),
          ('files', '2'),
        ]);
      });

      test('the last page', () async {
        final page = await list(8);

        expect(ids(page), [for (var i = 220; i < 250; i++) 'file$i']);
        expect(page.hasMore, isFalse);
        expect(page.totalItems, 380);
        expect(chunks(), [('folders', '1'), ('folders', '2'), ('files', '3')]);
      });
    });

    test('an unknown folder throws NotFoundException', () async {
      mf.on(
        'folder/get_content',
        apiError(112, 'Unknown or invalid FolderKey'),
        status: 404,
      );

      await expectLater(
        provider.listFolder(const FolderId('nope')),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('file links', () {
    Future<Uri?> firstLink(MediaFireProvider provider) async {
      serveContent(mf, folders: 0, files: 1);
      final page = await provider.listFolder(null);
      return (page.items.single as CloudFile).pageUrl;
    }

    test('providers created from code use the default template', () async {
      expect(
        await firstLink(provider),
        Uri.parse('https://www.mediafire.com/file/file0'),
      );
      expect(mediaFire.fileUrlTemplate, mediaFireFileUrlTemplate);
    });

    test('use the template of the entry when the API has no link', () async {
      final definition = mediaFireDriver.definitionFor(
        mediaFire.config!.copyWith(fileUrlTemplate: 'https://mf.test/f/{id}'),
      );
      final custom = definition.create(
        MediaFireHarness.credentials,
        options: ProviderOptions(dio: mf.dio, maxRetries: 0),
      ) as MediaFireProvider;
      addTearDown(custom.close);

      expect(await firstLink(custom), Uri.parse('https://mf.test/f/file0'));
    });

    test('the constructor accepts a template', () async {
      final custom = MediaFireProvider(
        credentials: MediaFireHarness.credentials,
        options: ProviderOptions(dio: mf.dio, maxRetries: 0),
        fileUrlTemplate: 'https://mf.test/{id}.html',
      );
      addTearDown(custom.close);

      expect(await firstLink(custom), Uri.parse('https://mf.test/file0.html'));
    });
  });

  group('folders', () {
    test('createFolder', () async {
      mf.on('folder/create', fixture('folder_create'));

      final folder = await provider.createFolder(
        'Test 101',
        parentId: const FolderId('rfoh06y8w3amg'),
      );

      expect(folder.id, const FolderId('ih5qo0ia9lhsy'));
      expect(folder.name, 'Test 101');
      expect(folder.parentId, const FolderId('rfoh06y8w3amg'));
      expect(folder.createdAt, DateTime.utc(2015, 5, 11, 18, 13, 17));
      expect(fields(mf.calls('folder/create').single), {
        'foldername': 'Test 101',
        'parent_key': 'rfoh06y8w3amg',
        'action_on_duplicate': 'keep',
        'session_token': loginToken,
        'response_format': 'json',
      });
    });

    test('createFolder in the root', () async {
      mf.on('folder/create', success({'folder_key': 'newkey', 'name': 'Docs'}));

      final folder = await provider.createFolder('Docs');

      expect(folder.parentId, isNull);
      expect(fields(mf.calls('folder/create').single)['parent_key'], 'myfiles');
    });

    test('rename, move and delete send the folder keys', () async {
      mf
        ..on('folder/update', fixture('success'))
        ..on('folder/move', fixture('success'))
        ..on('folder/delete', fixture('success'));

      await provider.renameFolder(const FolderId('f1'), 'New name');
      await provider.moveFolder(const FolderId('f1'), null);
      await provider.moveFolder(const FolderId('f1'), const FolderId('f2'));
      await provider.deleteFolder(const FolderId('f1'));

      expect(fields(mf.calls('folder/update').single), {
        'folder_key': 'f1',
        'foldername': 'New name',
        'session_token': loginToken,
        'response_format': 'json',
      });
      final moves = mf.calls('folder/move').map(fields).toList();
      expect(moves[0], containsPair('folder_key_src', 'f1'));
      expect(moves[0], containsPair('folder_key_dst', 'myfiles'));
      expect(moves[1], containsPair('folder_key_dst', 'f2'));
      expect(
        fields(mf.calls('folder/delete').single),
        containsPair('folder_key', 'f1'),
      );
    });
  });

  group('files', () {
    test('fileInfo', () async {
      mf.on('file/get_info', fixture('file_info'));

      final file = await provider.fileInfo(const FileId('7a8kc7354q939b6'));

      expect(file.name, 'test 001.txt');
      expect(file.folderId, const FolderId('rfoh06y8w3amg'));
      expect(file.size, const DataSize(11));
      expect(file.isReady, isTrue);
      expect(file.extra['hash'], startsWith('6c179f21'));
      expect(
        fields(mf.calls('file/get_info').single),
        containsPair('quick_key', '7a8kc7354q939b6'),
      );
    });

    test('fileInfo of an unknown file throws NotFoundException', () async {
      mf.on('file/get_info', fixture('error_invalid_quickkey'), status: 404);

      await expectLater(
        provider.fileInfo(const FileId('zzz')),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('rename, move and delete send the quickkey', () async {
      mf
        ..on('file/update', fixture('success'))
        ..on('file/move', fixture('success'))
        ..on('file/delete', fixture('success'));

      await provider.renameFile(const FileId('q1'), 'new.txt');
      await provider.moveFile(const FileId('q1'), null);
      await provider.deleteFile(const FileId('q1'));

      expect(fields(mf.calls('file/update').single), {
        'quick_key': 'q1',
        'filename': 'new.txt',
        'session_token': loginToken,
        'response_format': 'json',
      });
      expect(
        fields(mf.calls('file/move').single),
        containsPair('folder_key', 'myfiles'),
      );
      expect(
        fields(mf.calls('file/delete').single),
        containsPair('quick_key', 'q1'),
      );
    });
  });

  group('search', () {
    test('returns only files', () async {
      mf.on('folder/search', fixture('search'));

      final result = await provider.searchFiles(' sample ');

      expect(result.items.map((f) => f.id.value), [
        'eu9fs1setas5a05',
        'lx8fb6gpizuuv9o',
      ]);
      expect(result.items.first.folderId, const FolderId('b5brfb1s16fr0'));
      expect(result.items.last.folderId, isNull);
      expect(result.totalItems, 2);
      expect(result.hasMore, isFalse);
      expect(fields(mf.calls('folder/search').single), {
        'search_text': 'sample',
        'search_all': 'yes',
        'session_token': loginToken,
        'response_format': 'json',
      });
    });

    test('inside a folder, paginated locally', () async {
      mf.on('folder/search', fixture('search'));

      final result = await provider.searchFiles(
        'sample',
        folderId: const FolderId('b5brfb1s16fr0'),
        page: const PageRequest(page: 2, perPage: 1),
      );

      expect(result.items.single.id, const FileId('lx8fb6gpizuuv9o'));
      expect(result.hasMore, isFalse);
      expect(
        fields(mf.calls('folder/search').single),
        containsPair('folder_key', 'b5brfb1s16fr0'),
      );
    });

    test('no results', () async {
      mf.on('folder/search', fixture('search_empty'));

      final result = await provider.searchFiles('nothing');

      expect(result.items, isEmpty);
    });

    test('short queries are not supported', () async {
      await expectLater(
        provider.searchFiles('ab'),
        throwsA(isA<UnsupportedOperationException>()),
      );
      expect(mf.requests, isEmpty);
    });
  });

  test('accountInfo', () async {
    mf.on('user/get_info', fixture('user_info'));

    final info = await provider.accountInfo();

    expect(info.email, 't03@example.com');
    expect(info.login, 'Test 03');
    expect(info.isPremium, isFalse);
    expect(info.storageUsed, const DataSize(234364151));
    expect(info.storageLeft, const DataSize(11813257216 - 234364151));
    expect(info.extra['storageLimit'], 11813257216);
    expect(info.extra['bandwidth'], 3221211543406);
  });

  test('network errors are reported as NetworkException', () async {
    mf.onThrow(
      'user/get_info',
      DioException.connectionError(
        requestOptions: RequestOptions(path: 'user/get_info.php'),
        reason: 'offline',
      ),
    );

    await expectLater(provider.accountInfo(), throwsA(isA<NetworkException>()));
  });
}
