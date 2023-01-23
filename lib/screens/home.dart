import 'dart:io';

import 'package:entry_books/screens/book.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File file = File('');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
                      });
                    }
                  }),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                )
              : Book(path: file),
        ],
      ),
    );
  }
}
