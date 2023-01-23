import 'package:entry_books/screens/book.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 50),
          Book(path: 'Atomic_Habits_James_Clear.pdf')
        ],
      ),
    );
  }
}

/*Widget book() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 80),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: SfPdfViewer.asset(
        'assets/Atomic Habits James Clear.pdf',
        scrollDirection: PdfScrollDirection.horizontal,
      ),
    ),
  );
}*/
