import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange)
            .copyWith(
                secondary: Colors.deepOrangeAccent), // Set the accent color
      ),
      home: VoiceInputScreen(),
    );
  }
}

class VoiceInputScreen extends StatefulWidget {
  @override
  _VoiceInputScreenState createState() => _VoiceInputScreenState();
}

class _VoiceInputScreenState extends State<VoiceInputScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  String _text = 'Pressione o botão ou digite para tirar a sua dúvida.';
  String _answer = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CareConnect',
          style: GoogleFonts.openSans(),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VoiceInputBox(
                  onChanged: (text) {
                    setState(() {
                      _text = text;
                    });
                  },
                ),
                SizedBox(height: 20),
                Text(
                  _text,
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _listen,
                  child: Text(
                    _isListening ? 'Parar de Escutar' : 'Começar a escutar',
                    style: GoogleFonts.openSans(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _openAIRequest(_text);
                  },
                  child: Text(
                    'Obter Resposta',
                    style: GoogleFonts.openSans(),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  _answer,
                  style: GoogleFonts.openSans(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _speak(_answer);
                  },
                  child: Text(
                    'Ler Resposta',
                    style: GoogleFonts.openSans(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      // ... (existing code)
    } else {
      setState(() {
        _isListening = false;
        _text = 'Pressione o botão ou digite para tirar a sua dúvida.';
        _answer = ''; // Reset the answer when starting a new conversation
      });
      _speech.stop();
    }
  }

  Future<void> _openAIRequest(String input) async {
    try {
      final response = await OpenAiService().chatGPTApi(input);

      setState(() {
        _answer = utf8
            .decode(response.runes.toList()); // Explicitly decode using UTF-8
      });
    } catch (e) {
      print('Error during OpenAI API request: $e');
      setState(() {
        _answer = 'Failed to get response';
      });
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("pt-BR"); // Brazilian Portuguese language
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }
}

class VoiceInputBox extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const VoiceInputBox({Key? key, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: GoogleFonts.openSans(),
      decoration: InputDecoration(
        hintText: 'Escreva ou fale!',
        hintStyle: GoogleFonts.openSans(color: Colors.grey),
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

class OpenAiService {
  final List<Map<String, String>> messages = [
    {
      "role": "user",
      "content":
          "Limit the response to 150 words. Always say at the start that your CareConnect's Inteligência Artificial. You're going to help people with basic medical questions in an app called CareConnect. Answer the question with basic instructions and general advice. Always mention that if in doubt, the person should consult medical advice from a certified doctor. All this will be in Portuguese.",
    },
  ];

  Future<String> chatGPTApi(String prompt) async {
    messages.add({
      "role": "user",
      "content": prompt,
    });

    try {
      const apiKey = 'xxxxxxxxxxxxxx';
      const endpoint = "https://api.openai.com/v1/chat/completions";

      final res = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'Accept-Charset': 'utf-8', // Add this line to set the charset
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': messages,
        }),
      );

      if (res.statusCode == 200) {
        String response =
            jsonDecode(res.body)['choices'][0]['message']['content'];
        response = response.trim();

        messages.add({
          "role": "assistant",
          "content": response,
        });

        return response;
      } else {
        print('Error Response: ${res.body}');
        throw Exception('Failed to fetch a response from OpenAI API');
      }
    } catch (error) {
      return error.toString();
    }
  }
}
