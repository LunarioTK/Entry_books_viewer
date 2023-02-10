import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:entry_books/constants/panelplayer.dart';
import 'package:entry_books/constants/ttsplayer.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/gettext.dart';
import 'package:entry_books/services/playtts.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
//import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:provider/provider.dart';

class CurrenBook extends StatefulWidget {
  File file;
  CurrenBook({super.key, required this.file});

  @override
  State<CurrenBook> createState() => _CurrenBookState();
}

class _CurrenBookState extends State<CurrenBook> {
  final panelController = PanelController();
  AudioPlayer audioPlayer = AudioPlayer();
  TtsPlayer playTts = TtsPlayer();
  GetText getText = GetText();
  BookInfo bookInfo = BookInfo();

  FocusNode myfocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initTts();
  }

  void initTts() async {
    await getText.getText(bookInfo.getPageNumber, widget.file);
    await playTts.playBook('');
    audioPlayer.setSourceDeviceFile(playTts.getAudioFile.path);
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.90;
    var bookInfo = context.watch<BookInfo>();

    //final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    PdfViewerController controller = PdfViewerController();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SlidingUpPanel(
          maxHeight: panelHeightOpen,
          //onPanelClosed: () => isPanelOpen.setPanelOpen = false,
          onPanelOpened: () => initTts(),
          collapsed: Align(
            alignment: Alignment.bottomCenter,
            child: TTSPlayer(file: widget.file),
          ),
          panelBuilder: (controller) => PlayerWidget(
            player: audioPlayer,
            panelController: panelController,
            controller: controller,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 130),
                child: PdfViewer.openFile(
                  widget.file.path,
                  viewerController: controller,
                  params: PdfViewerParams(
                    onInteractionEnd: (details) {
                      bookInfo.setPageNumber = controller.currentPageNumber;
                    },
                    layoutPages: (viewSize, pages) {
                      List<Rect> rect = [];
                      final viewWidth = viewSize.width;
                      final viewHeight = viewSize.height;
                      final maxHeight = pages.fold<double>(0.0,
                          (maxHeight, page) => max(maxHeight, page.height));
                      final maxWidth = pages.fold<double>(
                          0.0, (maxWidth, page) => max(maxWidth, page.width));
                      final ratioHeigth = viewHeight / maxHeight;
                      final ratioWidth = viewWidth / maxWidth;
                      var top = 0.0;
                      for (var page in pages) {
                        final width = page.width * ratioWidth;
                        final height = page.height * ratioHeigth;
                        final left = viewWidth > viewHeight
                            ? (viewWidth / 2) - (width / 2)
                            : 0.0;
                        rect.add(Rect.fromLTWH(left, top, width, height));
                        top += height + 8;
                      }
                      return rect;
                    },
                  ),
                ),
              ),

              /*SfPdfViewer.file(
                widget.file,
                scrollDirection: PdfScrollDirection.horizontal,
                key: pdfViewerKey,
                controller: controller,
                canShowScrollHead: false,
                pageLayoutMode: PdfPageLayoutMode.single,
                onPageChanged: (details) {
                  bookInfo.setPageNumber = details.newPageNumber;
                },
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
