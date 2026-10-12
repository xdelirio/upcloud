import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/upcloud.dart';

void main() {
  group('DataSize', () {
    test('converts units', () {
      expect(const DataSize.kb(1).bytes, 1024);
      expect(const DataSize.mb(1).bytes, 1024 * 1024);
      expect(const DataSize.gb(2).inGigabytes, 2);
    });

    test('formats human readable values', () {
      expect(const DataSize(512).toString(), '512 B');
      expect(const DataSize.kb(2).toString(), '2.0 KB');
      expect(const DataSize(1572864).toString(), '1.5 MB');
      expect(const DataSize.gb(15).toString(), '15.0 GB');
    });

    test('compares and does arithmetic', () {
      expect(const DataSize.mb(2) > const DataSize.mb(1), isTrue);
      expect(const DataSize.mb(1) - const DataSize.mb(2), DataSize.zero);
      expect(const DataSize.mb(1) + const DataSize.mb(1), const DataSize.mb(2));
    });
  });

  group('PagedResult.hasMore', () {
    const request = PageRequest(perPage: 10);

    test('uses the explicit hint first', () {
      const page = PagedResult<int>(
        items: [],
        request: request,
        totalPages: 5,
        hasMoreHint: false,
      );
      expect(page.hasMore, isFalse);
    });

    test('uses totalPages', () {
      expect(
        const PagedResult<int>(
          items: [],
          request: request,
          totalPages: 2,
        ).hasMore,
        isTrue,
      );
      expect(
        PagedResult<int>(
          items: const [],
          request: request.copyWith(page: 2),
          totalPages: 2,
        ).hasMore,
        isFalse,
      );
    });

    test('uses totalItems', () {
      expect(
        const PagedResult<int>(
          items: [],
          request: request,
          totalItems: 11,
        ).hasMore,
        isTrue,
      );
      expect(
        const PagedResult<int>(
          items: [],
          request: request,
          totalItems: 10,
        ).hasMore,
        isFalse,
      );
    });

    test('falls back to a full page meaning there may be more', () {
      final full = List.generate(10, (i) => i);
      expect(PagedResult(items: full, request: request).hasMore, isTrue);
      expect(const PagedResult(items: [1], request: request).hasMore, isFalse);
    });
  });

  test('PageRequest.next increments the page', () {
    expect(PageRequest.first.next.page, 2);
  });

  test('TransferProgress.fraction', () {
    expect(const TransferProgress(transferred: 5, total: 10).fraction, 0.5);
    expect(const TransferProgress(transferred: 5).fraction, isNull);
    expect(const TransferProgress(transferred: 20, total: 10).fraction, 1);
  });

  group('UploadSource', () {
    test('derives name and extension from the path', () {
      const source = UploadSource.file('/tmp/My Video.MP4');
      expect(source.name, 'My Video.MP4');
      expect(source.extension, 'mp4');
    });

    test('handles windows paths and custom names', () {
      expect(const UploadSource.file(r'C:\a\b.mkv').name, 'b.mkv');
      expect(const UploadSource.file('/x/y', name: 'z.ts').extension, 'ts');
      expect(const UploadSource.bytes([1], name: 'noext').extension, '');
    });

    test('resolves length', () async {
      expect(
        await const UploadSource.bytes([1, 2, 3], name: 'a').resolveLength(),
        3,
      );
      expect(
        await const UploadSource.file('/definitely/missing').resolveLength(),
        isNull,
      );
      expect(await const UploadSource.file('/x', length: 7).resolveLength(), 7);
    });
  });

  group('ProviderLimits.check', () {
    const limits = ProviderLimits(
      maxFileSize: DataSize.mb(10),
      allowedExtensions: {'mp4'},
    );

    test('accepts valid files', () {
      expect(
        limits.check(extension: 'MP4', size: const DataSize.mb(5)),
        isNull,
      );
    });

    test('rejects extensions', () {
      expect(
        limits.check(extension: 'exe'),
        isA<ExtensionNotAllowed>().having((r) => r.extension, 'ext', 'exe'),
      );
    });

    test('rejects large files', () {
      expect(
        limits.check(extension: 'mp4', size: const DataSize.mb(11)),
        isA<FileTooLarge>(),
      );
    });

    test('rejects when storage is not enough', () {
      expect(
        limits.check(
          extension: 'mp4',
          size: const DataSize.mb(5),
          storageLeft: const DataSize.mb(1),
        ),
        isA<NotEnoughStorage>(),
      );
    });
  });

  group('Credentials', () {
    test('round trips through JSON', () {
      final credentials = Credentials.apiKey('abc');
      expect(Credentials.fromJson(credentials.toJson()), credentials);
      expect(credentials.apiKey, 'abc');
    });

    test('require throws AuthenticationException when missing', () {
      expect(
        () => const Credentials({'api_key': '  '}).apiKey,
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('schema reports missing required fields', () {
      final schema = CredentialSchema.apiKey();
      expect(schema.missingFields(const Credentials({})), ['api_key']);
      expect(schema.missingFields(Credentials.apiKey('x')), isEmpty);
    });
  });

  test('CloudAccount round trips through JSON', () {
    final account = CloudAccount(
      id: 'a1',
      providerId: 'demo',
      label: 'Demo',
      credentials: Credentials.apiKey('k'),
      baseUrl: Uri.parse('https://mirror.example.com/api'),
      maxFileSizeBytes: 100,
      createdAt: DateTime.utc(2024),
    );
    expect(CloudAccount.fromJson(account.toJson()), account);
  });

  test('capabilities are derived from implemented interfaces', () {
    final provider = InMemoryProviderForTest();
    expect(provider.supports(Capability.upload), isTrue);
    expect(provider.supports(Capability.remoteUpload), isFalse);
    expect(provider.capability<FileUploading>(), same(provider));
    expect(provider.capability<RemoteUploading>(), isNull);
  });

  group('upload requests', () {
    test('UploadSource.resolveInfo gives the name and size', () async {
      final info = await const UploadSource.bytes([
        1,
        2,
        3,
      ], name: 'Clip.MP4').resolveInfo();
      expect(info, const UploadFileInfo(name: 'Clip.MP4', size: 3));
      expect(info.extension, 'mp4');
      expect(const UploadFileInfo(name: 'README').extension, '');
    });

    test('UploadRequest round trips through JSON', () {
      final request = UploadRequest(
        url: Uri.parse('https://s1.example.com/upload?x=1'),
        encoding: UploadEncoding.binary,
        fields: const {'key': 'k'},
        headers: const {'x-filename': 'a.mp4'},
        context: const {'size': '3'},
      );
      final json = jsonDecode(jsonEncode(request.toJson()));
      expect(UploadRequest.fromJson(json as Map<String, dynamic>), request);
    });

    test('UploadRequest has multipart POST defaults', () {
      final request = UploadRequest(url: Uri.parse('https://a.test'));
      expect(request.method, 'POST');
      expect(request.encoding, UploadEncoding.multipart);
      expect(request.fileField, 'file');
      expect(request.fields, isEmpty);
    });

    test('UploadResponse reads status and headers', () {
      const response = UploadResponse(
        statusCode: 201,
        body: '{}',
        headers: {'Retry-After': '5'},
      );
      expect(response.isSuccessful, isTrue);
      expect(response.header('retry-after'), '5');
      expect(response.header('x-missing'), isNull);
      expect(
        const UploadResponse(statusCode: 302, body: '').isSuccessful,
        isFalse,
      );
      expect(UploadResponse.fromJson(response.toJson()), response);
    });

    test('uploadResponseException maps HTTP statuses', () {
      UpCloudException error(int status, [Map<String, String>? headers]) =>
          uploadResponseException(
            UploadResponse(
              statusCode: status,
              body: 'oops',
              headers: headers ?? const {},
            ),
          );

      expect(error(401), isA<AuthenticationException>());
      expect(error(404), isA<NotFoundException>());
      expect(
        error(429, {'retry-after': '7'}),
        isA<RateLimitedException>().having(
          (e) => e.retryAfter,
          'retryAfter',
          const Duration(seconds: 7),
        ),
      );
      expect(
        error(503),
        isA<ProviderException>()
            .having((e) => e.statusCode, 'statusCode', 503)
            .having((e) => e.response, 'response', 'oops'),
      );
    });
  });

  group('KeyValueStore', () {
    test('registry store names are aliases', () async {
      final RegistryStore store = InMemoryRegistryStore({'a': '1'});
      expect(store, isA<InMemoryKeyValueStore>());
      await store.write('b', '2');
      await store.write('a', null);
      expect((store as InMemoryKeyValueStore).values, {'b': '2'});
      expect(await store.read('b'), '2');
    });
  });
}

/// Minimal provider used to test capability detection.
final class InMemoryProviderForTest implements FileUploading {
  @override
  ProviderInfo get info => const ProviderInfo(id: 't', name: 'T');

  @override
  ProviderLimits get limits => ProviderLimits.none;

  @override
  Set<Capability> get capabilities => interfaceCapabilities(this);

  @override
  void close() {}

  @override
  Future<UploadRequest> prepareUpload(
    UploadFileInfo file, {
    UploadOptions options = const UploadOptions(),
  }) => throw UnimplementedError();

  @override
  Future<CloudFile> completeUpload(
    UploadRequest request,
    UploadResponse response,
  ) => throw UnimplementedError();
}
