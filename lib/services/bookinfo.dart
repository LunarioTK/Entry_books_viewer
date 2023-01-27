import 'dart:io';

import 'package:entry_books/models/bookmodel.dart';
import 'package:flutter/material.dart';

class BookInfo extends ChangeNotifier {
  File _file = File('path');
  int _pageNumber = 0;
  int _booksAdded = 0;
  final List<BookModel> _books = [];

  // Getting books available
  List<BookModel> get allBooks {
    return _books;
  }

  // Setting File
  set setFile(File newFile) {
    _file = newFile;
    _books.add(BookModel(bookId: getbooksAdded, file: newFile));
    notifyListeners();
  }

  // Getting File
  File get getFile {
    return _file;
  }

  // Setting Page Number
  set setPageNumber(int newPageNumber) {
    _pageNumber = newPageNumber;
    //notifyListeners();
  }

  // Getting Page Number
  int get getPageNumber {
    return _pageNumber;
  }

  // Setting Page Number
  set setbooksAdded(int newbooksAdded) {
    _booksAdded = newbooksAdded;
    notifyListeners();
  }

  // Getting Page Number
  int get getbooksAdded {
    return _booksAdded;
  }
}
