import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/gettext.dart';
import 'package:entry_books/services/panelstate.dart';
import 'package:entry_books/services/playtts.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter/material.dart';

class PlayerWidget extends StatefulWidget {
  final AudioPlayer player;
  final ScrollController controller;
  final PanelController panelController;

  const PlayerWidget(
      {super.key,
      required this.player,
      required this.controller,
      required this.panelController});

  @override
  State<StatefulWidget> createState() {
    return _PlayerWidgetState();
  }
}

class _PlayerWidgetState extends State<PlayerWidget> {
  final panelController = PanelController();
  GetText getText = GetText();
  TtsPlayer playTts = TtsPlayer();
  BookInfo bookInfo = BookInfo();

  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  bool get _isPlaying => _playerState == PlayerState.playing;

  bool get _isPaused => _playerState == PlayerState.paused;

  String? get _durationText =>
      playTts.getDuration?.toString().split('.').first ??
      _duration.toString().split('.').first;

  String? get _positionText =>
      playTts.getPosition?.toString().split('.').first ??
      _position.toString().split('.').first;

  // _position?.toString().split('.').first ??

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();
    // Use initial values from player
    _playerState = player.state;
    player.getDuration().then(
          (value) => setState(() {
            _duration = value;
          }),
        );
    player.getCurrentPosition().then(
          (value) => setState(() {
            _position = value;
          }),
        );
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
    playTts = context.watch<TtsPlayer>();
    player.seek(playTts.getPosition!);
    //_duration = playTts.getDuration ?? const Duration();
    //_position = playTts.getPosition ?? const Duration();
    return ListView(
      controller: widget.controller,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: <Widget>[
        const SizedBox(height: 12),
        buildHandle(),
        const SizedBox(height: 30),
        buildPlayer(),
      ],
    );
  }

  // Trace
  Widget buildHandle() => GestureDetector(
        onTap: (() => togglePanel(context)),
        child: Center(
          child: Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              )),
        ),
      );

  void togglePanel(BuildContext context) {
    var isPanelOpen = Provider.of<MyPanelState>(context, listen: false);

    if (widget.panelController.isPanelOpen) {
      widget.panelController.close();
      isPanelOpen.setPanelOpen = false;
    }
  }

  Widget buildPlayer() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 45),
          Container(
            height: 250,
            width: 280,
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(10),
              /*image: const DecorationImage(
                image: AssetImage('assetName'),
                fit: BoxFit.cover,
              ),*/
            ),
          ),
          const SizedBox(height: 40),
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
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                key: const Key('pause_button'),
                onPressed: _isPlaying ? _pause : null,
                iconSize: 40.0,
                icon: Icon(
                  Icons.pause,
                  color: _isPlaying ? Colors.black : Colors.grey,
                ),
                //color: Colors.grey,
              ),
              IconButton(
                key: const Key('play_button'),
                onPressed: _isPlaying ? null : _play,
                iconSize: 40.0,
                icon: const Icon(
                  Icons.play_arrow,
                ),
                color: Colors.black,
              ),
              IconButton(
                key: const Key('stop_button'),
                onPressed: /*_isPlaying || _isPaused ?*/ _stop,
                iconSize: 40.0,
                icon: Icon(
                  Icons.stop,
                  color: _isPlaying ? Colors.black : Colors.grey,
                ),
                //color: Colors.grey,
              ),
            ],
          ),
          Slider(
            activeColor: Colors.green.shade800,
            onChanged: (v) {
              final duration = _duration;
              //v = _position!.inMilliseconds.roundToDouble();
              if (duration == null) {
                return;
              }
              final position = v * duration.inMilliseconds;
              player.seek(Duration(milliseconds: position.round()));
            },
            value: (_position != null &&
                    _duration != null &&
                    _position!.inMilliseconds > 0 &&
                    _position!.inMilliseconds < _duration!.inMilliseconds)
                ? _position!.inMilliseconds / _duration!.inMilliseconds
                : 0.0,
          ),

          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _position.toString().split('.').first,
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  _duration.toString().split('.').first,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),

          /*Text(
            _position != null
                ? '$_positionText / $_durationText'
                : _duration != null
                    ? _durationText
                    : '',
            style: const TextStyle(fontSize: 16.0),
          ),*/
          //Text('State: ${_playerState ?? '-'}'),
        ],
      ),
    );
  }

  void _initStreams() {
    _durationSubscription = player.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });

    _positionSubscription = player.onPositionChanged.listen(
      (p) => setState(() => _position = p),
    );

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
    final position = _position;
    if (position != null && position.inMilliseconds > 0) {
      await player.seek(position);
    }
    await player.resume();
    setState(() => _playerState = PlayerState.playing);
  }

  Future<void> _pause() async {
    await player.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  Future<void> _stop() async {
    await player.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }
}
