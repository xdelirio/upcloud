import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:upcloud/src/app/account_store.dart';
import 'package:upcloud/src/app/app.dart';
import 'package:upcloud/src/app/settings.dart';
import 'package:upcloud/src/widgets/common/message_view.dart';
import 'package:upcloud/ui.dart';

/// A complete multi-cloud upload manager.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Uploads run with background_downloader and show system notifications
  // (their texts follow the app language, see UpCloudApp). Providers are
  // data: the bundled registry, updates downloaded from GitHub and the
  // user's edits, saved with the upload and app settings in shared
  // preferences. Accounts hold secrets, so their store is always explicit.
  final store = SharedPreferencesKeyValueStore();
  final uploads = BackgroundUploadExecutor();
  final upcloud = UpCloudFlutter.create(
    accounts: SharedPreferencesAccountStore(),
    store: store,
    uploadExecutor: uploads,
  );
  // Warms up the glass shaders while the saved data loads; the app works
  // without the warm-up, so its failures never block the start.
  unawaited(LiquidGlassWidgets.initialize().catchError((Object _) {}));
  await _start(upcloud, store, uploads);
}

/// Loads the saved data and shows the app, or an error with a retry
/// button: starting without the saved accounts could overwrite them.
Future<void> _start(
  UpCloud upcloud,
  KeyValueStore store,
  BackgroundUploadExecutor uploads,
) async {
  final AppSettings settings;
  try {
    // upcloud also checks the remote provider registry for updates in the
    // background.
    (_, settings) = await (upcloud.init(), AppSettings.load(store)).wait;
  } on Object catch (error) {
    runApp(
      _StartupError(
        error: error is ParallelWaitError ? error.errors : error,
        onRetry: () => unawaited(_start(upcloud, store, uploads)),
      ),
    );
    return;
  }
  runApp(
    LiquidGlassWidgets.wrap(
      // Glass follows the app theme mode instead of the system brightness.
      brightnessResolver: Theme.maybeBrightnessOf,
      child: UpCloudScope(
        upcloud: upcloud,
        child: UpCloudApp(
          uploadExecutor: uploads,
          settings: settings,
          settingsStore: store,
        ),
      ),
    ),
  );
}

/// Shown instead of the app when the saved data cannot be loaded.
class _StartupError extends StatelessWidget {
  const _StartupError({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.forLocale(
      PlatformDispatcher.instance.locale,
    );
    return MaterialApp(
      title: l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: Scaffold(
        body: MessageView(
          icon: Icons.error_outline_rounded,
          title: l10n.startupFailed,
          message: '$error',
          isError: true,
          action: FilledButton(onPressed: onRetry, child: Text(l10n.retry)),
        ),
      ),
    );
  }
}
