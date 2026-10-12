import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/ui.dart';

import '../support/testing.dart';
import 'helpers.dart';

void main() {
  testWidgets('shows an empty state with an add button', (tester) async {
    final upcloud = UpCloud(
      uploadExecutor: FakeUploadExecutor(),
      registry: offlineRegistry(),
      providers: [memoryDefinition()],
    );
    addTearDown(upcloud.dispose);
    var add = 0;

    await pumpApp(
      tester,
      AccountList(onAddAccount: () => add++),
      upcloud: upcloud,
    );
    await tester.pumpAndSettle();

    expect(find.text('No accounts yet'), findsOneWidget);
    await tester.tap(find.text('Add account'));
    expect(add, 1);
  });

  testWidgets('lists, verifies and removes accounts', (tester) async {
    final (upcloud, account) = await upcloudWithAccount();
    addTearDown(upcloud.dispose);
    CloudAccount? tapped;

    await pumpApp(
      tester,
      AccountList(onTap: (a) => tapped = a, verifyOnLoad: true),
      upcloud: upcloud,
    );
    await tester.pumpAndSettle();

    expect(find.text('Main'), findsOneWidget);
    expect(find.textContaining('Memory'), findsOneWidget);
    expect(find.textContaining('used'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    // The provider reports used and free space: shows a storage meter.
    final meter = tester.widget<LinearProgressIndicator>(
      find.byType(LinearProgressIndicator),
    );
    expect(meter.value, inExclusiveRange(0, 1));

    await tester.tap(find.text('Main'));
    expect(tapped, account);

    await tester.tap(find.byTooltip('More actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('"Main" will be removed'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Remove'));
    await tester.pumpAndSettle();

    expect(upcloud.accounts, isEmpty);
    expect(find.text('No accounts yet'), findsOneWidget);
  });
}
