import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:upcloud_example/src/glass_chrome.dart';
import 'package:upcloud_example/src/settings_page.dart';
import 'package:upcloud_example/src/strings.dart';

/// Theme and language chosen by the user.
@immutable
class AppSettings {
  const AppSettings({this.themeMode = ThemeMode.system, this.locale});

  final ThemeMode themeMode;

  /// `null` follows the system language.
  final Locale? locale;

  AppSettings copyWith({ThemeMode? themeMode, Locale? Function()? locale}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        locale: locale == null ? this.locale : locale(),
      );

  /// Languages the app is translated to.
  static const languages = {'en', 'es'};

  /// The settings as JSON, saved in configuration backups (see
  /// `BackupSection.exportExtra`).
  Map<String, Object?> toJson() => {
    'themeMode': themeMode.name,
    'language': locale?.languageCode,
  };

  /// These settings with the values of [json] (see [toJson]); missing or
  /// unknown values are kept.
  AppSettings merge(Map<String, Object?> json) {
    final language = json['language'];
    return copyWith(
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
    final strings = ExampleStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: strings.settings,
      child: GlassIconButton(
        icon: Icon(Icons.tune_rounded, color: scheme.onSurface),
        size: 40,
        iconSize: 22,
        useOwnLayer: true,
        quality: GlassQuality.premium,
        settings: chromeGlassSettings(scheme),
        semanticLabel: strings.settings,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (context) => const SettingsPage()),
        ),
      ),
    );
  }
}
