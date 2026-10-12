import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/src/core/http/http.dart';
import 'package:upcloud/upcloud.dart';

void main() {
  test('switches to a mirror when the primary host is unreachable', () async {
    final hosts = <String>[];
    final dio = Dio()
      ..httpClientAdapter = _HostAdapter(
        hosts,
        unreachable: {'primary.test', 'down.test'},
      );
    createDio(
      baseUrl: Uri.parse('https://primary.test/api'),
      options: ProviderOptions(
        dio: dio,
        maxRetries: 0,
        mirrors: [
          Uri.parse('https://down.test/api'),
          Uri.parse('https://mirror.test/api'),
        ],
      ),
    );

    final first = await dio.get<dynamic>('account/info');
    final second = await dio.get<dynamic>('file/list');

    expect(first.statusCode, 200);
    expect(second.statusCode, 200);
    expect(hosts, ['primary.test', 'down.test', 'mirror.test', 'mirror.test']);
    expect(dio.options.baseUrl, 'https://mirror.test/api/');
  });

  test('does not switch on HTTP errors', () async {
    final hosts = <String>[];
    final dio = Dio()..httpClientAdapter = _HostAdapter(hosts, status: 500);
    createDio(
      baseUrl: Uri.parse('https://primary.test/api'),
      options: ProviderOptions(
        dio: dio,
        maxRetries: 0,
        mirrors: [Uri.parse('https://mirror.test/api')],
      ),
    );

    await expectLater(
      guardRequest(() => dio.get<dynamic>('x')),
      throwsA(isA<ProviderException>()),
    );
    expect(hosts, ['primary.test']);
  });

  test('fails with a network error when every mirror is down', () async {
    final hosts = <String>[];
    final dio = Dio()
      ..httpClientAdapter = _HostAdapter(
        hosts,
        unreachable: {'primary.test', 'mirror.test'},
      );
    createDio(
      baseUrl: Uri.parse('https://primary.test/api'),
      options: ProviderOptions(
        dio: dio,
        maxRetries: 0,
        mirrors: [Uri.parse('https://mirror.test/api')],
      ),
    );

    await expectLater(
      guardRequest(() => dio.get<dynamic>('x')),
      throwsA(isA<NetworkException>()),
    );
    expect(hosts, ['primary.test', 'mirror.test']);
  });
}

/// Records the host of each request and fails for [unreachable] hosts.
final class _HostAdapter implements HttpClientAdapter {
  _HostAdapter(this.hosts, {this.unreachable = const {}, this.status = 200});

  final List<String> hosts;
  final Set<String> unreachable;
  final int status;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    hosts.add(options.uri.host);
    if (unreachable.contains(options.uri.host)) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'unreachable',
      );
    }
    return ResponseBody.fromString(
      '{}',
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
