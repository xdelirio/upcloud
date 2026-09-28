import 'package:flutter/widgets.dart';

/// Strings of the example app itself (the package widgets use
/// `UpCloudLocalizations`).
enum ExampleStrings {
  english,
  spanish;

  static ExampleStrings of(BuildContext context) =>
      Localizations.maybeLocaleOf(context)?.languageCode == 'es'
      ? spanish
      : english;

  bool get _es => this == spanish;

  String get appTitle => 'UpCloud Files';
  String get accounts => _es ? 'Cuentas' : 'Accounts';
  String get files => _es ? 'Archivos' : 'Files';
  String get transfers => _es ? 'Transferencias' : 'Transfers';

  /// Short label for the five-tab bar of phones.
  String get transfersTab => _es ? 'Subidas' : 'Transfers';
  String get providers => _es ? 'Proveedores' : 'Providers';
  String get addAccount => _es ? 'Añadir cuenta' : 'Add account';
  String get connectTitle =>
      _es ? 'Conecta una cuenta en la nube' : 'Connect a cloud account';
  String get connectMessage => _es
      ? 'Elige un proveedor e introduce las credenciales que pide.'
      : 'Choose a provider and enter the credentials it asks for.';
  String get noAccountTitle =>
      _es ? 'Conecta una cuenta primero' : 'Connect an account first';
  String get noAccountMessage => _es
      ? 'Añade una cuenta de alguno de tus proveedores para ver sus archivos.'
      : 'Add an account of one of your providers to see its files.';
  String get goToAccounts => _es ? 'Ir a cuentas' : 'Go to accounts';
  String get account => _es ? 'Cuenta' : 'Account';
  String get settings => _es ? 'Ajustes' : 'Settings';
  String get theme => _es ? 'Tema' : 'Theme';
  String get language => _es ? 'Idioma' : 'Language';
  String get system => _es ? 'Sistema' : 'System';
  String get light => _es ? 'Claro' : 'Light';
  String get dark => _es ? 'Oscuro' : 'Dark';
  String get upload => _es ? 'Subir' : 'Upload';
  String get uploadsSection => _es ? 'Subidas' : 'Uploads';
  String get uploadsSectionHint => _es
      ? 'Se aplican al momento a la cola de subidas.'
      : 'Applied right away to the upload queue.';
  String get appSection => _es ? 'App' : 'App';
  String get appSectionHint =>
      _es ? 'Aspecto e idioma de la app.' : 'Look and language of the app.';
  String get backupSection => _es ? 'Copia de seguridad' : 'Backup';
  String get backupFile => _es ? 'Archivo cifrado' : 'Encrypted file';
  String get backupSectionHint => _es
      ? 'Lleva tus cuentas, proveedores y ajustes a otro dispositivo.'
      : 'Move your accounts, providers and settings to another device.';
}
