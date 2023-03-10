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
  PlayerState? _playerState;
  GetText getText = GetText();
  TtsPlayer playTts = TtsPlayer();
  BookInfo bookInfo = BookInfo();

  FocusNode myfocus = FocusNode();

  bool get _isPlaying => _playerState == PlayerState.playing;

  @override
  void initState() {
    super.initState();
    //initTts();
    playTts.setAudioFile = File('');
    PlayerState.paused;
  }

  @override
  void dispose() {
    super.dispose();
    //playTts.setIsAudioLoaded = false;
    audioPlayer.release();
    audioPlayer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final panelHeightOpen = MediaQuery.of(context).size.height * 0.90;
    MediaQueryData media = MediaQuery.of(context);
    var bookInfo = context.watch<BookInfo>();
    var playTts = Provider.of<TtsPlayer>(context, listen: true);
    //context.watch<TtsPlayer>();

    // Sets audio loaded to false when current book closed
    // This is called on dispose
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      playTts.setIsAudioLoaded = false;
    });

    void isOpenThenPlay() async {
      try {
        audioPlayer.setSourceDeviceFile(playTts.getAudioFile.path);
        if (audioPlayer.source.toString() != '') {
          if (audioPlayer.state == PlayerState.playing) {
            audioPlayer.resume();
          } else {
            audioPlayer.seek(playTts.getPosition!);
          }
        } else {
          await getText.getText(bookInfo.getPageNumber, widget.file);
          await playTts.playBook(getText.pdfText);
          audioPlayer.setSourceDeviceFile(playTts.getAudioFile.path);
        }
        //audioPlayer.resume();
        playTts.setIsAudioLoaded = true;
      } catch (e) {
        print("Couldn't play audiobook");
      }
    }

    //final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    PdfViewerController pdfController = PdfViewerController();

    List<int> pagesViewed = [];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SlidingUpPanel(
          controller: panelController,
          maxHeight: panelHeightOpen,
          onPanelClosed: () => playTts.setIsAudioLoaded = false,
          onPanelOpened: () => isOpenThenPlay(),
          key: const Key('Sliding_panel'),
          collapsed: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TTSPlayer(
                file: widget.file,
                panelController: panelController,
                audioPlayer: audioPlayer,
              ),
            ),
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          panelBuilder: (controller) => PlayerWidget(
            isAudioLoaded: playTts.isAudioLoaded,
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
                  viewerController: pdfController,
                  params: PdfViewerParams(
                    pageNumber: 6,
                    onInteractionEnd: (details) {
                      // Clearing list if theres 2 items added
                      /*if (pagesViewed.length == 2) {
                        int lastPage = pagesViewed.last;
                        pagesViewed.clear();
                        pagesViewed.add(lastPage);

                        print('Last page: ${pagesViewed.last}');
                        print('Length: ${pagesViewed.length}');
                      }*/

                      if (pagesViewed.isEmpty) {
                        pagesViewed.add(pdfController.currentPageNumber);
                        bookInfo
                            .setStreamPages(pdfController.currentPageNumber);
                        bookInfo.setPageNumber =
                            pdfController.currentPageNumber;
                      } else {
                        if (!pagesViewed
                            .contains(pdfController.currentPageNumber)) {
                          pagesViewed.add(pdfController.currentPageNumber);
                          bookInfo
                              .setStreamPages(pdfController.currentPageNumber);
                          bookInfo.setPageNumber =
                              pdfController.currentPageNumber;
                        }
                      }
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
            ],
          ),
        ),
      ),
    );
  }
}
