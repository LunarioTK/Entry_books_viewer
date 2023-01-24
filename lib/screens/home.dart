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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            file.path == ''
                ? Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
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
                      child: Image.asset(
                        'assets/bookwithapplebgrm.png',
                        height: 70,
                        width: 50,
                      ),
                    ),
                  )
                : const Book(),
          ],
        ),
      ),
    );
  }
}

//'assets/bookwithapplebgrm.png'