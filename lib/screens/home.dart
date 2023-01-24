import 'dart:io';

import 'package:entry_books/constants/book.dart';
import 'package:entry_books/constants/uicolor.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File file = File('');

  @override
  Widget build(BuildContext context) {
    var bookInfo = context.watch<BookInfo>();

    return Scaffold(
      backgroundColor: uiColor,
      body: Column(
        children: [
          const SizedBox(height: 50),
          file.path == ''
              ? IconButton(
                  onPressed: (() async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc'],
                    );
                    if (result != null) {
                      setState(() {
                        file = File(result.files.single.path!);
                        bookInfo.setFile = file;
                      });
                    }
                  }),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )
              : const Book(),
        ],
      ),
    );
  }
}
