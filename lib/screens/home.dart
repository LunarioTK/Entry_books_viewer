import 'dart:io';

import 'package:entry_books/constants/book.dart';
import 'package:entry_books/constants/uicolor.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/hive_view_model.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int count = 0;
  File file = File('');
  List<int> indexs = [];
  final _box = Hive.box('books');
  BookViewModel bVM = BookViewModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (_box.get("BOOKLIST") != null) {
      bVM.loadData();
    } else {
      print('Empty');
    }
  }

  @override
  Widget build(BuildContext context) {
    var bookInfo = context.watch<BookInfo>();
    MediaQueryData media = MediaQuery.of(context);
    double height = media.size.height;
    double width = media.size.width;

    double ratio = media.size.height / media.size.width;
    late FilePickerResult? result;

    return Scaffold(
      backgroundColor: uiColor,
      body: SafeArea(
        child: Stack(
          children: [
            file.path == ''
                ? Container()
                : GridView.builder(
                    clipBehavior: Clip.none,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: height <= 600 ? 1 / 3 : 2 / 3,
                    ),
                    itemCount: bVM.bookList.length,
                    itemBuilder: (BuildContext context, int index) {
                      final book = bVM.bookList[index];
                      File bookFile = File(book.filePath);
                      return Book(
                        file: bookFile,
                        index: index,
                      );
                    },
                  ),
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
                      if (!bVM.bookList.contains({'', file.path})) {
                        bVM.addBooks(title: '', filePath: file.path);
                        bVM.updateData();
                      }
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