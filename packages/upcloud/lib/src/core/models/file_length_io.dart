import 'dart:io';

/// Size of the file at [path], or `null` if it does not exist.
Future<int?> fileLength(String path) async {
  final file = File(path);
  return file.existsSync() ? await file.length() : null;
}
