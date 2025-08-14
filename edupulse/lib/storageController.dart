import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:archive/archive_io.dart';

class StorageController {
  StorageController();

  Future<String> getDocumentsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Download a ZIP from a signed URL and extract it to the app documents directory.
  /// Returns a list of extracted file paths.
  Future<List<String>> downloadAndUnzip(String signedUrl, String fileName) async {
    final extractedFiles = <String>[];

    // 1️⃣ Get the app's documents directory
    final dir = await getApplicationDocumentsDirectory();
    final zipPath = '${dir.path}/$fileName';

    // 2️⃣ Download the ZIP file
    final response = await http.get(Uri.parse(signedUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to download file: ${response.statusCode}');
    }

    // Save the ZIP file locally
    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(response.bodyBytes);

    // 3️⃣ Extract the ZIP file
    final bytes = zipFile.readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filePath = '${dir.path}/${file.name}';
      if (file.isFile) {
        final outFile = File(filePath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);
        extractedFiles.add(filePath);
      } else {
        await Directory(filePath).create(recursive: true);
      }
    }

    print('Downloaded and extracted to: ${dir.path}');
    return extractedFiles;
  }

  Future<List<String>> getAllFolders() async {
    final Directory dir = await getApplicationDocumentsDirectory(); // Directory object
    final List<String> folders = [];

    // List entities asynchronously using Directory.list()
    await for (var entity in dir.list()) {
      if (entity is Directory) {
        folders.add(entity.path.split(Platform.pathSeparator).last);
      }
    }

    return folders;
  }

  Future<String> getMdContent(String folder) async {
    final dir = await getApplicationDocumentsDirectory();
    final mdContent = await File('${dir.path}/$folder/lesson.md').readAsString();
    return mdContent;
  }

  Future<void> printAllFiles() async {
    // Get the app's documents directory
    final Directory dir = await getApplicationDocumentsDirectory();

    // List all files and directories inside
    final List<FileSystemEntity> entities = dir.listSync(recursive: true);

    for (var entity in entities) {
      if (entity is File) {
        print('File: ${entity.path}');
      } else if (entity is Directory) {
        print('Directory: ${entity.path}');
      }
    }
  }


}
