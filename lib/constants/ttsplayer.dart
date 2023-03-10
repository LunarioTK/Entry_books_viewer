import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:entry_books/constants/uicolor.dart';
import 'package:entry_books/services/azureapi.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/getresponse.dart';
import 'package:entry_books/services/gettext.dart';
import 'package:entry_books/services/panelstate.dart';
import 'package:entry_books/services/playtts.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart' as render;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TTSPlayer extends StatefulWidget {
  File file;
  AudioPlayer audioPlayer = AudioPlayer();
  PanelController panelController = PanelController();
  TTSPlayer(
      {super.key,
      required this.file,
      required this.panelController,
      required this.audioPlayer});

  @override
  State<TTSPlayer> createState() => _TTSPlayerState();
}

class _TTSPlayerState extends State<TTSPlayer> {
  AudioPlayer get audioPlayer => widget.audioPlayer;

  late final render.PdfDocumentLoader pdfThumbnail =
      render.PdfDocumentLoader.openFile(
    widget.file.path,
    pageNumber: 1,
    pageBuilder: (context, textureBuilder, pageSize) => textureBuilder(
      backgroundFill: true,
      size: const Size(70, 100),
    ),
  );
  bool playButtonPressed = false;
  bool isPlaying = false;
  bool hasFinished = false;
  IconData iconData = Icons.play_arrow_rounded;

  PlayerState? _playerState;
  Duration _duration = const Duration();
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  //String get _durationText => _duration?.toString().split('.').first ?? '';

  String get _positionText {
    if (_duration.inHours >= const Duration(hours: 1).inHours) {
      return _position?.toString().split('.').first ?? '';
    } else {
      return _position?.toString().split('.').first.substring(2, 7) ?? '';
    }
  }

  // _position?.toString().split('.').first.substring(2, 7)
  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  PanelController get panelController => widget.panelController;

  /*Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load(name);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Use initial values from player
    _playerState = audioPlayer.state;
    _pause();
    //audioPlayer.seek(Duration.zero);
    audioPlayer.getDuration().then(
          (value) => setState(() {
            _duration = value!;
          }),
        );
    audioPlayer.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
    //_initStreams();
  }

  @override
  void setState(VoidCallback fn) {
    // Subscriptions only can be closed asynchronously,
    // therefore events can occur after widget has been disposed.
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    super.dispose();
  }

  void changeIcon(bool isButtonPressed) {
    setState(() {
      if (isButtonPressed) {
        iconData = Icons.pause;
      } else {
        iconData = Icons.play_arrow_rounded;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    GetText getText = GetText();
    TtsPlayer playTts = context.watch<TtsPlayer>();
    GetResponse getResponse = GetResponse();
    MediaQueryData media = MediaQuery.of(context);
    double height = media.size.height;
    double width = media.size.width;

    var bookInfo = context.watch<BookInfo>();
    var isPanelOpen = Provider.of<MyPanelState>(context, listen: false);

    //Duration getPosition = playTts.getPosition!;

    //String? text

    // Get position
    _positionSubscription = audioPlayer.onPositionChanged.listen(
      (p) => setState(() {
        _position = p;
        playTts.setPosition = p;
      }),
    );

    // Explain page with ChatGpt
    void showResult(String? text) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Explanation',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: uiColor,
              content: Scrollbar(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Text(
                    text!,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          });
    }

    // Test for azure ai voice
    void onPressThumbnailAzure(String text) async {
      http.Response response = await TextToSpeechApi.textToSpeech(text);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/audio.mp3');

      final bytes = response.bodyBytes;

      await file.writeAsBytes(bytes);

      await audioPlayer.play(DeviceFileSource(file.path));
    }

    // When you press the play button on tts player
    void onPressThumbnail() async {
      await getText.getText(bookInfo.getPageNumber, widget.file);

      // If audio has finished
      playTts.audioPlayer.onPlayerComplete.listen((event) {
        hasFinished = true;
        isPlaying = false;
        playTts.audioPlayer.release();
        setState(() {
          playButtonPressed = false;
          changeIcon(playButtonPressed);
        });
      });

      playTts.audioPlayer.getDuration();
      if (_isPlaying == false) {
        if (audioPlayer.source != null) {
          _play();
        } else {
          await playTts.playBook(getText.pdfText);
          //onPressThumbnailAzure(getText.pdfText);
          audioPlayer.play(DeviceFileSource(playTts.getAudioFile.path));
          setState(() => _playerState = PlayerState.playing);
        }
      } else {
        _pause();
      }
    }

    // Pdf Tumbnail
    Widget pdfTumbnail() {
      return GestureDetector(
        onTap: () {
          setState(() {
            playButtonPressed = _isPaused ? true : false;
            changeIcon(playButtonPressed);
          });
          onPressThumbnail();
        },
        child: Container(
          height: 70,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Center(
                child: pdfThumbnail,
              ),
              Center(
                child: Icon(
                  iconData,
                  size: 25,
                  color: uiColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    //! ---------- !\\
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        elevation: 10,
        color: uiColor,
        borderRadius: BorderRadius.circular(10),
        child: GestureDetector(
          onTap: () => widget.panelController.open(),
          child: Container(
            width: width,
            height: height * 0.15,
            decoration: BoxDecoration(
              color: uiColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Padding(
                padding: height <= 600
                    ? const EdgeInsets.only(bottom: 5)
                    : const EdgeInsets.only(top: 5, bottom: 5),
                child: pdfTumbnail(),
              ),
              title: const Text(
                'Book name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                _positionText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
              trailing: IconButton(
                onPressed: (() async {
                  await getText.getText(bookInfo.getPageNumber, widget.file);
                  await getResponse.getResponse(getText.pdfText);
                  showResult(getResponse.chatResponse);
                  //print(playTts.getPosition);
                }),
                color: Colors.white,
                iconSize: 30,
                icon: const Icon(Icons.menu_book_rounded),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initStreams() {
    //var playTts = context.watch<TtsPlayer>();
    _durationSubscription = audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
        //playTts.setDuration = duration;
      });
    });

    /*_positionSubscription = audioPlayer.onPositionChanged.listen(
      (p) => setState(() {
        _position = p;
        playTts.setPosition = p;
      }),
    );*/

    _playerCompleteSubscription = audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
        playButtonPressed = _isPaused ? true : false;
        changeIcon(playButtonPressed);
        //playTts.setPlayerState = PlayerState.completed;
      });
    });

    _playerStateChangeSubscription =
        audioPlayer.onPlayerStateChanged.listen((state) async {
      var positionOnStateChange = await audioPlayer.getCurrentPosition() ??
          const Duration(milliseconds: 0);
      setState(() {
        _playerState = state;
        //playTts.setPosition = positionOnStateChange;
        //playTts.setPlayerState = state;
      });
    });
  }

  Future<void> _play() async {
    final position = _position;
    if (position != null && position.inMilliseconds > 0) {
      await audioPlayer.seek(position);
    }
    await audioPlayer.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await audioPlayer.pause();
    //print(playTts.getPosition);
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await audioPlayer.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
