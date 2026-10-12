import 'dart:async';

import 'package:upcloud/ui.dart';

/// Runs before every test file of this directory: widget tests cannot open
/// network connections, so provider SVG icons are never downloaded.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  ProviderAvatar.svgLoader = (_) async => null;
  await testMain();
}
