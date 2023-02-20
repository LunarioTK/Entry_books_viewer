import 'dart:io';

import 'package:entry_books/constants/uicolor.dart';
import 'package:entry_books/screens/currentbook.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

class Book extends StatelessWidget {
  File file;
  Book({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    //var bookInfo = context.watch<BookInfo>();

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CurrenBook(file: file),
                ),
              );
            },
            child: Material(
              elevation: 10,
              child: Container(
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
