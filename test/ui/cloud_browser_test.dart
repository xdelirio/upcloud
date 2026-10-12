import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud/ui.dart';

import 'helpers.dart';

/// A provider that can only list folders.
final class _BrowseOnly implements FolderBrowsing {
  _BrowseOnly(this._inner);

  final InMemoryProvider _inner;

  @override
  ProviderInfo get info => _inner.info;

  @override
  ProviderLimits get limits => _inner.limits;

  @override
  Set<Capability> get capabilities => const {Capability.browseFolders};

  @override
  void close() => _inner.close();

  @override
  Future<PagedResult<CloudEntry>> listFolder(
    FolderId? folderId, {
    PageRequest page = PageRequest.first,
  }) => _inner.listFolder(folderId, page: page);
}

void main() {
  late InMemoryProvider provider;
  late CloudBrowserController controller;

  setUp(() {
    provider = fastSample();
    controller = CloudBrowserController(provider: provider);
  });

  tearDown(() => controller.dispose());

  Future<void> pumpBrowser(
    WidgetTester tester, {
    CloudBrowserController? browser,
    Size? size,
    PickUploadSources? onPickFiles,
  }) async {
    await pumpApp(
      tester,
      CloudBrowser(controller: browser ?? controller, onPickFiles: onPickFiles),
      size: size,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the root folder with breadcrumbs', (tester) async {
    await pumpBrowser(tester);

    expect(find.text('My files'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Series'), findsOneWidget);
    expect(find.text('trailer.mp4'), findsOneWidget);
    expect(find.textContaining('48.0 MB'), findsOneWidget);
    expect(find.byTooltip('Parent folder'), findsNothing);
  });

  testWidgets('opens folders and goes back with breadcrumbs', (tester) async {
    await pumpBrowser(tester);

    await tester.tap(find.text('Series'));
    await tester.pumpAndSettle();

    expect(controller.state.current.name, 'Series');
    expect(find.text('Season 1'), findsOneWidget);
    expect(find.text('episode_01.mp4'), findsOneWidget);
    expect(find.text('Series'), findsOneWidget); // Last breadcrumb.
    expect(find.byTooltip('Parent folder'), findsOneWidget);

    await tester.tap(find.text('Season 1'));
    await tester.pumpAndSettle();
    expect(find.text('This folder is empty'), findsOneWidget);

    // Breadcrumb in the middle of the path.
    await tester.tap(find.text('Series'));
    await tester.pumpAndSettle();
    expect(controller.state.current.name, 'Series');

    await tester.tap(find.text('My files'));
    await tester.pumpAndSettle();
    expect(controller.state.isRoot, isTrue);
    expect(find.text('Movies'), findsOneWidget);
  });

  testWidgets('loads more entries when scrolling to the end', (tester) async {
    await pumpBrowser(tester);
    await tester.tap(find.text('Series'));
    await tester.pumpAndSettle();

    expect(controller.state.entries, hasLength(50));
    expect(controller.state.hasMore, isTrue);

    await tester.scrollUntilVisible(
      find.text('episode_60.mp4'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(controller.state.entries, hasLength(61));
    expect(controller.state.hasMore, isFalse);
    expect(find.text('episode_60.mp4'), findsOneWidget);
  });

  testWidgets('creates a folder from the New menu', (tester) async {
    await pumpBrowser(tester);

    await tester.tap(find.byTooltip('New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Reports');
    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(find.text('Reports'), findsOneWidget);
    expect(provider.folders.map((f) => f.name), contains('Reports'));
  });

  testWidgets('validates the folder name', (tester) async {
    await pumpBrowser(tester);
    await tester.tap(find.byTooltip('New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New folder'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('renames a file from its menu', (tester) async {
    await pumpBrowser(tester);

    final tile = find.widgetWithText(CloudEntryTile, 'trailer.mp4');
    await tester.tap(
      find.descendant(of: tile, matching: find.byTooltip('More actions')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rename').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'teaser.mp4');
    await tester.tap(find.widgetWithText(FilledButton, 'Rename'));
    await tester.pumpAndSettle();

    expect(find.text('teaser.mp4'), findsOneWidget);
    expect(find.text('trailer.mp4'), findsNothing);
  });

  testWidgets('selects entries and deletes them', (tester) async {
    await pumpBrowser(tester);

    await tester.longPress(find.text('trailer.mp4'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.text('intro.mkv'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete 2 items?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('trailer.mp4'), findsNothing);
    expect(find.text('intro.mkv'), findsNothing);
    expect(controller.state.isSelecting, isFalse);
    expect(find.text('My files'), findsOneWidget);
  });

  testWidgets('shows provider errors in a snack bar', (tester) async {
    await pumpBrowser(tester);

    final tile = find.widgetWithText(CloudEntryTile, 'Movies');
    await tester.tap(
      find.descendant(of: tile, matching: find.byTooltip('More actions')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('The provider said: Folder is not empty'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    await dismissSnackBars(tester);
  });

  testWidgets('searches files', (tester) async {
    await pumpBrowser(tester);

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'sintel');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('sintel.webm'), findsOneWidget);
    expect(find.text('Movies'), findsNothing);

    await tester.enterText(find.byType(TextField), 'nothing-matches');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('No files match "nothing-matches"'), findsOneWidget);

    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();
    expect(find.text('Movies'), findsOneWidget);
  });

  testWidgets('switches to the grid layout', (tester) async {
    await pumpBrowser(tester);

    await tester.tap(find.byTooltip('Grid view'));
    await tester.pumpAndSettle();

    expect(find.byType(SliverGrid), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.byTooltip('List view'), findsOneWidget);
  });

  testWidgets('shows the empty state', (tester) async {
    final empty = CloudBrowserController(provider: InMemoryProvider());
    addTearDown(empty.dispose);
    await pumpBrowser(tester, browser: empty);

    expect(find.text('This folder is empty'), findsOneWidget);
  });

  testWidgets('pads the entries and the empty state', (tester) async {
    const padding = EdgeInsets.only(bottom: 120);
    await pumpApp(
      tester,
      CloudBrowser(controller: controller, padding: padding),
    );
    await tester.pumpAndSettle();
    final sliver = tester.widget<SliverPadding>(find.byType(SliverPadding));
    expect(sliver.padding, padding);
    expect(find.text('Movies'), findsOneWidget);

    final empty = CloudBrowserController(provider: InMemoryProvider());
    addTearDown(empty.dispose);
    await pumpApp(tester, CloudBrowser(controller: empty, padding: padding));
    await tester.pumpAndSettle();
    expect(find.text('This folder is empty'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('This folder is empty'),
        matching: find.byWidgetPredicate(
          (widget) => widget is Padding && widget.padding == padding,
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows the error state and retries', (tester) async {
    final broken = CloudBrowserController(
      provider: provider,
      initialPath: const [
        CloudBreadcrumb(id: FolderId('missing'), name: 'Missing'),
      ],
    );
    addTearDown(broken.dispose);
    await pumpBrowser(tester, browser: broken);

    expect(find.text("Couldn't load this folder"), findsOneWidget);
    expect(find.text('The file or folder no longer exists.'), findsOneWidget);

    await tester.tap(find.text('My files'));
    await tester.pumpAndSettle();
    expect(find.text('Movies'), findsOneWidget);
  });

  testWidgets('hides actions the provider does not support', (tester) async {
    final limited = CloudBrowserController(provider: _BrowseOnly(provider));
    addTearDown(limited.dispose);
    await pumpBrowser(tester, browser: limited);

    expect(find.text('Movies'), findsOneWidget);
    expect(find.byTooltip('New'), findsNothing);
    expect(find.byTooltip('Search'), findsNothing);

    // Files only offer their share link: the provider cannot manage them.
    expect(find.byTooltip('More actions'), findsNWidgets(2));
    await tester.tap(find.byTooltip('More actions').first);
    await tester.pumpAndSettle();
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Rename'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });

  testWidgets('uploads picked files through the transfer queue', (
    tester,
  ) async {
    final (upcloud, account) = await upcloudWithAccount();
    addTearDown(upcloud.dispose);
    final browser = CloudBrowserController.forAccount(upcloud, account.id);
    addTearDown(browser.dispose);

    await pumpBrowser(
      tester,
      browser: browser,
      onPickFiles: () async => [
        UploadSource.bytes(List.filled(2048, 1), name: 'photo.jpg'),
      ],
    );

    await tester.tap(find.byTooltip('New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload files'));
    await tester.pumpAndSettle();

    expect(find.text('1 upload queued'), findsOneWidget);
    expect(upcloud.transfers.tasks, hasLength(1));
    await tester.pumpAndSettle();
    expect(
      upcloud.transfers.tasks.single.state,
      const TransferState.completed(),
    );
    expect(find.text('photo.jpg'), findsOneWidget);
    await dismissSnackBars(tester);
  });

  testWidgets('creates its own controller from the scope', (tester) async {
    final (upcloud, account) = await upcloudWithAccount();
    addTearDown(upcloud.dispose);

    await pumpApp(
      tester,
      CloudBrowser(accountId: account.id),
      upcloud: upcloud,
    );
    await tester.pumpAndSettle();

    expect(find.text('Movies'), findsOneWidget);
  });
}
