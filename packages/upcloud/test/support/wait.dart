import 'package:test/test.dart';

/// Waits until [condition] is true, failing the test after [timeout].
Future<void> until(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 5),
}) async {
  final watch = Stopwatch()..start();
  while (!condition()) {
    if (watch.elapsed > timeout) fail('Condition not met after $timeout');
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
}
