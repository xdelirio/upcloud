import 'dart:convert';

import 'package:test/test.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_api.dart';
import 'package:upcloud/upcloud.dart';

import '../../support/bundled_providers.dart';

import 'mediafire_harness.dart';

void main() {
  late MediaFireHarness mf;

  setUp(() => mf = MediaFireHarness());

  group('signature', () {
    test('is SHA1(email + password + application id)', () {
      expect(
        mediaFireSessionSignature(
          email: 'me@example.com',
          password: 'secret',
          applicationId: '42',
        ),
        'd17d3967ae50fd7501f611b53fd2de8f2d3244aa',
      );
    });

    test('appends the api key when there is one', () {
      expect(
        mediaFireSessionSignature(
          email: 'me@example.com',
          password: 'secret',
          applicationId: '42',
          apiKey: 'appkey',
        ),
        '1246a977a29d32e7fc84d3ec6dab7ead3476f86e',
      );
    });
  });

  group('login', () {
    test('requests a version 1 token with the signature', () async {
      mf
        ..login()
        ..on('user/get_info', fixture('user_info'));

      await mf.provider().accountInfo();

      expect(mf.actions, ['user/get_session_token', 'user/get_info']);
      final login = mf.calls('user/get_session_token').single;
      expect(fields(login), {
        'email': 'me@example.com',
        'password': 'secret',
        'application_id': '42',
        'signature': 'd17d3967ae50fd7501f611b53fd2de8f2d3244aa',
        'token_version': '1',
        'response_format': 'json',
      });
      expect(
        fields(mf.calls('user/get_info').single)['session_token'],
        loginToken,
      );
    });

    test('signs with the api key when the credentials have one', () async {
      mf.login();
      final provider = MediaFireProvider(
        credentials: MediaFireCredentials.create(
          email: 'me@example.com',
          password: 'secret',
          applicationId: '42',
          apiKey: 'appkey',
        ),
        options: ProviderOptions(dio: mf.dio, maxRetries: 0),
      );

      await provider.signIn();

      expect(
        fields(mf.calls('user/get_session_token').single)['signature'],
        '1246a977a29d32e7fc84d3ec6dab7ead3476f86e',
      );
    });

    test('reuses the token for later calls', () async {
      mf
        ..login()
        ..on('user/get_info', fixture('user_info'));
      final provider = mf.provider();

      await provider.accountInfo();
      await provider.accountInfo();

      expect(mf.calls('user/get_session_token'), hasLength(1));
      expect(mf.calls('user/get_info'), hasLength(2));
    });

    test('concurrent calls share a single login', () async {
      mf
        ..login()
        ..on('user/get_info', fixture('user_info'));
      final provider = mf.provider();

      await Future.wait([
        provider.accountInfo(),
        provider.accountInfo(),
        provider.accountInfo(),
      ]);

      expect(mf.calls('user/get_session_token'), hasLength(1));
    });

    test('invalid credentials throw AuthenticationException', () async {
      mf.on(
        'user/get_session_token',
        fixture('error_invalid_credentials'),
        status: 403,
      );

      await expectLater(
        mf.provider().signIn(),
        throwsA(
          isA<AuthenticationException>().having(
            (e) => e.message,
            'message',
            'The Credentials you entered are invalid',
          ),
        ),
      );
      expect(mf.actions, ['user/get_session_token']);
    });

    test('a login without token throws AuthenticationException', () async {
      mf.on('user/get_session_token', success());

      await expectLater(
        mf.provider().signIn(),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('missing credentials are rejected when creating the provider', () {
      expect(
        () => mediaFire.create(
          const Credentials({'email': 'me@example.com', 'password': 'x'}),
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });

  group('expired token', () {
    test('logs in again and retries the call once', () async {
      var logins = 0;
      mf
        ..onCallback(
          'user/get_session_token',
          (_) => sessionToken(++logins == 1 ? 'old-token' : 'new-token'),
        )
        ..on(
          'user/get_info',
          fixture('error_invalid_token'),
          status: 403,
          data: {'session_token': 'old-token'},
        )
        ..on(
          'user/get_info',
          fixture('user_info'),
          data: {'session_token': 'new-token'},
        );

      final info = await mf.provider().accountInfo();

      expect(info.email, 't03@example.com');
      expect(mf.actions, [
        'user/get_session_token',
        'user/get_info',
        'user/get_session_token',
        'user/get_info',
      ]);
    });

    test('also detects token errors returned with HTTP 200', () async {
      var logins = 0;
      mf
        ..onCallback(
          'user/get_session_token',
          (_) => sessionToken(++logins == 1 ? 'old-token' : 'new-token'),
        )
        ..on(
          'file/delete',
          apiError(105, 'The supplied Session Token is expired or invalid'),
          data: {'session_token': 'old-token'},
        )
        ..on(
          'file/delete',
          fixture('success'),
          data: {'session_token': 'new-token'},
        );

      await mf.provider().deleteFile(const FileId('abc'));

      expect(mf.calls('file/delete'), hasLength(2));
    });

    test('gives up with AuthenticationException after one retry', () async {
      mf
        ..login()
        ..on('user/get_info', fixture('error_invalid_token'), status: 403);

      await expectLater(
        mf.provider().accountInfo(),
        throwsA(isA<AuthenticationException>()),
      );
      expect(mf.calls('user/get_session_token'), hasLength(2));
      expect(mf.calls('user/get_info'), hasLength(2));
    });

    test('an upload sent with an expired token is prepared again', () async {
      var logins = 0;
      mf
        ..onCallback(
          'user/get_session_token',
          (_) => sessionToken(++logins == 1 ? 'old-token' : 'new-token'),
        )
        ..on('upload/poll_upload', fixture('poll_upload_done'))
        ..on('file/get_info', fixture('file_info'));
      final provider = mf.provider();
      final expired = await provider.prepareUpload(
        const UploadFileInfo(name: 'test 001.txt', size: 11),
      );

      final error = await provider
          .completeUpload(
            expired,
            UploadResponse(
              statusCode: 200,
              body: jsonEncode(
                apiError(105, 'The supplied Session Token is expired'),
              ),
            ),
          )
          .then<Object?>((_) => null, onError: (Object e) => e);
      expect(error, isA<ProviderException>());
      expect(TransferManager.isRetryable(error! as ProviderException), isTrue);

      final retry = await provider.prepareUpload(
        const UploadFileInfo(name: 'test 001.txt', size: 11),
      );
      expect(retry.url.queryParameters['session_token'], 'new-token');
      final file = await provider.completeUpload(
        retry,
        UploadResponse(
          statusCode: 200,
          body: jsonEncode(fixture('upload_simple')),
        ),
      );
      expect(file.id, const FileId('7a8kc7354q939b6'));
    });
  });

  group('renewal', () {
    test('renews tokens older than six minutes before using them', () async {
      mf
        ..login()
        ..on('user/renew_session_token', fixture('renew_session_token'))
        ..on('user/get_info', fixture('user_info'));
      final provider = mf.provider();

      await provider.accountInfo();
      mf.now = mf.now.add(const Duration(minutes: 5));
      await provider.accountInfo();
      mf.now = mf.now.add(const Duration(minutes: 2));
      await provider.accountInfo();

      expect(mf.actions, [
        'user/get_session_token',
        'user/get_info',
        'user/get_info',
        'user/renew_session_token',
        'user/get_info',
      ]);
      final calls = mf.calls('user/get_info');
      expect(fields(calls[1])['session_token'], loginToken);
      expect(fields(calls[2])['session_token'], renewedToken);
      expect(
        fields(mf.calls('user/renew_session_token').single)['session_token'],
        loginToken,
      );
    });

    test('logs in again when the renewal is refused', () async {
      mf
        ..login()
        ..on(
          'user/renew_session_token',
          fixture('error_invalid_token'),
          status: 403,
        )
        ..on('user/get_info', fixture('user_info'));
      final provider = mf.provider();

      await provider.accountInfo();
      mf.now = mf.now.add(const Duration(minutes: 30));
      await provider.accountInfo();

      expect(mf.actions, [
        'user/get_session_token',
        'user/get_info',
        'user/renew_session_token',
        'user/get_session_token',
        'user/get_info',
      ]);
    });
  });

  test('a closed provider rejects calls', () async {
    final provider = mf.provider()..close();

    await expectLater(provider.accountInfo(), throwsStateError);
    expect(mf.requests, isEmpty);
  });
}
