import 'dart:isolate';

/// Runs [computation] in a new isolate and returns its result.
Future<T> runIsolated<T>(Future<T> Function() computation) =>
    Isolate.run(computation, debugName: 'upcloud-backup-kdf');
