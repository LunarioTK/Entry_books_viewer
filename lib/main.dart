import 'package:entry_books/screens/home.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/panelstate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    );
  }
}
