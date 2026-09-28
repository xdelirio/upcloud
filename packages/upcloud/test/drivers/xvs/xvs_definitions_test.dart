import 'package:test/test.dart';
import 'package:upcloud/upcloud.dart';

import '../../support/bundled_providers.dart';

void main() {
  group('XVS registry entries', () {
    // StreamHG and EarnVids answer "Invalid operation" to file/delete and
    // folder/delete.
    final withoutDelete = xvsCapabilities.difference({
      Capability.deleteFile,
      Capability.deleteFolder,
    });
    final expected = {
      xVideoSharing: (
        'xvideosharing',
        'https://xvideosharing.com/api',
        xvsCapabilities,
      ),
      streamHg: ('streamhg', 'https://streamhgapi.com/api', withoutDelete),
      earnVids: ('earnvids', 'https://earnvidsapi.com/api', withoutDelete),
    };

    for (final MapEntry(key: definition, value: (id, apiBase, capabilities))
        in expected.entries) {
      test('$id uses the xvs driver', () {
        expect(definition.id, id);
        expect(definition.info.driver, XvsDriver.driverId);
        expect(definition.defaultBaseUrl, Uri.parse(apiBase));
        expect(definition.capabilities, capabilities);
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
      final provider = xVideoSharing.create(Credentials.apiKey('k'));
      addTearDown(provider.close);

      expect(provider, isA<XvsProvider>());
      expect(provider.capabilities, xvsCapabilities);
      expect(provider.info.name, 'XVideoSharing');
      expect((provider as XvsProvider).baseUrl, xVideoSharing.defaultBaseUrl);
    });

    for (final definition in [streamHg, earnVids]) {
      test('${definition.id} cannot delete files or folders', () async {
        final provider =
            definition.create(Credentials.apiKey('k')) as XvsProvider;
        addTearDown(provider.close);

        expect(provider.info.name, definition.info.name);
        expect(provider.supports(Capability.deleteFile), isFalse);
        expect(provider.supports(Capability.deleteFolder), isFalse);
        expect(provider.supports(Capability.renameFile), isTrue);
        // Rejected before any request is sent.
        await expectLater(
          provider.deleteFile(const FileId('abc')),
          throwsA(isA<UnsupportedOperationException>()),
        );
        await expectLater(
          provider.deleteFolder(const FolderId('1')),
          throwsA(isA<UnsupportedOperationException>()),
        );
      });
    }

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

    test('passes the file link template of the entry to providers', () {
      final definition = testXvsDefinition(
        info: const ProviderInfo(id: 'c', name: 'C'),
        apiBase: Uri.parse('https://custom.test/api'),
        fileUrlTemplate: 'https://custom.test/v/{id}',
      );

      expect(definition.fileUrlTemplate, 'https://custom.test/v/{id}');
      expect(definition.fileUrl('abc'), Uri.parse('https://custom.test/v/abc'));
      expect(xvsDriver.settings, isEmpty);
    });

    test('has no default file link template', () {
      final definition = testXvsDefinition(
        info: const ProviderInfo(id: 'c', name: 'C'),
        apiBase: Uri.parse('https://custom.test/api'),
      );

      expect(definition.fileUrlTemplate, isNull);
      expect(definition.fileUrl('abc'), isNull);
    });

    test('registry entries link files to their websites', () {
      expect(streamHg.fileUrl('abc'), Uri.parse('https://hgcloud.to/abc'));
      expect(
        earnVids.fileUrl('abc'),
        Uri.parse('https://morencius.com/file/abc'),
      );
      expect(
        xVideoSharing.fileUrl('abc'),
        Uri.parse('https://xvideosharing.com/abc.html'),
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
}
