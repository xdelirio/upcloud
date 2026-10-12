/// Web fallback: there are no isolates, [runIsolated] runs in place.
const canRunIsolated = false;

/// Runs [computation] in the current isolate.
Future<T> runIsolated<T>(Future<T> Function() computation) => computation();
