import 'dart:io';

import 'package:entry_books/constants/ttsplayer.dart';
import 'package:sizer/sizer.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';

class CurrenBook extends StatefulWidget {
  File file;
  CurrenBook({super.key, required this.file});

  @override
  State<CurrenBook> createState() => _CurrenBookState();
}

class _CurrenBookState extends State<CurrenBook> {
  TextEditingController userMessage = TextEditingController();
  FocusNode myfocus = FocusNode();
  int initPage = 0;

  @override
  void initState() {
    super.initState();
    SizerUtil.width = 50;
    SizerUtil.height = 50;
  }

  @override
  Widget build(BuildContext context) {
    var bookInfo = context.watch<BookInfo>();

    final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    PdfViewerController controller = PdfViewerController();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Transform.scale(
                scaleY: 2.50.h,
                origin: Offset(0.0.w, 0.1.h),
                child: SfPdfViewer.file(
                  widget.file,
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
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: TTSPlayer(file: widget.file),
            ),
          ],
        ),
      ),
    );
  }
}
