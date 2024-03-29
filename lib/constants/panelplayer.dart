import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/panelstate.dart';
import 'package:entry_books/services/playtts.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  late bool? isAudioLoaded;
  final ScrollController controller;
  final PanelController panelController;

  PlayerWidget({
    super.key,
    required this.player,
    required this.controller,
    this.isAudioLoaded,
    required this.panelController,
  });

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  final debouncer = PublishSubject<double>();
  double _sliderValue = 0.0;

  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  //String get _durationText => _duration?.toString().split('.').first ?? '';

  //String get _positionText => _position?.toString().split('.').first ?? '';

  AudioPlayer get player => widget.player;
  PanelController get panelController => widget.panelController;

  // Play button
  Widget playButton() {
    bool isAudioLoaded =
        Provider.of<TtsPlayer>(context, listen: false).isAudioLoaded;
    return isAudioLoaded == false
        ? Container(
            margin: const EdgeInsets.all(10.0),
            width: 25.0,
            height: 25.0,
            child: const CircularProgressIndicator(
              color: Colors.grey,
            ),
          )
        : IconButton(
            key: const Key('play_button'),
            onPressed: _isPlaying && isAudioLoaded ? null : _play,
            iconSize: 40.0,
            icon: Icon(
              Icons.play_arrow,
              color: !_isPlaying && isAudioLoaded ? Colors.black : Colors.grey,
            ),
            color: Colors.grey,
          );
  }

  // Pause button
  Widget pauseButton() {
    bool isAudioLoaded =
        Provider.of<TtsPlayer>(context, listen: false).isAudioLoaded;
    return IconButton(
      key: const Key('pause_button'),
      onPressed: _isPlaying && isAudioLoaded ? _pause : null,
      iconSize: 40.0,
      icon: Icon(
        Icons.pause,
        color: _isPlaying ? Colors.black : Colors.grey,
      ),
    );
  }

  // Stop button
  Widget stopButton() {
    bool isAudioLoaded =
        Provider.of<TtsPlayer>(context, listen: false).isAudioLoaded;

    return IconButton(
      key: const Key('stop_button'),
      onPressed: _isPlaying && isAudioLoaded || _isPaused && isAudioLoaded
          ? _stop
          : null,
      iconSize: 40.0,
      icon: Icon(
        Icons.stop,
        color: _isPlaying && isAudioLoaded || _isPaused && isAudioLoaded
            ? Colors.black
            : Colors.grey,
      ),
    );
  }

  /*void playAudioIfOpen() async {
    GetText getText = GetText();
    TtsPlayer playTts = TtsPlayer();
    BookInfo bookInfo = BookInfo();

    if (panelController.isPanelOpen) {
      await getText.getText(bookInfo.getPageNumber, bookInfo.getFile);
      await playTts.playBook(getText.pdfText);
      await player.setSourceDeviceFile(playTts.getAudioFile.path);
    }
  }*/

  @override
  void initState() {
    super.initState();

    // Use initial values from player
    _playerState = player.state;
    _initStreams();
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

  @override
  Widget build(BuildContext context) {
    final panelHeight = MediaQuery.of(context).size.height;
    var panelState = context.watch<MyPanelState>().getPanelOpen;
    return ListView(
      controller: widget.controller,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: <Widget>[
        const SizedBox(height: 15),
        buildHandle(panelState),
        buildPlayer(panelHeight, context),
      ],
    );
  }

  // Trace
  Widget buildHandle(var isPanelOpen) {
    return Center(
      child: GestureDetector(
        onTap: () {
          panelController.isPanelOpen || isPanelOpen
              ? panelController.close()
              : panelController.open();
        },
        child: Container(
          width: 40,
          height: 6,
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget buildPlayer(double heightSize, BuildContext context) {
    return Consumer<TtsPlayer>(
      builder: (context, ttsPlayer, _) {
        return Padding(
          padding: EdgeInsets.only(
              top: (heightSize < 780 && heightSize >= 600)
                  ? heightSize * 0.09
                  : heightSize * 0.12,
              bottom: heightSize * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const BookThumbnail(),
              SizedBox(height: heightSize <= 600 ? 10 : 20),
              const Text(
                'Book Name',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Author Name'),
              SizedBox(height: heightSize <= 600 ? 10 : 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  pauseButton(),
                  playButton(),
                  stopButton(),
                ],
              ),
              Padding(
                padding: heightSize <= 600
                    ? const EdgeInsets.only(left: 40, right: 40)
                    : const EdgeInsets.only(left: 50, right: 50, top: 20),
                child: ProgressBar(
                  total: _duration ?? Duration.zero,
                  baseBarColor: Colors.grey,
                  thumbColor: Colors.black,
                  progressBarColor: Colors.black,
                  onSeek: (time) {
                    player.seek(
                        Duration(milliseconds: time.inMilliseconds.round()));
                  },
                  progress: Duration(
                    milliseconds: (_position != null &&
                            _duration != null &&
                            _position!.inMilliseconds > 0 &&
                            _position!.inMilliseconds <
                                _duration!.inMilliseconds)
                        ? _position!.inMilliseconds
                        : 0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /*_PlayerWidgetState() {
    debouncer.stream
        .debounceTime(const Duration(milliseconds: 500))
        .listen((value) {
      if (_duration != null) {
        final position = _duration! * value;
        player.seek(position);
      }
    });
  }*/

  void _initStreams() {
    _positionSubscription =
        player.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
        if (_duration != null) {
          _sliderValue = (_position!.inMilliseconds / _duration!.inMilliseconds)
              .clamp(0.0, 1.0);
        }
      });
    });

    _durationSubscription =
        player.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
        if (_position != null) {
          _sliderValue = (_position!.inMilliseconds / _duration!.inMilliseconds)
              .clamp(0.0, 1.0);
        }
      });
    });

    /*_durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );*/

    _playerCompleteSubscription = player.onPlayerComplete.listen((event) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });

    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });
  }

  Future<void> _play() async {
    var pagePlaying = Provider.of<BookInfo>(context, listen: false);
    final position = _position;
    if (position != null && position.inMilliseconds > 0) {
      await player.seek(position);
    }
    await player.resume();
    setState(() {
      _playerState = PlayerState.playing;
      pagePlaying.setPagePlaying = pagePlaying.getPageNumber;
      //player.state = PlayerState.playing;
    });
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() {
      _playerState = PlayerState.paused;
    });
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}

// Book Thumbnail
class BookThumbnail extends StatelessWidget {
  const BookThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    var bookInfo = context.watch<BookInfo>();
    final panelHeight = MediaQuery.of(context).size.height;

    return Container(
      key: const Key('Thumbnail_container'),
      height: panelHeight <= 600 ? 160 : 340,
      width: panelHeight <= 600 ? 240 : 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.blue,
      ),
      child: PdfDocumentLoader.openFile(
        bookInfo.getFile.path,
        key: const Key('Thumbnail_panel'),
        pageNumber: 1,
        pageBuilder: (context, textureBuilder, pageSize) => textureBuilder(
          size: Size(
            panelHeight <= 600 ? 240 : 300, // width
            panelHeight <= 600 ? 160 : 315, // heigth
          ),
        ),
      ),
    );
  }
}
