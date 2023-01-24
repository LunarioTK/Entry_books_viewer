import 'package:entry_books/constants/ttsplayer.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';

class CurrenBook extends StatefulWidget {
  const CurrenBook({super.key});

  @override
  State<CurrenBook> createState() => _CurrenBookState();
}

class _CurrenBookState extends State<CurrenBook> {
  TextEditingController userMessage = TextEditingController();
  FocusNode myfocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    var bookInfo = context.watch<BookInfo>();

    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    PdfViewerController controller = PdfViewerController();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Transform.scale(
              scaleY: 1.25,
              origin: const Offset(0.0, 200.0),
              child: SfPdfViewer.file(
                bookInfo.getFile,
                scrollDirection: PdfScrollDirection.horizontal,
                key: pdfViewerKey,
                controller: controller,
                canShowScrollHead: false,
                pageLayoutMode: PdfPageLayoutMode.single,
                onPageChanged: (details) {
                  bookInfo.setPageNumber = details.newPageNumber;
                },
              ),
            ),
            const Align(
              alignment: Alignment.bottomCenter,
              child: TTSPlayer(),
            ),
          ],
        ),
      ),
    );
  }
}
