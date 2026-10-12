import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/testing.dart';
import 'package:upcloud/ui.dart';

/// Every capability implemented by [InMemoryProvider].
final Set<Capability> memoryCapabilities = InMemoryProvider().capabilities;

/// A registry with the bundled providers and no network access.
ProviderRegistry offlineRegistry({RegistryStore? store}) =>
    ProviderRegistry(useRemote: false, store: store);

/// Sample data without latency, so tests do not need to wait for timers.
InMemoryProvider fastSample({ProviderLimits limits = ProviderLimits.none}) =>
    InMemoryProvider.sample(latency: Duration.zero, limits: limits);

/// A definition creating a new [fastSample] for every connection.
ProviderDefinition memoryDefinition({
  String id = 'memory',
  String name = 'Memory',
  String? description,
  ProviderLimits limits = ProviderLimits.none,
  CredentialSchema? schema,
}) => ProviderDefinition(
  info: ProviderInfo(id: id, name: name, description: description),
  credentialSchema: schema ?? CredentialSchema.apiKey(),
  capabilities: memoryCapabilities,
  defaultLimits: limits,
  factory: (definition, credentials, options) =>
      fastSample(limits: definition.limitsFor(options)),
);

/// Creates an [UpCloud] with [memoryDefinition] and one account.
Future<(UpCloud, CloudAccount)> upcloudWithAccount({
  ProviderLimits limits = ProviderLimits.none,
}) async {
  final upcloud = UpCloud(
    uploadExecutor: FakeUploadExecutor(),
    registry: offlineRegistry(),
    providers: [memoryDefinition(limits: limits)],
  );
  await upcloud.init();
  final account = await upcloud.addAccount(
    providerId: 'memory',
    credentials: Credentials.apiKey('key'),
    label: 'Main',
    verify: false,
  );
  return (upcloud, account);
}

/// English Material strings for any locale, so widget tests can use
/// Spanish without depending on `flutter_localizations`.
class _AnyLocaleMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _AnyLocaleMaterialDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture(const DefaultMaterialLocalizations());

  @override
  bool shouldReload(_AnyLocaleMaterialDelegate old) => false;
}

/// English Cupertino strings for any locale.
class _AnyLocaleCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _AnyLocaleCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture(const DefaultCupertinoLocalizations());

  @override
  bool shouldReload(_AnyLocaleCupertinoDelegate old) => false;
}

/// Pumps [child] inside a localized [MaterialApp] and [Scaffold].
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  UpCloud? upcloud,
  Size? size,
  Locale? locale,
  bool registerDelegate = true,
}) async {
  if (size != null) {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  Widget app = MaterialApp(
    locale: locale,
    supportedLocales: UpCloudLocalizations.supportedLocales,
    localizationsDelegates: [
      if (registerDelegate) UpCloudLocalizations.delegate,
      const _AnyLocaleMaterialDelegate(),
      const _AnyLocaleCupertinoDelegate(),
      DefaultWidgetsLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  );
  if (upcloud != null) app = UpCloudScope(upcloud: upcloud, child: app);
  await tester.pumpWidget(app);
}

/// Waits long enough for snack bars and their timers to go away.
Future<void> dismissSnackBars(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}
