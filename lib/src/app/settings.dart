import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:upcloud/src/app/glass_chrome.dart';
import 'package:upcloud/src/app/settings_page.dart';
import 'package:upcloud/ui.dart';

/// Theme and language chosen by the user.
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.animatedBackground = true,
  });

  final ThemeMode themeMode;

  /// `null` follows the system language.
  final Locale? locale;

  /// Whether the backdrop drifts slowly; still, it uses less battery.
  final bool animatedBackground;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? Function()? locale,
    bool? animatedBackground,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    locale: locale == null ? this.locale : locale(),
    animatedBackground: animatedBackground ?? this.animatedBackground,
  );

  /// Languages the app is translated to.
  static const languages = {'en', 'es'};

  /// Key of the settings in the [KeyValueStore] of the app.
  static const storeKey = 'upcloud.settings.app';

  /// The settings saved in [store], or the defaults.
  static Future<AppSettings> load(KeyValueStore store) async {
    final saved = await store.read(storeKey);
    if (saved == null) return const AppSettings();
    try {
      final json = jsonDecode(saved);
      if (json is Map<String, Object?>) return const AppSettings().merge(json);
    } on FormatException {
      // Saved by an incompatible version: use the defaults.
    }
    return const AppSettings();
  }

  /// Saves the settings in [store].
  Future<void> save(KeyValueStore store) =>
      store.write(storeKey, jsonEncode(toJson()));

  /// The settings as JSON, saved in configuration backups (see
  /// `BackupSection.exportExtra`).
  Map<String, Object?> toJson() => {
    'themeMode': themeMode.name,
    'language': locale?.languageCode,
    'animatedBackground': animatedBackground,
  };

  /// These settings with the values of [json] (see [toJson]); missing or
  /// unknown values are kept.
  AppSettings merge(Map<String, Object?> json) {
    final language = json['language'];
    final animated = json['animatedBackground'];
    return copyWith(
      animatedBackground: animated is bool ? animated : null,
      themeMode: ThemeMode.values.asNameMap()[json['themeMode']],
      locale: switch (language) {
        null when json.containsKey('language') => () => null,
        final String code when languages.contains(code) => () => Locale(code),
        _ => null,
      },
    );
  }
}

/// Provides the [AppSettings] notifier to the app.
class AppSettingsScope extends InheritedNotifier<ValueNotifier<AppSettings>> {
  const AppSettingsScope({
    required ValueNotifier<AppSettings> settings,
    required super.child,
    super.key,
  }) : super(notifier: settings);

  static ValueNotifier<AppSettings> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppSettingsScope>()!.notifier!;
}

/// App bar entry point of the [SettingsPage]: a small glass button.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = UpCloudLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: l10n.settings,
      child: GlassIconButton(
        icon: Icon(Icons.tune_rounded, color: scheme.onSurface),
        size: 40,
        iconSize: 22,
        useOwnLayer: true,
        quality: GlassQuality.premium,
        settings: chromeGlassSettings(scheme),
        semanticLabel: l10n.settings,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => const SettingsPage()),
        ),
      ),
    );
  }
}
