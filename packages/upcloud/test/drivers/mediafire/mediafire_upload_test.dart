import 'dart:convert';

import 'package:test/test.dart';
import 'package:upcloud/upcloud.dart';

import 'mediafire_harness.dart';

const _file = UploadFileInfo(name: 'test 001.txt', size: 11);

/// The answer of `upload/simple` as received by an upload executor.
UploadResponse _reply(Object body, {int status = 200}) =>
    UploadResponse(statusCode: status, body: jsonEncode(body));

void main() {
  late MediaFireHarness mf;

  setUp(() => mf = MediaFireHarness()..login());

  group('prepareUpload', () {
    test('targets upload/simple with a session token', () async {
      final request = await mf.provider().prepareUpload(_file);

      expect(mf.actions, ['user/get_session_token']);
      expect(
        request.url.replace(query: ''),
        Uri.parse('https://www.mediafire.com/api/1.5/upload/simple.php?'),
      );
      expect(request.url.queryParameters, {
        'folder_key': 'myfiles',
        'action_on_duplicate': 'keep',
        'session_token': loginToken,
        'response_format': 'json',
      });
      expect(request.method, 'POST');
      expect(request.encoding, UploadEncoding.binary);
      expect(request.headers, {
        'content-type': 'application/octet-stream',
        'x-filename': 'test 001.txt',
        'x-filesize': '11',
      });
      expect(request.fields, isEmpty);
    });

    test('uses the folder and lets fields override the query', () async {
      final request = await mf.provider().prepareUpload(
        _file,
        options: const UploadOptions(
          folderId: FolderId('rfoh06y8w3amg'),
          fields: {'action_on_duplicate': 'replace', 'path': 'a/b'},
        ),
      );

      expect(request.url.queryParameters, {
        'folder_key': 'rfoh06y8w3amg',
        'action_on_duplicate': 'replace',
        'path': 'a/b',
        'session_token': loginToken,
        'response_format': 'json',
      });
    });

    test('renews an old session token first', () async {
      mf.on('user/renew_session_token', fixture('renew_session_token'));
      final provider = mf.provider();
      await provider.prepareUpload(_file);
      mf.now = mf.now.add(const Duration(minutes: 7));

      final request = await provider.prepareUpload(_file);

      expect(mf.actions, [
        'user/get_session_token',
        'user/renew_session_token',
      ]);
      expect(request.url.queryParameters['session_token'], renewedToken);
    });

    test('rejects files over the size limit before signing in', () async {
      final provider = mf.provider(
        limits: const ProviderLimits(maxFileSize: DataSize(5)),
      );

      await expectLater(
        provider.prepareUpload(_file),
        throwsA(
          isA<UploadRejectedException>().having(
            (e) => e.reason,
            'reason',
            isA<FileTooLarge>(),
          ),
        ),
      );
      expect(mf.requests, isEmpty);
    });
  });

  group('completeUpload', () {
    test('polls until the quickkey and returns the file', () async {
      var polls = 0;
      mf
        ..onCallback(
          'upload/poll_upload',
          (_) => ++polls == 1
              ? fixture('poll_upload_in_progress')
              : fixture('poll_upload_done'),
        )
        ..on('file/get_info', fixture('file_info'));
      final provider = mf.provider();
      final request = await provider.prepareUpload(_file);

      final file = await provider.completeUpload(
        request,
        _reply(fixture('upload_simple')),
      );

      expect(file.id, const FileId('7a8kc7354q939b6'));
      expect(file.name, 'test 001.txt');
      expect(mf.actions, [
        'user/get_session_token',
        'upload/poll_upload',
        'upload/poll_upload',
        'file/get_info',
      ]);
      for (final poll in mf.calls('upload/poll_upload')) {
        expect(fields(poll), containsPair('key', '068n326bzaw'));
      }
      expect(
        fields(mf.calls('file/get_info').single)['quick_key'],
        '7a8kc7354q939b6',
      );
    });

    test('applies description and privacy', () async {
      mf
        ..on('upload/poll_upload', fixture('poll_upload_done'))
        ..on('file/update', fixture('success'))
        ..on('file/get_info', fixture('file_info'));
      final provider = mf.provider();
      final request = await provider.prepareUpload(
        _file,
        options: const UploadOptions(description: 'Notes', isPublic: false),
      );

      await provider.completeUpload(request, _reply(fixture('upload_simple')));

      expect(fields(mf.calls('file/update').single), {
        'quick_key': '7a8kc7354q939b6',
        'description': 'Notes',
        'privacy': 'private',
        'session_token': loginToken,
        'response_format': 'json',
      });
    });

    test('falls back to the poll data when the details fail', () async {
      mf
        ..on('upload/poll_upload', fixture('poll_upload_done'))
        ..on('file/get_info', apiError(999, 'Internal error'), status: 500);
      final provider = mf.provider();
      final request = await provider.prepareUpload(
        _file,
        options: const UploadOptions(folderId: FolderId('rfoh06y8w3amg')),
      );

      final file = await provider.completeUpload(
        request,
        _reply(fixture('upload_simple')),
      );

      expect(file.id, const FileId('7a8kc7354q939b6'));
      expect(file.name, 'test 001.txt');
      expect(file.size, const DataSize(11));
      expect(file.folderId, const FolderId('rfoh06y8w3amg'));
      expect(
        file.pageUrl,
        Uri.parse('https://www.mediafire.com/file/7a8kc7354q939b6'),
      );
    });

    test('storage full while processing throws QuotaExceeded', () async {
      mf.on('upload/poll_upload', fixture('poll_upload_storage_full'));
      final provider = mf.provider();
      final request = await provider.prepareUpload(_file);

      await expectLater(
        provider.completeUpload(request, _reply(fixture('upload_simple'))),
        throwsA(isA<QuotaExceededException>()),
      );
    });

    test('rejected uploads report the doupload result', () async {
      final provider = mf.provider();
      final request = await provider.prepareUpload(_file);

      await expectLater(
        provider.completeUpload(
          request,
          _reply(
            success({
              'doupload': {'result': '-881'},
            }),
          ),
        ),
        throwsA(
          isA<ProviderException>().having(
            (e) => e.statusCode,
            'statusCode',
            -881,
          ),
        ),
      );
      expect(mf.calls('upload/poll_upload'), isEmpty);
    });

    test('a missing destination folder is a NotFoundException', () async {
      final provider = mf.provider();
      final request = await provider.prepareUpload(_file);

      await expectLater(
        provider.completeUpload(
          request,
          _reply(
            success({
              'doupload': {'result': '-14'},
            }),
          ),
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('an unknown upload key while polling throws', () async {
      mf.on(
        'upload/poll_upload',
        success({
          'doupload': {'result': '-80'},
        }),
      );
      final provider = mf.provider();
      final request = await provider.prepareUpload(_file);

      await expectLater(
        provider.completeUpload(request, _reply(fixture('upload_simple'))),
        throwsA(isA<ProviderException>()),
      );
    });

    test('stops polling after the timeout, without retrying', () async {
      mf.on('upload/poll_upload', fixture('poll_upload_in_progress'));
      final provider = mf.provider(pollTimeout: Duration.zero);
      final request = await provider.prepareUpload(_file);

      final error = await provider
          .completeUpload(request, _reply(fixture('upload_simple')))
          .then<Object?>((_) => null, onError: (Object e) => e);

      expect(
        error,
        isA<ProviderException>().having(
          (e) => e.message,
          'message',
          contains('still processing'),
        ),
      );
      expect(TransferManager.isRetryable(error! as ProviderException), isFalse);
    });

    test('maps API errors of the upload response', () async {
      final provider = mf.provider();
      final request = await provider.prepareUpload(_file);

      await expectLater(
        provider.completeUpload(
          request,
          _reply(apiError(162, 'Storage limit exceeded'), status: 400),
        ),
        throwsA(isA<QuotaExceededException>()),
      );
      await expectLater(
        provider.completeUpload(
          request,
          const UploadResponse(statusCode: 503, body: 'Unavailable'),
        ),
        throwsA(
          isA<ProviderException>().having((e) => e.statusCode, 'status', 503),
        ),
      );
    });
  });

  group('remote uploads', () {
    test('uploadFromUrl names the file after the URL', () async {
      mf.on('upload/add_web_upload', fixture('add_web_upload'));

      final job = await mf.provider().uploadFromUrl(
        Uri.parse('http://download.thinkbroadband.com/20MB.zip?x=1'),
      );

      expect(job.id, 'aogvo25zua');
      expect(job.status, RemoteUploadStatus.pending);
      expect(
        job.sourceUrl,
        Uri.parse('http://download.thinkbroadband.com/20MB.zip?x=1'),
      );
      expect(fields(mf.calls('upload/add_web_upload').single), {
        'url': 'http://download.thinkbroadband.com/20MB.zip?x=1',
        'filename': '20MB.zip',
        'folder_key': 'myfiles',
        'session_token': loginToken,
        'response_format': 'json',
      });
    });

    test('uploadFromUrl uses the title and folder', () async {
      mf.on('upload/add_web_upload', fixture('add_web_upload'));

      final job = await mf.provider().uploadFromUrl(
        Uri.parse('https://example.com/download'),
        options: const UploadOptions(
          title: 'video.mp4',
          folderId: FolderId('f1'),
        ),
      );

      expect(job.folderId, const FolderId('f1'));
      final sent = fields(mf.calls('upload/add_web_upload').single);
      expect(sent['filename'], 'video.mp4');
      expect(sent['folder_key'], 'f1');
    });

    test('remoteUploads maps the web upload states', () async {
      mf.on('upload/get_web_uploads', fixture('web_uploads'));

      final jobs = await mf.provider().remoteUploads();

      expect(
        fields(mf.calls('upload/get_web_uploads').single),
        containsPair('all_web_uploads', 'yes'),
      );
      expect(jobs.map((j) => j.id), [
        '93do9m68rx',
        '2xpae4meae',
        'o1ld6w6ga1',
        'zz9failed1',
      ]);
      expect(jobs.map((j) => j.status), [
        RemoteUploadStatus.completed,
        RemoteUploadStatus.working,
        RemoteUploadStatus.pending,
        RemoteUploadStatus.failed,
      ]);
      expect(jobs[0].fileId, const FileId('qjffa4pk82zydy3'));
      expect(jobs[0].progress, 1);
      expect(jobs[1].fileId, isNull);
      expect(jobs[1].progress, closeTo(0.84, 1e-9));
      expect(jobs[1].extra['filename'], '008.zip');
      expect(jobs[3].error, 'Missing file');
    });

    test('cancelRemoteUpload is not supported', () async {
      await expectLater(
        mf.provider().cancelRemoteUpload('93do9m68rx'),
        throwsA(isA<UnsupportedOperationException>()),
      );
    });
  });
}
