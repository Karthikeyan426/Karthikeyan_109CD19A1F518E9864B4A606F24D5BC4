import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';

Future<File?> crop (int startingPageNumber, int endingPageNumber, File file) async {
  print("entered");
  final  PdfDocument oldDocument = PdfDocument(inputBytes: await file.readAsBytes());
  final PdfDocument newDocument = PdfDocument();
  final String fileName = "${DateTime.now().millisecondsSinceEpoch}_cropped.pdf";
  final int pageLength = oldDocument.pages.count;
  if(startingPageNumber > pageLength || endingPageNumber > pageLength) {
    oldDocument.dispose();
    newDocument.dispose();
    return null;
  }
  else {
    print('entered processing');
    for (int i = startingPageNumber;i <= endingPageNumber; i++) {
      newDocument.pages.add().graphics.drawPdfTemplate(
          oldDocument.pages[i-1].createTemplate(),
          Offset(0,0)
      );

    }
    final directory = await getDownloadsDirectory();
    File newFinalPdf = await File('${directory?.path}/${fileName}').writeAsBytes(await newDocument.save());
    oldDocument.dispose();
    newDocument.dispose();
    return newFinalPdf;
  }

}