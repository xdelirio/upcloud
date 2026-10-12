import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/ui.dart';

import 'helpers.dart';

void main() {
  testWidgets('falls back to English without the delegate', (tester) async {
    late UpCloudLocalizations l10n;
    await pumpApp(
      tester,
      Builder(
        builder: (context) {
          l10n = UpCloudLocalizations.of(context);
          return const SizedBox();
        },
      ),
      registerDelegate: false,
    );
    expect(l10n, isA<UpCloudLocalizationsEn>());
    expect(l10n.rootFolder, 'My files');
  });

  testWidgets('loads Spanish with the delegate', (tester) async {
    late UpCloudLocalizations l10n;
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('es', 'MX'),
        delegates: const [
          UpCloudLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: Builder(
          builder: (context) {
            l10n = UpCloudLocalizations.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(l10n, isA<UpCloudLocalizationsEs>());
    expect(l10n.rootFolder, 'Mis archivos');
  });

  test('delegate supports English and Spanish', () {
    const delegate = UpCloudLocalizations.delegate;
    expect(delegate.isSupported(const Locale('en', 'US')), isTrue);
    expect(delegate.isSupported(const Locale('es')), isTrue);
    expect(delegate.isSupported(const Locale('fr')), isFalse);
    expect(
      UpCloudLocalizations.forLocale(const Locale('fr')),
      isA<UpCloudLocalizationsEn>(),
    );
  });

  test('translates the file link template texts', () {
    const en = UpCloudLocalizationsEn();
    const es = UpCloudLocalizationsEs();
    const problem = ConfigProblem(
      ConfigProblemCode.missingIdPlaceholder,
      'fileUrlTemplate must contain {id}',
      field: 'fileUrlTemplate',
    );
    expect(en.fileUrlTemplate, 'File link template');
    expect(en.fileUrlTemplateHelper, '{id} is replaced by the file id');
    expect(es.fileUrlTemplate, 'Plantilla del enlace del archivo');
    expect(es.fileUrlTemplateHelper, '{id} se reemplaza por el id del archivo');
    expect(es.invalidFileUrlTemplate, contains('{id}'));
    expect(es.configProblem(problem), contains('{id}'));
  });

  test('formats sizes and speeds per language', () {
    const en = UpCloudLocalizationsEn();
    const es = UpCloudLocalizationsEs();
    expect(
      en.formatSize(const DataSize.mb(3) + const DataSize.kb(512)),
      '3.5 MB',
    );
    expect(
      es.formatSize(const DataSize.mb(3) + const DataSize.kb(512)),
      '3,5 MB',
    );
    expect(en.formatSpeed(2048), '2.0 KB/s');
    expect(es.formatBytes(-1), '0 B');
  });

  test('describes every error type', () {
    const l10n = UpCloudLocalizationsEn();
    const errors = <UpCloudException>[
      AuthenticationException('x'),
      NotFoundException('x'),
      QuotaExceededException('x'),
      RateLimitedException('x', retryAfter: Duration(seconds: 30)),
      NetworkException('x'),
      CancelledException(),
      UnsupportedOperationException('x'),
      ProviderException('boom'),
    ];
    final messages = errors.map(l10n.errorMessage).toList();
    expect(messages.toSet(), hasLength(errors.length));
    expect(messages[3], 'Too many requests. Try again in 30 s.');
    expect(messages.last, 'The provider said: boom');
    expect(l10n.errorMessage(StateError('odd')), contains('odd'));
  });

  test('translates well-known credential labels', () {
    const es = UpCloudLocalizationsEs();
    expect(
      es.credentialLabel(
        const CredentialField(id: CredentialField.apiKeyId, label: 'API key'),
      ),
      'Clave de API',
    );
    expect(
      es.credentialLabel(const CredentialField(id: 'token', label: 'Token')),
      'Token',
    );
    for (final capability in Capability.values) {
      expect(es.capability(capability), isNotEmpty);
    }
  });
}
