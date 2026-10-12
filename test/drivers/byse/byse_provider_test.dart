import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/upcloud.dart';

import '../../support/bundled_providers.dart';

import 'byse_test_utils.dart';

void main() {
  late ByseHarness h;
  late ByseProvider provider;

  setUp(() {
    h = ByseHarness();
    provider = h.provider;
  });

  group('definition', () {
    test('describes Byse', () {
      expect(byse.id, 'byse');
      expect(byse.info.name, 'Byse');
      expect(byse.info.driver, 'byse');
      expect(byse.defaultBaseUrl, Uri.parse('https://api.byse.sx'));
      final field = byse.credentialSchema.fields.single;
      expect(field.id, CredentialField.apiKeyId);
      expect(field.helpUrl, Uri.parse('https://byse.sx/settings'));
    });

    test('declares the capabilities implemented by the provider', () {
      final created = byse.create(Credentials.apiKey('k'));
      addTearDown(created.close);
      expect(created, isA<ByseProvider>());
      expect(created.capabilities, byse.capabilities);
      expect(byse.capabilities, isNot(contains(Capability.renameFile)));
      expect(byse.capabilities, contains(Capability.createFolder));
    });

    test('the provider leaves out the capabilities the entry disables', () {
      final definition = byseDriver.definitionFor(
        const ProviderConfig(
          id: 'byse-lite',
          name: 'Byse Lite',
          driver: ByseDriver.driverId,
          disabledCapabilities: ['remoteUpload', 'search'],
        ),
      );
      final lite = ByseHarness(definition: definition).provider;

      expect(lite.capabilities, definition.capabilities);
      expect(lite.supports(Capability.remoteUpload), isFalse);
      expect(lite.supports(Capability.search), isFalse);
      expect(lite.supports(Capability.upload), isTrue);
      // Created from code, without a registry entry.
      expect(provider.capabilities, byseCapabilities);
    });

    test('defaults to video extensions and 2 GB per file', () {
      expect(byseLimits.maxFileSize, const DataSize.mb(2048));
      expect(byseLimits.allowedExtensions, containsAll(['mp4', 'mkv']));
      expect(provider.limits, byseLimits);
    });

    test('requires an API key', () {
      expect(
        () => byse.create(const Credentials({})),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });

  group('accountInfo', () {
    test('maps the documented response', () async {
      h.onGet('account/info', byseFixture('account_info.json'));

      final account = await provider.accountInfo();

      expect(account.email, 'user@example.com');
      expect(account.balance, '0.00000');
      expect(account.storageUsed, const DataSize(24186265));
      expect(account.storageLeft, const DataSize(128824832615));
      expect(account.premiumUntil, DateTime.utc(2015, 10, 24, 21));
      expect(account.isPremium, isFalse);
      expect(h.requests.single.queryParameters['key'], testApiKey);
    });

    test('is premium while premium_expire is in the future', () async {
      h.onGet('account/info', {
        'status': 200,
        'msg': 'OK',
        'result': {'email': 'a@b.c', 'premium_expire': '2999-01-01 00:00:00'},
      });

      final account = await provider.accountInfo();

      expect(account.isPremium, isTrue);
      expect(account.storageUsed, isNull);
    });
  });

  group('listFolder', () {
    test('returns subfolders followed by the files of the root', () async {
      h
        ..onGet(
          'folder/list',
          byseFixture('folder_list.json'),
          query: {'fld_id': '0'},
        )
        ..onGet(
          'file/list',
          byseFixture('file_list.json'),
          query: {'fld_id': '0', 'page': 1, 'per_page': 50},
        );

      final page = await provider.listFolder(null);

      expect(h.paths, ['folder/list', 'file/list']);
      final [first, second, file] = page.items;
      expect(
        first,
        isA<CloudFolder>()
            .having((f) => f.id, 'id', const FolderId('16'))
            .having((f) => f.name, 'name', 'Breaking Bad')
            .having((f) => f.parentId, 'parentId', isNull)
            .having((f) => f.extra['code'], 'code', '4pwb4yvp7v'),
      );
      expect(
        second,
        isA<CloudFolder>().having((f) => f.name, 'name', 'Travis'),
      );
      // The documented 404 entry is skipped.
      expect(
        file,
        isA<CloudFile>()
            .having((f) => f.id, 'id', const FileId('gi4o0tlro01u'))
            .having(
              (f) => f.name,
              'name',
              '4K Time Lapse in the EOS 6D Mark II',
            )
            .having((f) => f.duration, 'duration', const Duration(seconds: 20))
            .having((f) => f.views, 'views', 0)
            .having((f) => f.isReady, 'isReady', isTrue)
            .having(
              (f) => f.createdAt,
              'createdAt',
              DateTime.utc(2017, 8, 10, 5, 7, 17),
            )
            .having(
              (f) => f.pageUrl,
              'pageUrl',
              Uri.parse('https://byse.sx/d/gi4o0tlro01u'),
            )
            .having((f) => f.extra['views_started'], 'views_started', '1'),
      );
      expect(page.hasMore, isFalse);
    });

    test('paginates files and only lists folders on the first page', () async {
      const request = PageRequest(perPage: 2);
      h
        ..onGet(
          'folder/list',
          {
            'status': 200,
            'result': {'folders': <Object?>[]},
          },
          query: {'fld_id': '16'},
        )
        ..onGet(
          'file/list',
          byseFixture('file_list_paged.json'),
          query: {'fld_id': '16', 'per_page': 2},
        );

      final first = await provider.listFolder(
        const FolderId('16'),
        page: request,
      );

      expect(first.items, hasLength(2));
      expect(first.totalItems, 3);
      expect(first.totalPages, 2);
      expect(first.hasMore, isTrue);
      final [a, b] = first.items.cast<CloudFile>();
      expect(a.folderId, const FolderId('16'));
      expect(a.isPublic, isFalse);
      expect(
        a.thumbnailUrl,
        Uri.parse('https://img.byse.sx/04nolnuszhph_t.jpg'),
      );
      expect(a.pageUrl, Uri.parse('https://byse.sx/d/04nolnuszhph'));
      expect(b.isReady, isFalse);
      expect(b.isPublic, isTrue);
      expect(b.duration, isNull);

      h.requests.clear();
      final second = await provider.listFolder(
        const FolderId('16'),
        page: request.next,
      );

      expect(h.paths, ['file/list']);
      expect(h.requests.single.queryParameters['page'], '2');
      expect(second.hasMore, isFalse);
    });
  });

  group('listFolder errors', () {
    test('throws the error of the failed request as it is', () async {
      h
        ..onGet(
          'folder/list',
          byseFixture('folder_list.json'),
          query: {'fld_id': '0'},
        )
        ..onGet(
          'file/list',
          byseFixture('error_invalid_key.json'),
          query: {'fld_id': '0', 'page': '1', 'per_page': '50'},
        );

      await expectLater(
        provider.listFolder(null),
        throwsA(isA<AuthenticationException>()),
      );
      expect(h.paths, ['folder/list', 'file/list']);
    });
  });

  group('searchFiles', () {
    test('filters by title', () async {
      h.onGet(
        'file/list',
        byseFixture('file_list.json'),
        query: {'title': 'Time Lapse', 'page': 1},
      );

      final result = await provider.searchFiles('Time Lapse');

      expect(result.items.single.id, const FileId('gi4o0tlro01u'));
      expect(h.requests.single.queryParameters, isNot(contains('fld_id')));
    });

    test('can be limited to a folder', () async {
      h.onGet(
        'file/list',
        byseFixture('file_list.json'),
        query: {'title': 'x', 'fld_id': '25'},
      );

      final result = await provider.searchFiles(
        'x',
        folderId: const FolderId('25'),
      );

      expect(result.items, hasLength(1));
    });
  });

  group('folders', () {
    test('createFolder returns the new folder', () async {
      h.onGet(
        'folder/create',
        byseFixture('folder_create.json'),
        query: {'name': 'New Videos', 'parent_id': '15'},
      );

      final folder = await provider.createFolder(
        'New Videos',
        parentId: const FolderId('15'),
      );

      expect(folder.id, const FolderId('29'));
      expect(folder.name, 'New Videos');
      expect(folder.parentId, const FolderId('15'));
    });

    test('createFolder uses 0 for the root', () async {
      h.onGet(
        'folder/create',
        byseFixture('folder_create.json'),
        query: {'parent_id': '0'},
      );

      final folder = await provider.createFolder('Root child');

      expect(folder.parentId, isNull);
    });

    test('rename, move and delete are not supported', () async {
      const id = FolderId('1');
      final unsupported = throwsA(isA<UnsupportedOperationException>());
      await expectLater(provider.renameFolder(id, 'x'), unsupported);
      await expectLater(provider.moveFolder(id, null), unsupported);
      await expectLater(provider.deleteFolder(id), unsupported);
      expect(h.requests, isEmpty);
    });
  });

  group('files', () {
    test('fileInfo returns the requested file', () async {
      h.onGet(
        'file/info',
        byseFixture('file_info.json'),
        query: {'file_code': 'gi4o0tlro01u'},
      );

      final file = await provider.fileInfo(const FileId('gi4o0tlro01u'));

      expect(file.name, '4K Time Lapse in the EOS 6D Mark II');
      expect(file.isReady, isTrue);
    });

    test('fileInfo reads the file_ fields of the live API', () async {
      // Recorded from api.byse.sx: unlike the documentation, file/info
      // prefixes the fields with `file_`.
      h.onGet(
        'file/info',
        byseFixture('file_info_live.json'),
        query: {'file_code': 'v5cp8e6rhvvc'},
      );

      final file = await provider.fileInfo(const FileId('v5cp8e6rhvvc'));

      expect(file.id, const FileId('v5cp8e6rhvvc'));
      expect(file.name, 'Big Buck Bunny 1080 10s 1MB');
      expect(file.folderId, const FolderId('402298'));
      expect(file.duration, const Duration(seconds: 10));
      expect(file.views, 3);
      expect(file.createdAt, DateTime.utc(2026, 9, 15, 16, 26, 58));
      expect(file.isPublic, isFalse);
      expect(file.isReady, isTrue);
      expect(
        file.thumbnailUrl,
        Uri.parse('https://videothumbs.me/v5cp8e6rhvvc.jpg'),
      );
      expect(file.pageUrl, Uri.parse('https://byse.sx/d/v5cp8e6rhvvc'));
      expect(file.extra, isNot(contains('file_title')));
    });

    test('fileInfo throws NotFoundException for missing files', () async {
      h.onGet(
        'file/info',
        byseFixture('file_info.json'),
        query: {'file_code': 'gi4o0tlro012'},
      );

      await expectLater(
        provider.fileInfo(const FileId('gi4o0tlro012')),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('moveFile sets the folder', () async {
      h.onGet(
        'file/set_folder',
        byseFixture('file_set_folder.json'),
        query: {'file_code': 'abc', 'fld_id': '15'},
      );

      await provider.moveFile(const FileId('abc'), const FolderId('15'));

      expect(h.paths, ['file/set_folder']);
    });

    test('rename and delete are not supported', () async {
      const id = FileId('abc');
      final unsupported = throwsA(isA<UnsupportedOperationException>());
      await expectLater(provider.renameFile(id, 'x'), unsupported);
      await expectLater(provider.deleteFile(id), unsupported);
    });
  });

  group('uploads', () {
    const server = 'https://s1.myvideo.com/upload/01';
    const clip = UploadFileInfo(name: 'clip.mp4', size: 4096);

    Future<UploadRequest> prepare([
      UploadOptions options = const UploadOptions(),
    ]) {
      h.onGet('upload/server', byseFixture('upload_server.json'));
      return provider.prepareUpload(clip, options: options);
    }

    UploadResponse reply(Object? body, {int status = 200}) => UploadResponse(
      statusCode: status,
      body: body is String ? body : jsonEncode(body),
    );

    test('prepareUpload targets the returned server', () async {
      final request = await prepare(
        const UploadOptions(
          folderId: FolderId('16'),
          title: 'My clip',
          isPublic: false,
          tags: ['a', 'b'],
        ),
      );

      expect(h.paths, ['upload/server']);
      expect(request.url, Uri.parse(server));
      expect(request.encoding, UploadEncoding.multipart);
      expect(request.fileField, 'file');
      expect(request.fields, {
        'key': testApiKey,
        'fld_id': '16',
        'file_title': 'My clip',
        'file_public': '0',
        'tags': 'a,b',
      });
      expect(request.fields.keys.first, 'key');
    });

    test('completeUpload returns the file with its share link', () async {
      final request = await prepare(
        const UploadOptions(folderId: FolderId('16'), title: 'My clip'),
      );

      final file = await provider.completeUpload(
        request,
        reply(byseFixture('upload_file.json')),
      );

      expect(h.paths, ['upload/server'], reason: 'no extra API call');
      expect(file.id, const FileId('tnklyibwwpsh'));
      expect(file.name, 'My clip');
      expect(file.folderId, const FolderId('16'));
      expect(file.size, const DataSize(4096));
      expect(file.pageUrl, Uri.parse('https://byse.sx/d/tnklyibwwpsh'));
      expect(file.isReady, isFalse);
      expect(file.extra['filename'], 'qwbs4m4ze4j4.mp4');
    });

    test('rejects extensions Byse does not accept', () async {
      await expectLater(
        provider.prepareUpload(const UploadFileInfo(name: 'notes.pdf')),
        throwsA(
          isA<UploadRejectedException>().having(
            (e) => e.reason,
            'reason',
            isA<ExtensionNotAllowed>().having(
              (r) => r.extension,
              'extension',
              'pdf',
            ),
          ),
        ),
      );
      expect(h.requests, isEmpty);
    });

    test('rejects files larger than the limit', () async {
      await expectLater(
        provider.prepareUpload(
          UploadFileInfo(name: 'movie.mkv', size: const DataSize.gb(3).bytes),
        ),
        throwsA(
          isA<UploadRejectedException>().having(
            (e) => e.reason,
            'reason',
            isA<FileTooLarge>().having(
              (r) => r.maxSize,
              'maxSize',
              const DataSize.mb(2048),
            ),
          ),
        ),
      );
      expect(h.requests, isEmpty);
    });

    test('uses the limits given in the options', () async {
      final custom = ByseHarness(
        limits: const ProviderLimits(maxFileSize: DataSize.kb(1)),
      );

      await expectLater(
        custom.provider.prepareUpload(
          const UploadFileInfo(name: 'a.pdf', size: 4096),
        ),
        throwsA(
          isA<UploadRejectedException>().having(
            (e) => e.reason,
            'reason',
            isA<FileTooLarge>(),
          ),
        ),
      );
    });

    test('refuses a non-HTTPS upload server', () async {
      h.onGet('upload/server', {
        'msg': 'OK',
        'status': 200,
        'result': 'http://s1.myvideo.com/upload/01',
      });

      await expectLater(
        provider.prepareUpload(clip),
        throwsA(
          isA<ProviderException>().having(
            (e) => e.message,
            'message',
            contains('non-HTTPS'),
          ),
        ),
      );
    });

    test('maps upload server errors', () async {
      final request = await prepare();

      await expectLater(
        provider.completeUpload(
          request,
          reply({
            'msg': 'OK',
            'status': 200,
            'files': [
              {
                'filecode': 'undef',
                'filename': 'clip.mp4',
                'status': '0:0:0:Not enough disk space',
              },
            ],
          }),
        ),
        throwsA(
          isA<QuotaExceededException>().having(
            (e) => e.message,
            'message',
            'Not enough disk space',
          ),
        ),
      );
    });

    test('errors of accepted uploads carry the HTTP status', () async {
      final request = await prepare();

      await expectLater(
        provider.completeUpload(
          request,
          reply({
            'files': [
              {'filecode': 'undef', 'status': '0:0:0:Unknown failure'},
            ],
          }),
        ),
        throwsA(
          isA<ProviderException>().having((e) => e.statusCode, 'status', 200),
        ),
      );
    });

    test('maps HTTP errors of the upload server', () async {
      final request = await prepare();

      await expectLater(
        provider.completeUpload(
          request,
          reply({'status': 401, 'msg': 'Invalid key'}, status: 401),
        ),
        throwsA(isA<AuthenticationException>()),
      );
      await expectLater(
        provider.completeUpload(
          request,
          const UploadResponse(
            statusCode: 429,
            body: 'Slow down',
            headers: {'retry-after': '3'},
          ),
        ),
        throwsA(
          isA<RateLimitedException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 3),
          ),
        ),
      );
    });

    test('accepts JSON sent with a text content type', () async {
      final request = await prepare();

      final file = await provider.completeUpload(
        request,
        reply(
          '{"msg":"OK","status":200,"files":[{"filecode":"abc123",'
          '"filename":"x.mp4","status":"OK"}]}',
        ),
      );

      expect(file.id, const FileId('abc123'));
    });
  });

  group('remote uploads', () {
    const source = 'http://site.com/v.mkv';

    test('queues a URL and tracks its status', () async {
      h
        ..onGet(
          'remote/add',
          byseFixture('remote_add.json'),
          query: {'url': source, 'fld_id': '16'},
        )
        ..onGet(
          'remote/status',
          byseFixture('remote_status.json'),
          query: {'file_code': 'jthi5jdsu8t9'},
        );

      final job = await provider.uploadFromUrl(
        Uri.parse(source),
        options: const UploadOptions(folderId: FolderId('16')),
      );

      expect(job.id, 'jthi5jdsu8t9');
      expect(job.fileId, const FileId('jthi5jdsu8t9'));
      expect(job.status, RemoteUploadStatus.pending);
      expect(job.sourceUrl, Uri.parse(source));

      final [status] = await provider.remoteUploads();

      expect(status.id, 'jthi5jdsu8t9');
      expect(status.status, RemoteUploadStatus.working);
      expect(status.progress, closeTo(0.55, 1e-9));
      expect(status.sourceUrl, Uri.parse('https://exampleurl.com/file.mp4'));
      expect(status.error, isNull);
      expect(status.extra['created'], '10:00:00 09-06-2022');
    });

    test('reports the status of any job', () async {
      h.onGet(
        'remote/status',
        {
          'status': 200,
          'result': {
            'url': source,
            'progress': '100%',
            'status': 'ERROR',
            'error_msg': 'Download failed',
          },
        },
        query: {'file_code': 'other'},
      );

      final job = await provider.remoteUploadStatus('other');

      expect(job.status, RemoteUploadStatus.failed);
      expect(job.progress, 1);
      expect(job.error, 'Download failed');
    });

    test('cancelRemoteUpload removes the job', () async {
      h
        ..onGet('remote/add', byseFixture('remote_add.json'))
        ..onGet(
          'remote/remove',
          byseFixture('remote_remove.json'),
          query: {'file_code': 'jthi5jdsu8t9'},
        );
      final job = await provider.uploadFromUrl(Uri.parse(source));

      await provider.cancelRemoteUpload(job.id);
      h.requests.clear();

      expect(await provider.remoteUploads(), isEmpty);
      expect(h.requests, isEmpty);
    });

    test('drops jobs Byse no longer knows', () async {
      h
        ..onGet('remote/add', byseFixture('remote_add.json'))
        ..onGet('remote/status', {'status': 404, 'msg': 'File not found'});
      await provider.uploadFromUrl(Uri.parse(source));

      expect(await provider.remoteUploads(), isEmpty);
      h.requests.clear();
      expect(await provider.remoteUploads(), isEmpty);
      expect(h.requests, isEmpty);
    });
  });

  group('file links', () {
    Map<String, Object?> fileList(List<Map<String, Object?>> files) => {
      'status': 200,
      'msg': 'OK',
      'result': {'files': files, 'results_total': files.length, 'pages': 1},
    };

    void serveFiles(ByseHarness harness) => harness.onGet(
      'file/list',
      fileList([
        {'file_code': 'fromapi', 'title': 'A', 'link': 'https://api.link/a'},
        {'file_code': 'no link', 'title': 'B'},
      ]),
      query: {'title': 'x'},
    );

    Future<List<Uri?>> links(ByseHarness harness) async {
      final page = await harness.provider.searchFiles('x');
      return [for (final file in page.items) file.pageUrl];
    }

    test('the link of the API wins over the template of the entry', () async {
      final harness = ByseHarness(
        definition: byseDriver.definitionFor(
          byse.config!.copyWith(fileUrlTemplate: 'https://mirror.test/w/{id}'),
        ),
      );
      serveFiles(harness);

      expect(await links(harness), [
        Uri.parse('https://api.link/a'),
        Uri.parse('https://mirror.test/w/no%20link'),
      ]);
    });

    test('entries without a template use the watch page of the website', () {
      final definition = byseDriver.definitionFor(
        ProviderConfig(
          id: 'byse-alt',
          name: 'Byse Alt',
          driver: ByseDriver.driverId,
          website: Uri.parse('https://byse.example/'),
        ),
      );

      expect(definition.fileUrlTemplate, 'https://byse.example/d/{id}');
      expect(byse.fileUrlTemplate, 'https://byse.sx/d/{id}');
      expect(byseFileUrlTemplate(), 'https://byse.sx/d/{id}');
      expect(
        byseFileUrlTemplate(Uri.parse('https://byse.example:8443/app/')),
        'https://byse.example:8443/app/d/{id}',
      );
    });

    test('providers created without a template use the default', () async {
      // A definition built by hand, not by the driver: no template.
      final definition = ProviderDefinition(
        info: ProviderInfo(
          id: 'byse-code',
          name: 'Byse (code)',
          website: Uri.parse('https://byse.example'),
        ),
        credentialSchema: CredentialSchema.apiKey(),
        capabilities: byseCapabilities,
        factory: (definition, credentials, options) =>
            throw UnimplementedError(),
      );
      final harness = ByseHarness(definition: definition);
      serveFiles(harness);

      expect(await links(harness), [
        Uri.parse('https://api.link/a'),
        Uri.parse('https://byse.example/d/no%20link'),
      ]);
    });

    test('completeUpload builds the link with the template', () async {
      final harness = ByseHarness(
        definition: byseDriver.definitionFor(
          byse.config!.copyWith(fileUrlTemplate: 'https://mirror.test/w/{id}'),
        ),
      )..onGet('upload/server', byseFixture('upload_server.json'));
      final request = await harness.provider.prepareUpload(
        const UploadFileInfo(name: 'clip.mp4', size: 4096),
      );

      final file = await harness.provider.completeUpload(
        request,
        UploadResponse(
          statusCode: 200,
          body: jsonEncode(byseFixture('upload_file.json')),
        ),
      );

      expect(file.pageUrl, Uri.parse('https://mirror.test/w/tnklyibwwpsh'));
    });
  });

  group('errors', () {
    Future<void> expectError(Object? body, Matcher matcher, {int code = 200}) {
      h.onGet('account/info', body, statusCode: code);
      return expectLater(provider.accountInfo(), throwsA(matcher));
    }

    test('an invalid key is an AuthenticationException', () async {
      await expectError(
        byseFixture('error_invalid_key.json'),
        isA<AuthenticationException>().having(
          (e) => e.message,
          'message',
          'Invalid key',
        ),
      );
    });

    test('API status 404 is a NotFoundException', () async {
      await expectError({
        'status': 404,
        'msg': 'Nothing here',
      }, isA<NotFoundException>());
    });

    test('too many requests is a RateLimitedException', () async {
      await expectError({
        'status': 400,
        'msg': 'Too many requests',
      }, isA<RateLimitedException>());
    });

    test('other API errors are ProviderExceptions', () async {
      await expectError(
        {'status': 400, 'msg': 'Cloning is disabled'},
        isA<ProviderException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having((e) => e.message, 'message', 'Cloning is disabled'),
      );
    });

    test('HTTP errors keep the API message', () async {
      await expectError(
        {'status': 500, 'msg': 'Database is down'},
        isA<ProviderException>()
            .having((e) => e.statusCode, 'statusCode', 500)
            .having((e) => e.message, 'message', 'Database is down'),
        code: 500,
      );
    });

    test('HTTP 429 keeps Retry-After over the API message', () async {
      h.adapter.onGet(
        'account/info',
        (s) => s.reply(
          429,
          {'status': 429, 'msg': 'Too many requests'},
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
            'retry-after': ['7'],
          },
        ),
        queryParameters: {'key': testApiKey},
      );

      await expectLater(
        provider.accountInfo(),
        throwsA(
          isA<RateLimitedException>().having(
            (e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 7),
          ),
        ),
      );
    });

    test('HTTP 401 without body is an AuthenticationException', () async {
      await expectError('', isA<AuthenticationException>(), code: 401);
    });

    test('non JSON responses are ProviderExceptions', () async {
      h.adapter.onGet(
        'account/info',
        (s) => s.reply(
          200,
          '<html>API docs</html>',
          headers: {
            Headers.contentTypeHeader: ['text/html'],
          },
        ),
        queryParameters: {'key': testApiKey},
      );

      await expectLater(
        provider.accountInfo(),
        throwsA(isA<ProviderException>()),
      );
    });

    test('connection errors are NetworkExceptions', () async {
      h.adapter.onGet(
        'account/info',
        (s) => s.throws(
          0,
          DioException.connectionError(
            requestOptions: RequestOptions(path: 'account/info'),
            reason: 'offline',
          ),
        ),
        queryParameters: {'key': testApiKey},
      );

      await expectLater(
        provider.accountInfo(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
