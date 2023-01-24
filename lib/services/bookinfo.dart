import 'dart:io';

import 'package:flutter/material.dart';

class BookInfo extends ChangeNotifier {
  File _file = File('path');
  int _pageNumber = 0;

  // Setting File
  set setFile(File newFile) {
    _file = newFile;
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
}
