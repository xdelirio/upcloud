import 'package:test/test.dart';
import 'package:upcloud/upcloud.dart';

import '../../support/bundled_providers.dart';

void main() {
  group('XVS registry entries', () {
    final expected = {
      xVideoSharing: ('xvideosharing', 'https://xvideosharing.com/api'),
      streamHg: ('streamhg', 'https://streamhgapi.com/api'),
      earnVids: ('earnvids', 'https://earnvidsapi.com/api'),
    };

    for (final MapEntry(key: definition, value: (id, apiBase))
        in expected.entries) {
      test('$id uses the xvs driver', () {
        expect(definition.id, id);
        expect(definition.info.driver, XvsDriver.driverId);
        expect(definition.defaultBaseUrl, Uri.parse(apiBase));
        expect(definition.capabilities, xvsCapabilities);
        expect(
          definition.defaultLimits.allowedExtensions,
          ProviderLimits.videoExtensions,
        );
        final field = definition.credentialSchema.fields.single;
        expect(field.id, CredentialField.apiKeyId);
        expect(field.helpUrl?.query, 'op=my_account');
      });
    }

    test('limits come from the entry or the driver default', () {
      expect(xVideoSharing.defaultLimits.maxFileSize, const DataSize.mb(1000));
      expect(streamHg.defaultLimits.maxFileSize, isNull);
      expect(earnVids.defaultLimits.maxFileSize, isNull);
    });
  });

  group('XvsDriver', () {
    test('creates providers with every capability', () {
      final provider = streamHg.create(Credentials.apiKey('k'));
      addTearDown(provider.close);

      expect(provider, isA<XvsProvider>());
      expect(provider.capabilities, xvsCapabilities);
      expect(provider.info.name, 'StreamHG');
      expect((provider as XvsProvider).baseUrl, streamHg.defaultBaseUrl);
    });

    test('honours base URL and limits overrides', () {
      const limits = ProviderLimits(maxFileSize: DataSize.gb(50));
      final provider = earnVids.create(
        Credentials.apiKey('k'),
        options: ProviderOptions(
          baseUrl: Uri.parse('https://mirror.test/api'),
          limits: limits,
        ),
      ) as XvsProvider;
      addTearDown(provider.close);

      expect(provider.baseUrl, Uri.parse('https://mirror.test/api'));
      expect(provider.limits, limits);
    });

    test('uses the credential fields of the entry when declared', () {
      final schema = CredentialSchema.apiKey(
        helpUrl: Uri.parse('https://custom.test/keys'),
      );
      final definition = testXvsDefinition(
        info: const ProviderInfo(id: 'c', name: 'C'),
        apiBase: Uri.parse('https://custom.test/api'),
        credentials: schema,
      );

      expect(definition.info.driver, XvsDriver.driverId);
      expect(definition.credentialSchema, schema);
    });

    test('reads the page link template from the entry settings', () {
      final definition = testXvsDefinition(
        info: const ProviderInfo(id: 'c', name: 'C'),
        apiBase: Uri.parse('https://custom.test/api'),
        pageUrlTemplate: 'https://custom.test/v/{code}',
      );
      final provider =
          definition.create(Credentials.apiKey('k')) as XvsProvider;
      addTearDown(provider.close);

      expect(
        provider.config.pageUrl('abc'),
        Uri.parse('https://custom.test/v/abc'),
      );
    });

    test('rejects entries without apiBase', () {
      final problems = xvsDriver.validate(
        const ProviderConfig(id: 'x', name: 'X', driver: 'xvs'),
      );
      expect(
        problems.map((p) => p.code),
        contains(ConfigProblemCode.missingApiBase),
      );
    });

    test('rejects insecure URLs and invalid ids', () {
      final problems = xvsDriver.validate(
        ProviderConfig(
          id: 'Bad Id',
          name: 'X',
          driver: 'xvs',
          apiBase: Uri.parse('http://x.test/api'),
          mirrors: [Uri.parse('relative/path')],
        ),
      );
      expect(problems.map((p) => p.code), [
        ConfigProblemCode.invalidId,
        ConfigProblemCode.insecureUrl,
        ConfigProblemCode.invalidUrl,
      ]);
    });
  });

  group('XvsConfig', () {
    test('expands the page template with the encoded file code', () {
      const config = XvsConfig(
        pageUrlTemplate: 'https://host.test/{code}.html',
      );

      expect(config.pageUrl('a b'), Uri.parse('https://host.test/a%20b.html'));
      expect(const XvsConfig().pageUrl('abc'), isNull);
    });
  });
}
