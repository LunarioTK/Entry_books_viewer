import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:entry_books/services/openai_api.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class TtsPlayer extends ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer();
  late File _audioFile = File('');
  Duration _position = const Duration();
  Duration _duration = const Duration();
  PlayerState _playerState = PlayerState.paused;

  // Play audio
  Future<void> playBook(String pageText) async {
    //var bookInfo = BookInfo();

    APIKey apiKey = APIKey();
    String histId = '';
    String apiUrl =
        "https://api.elevenlabs.io/v1/text-to-speech/oBblmJ2l8wOCsMUauDcR";
    String apiUrlHist = "https://api.elevenlabs.io/v1/history";

    Map<String, String> headers = {
      'accept': 'audio/mpeg',
      'xi-api-key': apiKey.getElevenLabsApiKey,
      'Content-Type': 'application/json',
    };

    Map<String, dynamic> jsonData = {
      'text': pageText,
    };

    //print(data['history'][0]['history_item_id']);

    // Get History
    var responseHist = await http.get(Uri.parse(apiUrlHist), headers: headers);
    Map<String, dynamic> data =
        json.decode(utf8.decode(responseHist.bodyBytes));

    List<dynamic> dataAll = data['history'];

    for (var element in dataAll) {
      Map<String, dynamic> every = element;
      every.forEach((key, value) {
        if (key == 'text' &&
            value.toString().toUpperCase() == pageText.toUpperCase()) {
          histId = every['history_item_id'];
        }
      });
    }
    String getAudioHist = 'https://api.elevenlabs.io/v1/history/$histId/audio';

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/audio.mp3');

    if (histId.isEmpty) {
      //userQuestList.add(userQuest);

      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: json.encode(jsonData));

      final bytes = response.bodyBytes;

      await file.writeAsBytes(bytes);

      if (response.statusCode == 200) {
        await audioPlayer.setSourceDeviceFile(file.path);
        setAudioFile = file;
      } else {
        print("Erro: ${response.statusCode}");
      }
    } else {
      //print('In History');
      var getAudioFromHist =
          await http.get(Uri.parse(getAudioHist), headers: headers);

      final bytes = getAudioFromHist.bodyBytes;

      await file.writeAsBytes(bytes);

      if (getAudioFromHist.statusCode == 200) {
        await audioPlayer.setSourceDeviceFile(file.path);
        setAudioFile = file;
      } else {
        print("Erro: ${getAudioFromHist.statusCode}");
      }
    }
  }

  // Set audio file
  set setAudioFile(File audioFile) {
    _audioFile = audioFile;
    //notifyListeners();
  }

  // Get audio file
  File get getAudioFile {
    return _audioFile;
  }

  // Set duration
  set setDuration(Duration duration) {
    _duration = duration;
    //notifyListeners();
  }

  // Get duration
  Duration? get getDuration {
    return _duration;
  }

  // Set position
  set setPosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  // Get position
  Duration? get getPosition {
    return _position;
  }

  // Set player state
  set setPlayerState(PlayerState playerState) {
    _playerState = playerState;
    //notifyListeners();
  }

  // Get player state
  PlayerState get getPlayerState {
    return _playerState;
  }
}
