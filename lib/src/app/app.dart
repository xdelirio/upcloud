import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:upcloud/src/app/ambient_background.dart';
import 'package:upcloud/src/app/home_page.dart';
import 'package:upcloud/src/app/settings.dart';
import 'package:upcloud/ui.dart';

/// Root widget: Material 3 light/dark themes and en/es localization.
///
/// Expects an [UpCloudScope] above it. Glass chrome comes from
/// `liquid_glass_widgets`; `main` wraps the app with
/// `LiquidGlassWidgets.wrap`.
class UpCloudApp extends StatefulWidget {
  const UpCloudApp({
    this.uploadExecutor,
    this.settings = const AppSettings(),
    this.settingsStore,
    super.key,
  });

  /// Executor whose notification texts follow the app language.
  final BackgroundUploadExecutor? uploadExecutor;

  /// Theme and language the app starts with.
  final AppSettings settings;

  /// Where changes of the theme and language are saved, if anywhere.
  final KeyValueStore? settingsStore;

  @override
  State<UpCloudApp> createState() => _UpCloudAppState();
}

class _UpCloudAppState extends State<UpCloudApp> {
  late final ValueNotifier<AppSettings> _settings = ValueNotifier(
    widget.settings,
  )..addListener(_save);

  static const _seed = Color(0xFF3D6DCC);

  void _save() {
    final store = widget.settingsStore;
    if (store != null) unawaited(_settings.value.save(store));
  }

  @override
  void dispose() {
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppSettingsScope(
      settings: _settings,
      child: ValueListenableBuilder(
        valueListenable: _settings,
        builder: (context, settings, _) => MaterialApp(
          onGenerateTitle: (context) =>
              UpCloudLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: UpCloudLocalizations.supportedLocales,
          localizationsDelegates: const [
            UpCloudLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Glass widgets are Material-free: give them a Material ancestor
          // for text styles and ink, and one clock for the backdrop.
          builder: (context, child) {
            Widget app = Material(
              type: MaterialType.transparency,
              child: AmbientMotion(
                enabled: settings.animatedBackground,
                child: child!,
              ),
            );
            final uploads = widget.uploadExecutor;
            if (uploads != null) {
              // Upload notifications in the language of the app.
              app = LocalizedUploadNotifications(executor: uploads, child: app);
            }
            return app;
          },
          home: const HomePage(),
        ),
      ),
    );
  }
}

/// The app theme: Material 3 from a seed color, with calmer surfaces,
/// a tighter type scale and rounder components.
ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: _UpCloudAppState._seed,
    brightness: brightness,
    // Keeps the brand blue vivid instead of the muted tonal default.
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  );
  final dark = brightness == Brightness.dark;
  final base = ThemeData(colorScheme: scheme);
  final text = base.textTheme;
  final textTheme = text.copyWith(
    headlineSmall: text.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    titleLarge: text.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
  );
  // Component themes are not localized like the text theme, so they need
  // the font sizes of the type scale too.
  final sized = base.typography.englishLike.merge(textTheme);
  const fieldRadius = BorderRadius.all(Radius.circular(14));
  const buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(14)),
  );
  return base.copyWith(
    // The app screens paint the ambient backdrop; pages pushed by the
    // shared widgets (e.g. the provider editor) get its base color.
    scaffoldBackgroundColor: dark
        ? scheme.surfaceContainerLowest
        : scheme.surfaceContainerLow,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: scheme.onSurface,
      titleTextStyle: sized.titleLarge?.copyWith(color: scheme.onSurface),
      systemOverlayStyle:
          (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
              .copyWith(statusBarColor: Colors.transparent),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      iconColor: scheme.onSurfaceVariant,
      titleTextStyle: sized.bodyLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      subtitleTextStyle: sized.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      selectedTileColor: scheme.secondaryContainer.withValues(alpha: 0.6),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
      space: 1,
      thickness: 1,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      // One step above the content panel, in both modes.
      color: dark ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: fieldRadius,
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: buttonShape,
        textStyle: sized.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 44),
        shape: buttonShape,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: buttonShape),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 3,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      showDragHandle: true,
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      insetPadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    chipTheme: ChipThemeData(
      side: BorderSide(color: scheme.outlineVariant),
      shape: const StadiumBorder(),
    ),
    // Look of the shared widgets (browser, transfers...).
    extensions: [
      UpCloudTheme.fromColorScheme(scheme).copyWith(
        folderColor: dark ? const Color(0xFFFFC94D) : const Color(0xFFE9A100),
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        progressHeight: 6,
      ),
    ],
  );
}
