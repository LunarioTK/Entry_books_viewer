import 'dart:io';

import 'package:entry_books/constants/ttsplayer.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CurrenBook extends StatefulWidget {
  File path;
  CurrenBook({super.key, required this.path});

  @override
  State<CurrenBook> createState() => _CurrenBookState();
}

class _CurrenBookState extends State<CurrenBook> {
  TextEditingController userMessage = TextEditingController();
  FocusNode myfocus = FocusNode();

  @override
  Widget build(BuildContext context) {
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
                widget.path,
                scrollDirection: PdfScrollDirection.horizontal,
                key: pdfViewerKey,
                controller: controller,
                canShowScrollHead: false,
                pageLayoutMode: PdfPageLayoutMode.single,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TTSPlayer(
                page: controller.pageNumber,
                path: widget.path,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
