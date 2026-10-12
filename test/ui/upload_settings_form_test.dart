import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/ui.dart';

import '../support/testing.dart';
import 'helpers.dart';

void main() {
  Future<(UpCloud, InMemoryKeyValueStore)> pumpForm(
    WidgetTester tester, {
    Locale? locale,
    Map<String, String> saved = const {},
  }) async {
    final store = InMemoryKeyValueStore(saved);
    final upcloud = UpCloud(
      uploadExecutor: FakeUploadExecutor(),
      registry: offlineRegistry(),
      settingsStore: store,
    );
    addTearDown(upcloud.dispose);
    await upcloud.init();
    await pumpApp(
      tester,
      const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: UploadSettingsForm(),
      ),
      upcloud: upcloud,
      locale: locale,
      size: const Size(800, 2000),
    );
    return (upcloud, store);
  }

  Finder key(String value) => find.byKey(ValueKey(value));

  testWidgets('shows the current settings', (tester) async {
    await pumpForm(tester);

    expect(find.text('Queue'), findsOneWidget);
    expect(find.text('Simultaneous uploads'), findsOneWidget);
    expect(
      tester.widget<Text>(key('upcloud-settings-concurrency-value')).data,
      '3',
    );
    expect(
      tester.widget<Text>(key('upcloud-settings-retries-value')).data,
      '2',
    );
    expect(
      tester
          .widget<SwitchListTile>(key('upcloud-settings-check-storage'))
          .value,
      isTrue,
    );
    for (final label in [
      'Never',
      'Immediately',
      'After 30 s',
      'After 5 min',
      'After 30 min',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(
      tester
          .widget<ChoiceChip>(key('upcloud-settings-auto-clear-null'))
          .selected,
      isTrue,
    );
    expect(find.text('Provider default'), findsOneWidget);
  });

  testWidgets('saves every change', (tester) async {
    final (upcloud, store) = await pumpForm(tester);
    final emitted = <UploadSettings>[];
    final subscription = upcloud.settingsChanges.listen(emitted.add);
    addTearDown(subscription.cancel);

    void slide(String prefix, double value) =>
        tester.widget<Slider>(key('$prefix-slider')).onChanged!(value);
    slide('upcloud-settings-concurrency', 4);
    await tester.pump();
    slide('upcloud-settings-retries', 1);
    await tester.pump();
    slide('upcloud-settings-retries', 0);
    await tester.pump();
    await tester.tap(key('upcloud-settings-check-storage'));
    await tester.tap(key('upcloud-settings-auto-clear-300'));
    await tester.tap(find.text('Private'));
    await tester.pumpAndSettle();

    final settings = upcloud.settings;
    expect(settings.maxConcurrentUploads, 4);
    expect(settings.retries, 0);
    expect(settings.checkStorage, isFalse);
    expect(settings.autoClearAfterSeconds, 300);
    expect(settings.defaultVisibility, UploadVisibility.private);
    expect(upcloud.transfers.settings, settings);
    expect(store.values[UpCloud.settingsKey], contains('"retries":0'));
    expect(emitted.last, settings);

    // No retries read "Off".
    expect(
      tester.widget<Text>(key('upcloud-settings-retries-value')).data,
      'Off',
    );
    expect(
      tester.widget<Slider>(key('upcloud-settings-retries-slider')).value,
      0,
    );

    // The sliders can be dragged too.
    await tester.drag(
      key('upcloud-settings-concurrency-slider'),
      const Offset(2000, 0),
    );
    await tester.pumpAndSettle();
    expect(upcloud.settings.maxConcurrentUploads, 10);
  });

  testWidgets('debounces the default folder and normalizes it', (tester) async {
    final (upcloud, _) = await pumpForm(tester);

    await tester.enterText(
      key('upcloud-settings-default-folder'),
      ' Movies// 2026 ',
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(upcloud.settings.defaultFolderPath, isNull);

    await tester.pump(const Duration(seconds: 1));
    expect(upcloud.settings.defaultFolderPath, 'Movies/2026');

    // Leaving the field shows the saved (normalized) path.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    expect(find.text('Movies/2026'), findsOneWidget);

    // Clearing it goes back to the root folder.
    await tester.enterText(key('upcloud-settings-default-folder'), '');
    await tester.pump(const Duration(seconds: 1));
    expect(upcloud.settings.defaultFolderPath, isNull);
  });

  testWidgets('suggests recent folder paths', (tester) async {
    await pumpForm(
      tester,
      saved: {UpCloud.recentFolderPathsKey: '["Series/Lost","Movies/2026"]'},
    );

    await tester.tap(key('upcloud-settings-default-folder'));
    await tester.enterText(key('upcloud-settings-default-folder'), 'mov');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ListTile, 'Movies/2026'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Series/Lost'), findsNothing);

    await tester.tap(find.widgetWithText(ListTile, 'Movies/2026'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('follows settings changed elsewhere', (tester) async {
    final (upcloud, _) = await pumpForm(tester);

    await upcloud.updateSettings(
      upcloud.settings.copyWith(
        maxConcurrentUploads: 7,
        autoClearAfterSeconds: 90,
        defaultFolderPath: 'Backups',
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(key('upcloud-settings-concurrency-value')).data,
      '7',
    );
    // A value that is not one of the choices is offered too.
    expect(
      tester.widget<ChoiceChip>(key('upcloud-settings-auto-clear-90')).selected,
      isTrue,
    );
    expect(find.text('After 90 s'), findsOneWidget);
    expect(find.text('Backups'), findsOneWidget);
  });

  testWidgets('is translated to Spanish', (tester) async {
    await pumpForm(tester, locale: const Locale('es'));

    expect(find.text('Subidas simultáneas'), findsOneWidget);
    expect(find.text('Reintentos automáticos'), findsOneWidget);
    expect(find.text('A los 5 min'), findsOneWidget);
    expect(find.text('Carpeta por defecto'), findsOneWidget);
    expect(find.text('Privada'), findsOneWidget);
  });
}
