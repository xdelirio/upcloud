import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:upcloud/ui.dart';

/// Lets the user pick one or more files and converts them to
/// [UploadSource]s.
///
/// * Native platforms upload from the file path, so large files are not
///   loaded in memory.
/// * Web has no paths: the bytes are read in memory.
Future<List<UploadSource>> pickUploadSources() async {
  final files = await FilePicker.pickFiles();
  return [for (final file in files) await _toSource(file)];
}

/// Lets the user choose where to save the configuration backup [json],
/// proposing [fileName]. Returns whether it was saved.
Future<bool> saveBackupFile(String json, String fileName) async {
  final saved = await FilePicker.saveFile(
    fileName: fileName,
    bytes: utf8.encode(json),
    mimeType: 'application/json',
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  return saved != null;
}

/// Lets the user choose a configuration backup and returns its content, or
/// `null` when cancelled.
Future<String?> openBackupFile() async {
  final files = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['json'],
  );
  if (files.isEmpty) return null;
  return utf8.decode(await files.first.readAsBytes());
}

Future<UploadSource> _toSource(PlatformFile file) async {
  final path = kIsWeb ? null : file.path;
  if (path != null) {
    return UploadSource.file(
      path,
      name: file.name,
      length: file.lengthSync() ?? await file.length(),
    );
  }
  final length = file.lengthSync() ?? await file.length();
  if (!kIsWeb && length != null) {
    // Content URIs (e.g. Android cloud documents): stream the content.
    return UploadSource.stream(
      file.readAsByteStream,
      name: file.name,
      length: length,
    );
  }
  return UploadSource.bytes(await file.readAsBytes(), name: file.name);
}
