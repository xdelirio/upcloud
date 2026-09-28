import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:upcloud_example/src/accounts_page.dart';
import 'package:upcloud_example/src/ambient_background.dart';
import 'package:upcloud_example/src/browser_page.dart';
import 'package:upcloud_example/src/glass_chrome.dart';
import 'package:upcloud_example/src/providers_page.dart';
import 'package:upcloud_example/src/strings.dart';
import 'package:upcloud_example/src/transfers_page.dart';
import 'package:upcloud_example/src/upload_page.dart';
import 'package:upcloud_flutter/upcloud_flutter.dart';

/// Responsive shell: a floating glass tab bar on phones and a glass side
/// rail on tablets and desktops, over the ambient backdrop.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _accountsTab = 0;
  static const _filesTab = 1;
  static const _transfersTab = 3;

  late final UpCloud _upcloud = UpCloudScope.of(context);
  late final AccountsController _accounts = AccountsController(_upcloud);
  late final TransfersController _transfers = TransfersController.of(_upcloud)
    ..addListener(_syncActiveUploads);
  late final ProvidersController _providers = ProvidersController(
    _upcloud.registry,
  );

  /// Badge of the transfers tab. Only changes when the count does, while
  /// the transfers controller notifies on every progress update.
  final ValueNotifier<int> _activeUploads = ValueNotifier(0);

  /// Keeps the pages (and their state) when the layout switches between
  /// the tab bar and the rail.
  final GlobalKey _pagesKey = GlobalKey();

  int _tab = _accountsTab;
  String? _accountId;

  @override
  void initState() {
    super.initState();
    // Start on the files tab when there is something to browse.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _upcloud.accounts.isNotEmpty) {
        setState(() => _tab = _filesTab);
      }
    });
  }

  void _syncActiveUploads() =>
      _activeUploads.value = _transfers.state.activeCount;

  @override
  void dispose() {
    _accounts.dispose();
    _transfers
      ..removeListener(_syncActiveUploads)
      ..dispose();
    _providers.dispose();
    _activeUploads.dispose();
    super.dispose();
  }

  void _select(int tab) => setState(() => _tab = tab);

  void _openAccount(CloudAccount account) => setState(() {
    _accountId = account.id;
    _tab = _filesTab;
  });

  /// Shows the progress of a batch started from the upload tab.
  void _onBatchStarted(UploadBatch batch) {
    setState(() => _tab = _transfersTab);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            UpCloudLocalizations.of(context).uploadsQueued(batch.tasks.length),
          ),
        ),
      );
  }

  List<AppDestination> _destinations(
    ExampleStrings strings, {
    required bool compact,
  }) => [
    AppDestination(
      icon: Icons.account_circle_outlined,
      selectedIcon: Icons.account_circle,
      label: strings.accounts,
    ),
    AppDestination(
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder_rounded,
      label: strings.files,
    ),
    AppDestination(
      icon: Icons.cloud_upload_outlined,
      selectedIcon: Icons.cloud_upload_rounded,
      label: strings.upload,
    ),
    AppDestination(
      icon: Icons.swap_vert_rounded,
      selectedIcon: Icons.swap_vert_circle_rounded,
      label: compact ? strings.transfersTab : strings.transfers,
      badgeCount: _activeUploads,
    ),
    AppDestination(
      icon: Icons.hub_outlined,
      selectedIcon: Icons.hub_rounded,
      label: strings.providers,
    ),
  ];

  Widget _buildPages() {
    return KeyedSubtree(
      key: _pagesKey,
      child: IndexedStack(
        index: _tab,
        children: [
          AccountsPage(
            controller: _accounts,
            selectedAccountId: _accountId,
            onOpen: _openAccount,
          ),
          ListenableBuilder(
            listenable: _accounts,
            builder: (context, _) {
              final accounts = _accounts.state.accounts;
              final selected = accounts.any((a) => a.id == _accountId)
                  ? _accountId
                  : accounts.firstOrNull?.id;
              return BrowserPage(
                accounts: accounts,
                accountId: selected,
                onAccountChanged: (id) => setState(() => _accountId = id),
                onAddAccount: () => _select(_accountsTab),
                isActive: _tab == _filesTab,
              );
            },
          ),
          UploadPage(onSubmitted: _onBatchStarted),
          TransfersPage(controller: _transfers),
          ProvidersPage(controller: _providers),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ExampleStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final pages = _buildPages();
    final width = MediaQuery.sizeOf(context).width;
    final destinations = _destinations(
      strings,
      compact: width < Breakpoints.medium,
    );

    if (width >= Breakpoints.medium) {
      final padding = MediaQuery.paddingOf(context);
      return GlassScaffold(
        background: const AmbientBackground(),
        body: Row(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                16 + padding.left,
                16 + padding.top,
                12,
                16 + padding.bottom,
              ),
              child: GlassSidebar(
                title: strings.appTitle,
                destinations: destinations,
                selectedIndex: _tab,
                onSelected: _select,
                extended: width >= Breakpoints.expanded,
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeLeft: true,
                child: pages,
              ),
            ),
          ],
        ),
      );
    }

    return GlassScaffold(
      background: const AmbientBackground(),
      // The body handles the keyboard itself (Material scaffolds), so the
      // tab bar stays at the bottom, behind the keyboard.
      resizeToAvoidBottomInset: false,
      bottomEdgeFade: false,
      body: _ClearTabBar(child: pages),
      bottomBar: GlassTabBar.bottom(
        // Five tabs: a bit more room for each label.
        horizontalPadding: 14,
        tabPadding: const EdgeInsets.symmetric(horizontal: 1),
        selectedIndex: _tab,
        onTabSelected: _select,
        selectedIconColor: scheme.primary,
        selectedLabelColor: scheme.primary,
        unselectedIconColor: scheme.onSurfaceVariant,
        unselectedLabelColor: scheme.onSurfaceVariant,
        settings: chromeGlassSettings(scheme),
        tabs: [
          for (final destination in destinations)
            GlassTab(
              icon: destination.buildIcon(selected: false),
              activeIcon: destination.buildIcon(selected: true),
              label: destination.label,
            ),
        ],
      ),
    );
  }
}

/// Adds the floating tab bar to the bottom padding of the pages, so their
/// lists, snack bars and floating buttons stay clear of it.
class _ClearTabBar extends StatelessWidget {
  const _ClearTabBar({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    double clear(double inset) => math.max(inset, Breakpoints.tabBarClearance);
    return MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(bottom: clear(media.padding.bottom)),
        viewPadding: media.viewPadding.copyWith(
          bottom: clear(media.viewPadding.bottom),
        ),
      ),
      child: child,
    );
  }
}
