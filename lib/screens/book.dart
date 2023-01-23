import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class Book extends StatelessWidget {
  String path;
  Book({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (() {}),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        fixedSize: const Size(120, 150),
      ),
      child: PdfDocumentLoader.openFile(
        path,
        pageNumber: 1,
        pageBuilder: (context, textureBuilder, pageSize) => textureBuilder(
          size: const Size(80, 120),
        ),
      ),
    );
  }
}
