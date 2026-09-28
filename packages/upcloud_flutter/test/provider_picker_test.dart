import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

import 'helpers.dart';

void main() {
  final uploadsOnly = ProviderDefinition(
    info: const ProviderInfo(id: 'drop', name: 'Drop', description: 'Uploads'),
    credentialSchema: CredentialSchema.apiKey(),
    capabilities: const {Capability.upload, Capability.remoteUpload},
    factory: (definition, credentials, options) => fastSample(),
  );

  testWidgets('lists providers by name only', (tester) async {
    ProviderDefinition? selected;
    await pumpApp(
      tester,
      ProviderPicker(
        providers: [inMemoryDemo, uploadsOnly],
        onSelected: (provider) => selected = provider,
      ),
    );

    expect(find.text('Demo (in memory)'), findsOneWidget);
    expect(find.text('Drop'), findsOneWidget);
    expect(
      find.text('Local sample data, nothing leaves the device.'),
      findsNothing,
    );
    expect(find.byType(CapabilityChips), findsNothing);

    await tester.tap(find.text('Drop'));
    expect(selected, uploadsOnly);
  });

  testWidgets('shows details on request', (tester) async {
    await pumpApp(
      tester,
      ProviderPicker(
        providers: [inMemoryDemo, uploadsOnly],
        showDetails: true,
        onSelected: (_) {},
      ),
    );

    expect(
      find.text('Local sample data, nothing leaves the device.'),
      findsOneWidget,
    );
    expect(find.text('Max. file size: 2.0 GB'), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);
    expect(find.text('Upload'), findsNWidgets(2));
    expect(find.text('Remote upload'), findsNWidgets(2));
  });

  testWidgets('reads providers from the scope', (tester) async {
    final upcloud = UpCloud(
      uploadExecutor: FakeUploadExecutor(),
      registry: offlineRegistry(),
      providers: [inMemoryDemo],
    );
    addTearDown(upcloud.dispose);
    await pumpApp(tester, ProviderPicker(onSelected: (_) {}), upcloud: upcloud);
    expect(find.text('Demo (in memory)'), findsOneWidget);
  });

  testWidgets('can use a grid on wide screens', (tester) async {
    await pumpApp(
      tester,
      ProviderPicker(
        providers: [inMemoryDemo, uploadsOnly],
        layout: ProviderPickerLayout.grid,
        onSelected: (_) {},
      ),
      size: const Size(1200, 800),
    );
    final demo = tester.getTopLeft(find.byType(ProviderCard).first);
    final drop = tester.getTopLeft(find.byType(ProviderCard).last);
    expect(drop.dy, demo.dy);
    expect(drop.dx, greaterThan(demo.dx));
  });

  testWidgets('shows an empty state', (tester) async {
    await pumpApp(
      tester,
      ProviderPicker(providers: const [], onSelected: (_) {}),
    );
    expect(find.text('No providers available'), findsOneWidget);
  });

  testWidgets('capability chips can be limited', (tester) async {
    await pumpApp(
      tester,
      const CapabilityChips(
        capabilities: {
          Capability.search,
          Capability.browseFolders,
          Capability.upload,
        },
        maxVisible: 2,
      ),
    );
    // Stable order: browse, search, then "+1" for upload.
    final chips = tester.widgetList<Chip>(find.byType(Chip)).toList();
    expect(chips, hasLength(3));
    expect(find.text('Browse'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
  });

  group('ProviderAvatar', () {
    test('detects SVG URLs', () {
      expect(
        ProviderAvatar.isSvgUrl(Uri.parse('https://x.test/logo.SVG?v=2')),
        isTrue,
      );
      expect(
        ProviderAvatar.isSvgUrl(Uri.parse('data:image/svg+xml;base64,AAAA')),
        isTrue,
      );
      expect(
        ProviderAvatar.isSvgUrl(Uri.parse('https://x.test/favicon.ico')),
        isFalse,
      );
    });

    testWidgets('SVG logos fall back to the initial until they load', (
      tester,
    ) async {
      await pumpApp(
        tester,
        ProviderAvatar(
          info: ProviderInfo(
            id: 'x',
            name: 'Example',
            iconUrl: Uri.parse('https://x.test/logo.svg'),
          ),
        ),
      );
      // While loading (and when the URL is not a valid SVG, as in tests
      // where HTTP fails) the initial is shown instead of an error.
      await tester.pumpAndSettle();
      expect(find.text('E'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders raster icons with Image', (tester) async {
      await pumpApp(
        tester,
        ProviderAvatar(
          info: ProviderInfo(
            id: 'x',
            name: 'Example',
            iconUrl: Uri.parse('https://x.test/favicon.png'),
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
