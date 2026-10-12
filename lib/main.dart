import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:upcloud/src/app/account_store.dart';
import 'package:upcloud/src/app/app.dart';
import 'package:upcloud/ui.dart';

/// A complete multi-cloud upload manager.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Uploads run with background_downloader and show system notifications
  // (their texts follow the app language, see ExampleApp). Providers are
  // data: the registry bundled with upcloud, updates downloaded from GitHub
  // and the user's edits, saved with the upload settings in shared
  // preferences. Accounts hold secrets, so their store is always explicit.
  final uploads = BackgroundUploadExecutor();
  final upcloud = UpCloudFlutter.create(
    accounts: SharedPreferencesAccountStore(),
    uploadExecutor: uploads,
  );
  // Warms up the glass shaders while the saved accounts load. upcloud also
  // checks the remote provider registry for updates in the background.
  await (LiquidGlassWidgets.initialize(), upcloud.init()).wait;
  runApp(
    LiquidGlassWidgets.wrap(
      // Glass follows the app theme mode instead of the system brightness.
      brightnessResolver: Theme.maybeBrightnessOf,
      child: UpCloudScope(
        upcloud: upcloud,
        child: ExampleApp(uploadExecutor: uploads),
      ),
    ),
  );
}
