import 'package:meta/meta.dart';

/// Cost of the Argon2id key derivation that turns a backup password into
/// the encryption key.
///
/// Every backup stores the parameters it was made with, so backups made
/// with other values (older defaults, tests...) can always be restored.
@immutable
final class Argon2idParams {
  /// Creates parameters. See [isValid] for the accepted ranges.
  const Argon2idParams({
    required this.memoryKiB,
    required this.iterations,
    this.parallelism = 1,
  });

  /// The minimum recommended by OWASP for Argon2id: 19 MiB of memory, 2
  /// passes and 1 lane.
  ///
  /// It takes about 70 ms on an Apple M3 with the pure Dart implementation
  /// (JIT and AOT alike); expect a few hundred milliseconds on slow phones.
  static const recommended = Argon2idParams(memoryKiB: 19456, iterations: 2);

  /// Highest [memoryKiB] accepted when reading a backup (256 MiB), so a
  /// crafted file cannot make the app allocate gigabytes.
  static const maxMemoryKiB = 262144;

  /// Highest [iterations] accepted when reading a backup.
  static const maxIterations = 32;

  /// Highest [parallelism] accepted when reading a backup.
  static const maxParallelism = 16;

  /// Memory used, in KiB (Argon2 blocks of 1 KiB).
  final int memoryKiB;

  /// Number of passes over the memory.
  final int iterations;

  /// Number of lanes computed in parallel.
  final int parallelism;

  /// Whether Argon2id accepts these values and they are within the limits
  /// above: `1 <= parallelism <= 16`, `1 <= iterations <= 32` and
  /// `8 * parallelism <= memoryKiB <= 262144`.
  bool get isValid =>
      parallelism >= 1 &&
      parallelism <= maxParallelism &&
      iterations >= 1 &&
      iterations <= maxIterations &&
      memoryKiB >= 8 * parallelism &&
      memoryKiB <= maxMemoryKiB;

  @override
  bool operator ==(Object other) =>
      other is Argon2idParams &&
      other.memoryKiB == memoryKiB &&
      other.iterations == iterations &&
      other.parallelism == parallelism;

  @override
  int get hashCode => Object.hash(memoryKiB, iterations, parallelism);

  @override
  String toString() =>
      'Argon2idParams(memoryKiB: $memoryKiB, iterations: $iterations, '
      'parallelism: $parallelism)';
}
