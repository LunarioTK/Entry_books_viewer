import 'package:hive_flutter/hive_flutter.dart';

class BookModel {
  final String? filePath;
  final String? title;
  final String? author;
  final int? bookId;

  BookModel({this.title, this.bookId, this.author, required this.filePath});
}

class BookModelAdapter extends TypeAdapter<BookModel> {
  @override
  final int typeId = 0; // Unique identifier for this type adapter

  @override
  BookModel read(BinaryReader reader) {
    // Deserialize the object from binary
    final title = reader.readString();
    final filePath = reader.readString();
    //final bookId = reader.readInt();

    return BookModel(title: title, filePath: filePath);
  }

  @override
  void write(BinaryWriter writer, BookModel obj) {
    // Serialize the object to binary
    writer.writeString(obj.title ?? '');
    //writer.writeInt(obj.bookId ?? 0);
    writer.writeString(obj.filePath ?? '');
  }
}
