import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';

Future<File?> merge({required File pdfFile1, required File pdfFile2}) async {
  final doc1 = PdfDocument(inputBytes: await pdfFile1.readAsBytes());
  final doc1Duplicate = doc1;
  final doc2 = PdfDocument(inputBytes: await pdfFile2.readAsBytes());
  final String fileName = "${DateTime.now().millisecondsSinceEpoch}_combined.pdf";
  for(var i=0; i < doc2.pages.count; i++) {
    doc1Duplicate.pages.add().graphics.drawPdfTemplate(
        doc2.pages[i].createTemplate(),
        Offset(0, 0)
    );
  }
  final combinedDoc = doc1Duplicate;
  final dir = await getDownloadsDirectory();
  File processedPdfFile = await File('${dir?.path}/$fileName').writeAsBytes(await combinedDoc.save());
  doc1Duplicate.dispose();
  doc1.dispose();
  doc2.dispose();
  combinedDoc.dispose();
  return processedPdfFile;
}
