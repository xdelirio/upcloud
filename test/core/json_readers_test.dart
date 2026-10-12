import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/src/core/http/json_readers.dart';

void main() {
  group('readInt', () {
    test('accepts ints, doubles, bools and numeric strings', () {
      expect(readInt(5), 5);
      expect(readInt(5.6), 6);
      expect(readInt(true), 1);
      expect(readInt(' 42 '), 42);
      expect(readInt('3.2'), 3);
    });

    test('returns null for anything else', () {
      expect(readInt(null), isNull);
      expect(readInt('abc'), isNull);
      expect(readInt(const <int>[]), isNull);
    });
  });

  test('readBool understands common encodings', () {
    for (final v in [true, 1, '1', 'true', 'YES', 'on']) {
      expect(readBool(v), isTrue, reason: '$v');
    }
    for (final v in [false, 0, '0', 'false', 'no', '']) {
      expect(readBool(v), isFalse, reason: '$v');
    }
    expect(readBool('maybe'), isNull);
    expect(readBool(null), isNull);
  });

  test('readString ignores empty strings and stringifies numbers', () {
    expect(readString(''), isNull);
    expect(readString('a'), 'a');
    expect(readString(12), '12');
    expect(readString(null), isNull);
  });

  group('readUri', () {
    test('parses absolute URIs', () {
      expect(readUri('https://a.com/x'), Uri.parse('https://a.com/x'));
    });

    test('adds https to protocol relative URIs', () {
      expect(
        readUri('//img.a.com/t.jpg'),
        Uri.parse('https://img.a.com/t.jpg'),
      );
    });

    test('rejects relative or empty values', () {
      expect(readUri('/x'), isNull);
      expect(readUri(''), isNull);
      expect(readUri(null), isNull);
    });
  });

  group('readDateTime', () {
    test('parses "yyyy-MM-dd HH:mm:ss" as UTC', () {
      expect(
        readDateTime('2024-01-02 03:04:05'),
        DateTime.utc(2024, 1, 2, 3, 4, 5),
      );
    });

    test('keeps explicit offsets', () {
      expect(
        readDateTime('2024-01-02T03:04:05+02:00'),
        DateTime.utc(2024, 1, 2, 1, 4, 5),
      );
    });

    test('parses unix timestamps in seconds and milliseconds', () {
      final expected = DateTime.utc(2024);
      final seconds = expected.millisecondsSinceEpoch ~/ 1000;
      expect(readDateTime(seconds), expected);
      expect(readDateTime('$seconds'), expected);
      expect(readDateTime(expected.millisecondsSinceEpoch), expected);
    });

    test('returns null for zero dates and garbage', () {
      expect(readDateTime('0000-00-00 00:00:00'), isNull);
      expect(readDateTime(0), isNull);
      expect(readDateTime('nope'), isNull);
    });
  });

  test('readSecondsDuration parses seconds and clock formats', () {
    expect(readSecondsDuration(90), const Duration(seconds: 90));
    expect(readSecondsDuration('90.5'), const Duration(milliseconds: 90500));
    expect(readSecondsDuration('01:02:03'), const Duration(seconds: 3723));
    expect(readSecondsDuration('02:03'), const Duration(seconds: 123));
    expect(readSecondsDuration('a:b'), isNull);
    expect(readSecondsDuration(-1), isNull);
  });

  test('readList and readMap are defensive', () {
    expect(readList([1, 2]), [1, 2]);
    expect(readList('x'), isEmpty);
    expect(readMap({'a': 1}), {'a': 1});
    expect(readMap([1]), isNull);
  });
}
