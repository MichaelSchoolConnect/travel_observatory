import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SaveFileLocally {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/file.json');
  }

  Future<int> readFile() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      print("Couldn't read file");
      return 0;
    }
  }

  Future<File> writeFile(String file) async {
    final file = await _localFile;

    print('File saved');

    // Write the file
    return file.writeAsString('$file');
  }
}
