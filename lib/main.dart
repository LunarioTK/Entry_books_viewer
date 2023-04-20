import 'package:entry_books/models/bookmodel.dart';
import 'package:entry_books/screens/home.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/panelstate.dart';
import 'package:entry_books/services/playtts.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register the BookModelAdapter
  Hive.registerAdapter<BookModel>(BookModelAdapter());

  // Open box
  final box = await Hive.openBox('books');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BookInfo()),
        ChangeNotifierProvider(create: (context) => MyPanelState()),
        ChangeNotifierProvider(create: (context) => TtsPlayer()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}
