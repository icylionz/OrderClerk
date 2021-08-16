import 'dart:convert';
import 'package:path/path.dart' as p;
import 'dart:io';

class FileHandler {
  static File itemFilterFile = new File("/");
  static Directory dir =
      new Directory(File(p.relative(Directory("lib/data").path)).absolute.path);

  static void createFile({required String fileName, var content}) {
    File file = new File(p.relative(dir.path) + "/" + fileName);
    if (!file.existsSync()) {
      file.createSync();
      file.writeAsStringSync(json.encode(content));
      itemFilterFile = File(file.absolute.path);
    } else {
      itemFilterFile = File(file.absolute.path);
    }
  }

  String get localPath {
    final directory = Directory("lib/data");

    return directory.path;
  }
}
