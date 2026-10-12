import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/upcloud.dart';

void main() {
  const limits = ProviderLimits(
    maxFileSize: DataSize.mb(10),
    allowedExtensions: {'mp4', 'mkv'},
  );

  group('ensureAccepts', () {
    test('accepts files within the limits', () {
      limits
        ..ensureAccepts(extension: 'MP4', size: const DataSize.mb(10))
        ..ensureAccepts(extension: 'mkv');
      ProviderLimits.none.ensureAccepts(
        extension: '',
        size: const DataSize.gb(100),
      );
    });

    test('throws the rejection with its description', () {
      expect(
        () => limits.ensureAccepts(extension: 'txt'),
        throwsA(
          isA<UploadRejectedException>()
              .having((e) => e.reason, 'reason', isA<ExtensionNotAllowed>())
              .having(
                (e) => e.message,
                'message',
                'File type ".txt" is not allowed',
              ),
        ),
      );
      expect(
        () =>
            limits.ensureAccepts(extension: 'mp4', size: const DataSize.mb(11)),
        throwsA(
          isA<UploadRejectedException>()
              .having((e) => e.reason, 'reason', isA<FileTooLarge>())
              .having(
                (e) => e.message,
                'message',
                describeUploadRejection(
                  const FileTooLarge(
                    size: DataSize.mb(11),
                    maxSize: DataSize.mb(10),
                  ),
                ),
              ),
        ),
      );
      expect(
        () => limits.ensureAccepts(
          extension: 'mp4',
          size: const DataSize.mb(5),
          storageLeft: const DataSize.mb(1),
        ),
        throwsA(
          isA<UploadRejectedException>().having(
            (e) => e.reason,
            'reason',
            isA<NotEnoughStorage>(),
          ),
        ),
      );
    });
  });

  test('describeUploadRejection is readable', () {
    expect(
      describeUploadRejection(
        const FileTooLarge(size: DataSize.mb(11), maxSize: DataSize.mb(10)),
      ),
      allOf(startsWith('File is too large ('), contains('max')),
    );
    expect(
      describeUploadRejection(
        const NotEnoughStorage(size: DataSize.mb(5), available: DataSize.mb(1)),
      ),
      startsWith('Not enough storage ('),
    );
  });
}
