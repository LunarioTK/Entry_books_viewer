import 'package:entry_books/constants/uicolor.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:provider/provider.dart';

class Book extends StatelessWidget {
  const Book({super.key});

  @override
  Widget build(BuildContext context) {
    var bookInfo = context.watch<BookInfo>();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          TextButton(
            onPressed: (() {
              Navigator.pushNamed(context, '/currentbook');
            }),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.all(0.0),
              backgroundColor: Colors.transparent,
              fixedSize: const Size(50, 60),
              elevation: 0,
            ),
            child: PdfDocumentLoader.openFile(
              bookInfo.getFile.path,
              pageNumber: 1,
              pageBuilder: (context, textureBuilder, pageSize) =>
                  textureBuilder(
                size: const Size(80, 120),
              ),
            ),
          ),
          Text(
            '__________',
            style: TextStyle(
              color: smallTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
