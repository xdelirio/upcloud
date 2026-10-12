import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/upcloud.dart';

import '../support/bundled_providers.dart';

ProviderConfig _xvs({String? fileUrlTemplate}) => ProviderConfig(
  id: 'alpha',
  name: 'Alpha',
  driver: XvsDriver.driverId,
  apiBase: Uri.parse('https://alpha.test/api'),
  fileUrlTemplate: fileUrlTemplate,
);

void main() {
  group('ProviderConfig.fileUrl', () {
    test('replaces {id} with the URL-encoded file id', () {
      final config = _xvs(fileUrlTemplate: 'https://alpha.test/f/{id}');

      expect(config.fileUrl('abc'), Uri.parse('https://alpha.test/f/abc'));
      expect(
        config.fileUrl('a b/c?d#é'),
        Uri.parse('https://alpha.test/f/a%20b%2Fc%3Fd%23%C3%A9'),
      );
      expect(
        ProviderConfig.expandFileUrl('https://a.test/{id}/{id}.html', 'x'),
        Uri.parse('https://a.test/x/x.html'),
      );
      expect(
        ProviderConfig.expandFileUrl(' https://a.test/?v={id} ', 'x'),
        Uri.parse('https://a.test/?v=x'),
      );
    });

    test('returns null without a usable template or id', () {
      expect(_xvs().fileUrl('abc'), isNull);
      expect(_xvs(fileUrlTemplate: '').fileUrl('abc'), isNull);
      expect(_xvs(fileUrlTemplate: 'https://a.test/{id}').fileUrl(''), isNull);
      expect(ProviderConfig.expandFileUrl('https://a.test/f', 'x'), isNull);
      expect(ProviderConfig.expandFileUrl('a.test/{id}', 'x'), isNull);
      expect(ProviderConfig.expandFileUrl('/files/{id}', 'x'), isNull);
    });

    test('is read from and written to registry JSON', () {
      final config = ProviderConfig.fromJson({
        'id': 'alpha',
        'name': 'Alpha',
        'driver': 'xvs',
        'fileUrlTemplate': 'https://alpha.test/{id}',
      });

      expect(config.fileUrlTemplate, 'https://alpha.test/{id}');
      expect(config.toJson()['fileUrlTemplate'], 'https://alpha.test/{id}');
      final decoded =
          jsonDecode(jsonEncode(config.toJson())) as Map<String, dynamic>;
      expect(ProviderConfig.fromJson(decoded), config);
    });
  });

  group('validation', () {
    List<ConfigProblem> problems(String? template) =>
        xvsDriver.validate(_xvs(fileUrlTemplate: template));

    test('accepts https templates with {id}, null and blank ones', () {
      expect(problems('https://alpha.test/{id}'), isEmpty);
      expect(problems('https://alpha.test/v?c={id}&x=1'), isEmpty);
      expect(problems(null), isEmpty);
      expect(problems('  '), isEmpty);
    });

    test('rejects templates without {id}', () {
      final problem = problems('https://alpha.test/{code}').single;
      expect(problem.code, ConfigProblemCode.missingIdPlaceholder);
      expect(problem.field, 'fileUrlTemplate');
    });

    test('rejects relative and insecure templates', () {
      expect(
        problems('alpha.test/{id}').single,
        isA<ConfigProblem>()
            .having((p) => p.code, 'code', ConfigProblemCode.invalidUrl)
            .having((p) => p.field, 'field', 'fileUrlTemplate'),
      );
      expect(
        problems('http://alpha.test/{id}').single.code,
        ConfigProblemCode.insecureUrl,
      );
      expect(
        CloudDriver.fileUrlTemplateProblem('ftp://alpha.test/{id}')?.code,
        ConfigProblemCode.insecureUrl,
      );
    });

    test('applies to every driver', () {
      for (final driver in builtInDrivers) {
        final config = ProviderConfig(
          id: 'x',
          name: 'X',
          driver: driver.id,
          apiBase: Uri.parse('https://x.test/api'),
          fileUrlTemplate: 'https://x.test/file',
        );
        expect(driver.validate(config).map((p) => p.code), [
          ConfigProblemCode.missingIdPlaceholder,
        ], reason: driver.id);
        expect(
          () => driver.definitionFor(config),
          throwsA(isA<InvalidProviderConfigException>()),
        );
      }
    });
  });

  group('definitions', () {
    test('use the template of the entry, else the driver default', () {
      final custom = mediaFireDriver.definitionFor(
        mediaFire.config!.copyWith(fileUrlTemplate: 'https://mf.test/{id}'),
      );
      final blank = mediaFireDriver.definitionFor(
        mediaFire.config!.copyWith(fileUrlTemplate: ' '),
      );
      final none = mediaFireDriver.definitionFor(
        mediaFire.config!.copyWith(fileUrlTemplate: null),
      );

      expect(custom.fileUrl('k'), Uri.parse('https://mf.test/k'));
      expect(blank.fileUrlTemplate, mediaFireFileUrlTemplate);
      expect(none.fileUrl('k'), Uri.parse('https://www.mediafire.com/file/k'));
      expect(xvsDriver.defaultFileUrlTemplate(_xvs()), isNull);
      expect(xvsDriver.definitionFor(_xvs()).fileUrl('k'), isNull);
    });

    test('built by hand can declare a template', () {
      final definition = ProviderDefinition(
        info: const ProviderInfo(id: 'h', name: 'H'),
        credentialSchema: CredentialSchema.apiKey(),
        capabilities: const {},
        fileUrlTemplate: 'https://h.test/{id}',
        factory: (definition, credentials, options) =>
            throw UnimplementedError(),
      );

      expect(definition.fileUrl('a b'), Uri.parse('https://h.test/a%20b'));
      expect(definition.config, isNull);
    });
  });

  group('registry', () {
    test('bundled entries declare their file link templates', () {
      final registry = ProviderRegistry(useRemote: false);
      addTearDown(registry.dispose);
      const expected = {
        'streamhg': 'https://hgcloud.to/{id}',
        'earnvids': 'https://morencius.com/file/{id}',
        'byse': 'https://byse.sx/d/{id}',
        'mediafire': 'https://www.mediafire.com/file/{id}',
      };

      for (final MapEntry(key: id, value: template) in expected.entries) {
        final config = registry.config(id)!;
        expect(config.fileUrlTemplate, template, reason: id);
        expect(config.settings, isEmpty, reason: '$id has no settings');
        expect(registry.definition(id)!.fileUrlTemplate, template);
      }
      expect(
        registry.definition('streamhg')!.fileUrl('abc123'),
        Uri.parse('https://hgcloud.to/abc123'),
      );
    });

    test('registry/providers.json uses fileUrlTemplate only', () {
      final file = File('../../registry/providers.json');
      if (!file.existsSync()) {
        markTestSkipped('Repository file not available');
        return;
      }
      final text = file.readAsStringSync();
      expect(text, isNot(contains('pageUrlTemplate')));
      expect(text, isNot(contains('{code}')));
    });

    test('stores the template as a user edit and resets it', () async {
      final store = InMemoryRegistryStore();
      final registry = ProviderRegistry(useRemote: false, store: store);
      addTearDown(registry.dispose);
      await registry.load();

      await registry.save(
        registry
            .config('streamhg')!
            .copyWith(fileUrlTemplate: 'https://mirror.test/{id}'),
      );
      expect(jsonDecode(store.values[ProviderRegistry.overridesKey]!), [
        {'id': 'streamhg', 'fileUrlTemplate': 'https://mirror.test/{id}'},
      ]);
      expect(
        registry.definition('streamhg')!.fileUrl('a'),
        Uri.parse('https://mirror.test/a'),
      );

      // Removing the template of an entry that has one: no link.
      await registry.save(
        registry.config('streamhg')!.copyWith(fileUrlTemplate: null),
      );
      expect(jsonDecode(store.values[ProviderRegistry.overridesKey]!), [
        {'id': 'streamhg', 'fileUrlTemplate': null},
      ]);
      expect(registry.definition('streamhg')!.fileUrl('a'), isNull);

      // Byse falls back to the driver default.
      await registry.save(
        registry.config('byse')!.copyWith(fileUrlTemplate: null),
      );
      expect(
        registry.definition('byse')!.fileUrl('a'),
        Uri.parse('https://byse.sx/d/a'),
      );

      await registry.resetAll();
      expect(
        registry.definition('streamhg')!.fileUrl('a'),
        Uri.parse('https://hgcloud.to/a'),
      );
    });

    test('rejects invalid templates when saving', () async {
      final registry = ProviderRegistry(useRemote: false);
      addTearDown(registry.dispose);

      await expectLater(
        registry.save(
          registry
              .config('earnvids')!
              .copyWith(fileUrlTemplate: 'http://morencius.com/file/{id}'),
        ),
        throwsA(
          isA<InvalidProviderConfigException>().having(
            (e) => e.problems.single.code,
            'code',
            ConfigProblemCode.insecureUrl,
          ),
        ),
      );
    });
  });
}
