import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

import 'helpers.dart';

/// Cheap key derivation so tests run fast (apps keep the default).
const cheapKdf = Argon2idParams(memoryKiB: 64, iterations: 1);

const password = 'correct horse battery';

void main() {
  Future<UpCloud> createUpCloud([List<String> labels = const []]) async {
    final upcloud = UpCloud(
      uploadExecutor: FakeUploadExecutor(),
      registry: offlineRegistry(),
      disposeRegistry: true,
      providers: [memoryDefinition()],
      store: InMemoryAccountStore([
        for (final label in labels)
          CloudAccount(
            id: label.toLowerCase(),
            providerId: 'memory',
            label: label,
            credentials: Credentials.apiKey('key-$label'),
          ),
      ]),
      settingsStore: InMemoryKeyValueStore(),
      backupKdf: cheapKdf,
    );
    addTearDown(upcloud.dispose);
    await upcloud.init(refreshRegistry: false);
    return upcloud;
  }

  Finder key(String value) => find.byKey(ValueKey(value));

  Future<void> pumpSection(
    WidgetTester tester,
    UpCloud upcloud, {
    BackupFileSaver? onSave,
    BackupFileOpener? onOpen,
    Map<String, Object?> Function()? exportExtra,
    void Function(Map<String, Object?>)? onImportedExtra,
    Locale? locale,
  }) => pumpApp(
    tester,
    SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: BackupSection(
        onSave: onSave ?? (json, name) async => true,
        onOpen: onOpen ?? () async => null,
        exportExtra: exportExtra,
        onImportedExtra: onImportedExtra,
      ),
    ),
    upcloud: upcloud,
    locale: locale,
    size: const Size(800, 1400),
  );

  group('export', () {
    testWidgets('validates the password and saves a decryptable backup', (
      tester,
    ) async {
      final upcloud = await createUpCloud(['Main']);
      final saved = <(String, String)>[];
      await pumpSection(
        tester,
        upcloud,
        onSave: (json, name) async {
          saved.add((json, name));
          return true;
        },
        exportExtra: () => {'themeMode': 'dark'},
      );

      expect(find.text('Backup'), findsOneWidget);
      await tester.tap(find.text('Export configuration'));
      await tester.pumpAndSettle();
      expect(find.text('Encrypt the backup'), findsOneWidget);
      expect(
        find.text(
          "If you lose this password, the backup can't be restored. "
          'Nobody can recover it.',
        ),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(key('upcloud-backup-strength')).data,
        'Too short',
      );

      // Too short.
      await tester.enterText(key('upcloud-backup-password'), 'short');
      await tester.tap(key('upcloud-backup-submit'));
      await tester.pumpAndSettle();
      expect(find.text('Use at least 8 characters'), findsOneWidget);
      expect(saved, isEmpty);

      // The strength follows the typing.
      await tester.enterText(key('upcloud-backup-password'), 'password');
      await tester.pump();
      expect(tester.widget<Text>(key('upcloud-backup-strength')).data, 'Weak');
      await tester.enterText(key('upcloud-backup-password'), password);
      await tester.pump();
      expect(
        tester.widget<Text>(key('upcloud-backup-strength')).data,
        'Strong',
      );

      // Mismatch.
      await tester.enterText(key('upcloud-backup-confirm'), '${password}x');
      await tester.tap(key('upcloud-backup-submit'));
      await tester.pumpAndSettle();
      expect(find.text("Passwords don't match"), findsOneWidget);
      expect(saved, isEmpty);

      await tester.enterText(key('upcloud-backup-confirm'), password);
      await tester.tap(key('upcloud-backup-submit'));
      await tester.pumpAndSettle();

      expect(find.text('Encrypt the backup'), findsNothing);
      expect(find.text('Backup saved'), findsOneWidget);
      final (json, name) = saved.single;
      expect(
        name,
        matches(RegExp(r'^upcloud-backup-\d{4}-\d{2}-\d{2}\.json$')),
      );
      expect(UpCloud.inspectBackup(json).kdf, cheapKdf);

      final other = await createUpCloud();
      final result = await other.importBackup(json, password: password);
      expect(other.accounts, upcloud.accounts);
      expect(result.extra, {'themeMode': 'dark'});
      await dismissSnackBars(tester);
    });

    testWidgets('shows and hides the password', (tester) async {
      await pumpSection(tester, await createUpCloud());
      await tester.tap(find.text('Export configuration'));
      await tester.pumpAndSettle();

      bool obscured(String field) => tester
          .widget<EditableText>(
            find.descendant(
              of: key(field),
              matching: find.byType(EditableText),
            ),
          )
          .obscureText;
      expect(obscured('upcloud-backup-password'), isTrue);
      expect(obscured('upcloud-backup-confirm'), isTrue);
      await tester.tap(find.byTooltip('Show'));
      await tester.pump();
      expect(obscured('upcloud-backup-password'), isFalse);
      expect(obscured('upcloud-backup-confirm'), isFalse);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Encrypt the backup'), findsNothing);
    });

    testWidgets('reports a failed save and ignores a cancelled one', (
      tester,
    ) async {
      var fail = false;
      await pumpSection(
        tester,
        await createUpCloud(),
        onSave: (json, name) async {
          if (fail) throw StateError('disk full');
          return false;
        },
      );
      Future<void> export() async {
        await tester.tap(find.text('Export configuration'));
        await tester.pumpAndSettle();
        await tester.enterText(key('upcloud-backup-password'), password);
        await tester.enterText(key('upcloud-backup-confirm'), password);
        await tester.tap(key('upcloud-backup-submit'));
        await tester.pumpAndSettle();
      }

      await export();
      expect(find.byType(SnackBar), findsNothing);

      fail = true;
      await export();
      expect(find.text("Couldn't save the backup"), findsOneWidget);
      await dismissSnackBars(tester);
    });
  });

  group('import', () {
    Future<String> makeBackup() async {
      final source = await createUpCloud(['Main', 'Other']);
      await source.updateSettings(
        const UploadSettings(maxConcurrentUploads: 6),
      );
      return await source.exportBackup(
        password: password,
        extra: {'themeMode': 'dark', 'language': 'es'},
      );
    }

    Future<void> enterPassword(WidgetTester tester, String text) async {
      await tester.enterText(key('upcloud-backup-import-password'), text);
      await tester.tap(key('upcloud-backup-submit'));
      await tester.pumpAndSettle();
    }

    testWidgets('retries a wrong password and merges', (tester) async {
      final backup = await makeBackup();
      final upcloud = await createUpCloud(['Main', 'Local']);
      final extras = <Map<String, Object?>>[];
      await pumpSection(
        tester,
        upcloud,
        onOpen: () async => backup,
        onImportedExtra: extras.add,
      );

      await tester.tap(find.text('Import configuration'));
      await tester.pumpAndSettle();
      expect(find.text('Restore a backup'), findsOneWidget);
      expect(find.textContaining('Made on '), findsOneWidget);
      expect(find.text('Merge'), findsOneWidget);

      await enterPassword(tester, 'not the password');
      expect(
        find.text('Wrong password, or the file was modified.'),
        findsOneWidget,
      );
      expect(find.text('Restore a backup'), findsOneWidget);
      expect(upcloud.accounts, hasLength(2));

      // Typing again clears the error.
      await tester.enterText(key('upcloud-backup-import-password'), 'x');
      await tester.pumpAndSettle();
      expect(
        find.text('Wrong password, or the file was modified.'),
        findsNothing,
      );

      await enterPassword(tester, password);
      expect(find.text('Restore a backup'), findsNothing);
      expect(find.text('Backup restored'), findsOneWidget);
      expect(find.text('1 account added'), findsOneWidget);
      expect(find.text('1 account updated'), findsNothing);
      expect(find.text('Upload settings restored'), findsOneWidget);
      expect(extras, [
        {'themeMode': 'dark', 'language': 'es'},
      ]);
      expect(upcloud.accounts.map((a) => a.label), ['Main', 'Local', 'Other']);
      expect(upcloud.settings.maxConcurrentUploads, 6);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Backup restored'), findsNothing);
    });

    testWidgets('asks for confirmation before replacing', (tester) async {
      final backup = await makeBackup();
      final upcloud = await createUpCloud(['Main', 'Local']);
      await pumpSection(tester, upcloud, onOpen: () async => backup);

      await tester.tap(find.text('Import configuration'));
      await tester.pumpAndSettle();
      await tester.tap(key('upcloud-backup-mode-replace'));
      await tester.pump();
      expect(
        find.widgetWithText(FilledButton, 'Replace'),
        findsOneWidget,
        reason: 'the import button becomes destructive',
      );

      // Cancelling the confirmation imports nothing.
      await enterPassword(tester, password);
      expect(find.text('Replace your configuration?'), findsOneWidget);
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      expect(find.text('Replace your configuration?'), findsNothing);
      expect(find.text('Restore a backup'), findsOneWidget);
      expect(upcloud.accounts.map((a) => a.label), ['Main', 'Local']);

      await tester.tap(key('upcloud-backup-submit'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Replace').last);
      await tester.pumpAndSettle();

      expect(find.text('Backup restored'), findsOneWidget);
      expect(find.text('1 account added'), findsOneWidget);
      expect(find.text('1 account removed'), findsOneWidget);
      expect(upcloud.accounts.map((a) => a.label), ['Main', 'Other']);
    });

    testWidgets('explains why a file cannot be restored', (tester) async {
      var file = 'not a backup';
      final upcloud = await createUpCloud(['Main']);
      await pumpSection(tester, upcloud, onOpen: () async => file);

      await tester.tap(find.text('Import configuration'));
      await tester.pumpAndSettle();
      expect(find.text("Can't restore this file"), findsOneWidget);
      expect(
        find.text("This file isn't a configuration backup."),
        findsOneWidget,
      );
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      file = (await makeBackup()).replaceFirst('"version": 1', '"version": 99');
      await tester.tap(find.text('Import configuration'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'This backup was made by a newer version of the app. Update the '
          'app to restore it.',
        ),
        findsOneWidget,
      );
      expect(find.text('Restore a backup'), findsNothing);
      expect(upcloud.accounts, hasLength(1));
    });

    testWidgets('does nothing when no file is chosen', (tester) async {
      var opened = 0;
      await pumpSection(
        tester,
        await createUpCloud(),
        onOpen: () async {
          opened++;
          return null;
        },
      );
      await tester.tap(find.text('Import configuration'));
      await tester.pumpAndSettle();
      expect(opened, 1);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('reports a file that cannot be read', (tester) async {
      await pumpSection(
        tester,
        await createUpCloud(),
        onOpen: () async => throw StateError('denied'),
      );
      await tester.tap(find.text('Import configuration'));
      await tester.pumpAndSettle();
      expect(find.text("Couldn't open the file"), findsOneWidget);
      await dismissSnackBars(tester);
    });
  });

  testWidgets('speaks Spanish', (tester) async {
    await pumpSection(
      tester,
      await createUpCloud(),
      locale: const Locale('es'),
    );
    expect(find.text('Copia de seguridad'), findsOneWidget);
    expect(find.text('Exportar configuración'), findsOneWidget);
    await tester.tap(find.text('Exportar configuración'));
    await tester.pumpAndSettle();
    expect(find.text('Cifra la copia'), findsOneWidget);
    expect(find.text('Demasiado corta'), findsOneWidget);
  });

  test('suggests a file name with the date', () {
    expect(
      BackupSection.fileName(DateTime(2026, 9, 8, 23, 59)),
      'upcloud-backup-2026-09-08.json',
    );
    expect(
      BackupSection.fileName(DateTime(2026, 12, 31), prefix: 'my-app'),
      'my-app-2026-12-31.json',
    );
  });

  test('estimates the strength of passwords', () {
    PasswordStrength of(String password) => PasswordStrength.of(password);
    expect(of(''), PasswordStrength.tooShort);
    expect(of('1234567'), PasswordStrength.tooShort);
    expect(of('aaaaaaaaaaaaaaaaaaaa'), PasswordStrength.weak);
    expect(of('password'), PasswordStrength.weak);
    expect(of('Password1'), PasswordStrength.fair);
    expect(of('Tr0ub4dor&3'), PasswordStrength.good);
    expect(of('correct horse battery staple'), PasswordStrength.strong);
    expect(PasswordStrength.of('abcd', minLength: 4), PasswordStrength.weak);
  });

  test('translates backup errors', () {
    const en = UpCloudLocalizationsEn();
    const es = UpCloudLocalizationsEs();
    expect(
      en.errorMessage(const WrongBackupPasswordException()),
      'Wrong password, or the file was modified.',
    );
    expect(
      es.errorMessage(const WeakBackupPasswordException(8)),
      'Usa al menos 8 caracteres',
    );
    for (final reason in InvalidBackupReason.values) {
      final error = InvalidBackupException('x', reason: reason);
      expect(en.errorMessage(error), en.invalidBackup(reason));
      expect(es.invalidBackup(reason), isNot(en.invalidBackup(reason)));
    }
    for (final strength in PasswordStrength.values) {
      expect(es.passwordStrength(strength), isNotEmpty);
    }
    expect(es.accountsAdded(2), '2 cuentas añadidas');
    expect(en.providersSkipped(1), contains('newer version'));
  });
}
