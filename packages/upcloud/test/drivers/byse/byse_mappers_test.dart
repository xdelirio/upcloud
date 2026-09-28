import 'package:test/test.dart';
import 'package:upcloud/src/drivers/byse/byse_api.dart';
import 'package:upcloud/src/drivers/byse/byse_mappers.dart';
import 'package:upcloud/upcloud.dart';

void main() {
  const template = 'https://byse.sx/d/{id}';

  group('byseApiException', () {
    UpCloudException map(String message, [int? status = 400]) =>
        byseApiException(status, message);

    test('detects authentication errors', () {
      for (final message in [
        'Invalid key',
        'Wrong API key',
        'key is invalid',
        'Unauthorized',
      ]) {
        expect(map(message), isA<AuthenticationException>(), reason: message);
      }
      expect(map('Oops', 401), isA<AuthenticationException>());
    });

    test('detects missing files', () {
      for (final message in [
        'File not found',
        'No such file',
        "Folder doesn't exist",
        'no file',
      ]) {
        expect(map(message), isA<NotFoundException>(), reason: message);
      }
      expect(map('Oops', 404), isA<NotFoundException>());
    });

    test('detects rate limits and quotas', () {
      expect(map('Too many requests'), isA<RateLimitedException>());
      expect(map('Oops', 429), isA<RateLimitedException>());
      expect(map('Not enough disk space'), isA<QuotaExceededException>());
      expect(map('Daily limit reached'), isA<QuotaExceededException>());
    });

    test('keeps other errors as ProviderException', () {
      expect(
        map('Cloning disabled', 403),
        isA<ProviderException>().having((e) => e.statusCode, 'status', 403),
      );
      expect(byseApiException(null, null).message, 'Byse API error');
    });
  });

  group('parseByseEnvelope', () {
    test('accepts successful responses and JSON strings', () {
      expect(parseByseEnvelope({'status': 200, 'msg': 'OK'}), isNotEmpty);
      expect(parseByseEnvelope('{"status":"200"}'), {'status': '200'});
      expect(parseByseEnvelope({'new_domain': 'x.com'}), isNotEmpty);
    });

    test('throws for API errors and unexpected bodies', () {
      expect(
        () => parseByseEnvelope({'status': 400, 'msg': 'Invalid key'}),
        throwsA(isA<AuthenticationException>()),
      );
      expect(
        () => parseByseEnvelope('<html></html>'),
        throwsA(isA<ProviderException>()),
      );
      expect(
        () => parseByseEnvelope([1, 2]),
        throwsA(isA<ProviderException>()),
      );
    });
  });

  group('files and folders', () {
    test('reads alternative keys and root folders', () {
      final file = byseFileFromJson({
        'filecode': 'abc',
        'name': 'Name',
        'fld_id': '0',
        'size': '1024',
      }, fileUrlTemplate: template)!;

      expect(file.id, const FileId('abc'));
      expect(file.name, 'Name');
      expect(file.folderId, isNull);
      expect(file.size, const DataSize.kb(1));
      expect(file.pageUrl, Uri.parse('https://byse.sx/d/abc'));
    });

    test('prefers the link of the API to the template', () {
      final json = {'file_code': 'abc', 'link': 'https://new.byse/d/abc'};

      expect(
        byseFileFromJson(json, fileUrlTemplate: template)!.pageUrl,
        Uri.parse('https://new.byse/d/abc'),
      );
      expect(
        byseFileFromJson({
          'file_code': 'a b',
        }, fileUrlTemplate: template)!.pageUrl,
        Uri.parse('https://byse.sx/d/a%20b'),
      );
      expect(byseFileFromJson({'file_code': 'abc'})!.pageUrl, isNull);
    });

    test('ignores objects without a code', () {
      expect(byseFileFromJson({'name': 'x'}), isNull);
      expect(byseFileFromJson({'file_code': 'undef'}), isNull);
      expect(byseFolderFromJson({'name': 'x'}), isNull);
    });

    test('folders keep their parent', () {
      final folder = byseFolderFromJson({
        'fld_id': 5,
        'name': 'A',
        'code': 'xyz',
      }, parentId: const FolderId('2'))!;

      expect(folder.id, const FolderId('5'));
      expect(folder.parentId, const FolderId('2'));
      expect(folder.extra, {'code': 'xyz'});
    });

    test('file pages accept lists and XVS objects', () {
      final list = byseFilePageFromJson([
        {'file_code': 'a'},
        {'file_code': 'b', 'status': 404},
      ]);
      expect(list.files, hasLength(1));
      expect(list.totalPages, isNull);

      final object = byseFilePageFromJson({
        'files': [
          {'file_code': 'a'},
        ],
        'results_total': '9',
        'pages': 5,
      });
      expect(object.files, hasLength(1));
      expect(object.totalItems, 9);
      expect(object.totalPages, 5);

      expect(byseFilePageFromJson(null).files, isEmpty);
    });
  });

  group('account', () {
    test('accepts both spellings of premium_expire', () {
      final now = DateTime.utc(2020);
      final documented = byseAccountFromJson({
        'premim_expire': '2021-01-01 00:00:00',
      }, now: now);
      final standard = byseAccountFromJson({
        'premium_expire': '2019-01-01 00:00:00',
        'login': 'me',
        'files_total': '12',
        'custom': 1,
      }, now: now);

      expect(documented.isPremium, isTrue);
      expect(standard.isPremium, isFalse);
      expect(standard.login, 'me');
      expect(standard.filesTotal, 12);
      expect(standard.extra, {'custom': 1});
    });
  });

  group('remote uploads', () {
    test('map statuses', () {
      expect(byseRemoteStatus('PENDING'), RemoteUploadStatus.pending);
      expect(byseRemoteStatus('working'), RemoteUploadStatus.working);
      expect(byseRemoteStatus('OK'), RemoteUploadStatus.completed);
      expect(byseRemoteStatus('ERROR'), RemoteUploadStatus.failed);
      expect(byseRemoteStatus('???'), RemoteUploadStatus.unknown);
      expect(byseRemoteStatus(null), RemoteUploadStatus.unknown);
    });

    test('read percentages', () {
      expect(bysePercent('55%'), closeTo(0.55, 1e-9));
      expect(bysePercent(91), closeTo(0.91, 1e-9));
      expect(bysePercent('250'), 1);
      expect(bysePercent(''), isNull);
    });
  });
}
