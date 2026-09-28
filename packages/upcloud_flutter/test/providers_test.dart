import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

import 'helpers.dart';

void main() {
  late InMemoryRegistryStore store;
  late ProviderRegistry registry;
  late ProvidersController controller;

  setUp(() async {
    store = InMemoryRegistryStore();
    registry = offlineRegistry(store: store);
    await registry.load();
    controller = ProvidersController(registry);
  });

  tearDown(() async {
    controller.dispose();
    await registry.dispose();
  });

  Finder field(String name) => find.byKey(ValueKey('upcloud-provider-$name'));

  Future<void> pumpEditor(
    WidgetTester tester, {
    ProviderConfig? initial,
    ValueChanged<ProviderConfig>? onSaved,
  }) => pumpApp(
    tester,
    SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ProviderEditor(
        controller: controller,
        initial: initial,
        onSaved: onSaved,
      ),
    ),
    size: const Size(900, 2400),
  );

  Future<ProviderRegistry> reloadRegistry() async {
    final reloaded = offlineRegistry(store: store);
    addTearDown(reloaded.dispose);
    await reloaded.load();
    return reloaded;
  }

  group('ProvidersController', () {
    test('exposes configs and user changes', () async {
      expect(
        controller.state.configs.map((c) => c.id),
        containsAll(['streamhg', 'byse', 'mediafire']),
      );
      expect(controller.state.customIds, isEmpty);

      await controller.setEnabled('byse', enabled: false);
      expect(controller.state.config('byse')!.enabled, isFalse);
      expect(controller.state.isModified('byse'), isTrue);
      expect(registry.definition('byse'), isNull);
      expect((await reloadRegistry()).config('byse')!.enabled, isFalse);

      await controller.reset('byse');
      expect(controller.state.isModified('byse'), isFalse);
      expect(registry.definition('byse'), isNotNull);
    });

    test('refresh reports disabled remote updates', () async {
      final result = await controller.refresh();
      expect(result.status, RegistryRefreshStatus.disabled);
      expect(controller.state.lastRefresh, result);
      expect(controller.state.isRefreshing, isFalse);
    });

    test('rejects invalid configs', () async {
      const config = ProviderConfig(id: 'x', name: 'X', driver: 'xvs');
      expect(controller.validate(config), isNotEmpty);
      await expectLater(
        controller.save(config),
        throwsA(isA<InvalidProviderConfigException>()),
      );
      expect(controller.state.error, isA<InvalidProviderConfigException>());
      expect(
        controller.validate(config.copyWith(driver: 'nope')).single.code,
        ConfigProblemCode.unknownDriver,
      );
    });
  });

  group('ProviderEditor', () {
    testWidgets('edits an entry and persists the changes', (tester) async {
      ProviderConfig? saved;
      await pumpEditor(
        tester,
        initial: registry.config('streamhg'),
        onSaved: (config) => saved = config,
      );

      expect(find.textContaining('streamhg'), findsWidgets);
      expect(find.text('Reset to default'), findsNothing);
      await tester.enterText(field('name'), 'StreamHG Pro');
      await tester.enterText(field('max-size'), '1024');
      await tester.enterText(field('extensions'), 'MP4, .mkv');
      await tester.tap(find.text('Add mirror'));
      await tester.pump();
      await tester.enterText(
        field('mirror-0'),
        'https://mirror.example.com/api',
      );
      await tester.enterText(
        field('setting-pageUrlTemplate'),
        'https://play.example.com/v/{code}',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(saved?.name, 'StreamHG Pro');
      final config = registry.config('streamhg')!;
      expect(config.name, 'StreamHG Pro');
      expect(config.limits?.maxFileSizeMb, 1024);
      expect(config.limits?.allowedExtensions, ['mp4', 'mkv']);
      expect(config.mirrors, [Uri.parse('https://mirror.example.com/api')]);
      expect(
        config.settings['pageUrlTemplate'],
        'https://play.example.com/v/{code}',
      );
      expect(registry.isModified('streamhg'), isTrue);
      expect(store.values, contains(ProviderRegistry.overridesKey));

      final reloaded = await reloadRegistry();
      expect(reloaded.config('streamhg')!.name, 'StreamHG Pro');
      final definition = reloaded.definition('streamhg')!;
      expect(definition.defaultLimits.maxFileSize, const DataSize.gb(1));

      // The editor now offers to reset the entry.
      expect(find.text('Reset to default'), findsOneWidget);
      expect(find.text('Modified'), findsOneWidget);
      await tester.tap(find.text('Reset to default'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset to default'));
      await tester.pumpAndSettle();

      expect(registry.config('streamhg')!.name, 'StreamHG');
      expect(registry.isModified('streamhg'), isFalse);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: field('name'),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        'StreamHG',
      );
    });

    testWidgets('adds a custom provider', (tester) async {
      await pumpEditor(tester);

      expect(find.text('XVideoSharing'), findsOneWidget);
      await tester.enterText(field('id'), 'myhost');
      await tester.enterText(field('name'), 'My Host');
      await tester.enterText(field('api-base'), 'https://api.myhost.com/api');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final config = registry.config('myhost');
      expect(config, isNotNull);
      expect(config!.driver, 'xvs');
      expect(config.apiBase, Uri.parse('https://api.myhost.com/api'));
      expect(registry.isCustom('myhost'), isTrue);
      expect(registry.definition('myhost')?.info.name, 'My Host');
      expect((await reloadRegistry()).config('myhost'), isNotNull);
    });

    testWidgets('chooses another driver', (tester) async {
      await pumpEditor(tester);

      await tester.tap(field('driver'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Byse').last);
      await tester.pumpAndSettle();

      // Byse does not require an API base URL nor driver settings.
      expect(find.text('Page URL template'), findsNothing);
      expect(find.text('API base URL (Optional)'), findsOneWidget);
      await tester.enterText(field('id'), 'byse-2');
      await tester.enterText(field('name'), 'Byse 2');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(registry.config('byse-2')?.driver, 'byse');
    });

    testWidgets('shows validation errors', (tester) async {
      await pumpEditor(tester);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('ID is required'), findsOneWidget);
      expect(find.text('Name is required'), findsOneWidget);
      expect(find.text('API base URL is required'), findsOneWidget);

      await tester.enterText(field('id'), 'My Host');
      await tester.enterText(field('name'), 'My Host');
      await tester.enterText(field('api-base'), 'ftp://files.example.com');
      await tester.enterText(field('max-size'), 'lots');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Use lowercase letters, numbers, "-" and "_"'),
        findsOneWidget,
      );
      expect(find.text('Enter a valid http(s) URL'), findsOneWidget);
      expect(find.text('Enter a valid number'), findsOneWidget);

      await tester.enterText(field('id'), 'streamhg');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('This ID is already in use'), findsOneWidget);
      expect(registry.configs.where((c) => c.name == 'My Host'), isEmpty);
    });
  });

  group('ProviderList', () {
    Future<void> pumpList(WidgetTester tester) => pumpApp(
      tester,
      ProviderList(controller: controller),
      size: const Size(900, 1600),
    );

    testWidgets('toggles, edits and resets providers', (tester) async {
      await pumpList(tester);

      expect(find.text('StreamHG'), findsOneWidget);
      expect(find.text('MediaFire'), findsOneWidget);
      expect(find.text('Modified'), findsNothing);

      final byse = find.ancestor(
        of: find.text('Byse'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(of: byse, matching: find.byType(Switch)),
      );
      await tester.pumpAndSettle();
      expect(registry.config('byse')!.enabled, isFalse);
      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Modified'), findsOneWidget);

      // Edit through the default editor page.
      await tester.tap(find.text('StreamHG'));
      await tester.pumpAndSettle();
      expect(find.text('Edit provider'), findsOneWidget);
      await tester.enterText(field('name'), 'StreamHG 2');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Provider saved'), findsOneWidget);
      expect(find.text('StreamHG 2'), findsOneWidget);
      expect(find.text('Modified'), findsNWidgets(2));

      // Reset from the menu.
      final streamhg = find.ancestor(
        of: find.text('StreamHG 2'),
        matching: find.byType(ListTile),
      );
      await tester.tap(
        find.descendant(of: streamhg, matching: find.byTooltip('More actions')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset to default'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset to default'));
      await tester.pumpAndSettle();
      expect(find.text('StreamHG'), findsOneWidget);
      await dismissSnackBars(tester);
    });

    testWidgets('adds custom providers and shows badges', (tester) async {
      await pumpList(tester);

      await tester.tap(find.text('Add provider'));
      await tester.pumpAndSettle();
      await tester.enterText(field('id'), 'mine');
      await tester.enterText(field('name'), 'Mine');
      await tester.enterText(field('api-base'), 'https://mine.example.com/api');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Mine'), findsOneWidget);
      expect(find.text('Custom'), findsOneWidget);
      await dismissSnackBars(tester);
    });

    testWidgets('checks for updates', (tester) async {
      await pumpList(tester);

      await tester.tap(find.text('Check for updates'));
      await tester.pumpAndSettle();
      expect(find.text('Remote updates are disabled'), findsOneWidget);
      await dismissSnackBars(tester);
    });

    testWidgets('shows entries with unknown drivers', (tester) async {
      await store.write(
        ProviderRegistry.overridesKey,
        jsonEncode([
          {'id': 'future', 'name': 'Future Host', 'driver': 'nextgen'},
        ]),
      );
      await registry.load();
      await pumpList(tester);

      expect(find.text('Future Host'), findsOneWidget);
      expect(find.textContaining('Unknown driver "nextgen"'), findsWidgets);
      expect(find.text('Custom'), findsOneWidget);
    });
  });
}
