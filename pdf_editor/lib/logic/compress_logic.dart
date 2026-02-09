import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<File?> compress({required File pdfFile}) async {
  final PdfDocument oldDocument = PdfDocument(inputBytes: await pdfFile.readAsBytes());
  oldDocument.compressionLevel = PdfCompressionLevel.best;
  final directory = await getDownloadsDirectory();
  File processedFile = await File("${directory?.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.pdf").writeAsBytes( await oldDocument.save());
  oldDocument.dispose();
  return processedFile;
}