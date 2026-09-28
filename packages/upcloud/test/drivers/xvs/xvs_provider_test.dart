import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:upcloud/src/core/capabilities/capabilities.dart';
import 'package:upcloud/src/core/credentials.dart';
import 'package:upcloud/src/core/errors.dart';
import 'package:upcloud/src/core/models/cloud_entry.dart';
import 'package:upcloud/src/core/models/data_size.dart';
import 'package:upcloud/src/core/models/ids.dart';
import 'package:upcloud/src/core/models/paging.dart';
import 'package:upcloud/src/core/models/remote_upload.dart';
import 'package:upcloud/src/core/models/upload.dart';
import 'package:upcloud/src/core/models/upload_request.dart';
import 'package:upcloud/src/core/provider_definition.dart';
import 'package:upcloud/src/core/provider_limits.dart';
import 'package:upcloud/src/drivers/xvs/xvs.dart';
import 'package:upcloud/src/settings/upload_settings.dart';
import 'package:upcloud/src/transfer/transfer_manager.dart';
import 'package:upcloud/testing.dart';

import '../../support/bundled_providers.dart';

import 'xvs_harness.dart';

void main() {
  late XvsHarness h;

  setUp(() => h = XvsHarness());

  group('accountInfo', () {
    test('maps account/info', () async {
      h.onGet('account/info', fixture('account_info'));

      final account = await h.provider.accountInfo();

      expect(account.login, 'megauploader21');
      expect(account.email, 'megauploader21@example.com');
      expect(account.storageUsed, const DataSize(685101));
      expect(account.storageLeft, const DataSize(1288483337));
      expect(account.filesTotal, 31);
      expect(account.isPremium, isTrue);
      expect(account.premiumUntil, DateTime.utc(2022, 10, 15, 4, 46, 59));
      expect(account.balance, '108.00000');
      expect(h.lastRequest('account/info').queryParameters, {
        'key': testApiKey,
      });
    });

    test('accepts JSON served as text/html', () async {
      h.onGet(
        'account/info',
        '{"msg":"OK","status":200,"result":{"login":"html"}}',
        headers: const {
          Headers.contentTypeHeader: ['text/html; charset=UTF-8'],
        },
      );

      final account = await h.provider.accountInfo();

      expect(account.login, 'html');
    });
  });

  group('listFolder', () {
    test('returns folders then files on the first page', () async {
      h
        ..onGet('folder/list', fixture('folder_list'), query: {'fld_id': '0'})
        ..onGet(
          'file/list',
          fixture('file_list_page1'),
          query: {'fld_id': '0', 'page': '1', 'per_page': '2'},
        );

      final page = await h.provider.listFolder(
        null,
        page: const PageRequest(perPage: 2),
      );

      expect(page.items, hasLength(4));
      final [first, second, file, encoding] = page.items;
      expect(first, isA<CloudFolder>());
      expect((first as CloudFolder).id, const FolderId('16'));
      expect(first.name, 'Breaking Bad');
      expect(first.parentId, isNull);
      expect(first.extra['code'], '4pwb4yvp7v');
      expect((second as CloudFolder).name, 'Travis');

      file as CloudFile;
      expect(file.id, const FileId('fb5asfuj2snh'));
      expect(file.name, 'Test 123');
      expect(file.folderId, isNull);
      expect(file.duration, const Duration(seconds: 60));
      expect(file.views, 0);
      expect(file.isPublic, isFalse);
      expect(file.isReady, isTrue);
      expect(file.createdAt, DateTime.utc(2021, 7, 12, 20, 56, 54));
      expect(
        file.thumbnailUrl,
        Uri.parse('http://img.xvs.tt/fb5asfuj2snh_t.jpg'),
      );
      expect(file.pageUrl, Uri.parse('http://xvs.tt/fb5asfuj2snh.html'));

      encoding as CloudFile;
      expect(encoding.isReady, isFalse);
      expect(encoding.duration, isNull, reason: 'length 0 is unknown');

      expect(page.totalPages, 2);
      expect(page.hasMore, isTrue);
    });

    test('only lists files on later pages', () async {
      h.onGet(
        'file/list',
        fixture('file_list_page2'),
        query: {'fld_id': '0', 'page': '2', 'per_page': '2'},
      );

      final page = await h.provider.listFolder(
        null,
        page: const PageRequest(page: 2, perPage: 2),
      );

      expect(page.items.map((e) => e.name), ['Last one']);
      expect(page.hasMore, isFalse);
      expect(h.requests.map((r) => r.path), ['file/list']);
    });

    test('lists a subfolder with VidHide shaped entries', () async {
      h
        ..onGet(
          'folder/list',
          fixture('folder_list_empty'),
          query: {'fld_id': '25'},
        )
        ..onGet(
          'file/list',
          fixture('file_list_vidhide'),
          query: {'fld_id': '25', 'page': '1', 'per_page': '50'},
        );

      final page = await h.provider.listFolder(const FolderId('25'));

      final file = page.items.single as CloudFile;
      expect(file.id, const FileId('lscc79sittad'));
      expect(file.name, 'Iron man trailer');
      expect(file.folderId, const FolderId('25'));
      expect(file.duration, const Duration(minutes: 26));
      expect(file.views, 3);
      expect(file.isPublic, isTrue);
      expect(file.isReady, isTrue);
      expect(file.pageUrl, Uri.parse('https://vidhide.com/v/lscc79sittad'));
      expect(page.totalPages, 1);
      expect(page.hasMore, isFalse);
    });
  });

  group('searchFiles', () {
    test('filters file/list by title in every folder', () async {
      h.onGet(
        'file/list',
        fixture('file_list_page2'),
        query: {'title': 'last'},
      );

      final page = await h.provider.searchFiles('last');

      expect(page.items.single.id, const FileId('u9150wqzvhxj'));
      final query = h.lastRequest('file/list').queryParameters;
      expect(query, isNot(contains('fld_id')));
      expect(query, containsPair('page', '1'));
    });
  });

  group('folders', () {
    test('createFolder returns the new folder', () async {
      h.onGet(
        'folder/create',
        fixture('folder_create'),
        query: {'name': 'Movies 2021', 'parent_id': '16'},
      );

      final folder = await h.provider.createFolder(
        'Movies 2021',
        parentId: const FolderId('16'),
      );

      expect(folder.id, const FolderId('29'));
      expect(folder.name, 'Movies 2021');
      expect(folder.parentId, const FolderId('16'));
    });

    test('rename, move and delete call the folder endpoints', () async {
      h
        ..onGet('folder/edit', fixture('edit_ok'))
        ..onGet('folder/delete', fixture('delete_ok'));

      await h.provider.renameFolder(const FolderId('29'), 'Series');
      expect(h.lastRequest('folder/edit').queryParameters, {
        'key': testApiKey,
        'fld_id': '29',
        'name': 'Series',
      });

      await h.provider.moveFolder(const FolderId('29'), null);
      expect(
        h.lastRequest('folder/edit').queryParameters,
        containsPair('parent_id', '0'),
      );

      await h.provider.deleteFolder(const FolderId('29'));
      expect(
        h.lastRequest('folder/delete').queryParameters,
        containsPair('fld_id', '29'),
      );
    });
  });

  group('files', () {
    test('fileInfo maps file/info', () async {
      h.onGet(
        'file/info',
        fixture('file_info'),
        query: {'file_code': 'fb5asfuj2snh'},
      );

      final file = await h.provider.fileInfo(const FileId('fb5asfuj2snh'));

      expect(file.name, 'big buck bunny');
      expect(file.folderId, const FolderId('25'));
      expect(file.duration, const Duration(seconds: 60));
      expect(file.isPublic, isTrue);
      expect(
        file.thumbnailUrl,
        Uri.parse('http://img.xvs.tt/fb5asfuj2snh.jpg'),
      );
      expect(file.createdAt, isNull, reason: 'invalid date in the docs');
      expect(file.pageUrl, Uri.parse('https://xvs.test/fb5asfuj2snh.html'));
      expect(file.extra, containsPair('tags', 'promo, high quality'));
      expect(file.extra, containsPair('cat_id', '3'));
    });

    test('fileInfo reads StreamHG file_sizes', () async {
      h.onGet('file/info', fixture('file_info_streamhg'));

      final file = await h.provider.fileInfo(const FileId('fb5asfuj2snh'));

      expect(file.size, const DataSize(202191544));
      expect(file.folderId, isNull);
      expect(file.createdAt, DateTime.utc(2021, 8, 10, 20, 51, 52));
    });

    test('fileInfo builds the link with the template of the entry', () async {
      h = XvsHarness(definition: streamHg)
        ..onGet('file/info', fixture('file_info_streamhg'));

      final file = await h.provider.fileInfo(const FileId('fb5asfuj2snh'));

      expect(file.pageUrl, Uri.parse('https://hgcloud.to/fb5asfuj2snh'));
    });

    test('files get no link without API link nor template', () async {
      h = XvsHarness(
        definition: testXvsDefinition(
          info: const ProviderInfo(id: 'plain', name: 'Plain'),
          apiBase: Uri.parse('https://plain.test/api'),
        ),
      )..onGet('file/info', fixture('file_info_streamhg'));

      final file = await h.provider.fileInfo(const FileId('fb5asfuj2snh'));

      expect(file.pageUrl, isNull, reason: 'xvs has no default template');
    });

    test('fileInfo throws NotFoundException for unknown codes', () async {
      h.onGet('file/info', fixture('file_info_not_found'));

      expect(
        h.provider.fileInfo(const FileId('missing12345')),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('rename, move and delete call the file endpoints', () async {
      h
        ..onGet('file/edit', fixture('edit_ok'))
        ..onGet('file/delete', fixture('delete_ok'));

      await h.provider.renameFile(const FileId('abc'), 'New title');
      expect(
        h.lastRequest('file/edit').queryParameters,
        allOf(
          containsPair('file_code', 'abc'),
          containsPair('file_title', 'New title'),
        ),
      );

      await h.provider.moveFile(const FileId('abc'), const FolderId('7'));
      expect(
        h.lastRequest('file/edit').queryParameters,
        containsPair('file_fld_id', '7'),
      );

      await h.provider.deleteFile(const FileId('abc'));
      expect(
        h.lastRequest('file/delete').queryParameters,
        containsPair('file_code', 'abc'),
      );
    });
  });

  group('uploads', () {
    const serverUrl = 'https://s1.myvideo.com/upload/01';
    const video = UploadFileInfo(name: 'movie.mp4', size: 64 * 1024);

    Map<String, dynamic> infoFor(String code) {
      final json = fixture('file_info');
      final entry = (json['result'] as List).single as Map<String, dynamic>;
      entry['file_code'] = code;
      return json;
    }

    UploadResponse reply(Object body, {int status = 200}) =>
        UploadResponse(statusCode: status, body: jsonEncode(body));

    Future<UploadRequest> prepare([
      UploadOptions options = const UploadOptions(),
    ]) {
      h.onGet('upload/server', fixture('upload_server'));
      return h.provider.prepareUpload(video, options: options);
    }

    test('prepareUpload targets the server of upload/server', () async {
      final request = await prepare(
        const UploadOptions(
          title: 'My movie',
          description: 'Trailer',
          folderId: FolderId('16'),
          isPublic: true,
          isAdult: false,
          tags: ['promo', 'hd'],
          fields: {'extra': 'x'},
        ),
      );

      expect(h.requests.map((r) => r.path), ['upload/server']);
      expect(request.url, Uri.parse(serverUrl));
      expect(request.method, 'POST');
      expect(request.encoding, UploadEncoding.multipart);
      expect(request.fileField, 'file');
      expect(request.fields, {
        'key': testApiKey,
        'fld_id': '16',
        'file_title': 'My movie',
        'file_descr': 'Trailer',
        'file_public': '1',
        'file_adult': '0',
        'tags': 'promo, hd',
        'extra': 'x',
      });
      expect(request.fields.keys.first, 'key');
      expect(request.headers, isEmpty);
      expect(
        UploadRequest.fromJson(
          jsonDecode(jsonEncode(request.toJson())) as Map<String, dynamic>,
        ),
        request,
      );
    });

    test('prepareUpload skips options that are not set', () async {
      final request = await prepare();
      expect(request.fields, {'key': testApiKey});
    });

    test('completeUpload returns the details of the new file', () async {
      final request = await prepare(
        const UploadOptions(title: 'My movie', folderId: FolderId('16')),
      );
      h.onGet(
        'file/info',
        infoFor('u9150wqzvhxj'),
        query: {'file_code': 'u9150wqzvhxj'},
      );

      final file = await h.provider.completeUpload(
        request,
        reply(fixture('upload_result')),
      );

      expect(file.id, const FileId('u9150wqzvhxj'));
      expect(file.name, 'big buck bunny');
      expect(file.size, const DataSize(64 * 1024), reason: 'known length');
    });

    test('accepts `file_code` and builds a minimal file', () async {
      final request = await prepare(
        const UploadOptions(folderId: FolderId('7'), isPublic: false),
      );
      h.onGet('file/info', fixture('file_info_not_found'));

      final file = await h.provider.completeUpload(
        request,
        reply(fixture('upload_result_vidhide')),
      );

      expect(file.id, const FileId('lscc79sittad'));
      expect(file.name, 'trailer.mp4');
      expect(file.folderId, const FolderId('7'));
      expect(file.size, const DataSize(64 * 1024));
      expect(file.isPublic, isFalse);
      expect(file.isReady, isFalse);
      expect(file.pageUrl, Uri.parse('https://xvs.test/lscc79sittad.html'));
    });

    test('rejects extensions not allowed before calling the API', () async {
      final error = await h.provider
          .prepareUpload(const UploadFileInfo(name: 'notes.txt', size: 3))
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(error, isA<UploadRejectedException>());
      final reason = (error! as UploadRejectedException).reason;
      expect(reason, isA<ExtensionNotAllowed>());
      expect((reason as ExtensionNotAllowed).extension, 'txt');
      expect(h.requests, isEmpty);
    });

    test(
      'rejects files larger than the limit before calling the API',
      () async {
        h = XvsHarness(
          limits: const ProviderLimits(maxFileSize: DataSize.kb(1)),
        );

        final error = await h.provider
            .prepareUpload(video)
            .then<Object?>((_) => null, onError: (Object e) => e);

        expect(error, isA<UploadRejectedException>());
        final reason = (error! as UploadRejectedException).reason;
        expect(reason, isA<FileTooLarge>());
        expect((reason as FileTooLarge).maxSize, const DataSize.kb(1));
        expect(h.requests, isEmpty);
      },
    );

    test('refuses an insecure upload server', () async {
      h.onGet('upload/server', {
        'msg': 'OK',
        'status': 200,
        'result': 'http://s1.myvideo.com/upload/01',
      });

      await expectLater(
        h.provider.prepareUpload(video),
        throwsA(isA<ProviderException>()),
      );
    });

    test('maps errors reported for the uploaded file', () async {
      final request = await prepare();

      await expectLater(
        h.provider.completeUpload(
          request,
          reply({
            'msg': 'OK',
            'status': 200,
            'files': [
              {
                'filecode': '',
                'filename': 'movie.mp4',
                'status': 'Max filesize limit exceeded',
              },
            ],
          }),
        ),
        throwsA(isA<QuotaExceededException>()),
      );
    });

    test('removes the code prefix of upload server errors', () async {
      final request = await prepare();

      final error = await h.provider
          .completeUpload(request, reply(fixture('upload_result_too_short')))
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(
        error,
        isA<ProviderException>()
            .having((e) => e.message, 'message', 'video is too short')
            .having((e) => e.statusCode, 'status', 200),
      );
      expect(TransferManager.isRetryable(error! as ProviderException), isFalse);
    });

    test('errors of accepted uploads are not retried', () async {
      final request = await prepare();

      final error = await h.provider
          .completeUpload(
            request,
            reply({
              'files': [
                {'filecode': '', 'status': 'Conversion queue is broken'},
              ],
            }),
          )
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(
        error,
        isA<ProviderException>().having((e) => e.statusCode, 'status', 200),
      );
      expect(TransferManager.isRetryable(error! as ProviderException), isFalse);
    });

    test('maps HTTP errors of the upload server', () async {
      final request = await prepare();

      await expectLater(
        h.provider.completeUpload(
          request,
          reply({'msg': 'Invalid key', 'status': 403}, status: 403),
        ),
        throwsA(isA<AuthenticationException>()),
      );
      final error = await h.provider
          .completeUpload(
            request,
            const UploadResponse(statusCode: 502, body: '<html>Bad</html>'),
          )
          .then<Object?>((_) => null, onError: (Object e) => e);
      expect(
        error,
        isA<ProviderException>().having((e) => e.statusCode, 'status', 502),
      );
      expect(TransferManager.isRetryable(error! as ProviderException), isTrue);
    });

    test('runs through TransferManager with an executor', () async {
      h
        ..onGet('upload/server', fixture('upload_server'))
        ..onGet(
          'file/info',
          infoFor('u9150wqzvhxj'),
          query: {'file_code': 'u9150wqzvhxj'},
        );
      final executor = FakeUploadExecutor(
        respond: (request, _) => request.url == Uri.parse(serverUrl)
            ? reply(fixture('upload_result'))
            : null,
      );
      final manager = TransferManager(
        resolveProvider: (_) => h.provider,
        executor: executor,
        settings: const UploadSettings(checkStorage: false),
      );
      addTearDown(manager.dispose);

      final task = manager.upload(
        'acc',
        UploadSource.bytes(List.filled(1024, 1), name: 'movie.mp4'),
        options: const UploadOptions(title: 'My movie'),
      );
      final file = await task.result;

      expect(file.id, const FileId('u9150wqzvhxj'));
      expect(executor.requests.single.fields, {
        'key': testApiKey,
        'file_title': 'My movie',
      });
      expect(h.requests.map((r) => r.path), ['upload/server', 'file/info']);
    });

    test('reports responses that are not JSON', () async {
      final request = await prepare();

      await expectLater(
        h.provider.completeUpload(
          request,
          const UploadResponse(statusCode: 200, body: 'Upload done'),
        ),
        throwsA(isA<ProviderException>()),
      );
    });
  });

  group('remote uploads', () {
    test('uploadFromUrl queues the URL', () async {
      final url = Uri.parse(
        'http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4',
      );
      h.onGet(
        'upload/url',
        fixture('upload_url'),
        query: {'url': url.toString(), 'fld_id': '7', 'file_adult': '0'},
      );

      final job = await h.provider.uploadFromUrl(
        url,
        options: const UploadOptions(folderId: FolderId('7'), isAdult: false),
      );

      expect(job.id, 'fb5asfuj2snh');
      expect(job.fileId, const FileId('fb5asfuj2snh'));
      expect(job.status, RemoteUploadStatus.pending);
      expect(job.sourceUrl, url);
      expect(job.folderId, const FolderId('7'));
    });

    test('remoteUploads maps file/url_uploads', () async {
      h.onGet('file/url_uploads', fixture('url_uploads'));

      final [pending, working, failed] = await h.provider.remoteUploads();

      expect(pending.id, 'https://xvs.tt/1.mp4');
      expect(pending.fileId, isNull);
      expect(pending.status, RemoteUploadStatus.pending);
      expect(pending.folderId, isNull);

      expect(working.id, 'xyayxm9ajlys');
      expect(working.status, RemoteUploadStatus.working);
      expect(working.progress, closeTo(0.45, 1e-9));
      expect(working.folderId, const FolderId('7'));

      expect(failed.status, RemoteUploadStatus.failed);
      expect(failed.error, 'ERROR');
    });

    test('remoteUploadStatus finds a job by file code', () async {
      h
        ..onGet(
          'file/url_uploads',
          fixture('url_uploads'),
          query: {'file_code': 'xyayxm9ajlys'},
        )
        ..onGet(
          'file/url_uploads',
          {'status': 200, 'msg': 'OK', 'result': <Object>[]},
          query: {'file_code': 'unknown'},
        );

      final job = await h.provider.remoteUploadStatus('xyayxm9ajlys');

      expect(job.status, RemoteUploadStatus.working);
      await expectLater(
        h.provider.remoteUploadStatus('unknown'),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('cancelRemoteUpload deletes by code', () async {
      h.onGet(
        'file/url_actions',
        fixture('url_actions'),
        query: {'delete_code': 'xyayxm9ajlys'},
      );

      await h.provider.cancelRemoteUpload('xyayxm9ajlys');

      expect(h.requests, hasLength(1));
      await expectLater(
        h.provider.cancelRemoteUpload('https://xvs.tt/1.mp4'),
        throwsA(isA<UnsupportedOperationException>()),
      );
    });
  });

  group('errors', () {
    test('maps an invalid key to AuthenticationException', () async {
      h.onGet('account/info', fixture('invalid_key'));

      await expectLater(
        h.provider.accountInfo(),
        throwsA(
          isA<AuthenticationException>().having(
            (e) => e.message,
            'message',
            'Invalid key',
          ),
        ),
      );
    });

    test('reads the API message of HTTP errors', () async {
      h.onGet('account/info', fixture('invalid_key'), status: 403);

      await expectLater(
        h.provider.accountInfo(),
        throwsA(
          isA<AuthenticationException>().having(
            (e) => e.message,
            'message',
            'Invalid key',
          ),
        ),
      );
    });

    test('maps 404 to NotFoundException', () async {
      h.onGet('file/delete', fixture('file_not_found'));

      await expectLater(
        h.provider.deleteFile(const FileId('nope')),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('maps "Invalid operation" to UnsupportedOperationException', () async {
      // What StreamHG and EarnVids answer to file/delete and folder/delete.
      h
        ..onGet('file/delete', fixture('invalid_operation'))
        ..onGet('folder/delete', fixture('invalid_operation'));

      await expectLater(
        h.provider.deleteFile(const FileId('abc')),
        throwsA(
          isA<UnsupportedOperationException>().having(
            (e) => e.message,
            'message',
            'Invalid operation',
          ),
        ),
      );
      await expectLater(
        h.provider.deleteFolder(const FolderId('1')),
        throwsA(isA<UnsupportedOperationException>()),
      );
    });

    test('maps quota messages to QuotaExceededException', () async {
      h.onGet('upload/url', {
        'msg': 'You have reached the daily upload limit',
        'status': 400,
      });

      await expectLater(
        h.provider.uploadFromUrl(Uri.parse('https://example.com/a.mp4')),
        throwsA(isA<QuotaExceededException>()),
      );
    });

    test('maps other errors to ProviderException', () async {
      h.onGet('folder/delete', {'msg': 'Folder is not empty', 'status': 400});

      await expectLater(
        h.provider.deleteFolder(const FolderId('1')),
        throwsA(
          isA<ProviderException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', 'Folder is not empty')
              .having(
                (e) => e.response,
                'response',
                isA<Map<String, Object?>>(),
              ),
        ),
      );
    });

    test('maps server errors without envelope to ProviderException', () async {
      h.onGet('account/info', '<html>Bad gateway</html>', status: 502);

      await expectLater(
        h.provider.accountInfo(),
        throwsA(
          isA<ProviderException>().having((e) => e.statusCode, 'status', 502),
        ),
      );
    });

    test('reports a missing API key as AuthenticationException', () async {
      final provider = testDefinition.create(
        const Credentials({}),
        options: ProviderOptions(dio: Dio(), maxRetries: 0),
      ) as XvsProvider;

      await expectLater(
        provider.accountInfo(),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('disabled capabilities throw UnsupportedOperationException', () {
      final definition = testXvsDefinition(
        info: const ProviderInfo(id: 'lite', name: 'Lite'),
        apiBase: Uri.parse('https://lite.test/api'),
        disabledCapabilities: {Capability.remoteUpload},
      );
      final provider =
          definition.create(Credentials.apiKey('k')) as XvsProvider;
      addTearDown(provider.close);

      expect(definition.capabilities, isNot(contains(Capability.remoteUpload)));
      expect(provider.supports(Capability.remoteUpload), isFalse);
      expect(
        () => provider.uploadFromUrl(Uri.parse('https://x.test/a.mp4')),
        throwsA(isA<UnsupportedOperationException>()),
      );
    });
  });
}
