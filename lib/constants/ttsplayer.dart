import 'dart:convert';
import 'dart:io';

import 'package:entry_books/services/bookinfo.dart';
import 'package:entry_books/services/openai_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:pdf_render/pdf_render_widgets.dart' as render;

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as pdfdoc;

class TTSPlayer extends StatefulWidget {
  const TTSPlayer({super.key});

  @override
  State<TTSPlayer> createState() => _TTSPlayerState();
}

class _TTSPlayerState extends State<TTSPlayer> {
  Future<List<int>> _readDocumentData(String name) async {
    final ByteData data = await rootBundle.load(name);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  Widget build(BuildContext context) {
    String? chatResponse;
    var bookInfo = context.watch<BookInfo>();

    void showResult(String? text) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Explanation'),
              content: Scrollbar(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: Text(text!),
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
        "Authorization": "Bearer ${apiKey.getApiKey}"
      };

      //! Change to text-davinci-002 later
      Map<String, dynamic> body = {
        "prompt":
            'Explica-me este texto por topicos e o mais resumido possivel "$userQuest", em português',
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

    Future<void> explainPage(int pageNumber) async {
      //Load an existing PDF document.
      pdfdoc.PdfDocument document = pdfdoc.PdfDocument(
          inputBytes: File(bookInfo.getFile.path).readAsBytesSync());

      /*pdfdoc.PdfDocument document = pdfdoc.PdfDocument(
          inputBytes: await _readDocumentData(widget.file.path));*/

      //Create a new instance of the PdfTextExtractor.
      pdfdoc.PdfTextExtractor extractor = pdfdoc.PdfTextExtractor(document);

      //Extract all the text from the document.
      String text = extractor.extractText(startPageIndex: (pageNumber + 1));

      getResponse(text);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Material(
        elevation: 10,
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 360,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: TextButton(
              onPressed: (() {}),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                fixedSize: const Size(20, 120),
              ),
              child: Stack(
                children: [
                  Center(
                    child: render.PdfDocumentLoader.openFile(
                      bookInfo.getFile.path,
                      pageNumber: 1,
                      pageBuilder: (context, textureBuilder, pageSize) =>
                          textureBuilder(
                        backgroundFill: true,
                        size: const Size(50, 70),
                      ),
                    ),
                  ),
                  const Center(
                      child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.black,
                  )),
                ],
              ),
            ),
            title: const Text('Book name'),
            subtitle: const Text('02:24'),
            trailing: IconButton(
              onPressed: (() {
                explainPage(bookInfo.getPageNumber);
              }),
              color: Colors.black,
              iconSize: 30,
              icon: const Icon(Icons.menu_book_rounded),
            ),
          ),
        ),
      ),
    );
  }
}
