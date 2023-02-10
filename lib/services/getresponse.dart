import 'package:entry_books/services/openai_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GetResponse {
  String chatResponse = '';

  Future<void> getResponse(String userQuest) async {
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
      chatResponse = (data["choices"][0]["text"]);
    } else {
      chatResponse = ("Erro: ${response.statusCode}");
    }
  }
}
