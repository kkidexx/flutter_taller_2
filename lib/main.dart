import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> chatHistory = [];
  List<Map<String, dynamic>> imageHistory = []; 
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = '';

  Map<String, String> predefinedResponses = {
    'hola': 'Hola, ¿cómo estás? ¿En qué puedo ayudarte?',
    'adiós': '¡Hasta luego! Espero haberte sido útil.',
    'ayuda': 'Puedes pedirme que suba una imagen o simplemente conversar.',
    'imagen': 'Para subir una imagen, presiona el botón "Subir Imagen".',
    'gracias': '¡De nada! Estoy aquí para ayudarte.',
    'default': 'Lo siento, no entiendo tu mensaje.',
    'cuanto es 2 + 2': 'La respuesta es 4.'
  };

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      print('Permiso de micrófono no concedido');
    }
  }

  void _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      DateTime now = DateTime.now();
      String formattedDateTime =
          '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}';

      setState(() {
        _imageBytes = result.files.first.bytes;
      
        Map<String, dynamic> imageData = {
          'image': _imageBytes,
          'timestamp': formattedDateTime,
        };

        imageHistory.add(imageData);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage(String message) {
    setState(() {
      DateTime now = DateTime.now();
      String formattedDateTime = '${now.hour}:${now.minute}';

      String trimmedMessage = message.trim().toLowerCase();
      String response = predefinedResponses.containsKey(trimmedMessage)
          ? predefinedResponses[trimmedMessage]!
          : predefinedResponses['default']!;

      Map<String, dynamic> messageData = {
        'message': message,
        'response': response,
        'timestamp': formattedDateTime,
      };

      chatHistory.add(messageData);
      _controller.clear();
    });
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
              if (val.hasConfidenceRating && val.confidence > 0) {
                _controller.text = _text;
              }
            });
            if (val.finalResult) {
              _sendMessage(_text); 
            }
          },
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _speech.stop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Container(
        color: Colors.blueGrey[900],
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading) CircularProgressIndicator(),
            Text(
              'Fecha actual: $formattedDate',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var item in chatHistory)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tú: ${item['message']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    item['timestamp'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Bot: ${item['response']}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    item['timestamp'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),
                    for (var imageItem in imageHistory)
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Imagen subida el ${imageItem['timestamp']}',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 179, 163, 209),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Image.memory(imageItem['image']),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                    ),
                    onSubmitted: (value) => _sendMessage(value),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: _isListening ? Colors.red : Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: _listen,
                ),
                IconButton(
                  icon: Icon(
                    Icons.upload_file,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: _pickImage,
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Colors.blueAccent,
                    size: 30,
                  ),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
