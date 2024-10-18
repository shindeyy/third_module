
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:third_module/core/logger/app_logger.dart';

class FileService {
  static const platform = MethodChannel('file_channel');

  Future<String?> readFileFromAndroid(String fileName) async {
    try {
      final String? result = await platform.invokeMethod('readFile', fileName);
      return result;
    } catch (e) {
      AppLogger.d("Failed to read file: $e");
      return null;
    }
  }

  Future<void> writeFileToAndroid(String fileName, String data) async {
    try {
      await platform.invokeMethod('writeFile', {"fileName": fileName, "data": data});
    } catch (e) {
      AppLogger.d("Failed to read file: $e");
    }
  }

  Future<void> writeToFileInFlutter(String fileName, String content) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    AppLogger.d("File written at: ${file.path}");
    await file.writeAsString(content);
  }

  void writeFileInFlutter() async {
    await writeToFileInFlutter('flutter.txt', 'Hello from Flutter');
  }
}
