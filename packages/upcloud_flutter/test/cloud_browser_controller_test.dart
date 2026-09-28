import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

import 'helpers.dart';

void main() {
  late InMemoryProvider provider;
  late CloudBrowserController controller;

  setUp(() {
    provider = fastSample();
    controller = CloudBrowserController(provider: provider);
  });

  tearDown(() => controller.dispose());

  List<String> names() => [for (final e in controller.state.entries) e.name];

  CloudFolder folder(String name) => controller.state.entries
      .whereType<CloudFolder>()
      .firstWhere((f) => f.name == name);

  CloudFile file(String name) => controller.state.entries
      .whereType<CloudFile>()
      .firstWhere((f) => f.name == name);

  test('loads the root folder right away', () async {
    final eager = CloudBrowserController(provider: provider);
    addTearDown(eager.dispose);
    expect(eager.state.isLoading, isTrue);
    expect(eager.state.hasLoaded, isFalse);
    await controller.refresh();

    final state = controller.state;
    expect(state.isLoading, isFalse);
    expect(state.hasLoaded, isTrue);
    expect(state.isRoot, isTrue);
    expect(state.path, [CloudBreadcrumb.root]);
    expect(names(), ['Movies', 'Series', 'trailer.mp4', 'intro.mkv']);
    expect(state.hasMore, isFalse);
  });

  test('navigates folders and keeps breadcrumbs', () async {
    await controller.refresh();
    await controller.openFolder(folder('Series'));
    expect(controller.state.path.map((c) => c.name), ['', 'Series']);
    expect(controller.canGoUp, isTrue);

    await controller.openFolder(folder('Season 1'));
    expect(controller.state.path.map((c) => c.name), [
      '',
      'Series',
      'Season 1',
    ]);
    expect(controller.state.isEmpty, isTrue);

    await controller.goTo(controller.state.path[1]);
    expect(controller.state.current.name, 'Series');
    expect(names(), contains('Season 1'));

    await controller.goUp();
    expect(controller.state.isRoot, isTrue);
    expect(names(), contains('Movies'));

    await controller.goUp();
    expect(controller.state.isRoot, isTrue);
  });

  test('paginates with loadMore', () async {
    controller.dispose();
    controller = CloudBrowserController(provider: provider, pageSize: 25);
    await controller.refresh();
    await controller.openFolder(folder('Series'));

    expect(controller.state.entries, hasLength(25));
    expect(controller.state.hasMore, isTrue);

    await controller.loadMore();
    expect(controller.state.entries, hasLength(50));
    await controller.loadMore();
    expect(controller.state.entries, hasLength(61));
    expect(controller.state.hasMore, isFalse);

    // No-op once everything is loaded.
    await controller.loadMore();
    expect(controller.state.entries, hasLength(61));
    expect(names().last, 'episode_60.mp4');
  });

  test('ignores results of a folder that is no longer shown', () async {
    await controller.refresh();
    final series = controller.openFolder(folder('Series'));
    final root = controller.goTo(CloudBreadcrumb.root);
    await Future.wait([series, root]);
    expect(controller.state.isRoot, isTrue);
    expect(names(), contains('Movies'));
  });

  test('stores loading errors in the state', () async {
    controller.dispose();
    controller = CloudBrowserController(
      provider: provider,
      initialPath: const [
        CloudBreadcrumb.root,
        CloudBreadcrumb(id: FolderId('missing'), name: 'Missing'),
      ],
    );
    await controller.refresh();
    expect(controller.state.error, isA<NotFoundException>());
    expect(controller.state.entries, isEmpty);
    expect(controller.state.isLoading, isFalse);
  });

  test('creates folders after the existing folders', () async {
    await controller.refresh();
    final created = await controller.createFolder('  Reports ');

    expect(created.name, 'Reports');
    expect(names(), [
      'Movies',
      'Series',
      'Reports',
      'trailer.mp4',
      'intro.mkv',
    ]);
    expect(provider.folders.map((f) => f.name), contains('Reports'));
    expect(controller.state.isBusy, isFalse);
  });

  test('renames files and folders', () async {
    await controller.refresh();
    await controller.rename(file('trailer.mp4'), 'teaser.mp4');
    await controller.rename(folder('Movies'), 'Films');

    expect(names(), ['Films', 'Series', 'teaser.mp4', 'intro.mkv']);
    expect(provider.files.map((f) => f.name), contains('teaser.mp4'));
  });

  test('deletes entries and reports the first error', () async {
    await controller.refresh();
    controller
      ..toggleSelection(file('trailer.mp4'))
      ..toggleSelection(folder('Movies'));
    expect(controller.state.selection, hasLength(2));

    // Movies is not empty: the file is deleted, the folder fails.
    await expectLater(
      controller.delete(controller.state.selectedEntries),
      throwsA(isA<ProviderException>()),
    );
    expect(names(), ['Movies', 'Series', 'intro.mkv']);
    expect(controller.state.actionError, isA<ProviderException>());
    expect(controller.state.selection, hasLength(1));
    expect(controller.state.isBusy, isFalse);
  });

  test('moves entries out of the current folder', () async {
    await controller.refresh();
    final movies = folder('Movies');
    await controller.move([file('intro.mkv')], movies.id);

    expect(names(), isNot(contains('intro.mkv')));
    await controller.openFolder(movies);
    expect(names(), contains('intro.mkv'));
  });

  test('searches files and closes the search', () async {
    await controller.refresh();
    await controller.search('episode_0');

    expect(controller.state.isSearching, isTrue);
    expect(names(), hasLength(9));
    expect(names().first, 'episode_01.mp4');

    await controller.clearSearch();
    expect(controller.state.isSearching, isFalse);
    expect(names(), contains('Movies'));
  });

  test('selects all and clears the selection', () async {
    await controller.refresh();
    controller.selectAll();
    expect(controller.state.selection, hasLength(4));
    expect(controller.state.isSelecting, isTrue);
    controller.clearSelection();
    expect(controller.state.isSelecting, isFalse);
  });

  test('reports capabilities of the provider', () async {
    expect(controller.canCreateFolder, isTrue);
    expect(controller.canSearch, isTrue);
    expect(controller.canRemoteUpload, isTrue);
    // Transfers need an UpCloud instance.
    expect(controller.canUpload, isFalse);
    expect(
      () => controller.upload([
        const UploadSource.bytes([1], name: 'a.txt'),
      ]),
      throwsA(isA<UnsupportedOperationException>()),
    );
  });

  test('uploads from a URL into the current folder', () async {
    await controller.refresh();
    final job = await controller.uploadFromUrl(
      Uri.parse('https://example.com/video.mp4'),
    );
    expect(job.status, RemoteUploadStatus.completed);
    await pumpEventQueue();
    expect(names(), contains('video.mp4'));
  });

  test('adds uploaded files to the list', () async {
    final (upcloud, account) = await upcloudWithAccount();
    addTearDown(upcloud.dispose);
    final browser = CloudBrowserController.forAccount(upcloud, account.id);
    addTearDown(browser.dispose);
    await browser.refresh();

    expect(browser.canUpload, isTrue);
    final tasks = browser.upload([
      UploadSource.bytes(List.filled(10, 0), name: 'notes.txt'),
    ]);
    final uploaded = await tasks.single.result;
    await pumpEventQueue();

    expect(uploaded.name, 'notes.txt');
    expect(browser.state.entries.map((e) => e.name), contains('notes.txt'));
  });
}
