import 'package:entry_books/services/bookinfo.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdfdoc;
import 'dart:io';

class GetText extends ChangeNotifier {
  //File? _file;
  String pdfText = '';

  Future<void> getText(int pageNumber, File file) async {
    BookInfo bookInfo = BookInfo();
    //pageNumbers.add(pageNumber);
    //Load an existing PDF document.
    pdfdoc.PdfDocument document =
        pdfdoc.PdfDocument(inputBytes: File(file.path).readAsBytesSync());

    //Create a new instance of the PdfTextExtractor.
    pdfdoc.PdfTextExtractor extractor = pdfdoc.PdfTextExtractor(document);

    //Extract all the text from the document.
    pdfText = extractor.extractText(
        startPageIndex: (pageNumber == 0 ? 0 : pageNumber - 1));
  }
}
