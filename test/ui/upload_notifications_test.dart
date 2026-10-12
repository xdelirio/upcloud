import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/src/uploads/background_upload_io.dart';
import 'package:upcloud/ui.dart';

import 'helpers.dart';

void main() {
  group('UploadNotifications', () {
    test('defaults to English texts with background_downloader tokens', () {
      const notifications = UploadNotifications();
      expect(notifications.enabled, isTrue);
      expect(notifications.grouped, isFalse);
      expect(notifications.allowLongUploads, isTrue);
      expect(notifications.requestPermission, isTrue);
      expect(
        notifications.running,
        const UploadNotificationText('Uploading {displayName}', '{progress}'),
      );
      expect(notifications.complete.title, 'Upload complete');
      expect(notifications.error.body, '{displayName}');
      expect(
        notifications.groupRunning.body,
        '{numFinished} of {numTotal} done',
      );
      expect(notifications.cancelLabel, 'Cancel');
      expect(UploadNotifications.disabled.enabled, isFalse);
    });

    test('are localized in English and Spanish', () {
      final en = UploadNotifications.localized(const UpCloudLocalizationsEn());
      expect(en, const UploadNotifications());

      final es = UploadNotifications.localized(
        const UpCloudLocalizationsEs(),
        grouped: true,
        allowLongUploads: false,
      );
      expect(
        es.running,
        const UploadNotificationText('Subiendo {displayName}', '{progress}'),
      );
      expect(es.complete.title, 'Subida completada');
      expect(es.error.title, 'Error al subir');
      expect(es.groupRunning.body, '{numFinished} de {numTotal} terminadas');
      expect(es.groupError.body, '{numFailed} de {numTotal} fallidas');
      expect(es.cancelLabel, 'Cancelar');
      expect(es.grouped, isTrue);
      expect(es.allowLongUploads, isFalse);

      // Texts are replaced, the other settings kept.
      final back = es.localizedWith(const UpCloudLocalizationsEn());
      expect(back.running.title, 'Uploading {displayName}');
      expect(back.grouped, isTrue);
      expect(back.allowLongUploads, isFalse);
    });

    test('copyWith and equality', () {
      const base = UploadNotifications();
      final changed = base.copyWith(
        running: const UploadNotificationText('Sending {displayName}'),
        requestPermission: false,
      );
      expect(changed.running.body, '');
      expect(changed.requestPermission, isFalse);
      expect(changed.complete, base.complete);
      expect(changed, isNot(base));
      expect(base.copyWith(), base);
      expect(base.copyWith().hashCode, base.hashCode);
    });
  });

  group('background_downloader configuration', () {
    test('one notification per upload with a progress bar', () {
      final config = notificationConfigFor(const UploadNotifications(), 'g')!;
      expect(config.taskOrGroup, 'g');
      expect(config.running?.title, 'Uploading {displayName}');
      expect(config.running?.body, '{progress}');
      expect(config.complete?.title, 'Upload complete');
      expect(config.error?.title, 'Upload failed');
      expect(config.progressBar, isTrue);
      expect(config.groupNotificationId, '');
      // No pause notification: uploads cannot pause.
      expect(config.paused, isNull);
      expect(config.canceled, isNull);
    });

    test('one grouped notification when asked', () {
      final config = notificationConfigFor(
        const UploadNotifications(grouped: true),
        'g',
      )!;
      expect(config.running?.title, 'Uploading files');
      expect(config.complete?.body, '{numTotal} files uploaded');
      expect(config.error?.body, '{numFailed} of {numTotal} failed');
      expect(config.groupNotificationId, 'upcloud.g');
    });

    test('nothing when disabled, in a group of their own', () {
      expect(notificationConfigFor(UploadNotifications.disabled, 'g'), isNull);
      expect(taskGroupFor(UploadNotifications.disabled, 'g'), 'g.silent');
      expect(taskGroupFor(const UploadNotifications(), 'g'), 'g');
    });

    test('long uploads need allowed notifications', () {
      const notifications = UploadNotifications();
      expect(
        taskPriorityFor(notifications, notificationsAllowed: true),
        longUploadPriority,
      );
      expect(longUploadPriority, 0);
      expect(
        taskPriorityFor(notifications, notificationsAllowed: false),
        normalPriority,
      );
      expect(
        taskPriorityFor(
          notifications.copyWith(allowLongUploads: false),
          notificationsAllowed: true,
        ),
        normalPriority,
      );
      expect(
        taskPriorityFor(
          UploadNotifications.disabled,
          notificationsAllowed: true,
        ),
        normalPriority,
      );
    });

    test('foreground mode on Android and the Cancel label on iOS', () {
      final config = platformConfigFor(
        const UploadNotifications(cancelLabel: 'Cancelar'),
      );
      expect(config.android, (bd.Config.runInForeground, bd.Config.always));
      expect(config.ios.$1, bd.Config.localize);
      expect(config.ios.$2, {'Cancel': 'Cancelar'});
      expect(
        platformConfigFor(UploadNotifications.disabled).android.$2,
        bd.Config.never,
      );
      expect(
        platformConfigFor(const UploadNotifications(allowLongUploads: false))
            .android
            .$2,
        bd.Config.never,
      );
    });

    test('tasks carry the priority and group', () {
      final task = buildUploadTask(
        UploadRequest(url: Uri.parse('https://up.example/u')),
        path: '/tmp/a.mp4',
        displayName: 'a.mp4',
        group: 'upcloud',
        priority: longUploadPriority,
      );
      expect(task.priority, 0);
      expect(task.group, 'upcloud');
      expect(task.displayName, 'a.mp4');
      expect(task.retries, 0);
      expect(task.allowPause, isFalse);
    });
  });

  group('BackgroundUploadExecutor', () {
    test('notifications can change at any time', () {
      final executor = BackgroundUploadExecutor();
      expect(executor.notifications, const UploadNotifications());
      executor.notifications = UploadNotifications.disabled;
      expect(executor.notifications.enabled, isFalse);
      expect(
        BackgroundUploadExecutor(
          notifications: const UploadNotifications(grouped: true),
        ).notifications.grouped,
        isTrue,
      );
    });
  });

  group('LocalizedUploadNotifications', () {
    testWidgets('follows the language of the app', (tester) async {
      final executor = BackgroundUploadExecutor(
        notifications: const UploadNotifications(grouped: true),
      );
      final locale = ValueNotifier(const Locale('es'));
      addTearDown(locale.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder(
          valueListenable: locale,
          builder: (context, value, _) => Localizations(
            locale: value,
            delegates: const [
              UpCloudLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
            ],
            child: LocalizedUploadNotifications(
              executor: executor,
              child: const SizedBox(),
            ),
          ),
        ),
      );
      expect(executor.notifications.running.title, 'Subiendo {displayName}');
      expect(executor.notifications.grouped, isTrue);

      locale.value = const Locale('en');
      await tester.pump();
      expect(executor.notifications.running.title, 'Uploading {displayName}');
      expect(executor.notifications.cancelLabel, 'Cancel');
      expect(executor.notifications.grouped, isTrue);
    });

    testWidgets('works inside a localized app', (tester) async {
      final executor = BackgroundUploadExecutor();
      await pumpApp(
        tester,
        LocalizedUploadNotifications(
          executor: executor,
          child: const Text('app'),
        ),
        locale: const Locale('es'),
      );
      expect(find.text('app'), findsOneWidget);
      expect(executor.notifications.complete.title, 'Subida completada');
    });
  });

  test('UpCloudFlutter.create accepts notifications', () async {
    final upcloud = UpCloudFlutter.create(
      accounts: InMemoryAccountStore(),
      store: InMemoryKeyValueStore(),
      useRemoteRegistry: false,
      notifications: UploadNotifications.disabled,
    );
    await upcloud.dispose();
  });
}
