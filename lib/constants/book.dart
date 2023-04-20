import 'dart:io';

import 'package:entry_books/constants/uicolor.dart';
import 'package:entry_books/screens/currentbook.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:provider/provider.dart';

class Book extends StatelessWidget {
  File file;
  int? index;
  Book({super.key, this.index, required this.file});

  @override
  Widget build(BuildContext context) {
    var bookInfo = context.watch<BookInfo>();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              bookInfo.setFile = file;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CurrenBook(file: file),
                ),
              );
            },
            child: Material(
              elevation: 10,
              child: PdfDocumentLoader.openFile(
                file.path,
                pageNumber: 1,
                pageBuilder: (context, textureBuilder, pageSize) =>
                    textureBuilder(
                  size: const Size(80, 120),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
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
