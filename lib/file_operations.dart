

import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> writeToFile(String fileName, String data) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsString(data);
}

Future<String?> readFromFile(String fileName) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    String fileContents = await file.readAsString();
    return fileContents;
  } catch (e) {
    return null;
  }
}