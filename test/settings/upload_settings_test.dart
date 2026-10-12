import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:upcloud/upcloud.dart';

void main() {
  test('has sensible defaults', () {
    const settings = UploadSettings();
    expect(settings.maxConcurrentUploads, 3);
    expect(settings.retries, 2);
    expect(settings.checkStorage, isTrue);
    expect(settings.autoClearAfterSeconds, isNull);
    expect(settings.autoClearAfter, isNull);
    expect(settings.defaultFolderPath, isNull);
    expect(settings.defaultVisibility, UploadVisibility.providerDefault);
  });

  test('round trips through JSON', () {
    const settings = UploadSettings(
      maxConcurrentUploads: 5,
      retries: 0,
      checkStorage: false,
      autoClearAfterSeconds: 30,
      defaultFolderPath: 'Movies/2026',
      defaultVisibility: UploadVisibility.private,
    );
    final json = jsonDecode(jsonEncode(settings.toJson()));
    expect(UploadSettings.fromJson(json as Map<String, dynamic>), settings);
    expect(settings.autoClearAfter, const Duration(seconds: 30));
  });

  test('reads old or partial JSON with defaults', () {
    expect(
      UploadSettings.fromJson({
        'retries': 4,
        'defaultVisibility': 'unlisted',
        'unknown': true,
      }),
      const UploadSettings(retries: 4),
    );
  });

  test('normalized clamps values and cleans the folder path', () {
    expect(
      const UploadSettings(
        maxConcurrentUploads: 0,
        retries: 99,
        autoClearAfterSeconds: -5,
        defaultFolderPath: ' Movies // 2026 ',
      ).normalized(),
      const UploadSettings(
        maxConcurrentUploads: UploadSettings.minConcurrentUploads,
        retries: UploadSettings.maxRetries,
        autoClearAfterSeconds: 0,
        defaultFolderPath: 'Movies/2026',
      ),
    );
    expect(
      const UploadSettings(maxConcurrentUploads: 11).normalized(),
      const UploadSettings(
        maxConcurrentUploads: UploadSettings.maxConcurrentUploadsLimit,
      ),
    );
    expect(
      const UploadSettings(defaultFolderPath: ' / ').normalized(),
      const UploadSettings(),
    );
  });

  test('visibility maps to UploadOptions.isPublic', () {
    expect(UploadVisibility.providerDefault.isPublic, isNull);
    expect(UploadVisibility.public.isPublic, isTrue);
    expect(UploadVisibility.private.isPublic, isFalse);
  });
}
