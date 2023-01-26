import 'dart:io';

class BookModel {
  final File file;
  final String? bookName;
  final String? author;
  final int bookId;

  BookModel(
      {this.bookName, required this.bookId, this.author, required this.file});
}
