import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/src/drivers/mediafire/mediafire_api.dart';
import 'package:upcloud/upcloud.dart';

import '../../support/bundled_providers.dart';

import 'mediafire_harness.dart';

void main() {
  group('definition', () {
    test('describes the provider', () {
      expect(mediaFire.id, 'mediafire');
      expect(mediaFire.info.driver, 'mediafire');
      expect(mediaFire.info.name, 'MediaFire');
      expect(
        mediaFire.defaultBaseUrl,
        Uri.parse('https://www.mediafire.com/api/1.5/'),
      );
      expect(mediaFire.defaultLimits.maxFileSize, const DataSize.gb(5));
    });

    test('credential schema', () {
      final fields = {
        for (final f in mediaFire.credentialSchema.fields) f.id: f,
      };
      // Only email and password: the public application id is implicit.
      expect(fields.keys, ['email', 'password']);
      expect(fields['email']!.kind, CredentialInputKind.email);
      expect(fields['password']!.kind, CredentialInputKind.secret);
      expect(
        mediaFire.credentialSchema.missingFields(MediaFireHarness.credentials),
        isEmpty,
      );
      expect(
        mediaFire.credentialSchema.missingFields(
          const Credentials({'email': 'me@example.com'}),
        ),
        ['password'],
      );
    });

    test('create() builds a provider with every declared capability', () {
      final mf = MediaFireHarness();
      final provider = mediaFire.create(
        MediaFireHarness.credentials,
        options: ProviderOptions(dio: mf.dio),
      );

      expect(provider, isA<MediaFireProvider>());
      expect(provider.info, mediaFire.info);
      expect(provider.capabilities, mediaFire.capabilities);
      expect(provider.limits, mediaFire.defaultLimits);
      expect(provider.supports(Capability.remoteUpload), isTrue);
      provider.close();
    });

    test('the provider leaves out the capabilities the entry disables', () {
      final definition = mediaFireDriver.definitionFor(
        const ProviderConfig(
          id: 'mediafire-lite',
          name: 'MediaFire Lite',
          driver: MediaFireDriver.driverId,
          disabledCapabilities: ['remoteUpload', 'deleteFile'],
        ),
      );
      final mf = MediaFireHarness();
      final provider = definition.create(
        MediaFireHarness.credentials,
        options: ProviderOptions(dio: mf.dio),
      );

      expect(provider.capabilities, definition.capabilities);
      expect(provider.supports(Capability.remoteUpload), isFalse);
      expect(provider.supports(Capability.deleteFile), isFalse);
      expect(provider.supports(Capability.upload), isTrue);
      // Created from code, without a registry entry.
      expect(mf.provider().capabilities, mediaFireCapabilities);
    });

    test('options override the limits and the base URL', () async {
      final mf = MediaFireHarness()..login();
      final provider = mediaFire.create(
        MediaFireHarness.credentials,
        options: ProviderOptions(
          dio: mf.dio,
          baseUrl: Uri.parse('https://mirror.example.com/api/1.5'),
          limits: const ProviderLimits(maxFileSize: DataSize.gb(50)),
        ),
      );

      expect(provider.limits.maxFileSize, const DataSize.gb(50));
      await (provider as MediaFireProvider).signIn();
      expect(
        mf.requests.single.uri.toString(),
        'https://mirror.example.com/api/1.5/user/get_session_token.php',
      );
    });

    test('MediaFireCredentials.create skips a blank api key', () {
      final credentials = MediaFireCredentials.create(
        email: 'me@example.com',
        password: 'secret',
        applicationId: '42',
        apiKey: ' ',
      );
      expect(credentials.values.keys, ['email', 'password', 'application_id']);
    });
  });

  group('error mapping', () {
    UpCloudException map(int code) => mediaFireException(code, 'message');

    test('authentication errors', () {
      for (final code in [102, 103, 104, 105, 107, 108, 109, 127, 145, 215]) {
        expect(map(code), isA<AuthenticationException>(), reason: '$code');
      }
    });

    test('not found errors', () {
      for (final code in [110, 112, 209, 210, 259, 260]) {
        expect(map(code), isA<NotFoundException>(), reason: '$code');
      }
    });

    test('quota and rate limit errors', () {
      expect(map(162), isA<QuotaExceededException>());
      expect(map(130), isA<QuotaExceededException>());
      expect(map(163), isA<RateLimitedException>());
      expect(map(261), isA<RateLimitedException>());
    });

    test('anything else keeps the MediaFire code', () {
      expect(
        mediaFireException(114, 'Access denied', response: {'error': 114}),
        isA<ProviderException>()
            .having((e) => e.statusCode, 'statusCode', 114)
            .having((e) => e.message, 'message', 'Access denied')
            .having((e) => e.response, 'response', {'error': 114}),
      );
    });

    late MediaFireHarness mf;

    setUp(() => mf = MediaFireHarness()..login());

    test('errors in HTTP error responses use the MediaFire code', () async {
      mf.on('folder/delete', apiError(114, 'Access denied'), status: 403);

      await expectLater(
        mf.provider().deleteFolder(const FolderId('x')),
        throwsA(
          isA<ProviderException>().having((e) => e.statusCode, 'code', 114),
        ),
      );
    });

    test('storage limit errors throw QuotaExceededException', () async {
      mf.on(
        'folder/create',
        apiError(
          162,
          'The file(s)/folder(s) you upload/copy exceed your storage limit',
        ),
      );

      await expectLater(
        mf.provider().createFolder('Videos'),
        throwsA(isA<QuotaExceededException>()),
      );
    });

    test('codes prefixed with a sign are understood', () async {
      mf.on('file/get_info', {
        'response': {
          'result': 'Error',
          'error': '-110',
          'message': 'Unknown or Invalid QuickKey',
        },
      });

      await expectLater(
        mf.provider().fileInfo(const FileId('x')),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('non MediaFire error pages fall back to the HTTP status', () async {
      mf.on('user/get_info', '<html>Bad gateway</html>', status: 502);

      await expectLater(
        mf.provider().accountInfo(),
        throwsA(
          isA<ProviderException>().having((e) => e.statusCode, 'code', 502),
        ),
      );
    });

    test('unexpected successful bodies throw ProviderException', () async {
      mf.on('user/get_info', 'not json', asText: true);

      await expectLater(
        mf.provider().accountInfo(),
        throwsA(isA<ProviderException>()),
      );
    });
  });
}
