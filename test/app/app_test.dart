import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:upcloud/src/app/app.dart';
import 'package:upcloud/src/app/glass_chrome.dart';
import 'package:upcloud/src/app/settings.dart';
import 'package:upcloud/src/app/settings_page.dart';
import 'package:upcloud/ui.dart';

import '../support/testing.dart';

void main() {
  Future<UpCloud> pumpApp(WidgetTester tester, Size size) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Keeps the ambient backdrop still, so pumpAndSettle can settle.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final upcloud = UpCloud(
      uploadExecutor: FakeUploadExecutor(),
      registry: ProviderRegistry(useRemote: false),
      providers: [inMemoryDemo],
    );
    addTearDown(upcloud.dispose);
    await upcloud.init();

    await tester.pumpWidget(
      LiquidGlassWidgets.wrap(
        brightnessResolver: Theme.maybeBrightnessOf,
        child: UpCloudScope(upcloud: upcloud, child: const UpCloudApp()),
      ),
    );
    await tester.pumpAndSettle();
    return upcloud;
  }

  Future<void> addDemoAccount(WidgetTester tester) async {
    await tester.tap(find.text('Add account').last);
    await tester.pumpAndSettle();
    // Providers written in code come first, so the demo is preselected.
    expect(find.text('Demo (in memory)'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('upcloud-credential-api_key')),
      'demo-key',
    );
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
  }

  testWidgets('adds a demo account and browses it on a desktop', (
    tester,
  ) async {
    final upcloud = await pumpApp(tester, const Size(1280, 900));
    expect(find.byType(GlassSidebar), findsOneWidget);
    expect(find.text('No accounts yet'), findsOneWidget);

    await addDemoAccount(tester);

    // Back on the files tab with the new account.
    expect(upcloud.accounts, hasLength(1));
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('My files'), findsOneWidget);

    // The provider registry can be managed from its own tab.
    await tester.tap(find.text('Providers').first);
    await tester.pumpAndSettle();
    expect(find.text('Check for updates'), findsOneWidget);
    expect(find.text('StreamHG'), findsOneWidget);
  });

  testWidgets('navigates with the glass tab bar on a phone', (tester) async {
    await pumpApp(tester, const Size(393, 852));
    expect(find.byType(GlassTabBar), findsOneWidget);
    expect(find.byType(GlassSidebar), findsNothing);

    await addDemoAccount(tester);
    expect(find.text('Movies'), findsOneWidget);

    // The tab bar draws its labels twice (plain and under the lens).
    await tester.tap(find.text('Transfers').first);
    await tester.pumpAndSettle();
    expect(find.text('No transfers'), findsOneWidget);

    // Upload settings, theme and language live in the settings page.
    await tester.tap(find.byTooltip('Settings').last);
    await tester.pumpAndSettle();
    expect(find.text('Simultaneous uploads'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Español'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(SettingsPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Subidas simultáneas'), findsOneWidget);
    await tester.tap(find.byTooltip('Atrás').last);
    await tester.pumpAndSettle();
    expect(find.text('Transferencias'), findsWidgets);
  });

  testWidgets('offers encrypted backups in the settings page', (tester) async {
    await pumpApp(tester, const Size(393, 852));
    await tester.tap(find.byTooltip('Settings').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Import configuration'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(SettingsPage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Backup'), findsOneWidget);
    expect(find.text('Encrypted file'), findsOneWidget);
    expect(find.text('Export configuration'), findsOneWidget);

    await tester.tap(find.text('Export configuration'));
    await tester.pumpAndSettle();
    expect(find.text('Encrypt the backup'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  test('the theme and language travel in backups', () {
    const saved = AppSettings(themeMode: ThemeMode.dark, locale: Locale('es'));
    final restored = const AppSettings().merge(saved.toJson());
    expect(restored.themeMode, ThemeMode.dark);
    expect(restored.locale, const Locale('es'));

    // The system language is restored too; unknown values are ignored.
    expect(saved.merge(const {'language': null}).locale, isNull);
    final kept = saved.merge(const {'themeMode': 'sepia', 'language': 'fr'});
    expect(kept.themeMode, ThemeMode.dark);
    expect(kept.locale, const Locale('es'));
    expect(saved.merge(const {}).locale, const Locale('es'));
  });

  test('the theme and language are saved and loaded', () async {
    final store = InMemoryKeyValueStore();
    expect((await AppSettings.load(store)).themeMode, ThemeMode.system);

    await const AppSettings(
      themeMode: ThemeMode.dark,
      locale: Locale('es'),
      animatedBackground: false,
    ).save(store);
    final loaded = await AppSettings.load(store);
    expect(loaded.themeMode, ThemeMode.dark);
    expect(loaded.locale, const Locale('es'));
    expect(loaded.animatedBackground, isFalse);

    // Unreadable values fall back to the defaults.
    await store.write(AppSettings.storeKey, 'not json');
    expect((await AppSettings.load(store)).locale, isNull);
  });

  testWidgets('starts a batch from the upload tab', (tester) async {
    final upcloud = await pumpApp(tester, const Size(1280, 900));
    await addDemoAccount(tester);

    await tester.tap(find.text('Upload').first);
    await tester.pumpAndSettle();
    // The only account is selected; files come from the file picker.
    expect(find.text('Files'), findsWidgets);
    expect(find.text('1 of 1 selected'), findsOneWidget);
    expect(upcloud.transfers.tasks, isEmpty);
  });
}
