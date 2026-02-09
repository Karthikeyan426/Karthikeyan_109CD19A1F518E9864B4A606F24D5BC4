import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';

Future<List<dynamic>?> uploadFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if(result != null) {
      String fileName = path.basename(result.files.single.path!);
      File file = File(result.files.single.path!);
      return [fileName,file];
  }
  else {
    return null;
  }
}

Future<bool> downloadFile(File file, String fileName) async {
  final directory = await AndroidPathProvider.downloadsPath;
  try {
    file.copy('$directory/$fileName.pdf');
    return true;
  }
  catch(e) {
    return false;
  }

}