import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/ui.dart';

import '../support/testing.dart';
import 'helpers.dart';

/// A provider that rejects every credential.
final class _RejectingProvider implements AccountInfoProviding {
  @override
  ProviderInfo get info => const ProviderInfo(id: 'strict', name: 'Strict');

  @override
  ProviderLimits get limits => ProviderLimits.none;

  @override
  Set<Capability> get capabilities => const {Capability.accountInfo};

  @override
  void close() {}

  @override
  Future<AccountInfo> accountInfo() async =>
      throw const AuthenticationException('Invalid API key (code 401)');
}

final _strict = ProviderDefinition(
  info: const ProviderInfo(id: 'strict', name: 'Strict'),
  credentialSchema: CredentialSchema.apiKey(
    helpUrl: Uri.parse('https://strict.example.com/account/api'),
  ),
  capabilities: const {Capability.accountInfo},
  factory: (definition, credentials, options) => _RejectingProvider(),
);

final _mail = ProviderDefinition(
  info: const ProviderInfo(id: 'mail', name: 'Mail'),
  credentialSchema: const CredentialSchema([
    CredentialField(
      id: 'email',
      label: 'Email',
      kind: CredentialInputKind.email,
    ),
    CredentialField(
      id: 'password',
      label: 'Password',
      kind: CredentialInputKind.secret,
    ),
    CredentialField(
      id: 'server',
      label: 'Server',
      kind: CredentialInputKind.url,
      isRequired: false,
    ),
  ]),
  capabilities: const {Capability.browseFolders},
  factory: (definition, credentials, options) => fastSample(),
);

void main() {
  Finder field(String id) => find.byKey(ValueKey('upcloud-credential-$id'));

  Future<UpCloud> pumpForm(
    WidgetTester tester,
    ProviderDefinition provider, {
    ValueChanged<CloudAccount>? onAdded,
  }) async {
    final upcloud = UpCloud(
      uploadExecutor: FakeUploadExecutor(),
      registry: offlineRegistry(),
      providers: [provider],
    );
    addTearDown(upcloud.dispose);
    await pumpApp(
      tester,
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AccountForm(provider: provider, onAdded: onAdded),
      ),
      upcloud: upcloud,
      size: const Size(800, 1200),
    );
    return upcloud;
  }

  testWidgets('chooses the provider in a dropdown', (tester) async {
    final upcloud = UpCloud(
      uploadExecutor: FakeUploadExecutor(),
      registry: offlineRegistry(),
      providers: [inMemoryDemo],
    );
    addTearDown(upcloud.dispose);
    CloudAccount? added;
    await pumpApp(
      tester,
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AccountForm(onAdded: (account) => added = account),
      ),
      upcloud: upcloud,
      size: const Size(800, 1200),
    );

    // The first provider is preselected and its fields are shown.
    expect(find.text('Demo (in memory)'), findsOneWidget);
    expect(find.text('Email'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('upcloud-account-provider')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('MediaFire').last);
    await tester.pumpAndSettle();

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Back to the demo and connect.
    await tester.tap(find.byKey(const ValueKey('upcloud-account-provider')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Demo (in memory)').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('upcloud-credential-api_key')),
      'key',
    );
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(added?.providerId, 'demo');
  });

  testWidgets('validates required fields', (tester) async {
    await pumpForm(tester, inMemoryDemo);

    expect(find.text('Demo (in memory)'), findsOneWidget);
    expect(find.text('API key'), findsOneWidget);

    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(find.text('API key is required'), findsOneWidget);
  });

  testWidgets('adds an inMemoryDemo account after verifying it', (
    tester,
  ) async {
    CloudAccount? added;
    final upcloud = await pumpForm(
      tester,
      inMemoryDemo,
      onAdded: (account) => added = account,
    );

    await tester.enterText(field(CredentialField.apiKeyId), '  secret  ');
    await tester.tap(find.text('Connect'));
    await tester.pump();
    // The button shows progress while the credentials are checked.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(added, isNotNull);
    expect(added!.providerId, 'demo');
    expect(added!.credentials.apiKey, 'secret');
    expect(added!.label, 'Demo (in memory) · demo');
    expect(upcloud.accounts, [added]);
  });

  testWidgets('uses the account name when given', (tester) async {
    CloudAccount? added;
    await pumpForm(tester, inMemoryDemo, onAdded: (a) => added = a);

    await tester.enterText(
      find.byKey(const ValueKey('upcloud-account-label')),
      'Work',
    );
    await tester.enterText(field(CredentialField.apiKeyId), 'secret');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(added?.label, 'Work');
  });

  testWidgets('shows authentication errors', (tester) async {
    CloudAccount? added;
    final upcloud = await pumpForm(
      tester,
      _strict,
      onAdded: (account) => added = account,
    );

    await tester.enterText(field(CredentialField.apiKeyId), 'wrong');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'The provider rejected the credentials. Check them and try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('Invalid API key (code 401)'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    expect(added, isNull);
    expect(upcloud.accounts, isEmpty);
    // The form can be submitted again.
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('shows the help link of a field', (tester) async {
    await pumpForm(tester, _strict);
    expect(find.textContaining('Where do I find it?'), findsOneWidget);
    expect(
      find.textContaining('strict.example.com/account/api'),
      findsOneWidget,
    );
  });

  testWidgets('validates emails and URLs, hides secrets', (tester) async {
    await pumpForm(tester, _mail);

    expect(find.text('Server (Optional)'), findsOneWidget);
    await tester.enterText(field('email'), 'not-an-email');
    await tester.enterText(field('password'), 'hunter2');
    await tester.enterText(field('server'), 'ftp://files');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Enter a valid http(s) URL'), findsOneWidget);

    EditableText password() => tester.widget<EditableText>(
      find.descendant(
        of: field('password'),
        matching: find.byType(EditableText),
      ),
    );
    expect(password().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show'));
    await tester.pump();
    expect(password().obscureText, isFalse);
    expect(find.byTooltip('Hide'), findsOneWidget);
  });

  testWidgets('applies default values of empty fields', (tester) async {
    final withDefault = ProviderDefinition(
      info: const ProviderInfo(id: 'host', name: 'Host'),
      credentialSchema: const CredentialSchema([
        CredentialField(id: CredentialField.apiKeyId, label: 'API key'),
        CredentialField(id: 'region', label: 'Region', defaultValue: 'eu-west'),
      ]),
      capabilities: const {Capability.browseFolders},
      factory: (definition, credentials, options) => fastSample(),
    );
    CloudAccount? added;
    await pumpForm(tester, withDefault, onAdded: (a) => added = a);

    expect(find.text('Region (Optional)'), findsOneWidget);
    await tester.enterText(field(CredentialField.apiKeyId), 'key');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(added?.credentials['region'], 'eu-west');
  });

  testWidgets('adds accounts through an AccountsController', (tester) async {
    final upcloud = UpCloud(
      uploadExecutor: FakeUploadExecutor(),
      registry: offlineRegistry(),
      providers: [inMemoryDemo],
    );
    addTearDown(upcloud.dispose);
    final controller = AccountsController(upcloud);
    addTearDown(controller.dispose);

    await pumpApp(
      tester,
      SingleChildScrollView(
        child: AccountForm(provider: inMemoryDemo, controller: controller),
      ),
      size: const Size(800, 1200),
    );
    await tester.enterText(field(CredentialField.apiKeyId), 'secret');
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();

    expect(controller.state.accounts, hasLength(1));
    final id = controller.state.accounts.single.id;
    expect(controller.state.statusOf(id), isA<AccountStatusConnected>());
  });
}
