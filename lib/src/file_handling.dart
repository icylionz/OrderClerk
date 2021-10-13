import 'dart:convert';
import 'package:path/path.dart' as p;
import 'dart:io';

class FileHandler {
  static final Directory dir =
      new Directory(File(p.relative(Directory("lib/data").path)).absolute.path);

  static void createFile(
      {required String fileName, var content, bool writeAsString = true}) {
    print(Directory.current);
    File file = new File(p.join(FileHandler.dir.path, fileName));
    if (!file.existsSync()) {
      print("Showing file path: ${file.path}");
      file.createSync();
      writeAsString ? file.writeAsString(content) : file.writeAsBytes(content);
    }
  }

  String get localPath {
    final directory = Directory("lib/data");

    return directory.path;
  }
}
