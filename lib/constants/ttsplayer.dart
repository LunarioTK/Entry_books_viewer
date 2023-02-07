import 'dart:convert';
import 'dart:io';

import 'package:entry_books/constants/uicolor.dart';
import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/openai_api.dart';
import 'package:flutter/material.dart';
import 'package:pdf_render/pdf_render_widgets.dart' as render;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdfdoc;

class TTSPlayer extends StatefulWidget {
  File file;
  TTSPlayer({super.key, required this.file});

  @override
  State<TTSPlayer> createState() => _TTSPlayerState();
}

class _TTSPlayerState extends State<TTSPlayer> {
  /*Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load(name);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }*/

  @override
  Widget build(BuildContext context) {
    String? chatResponse;
    var bookInfo = context.watch<BookInfo>();
    List<int> pageNumbers = [];
    AudioPlayer audioPlayer = AudioPlayer();
    List<String> pageTextList = [];
    File? fileAnt;
    bool isPlaying = false;
    bool hasFinished = false;
    String? text;

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

    void getResponse(String userQuest) async {
      APIKey apiKey = APIKey();
      String apiUrl = "https://api.openai.com/v1/completions";
      Map<String, String> headers = {
        "Content-type": "application/json",
        "Authorization": "Bearer ${apiKey.getChatGptApiKey}"
      };

      //! Change to text-davinci-002 later
      //* text-babbage-001
      Map<String, dynamic> body = {
        "prompt":
            'Explain this text to me by topic and as briefly as possible "$userQuest".',
        "model": "text-babbage-001",
        "max_tokens": 1200,
        "temperature": 0.0,
      };

      var response = await http.post(Uri.parse(apiUrl),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          chatResponse = (data["choices"][0]["text"]);
          showResult(chatResponse);
        });
      } else {
        setState(() {
          chatResponse = ("Erro: ${response.statusCode}");
          showResult(chatResponse);
        });
      }
    }

    Future<void> getText(int pageNumber) async {
      //pageNumbers.add(pageNumber);
      //Load an existing PDF document.
      pdfdoc.PdfDocument document = pdfdoc.PdfDocument(
          inputBytes: File(widget.file.path).readAsBytesSync());

      //Create a new instance of the PdfTextExtractor.
      pdfdoc.PdfTextExtractor extractor = pdfdoc.PdfTextExtractor(document);

      //Extract all the text from the document.
      text = extractor.extractText(
          startPageIndex: (pageNumber == 0 ? 0 : pageNumber - 1));
    }

    // Play audio
    void playBook(String pageText) async {
      APIKey apiKey = APIKey();
      String histId = '';
      String apiUrl =
          "https://api.elevenlabs.io/v1/text-to-speech/21m00Tcm4TlvDq8ikWAM";
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
      var responseHist =
          await http.get(Uri.parse(apiUrlHist), headers: headers);
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
      String getAudioHist =
          'https://api.elevenlabs.io/v1/history/$histId/audio';

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/audio.mp3');

      if (histId.isEmpty) {
        //userQuestList.add(userQuest);

        var response = await http.post(Uri.parse(apiUrl),
            headers: headers, body: json.encode(jsonData));

        final bytes = response.bodyBytes;

        await file.writeAsBytes(bytes);
        fileAnt = file;

        if (response.statusCode == 200) {
          audioPlayer.play(DeviceFileSource(file.path));
          isPlaying = true;
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
          audioPlayer.play(DeviceFileSource(file.path));
          isPlaying = true;
        } else {
          print("Erro: ${getAudioFromHist.statusCode}");
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        elevation: 10,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 380,
          height: 80,
          decoration: BoxDecoration(
            color: uiColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 13, top: 5, bottom: 5),
                child: TextButton(
                  onPressed: (() {
                    getText(bookInfo.getPageNumber);
                    audioPlayer.onPlayerComplete.listen((event) {
                      hasFinished = true;
                      isPlaying = false;
                      audioPlayer.release();
                    });
                    if (isPlaying == false) {
                      playBook(text!);
                    } else {
                      audioPlayer.pause();
                      isPlaying = false;
                    }
                  }),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    fixedSize: const Size(50, 80),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: render.PdfDocumentLoader.openFile(
                          widget.file.path,
                          pageNumber: 1,
                          pageBuilder: (context, textureBuilder, pageSize) =>
                              textureBuilder(
                            backgroundFill: true,
                            size: const Size(50, 120),
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: uiColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Text(
                    'Book name',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '02:24',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 130),
              IconButton(
                onPressed: (() {
                  getText(bookInfo.getPageNumber);
                  getResponse(text!);
                }),
                color: Colors.white,
                iconSize: 30,
                icon: const Icon(Icons.menu_book_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
