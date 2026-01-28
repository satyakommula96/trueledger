import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class FileService {
  Future<String> readAsString(String path) async {
    if (kIsWeb) {
      throw UnsupportedError("File I/O not supported on Web");
    }
    return File(path).readAsString();
  }

  Future<void> writeAsString(String path, String content) async {
    if (kIsWeb) {
      throw UnsupportedError("File I/O not supported on Web");
    }
    await File(path).writeAsString(content);
  }
}

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});
