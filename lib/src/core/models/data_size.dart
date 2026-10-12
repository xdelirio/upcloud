import 'package:meta/meta.dart';

/// An amount of data, stored in bytes.
///
/// ```dart
/// const limit = DataSize.gb(15);
/// print(limit); // 15.0 GB
/// ```
@immutable
final class DataSize implements Comparable<DataSize> {
  /// Creates a size of [bytes].
  const DataSize(this.bytes) : assert(bytes >= 0, 'bytes must be >= 0');

  /// Creates a size of [kb] kibibytes.
  const DataSize.kb(int kb) : this(kb * _kb);

  /// Creates a size of [mb] mebibytes.
  const DataSize.mb(int mb) : this(mb * _mb);

  /// Creates a size of [gb] gibibytes.
  const DataSize.gb(int gb) : this(gb * _gb);

  static const int _kb = 1024;
  static const int _mb = _kb * 1024;
  static const int _gb = _mb * 1024;
  static const int _tb = _gb * 1024;

  /// A size of zero bytes.
  static const zero = DataSize(0);

  /// Number of bytes.
  final int bytes;

  /// Size expressed in mebibytes.
  double get inMegabytes => bytes / _mb;

  /// Size expressed in gibibytes.
  double get inGigabytes => bytes / _gb;

  /// Adds two sizes.
  DataSize operator +(DataSize other) => DataSize(bytes + other.bytes);

  /// Subtracts [other], clamping at zero.
  DataSize operator -(DataSize other) =>
      DataSize(bytes > other.bytes ? bytes - other.bytes : 0);

  /// Whether this size is larger than [other].
  bool operator >(DataSize other) => bytes > other.bytes;

  /// Whether this size is smaller than [other].
  bool operator <(DataSize other) => bytes < other.bytes;

  /// Whether this size is larger than or equal to [other].
  bool operator >=(DataSize other) => bytes >= other.bytes;

  /// Whether this size is smaller than or equal to [other].
  bool operator <=(DataSize other) => bytes <= other.bytes;

  @override
  int compareTo(DataSize other) => bytes.compareTo(other.bytes);

  @override
  bool operator ==(Object other) => other is DataSize && other.bytes == bytes;

  @override
  int get hashCode => bytes.hashCode;

  /// Human readable representation, e.g. `1.5 GB`.
  @override
  String toString() {
    if (bytes >= _tb) return '${(bytes / _tb).toStringAsFixed(1)} TB';
    if (bytes >= _gb) return '${(bytes / _gb).toStringAsFixed(1)} GB';
    if (bytes >= _mb) return '${(bytes / _mb).toStringAsFixed(1)} MB';
    if (bytes >= _kb) return '${(bytes / _kb).toStringAsFixed(1)} KB';
    return '$bytes B';
  }
}
