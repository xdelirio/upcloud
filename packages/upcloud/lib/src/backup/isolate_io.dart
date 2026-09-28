import 'dart:isolate';

/// Whether [runIsolated] runs its computation in another isolate.
const canRunIsolated = true;

/// Runs [computation] in a new isolate and returns its result.
Future<T> runIsolated<T>(Future<T> Function() computation) =>
    Isolate.run(computation, debugName: 'upcloud-backup-kdf');
