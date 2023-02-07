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
    MediaQueryData media = MediaQuery.of(context);
    double height = media.size.height;
    double width = media.size.width;

    double ratio = media.size.height / media.size.width;
    late FilePickerResult? result;
    int count = 0;

    return Scaffold(
      backgroundColor: uiColor,
      body: SafeArea(
        child: Stack(
          children: [
            file.path == ''
                ? Container()
                : GridView.builder(
                    clipBehavior: Clip.none,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: bookInfo.allBooks.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Book(
                        file: bookInfo.allBooks[index].file,
                      );
                    }),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: (() async {
                    result = null;
                    result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null) {
                      file = File(result!.files.single.path!);
                      bookInfo.setFile = file;
                      count++;
                      bookInfo.setbooksAdded = count;
                    }
                  }),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/bookbgrm.png',
                        height: height * 0.20,
                        width: width * 0.20,
                      ),
                      const Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.add,
                          weight: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//'assets/bookwithapplebgrm.png'