import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

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
  List<Map<String, String>> chatHistory = []; // Modified to store messages and responses

  Map<String, String> predefinedResponses = {
    'hola': 'Hola, ¿cómo estás? ¿En qué puedo ayudarte?',
    'adiós': '¡Hasta luego! Espero haberte sido útil.',
    'ayuda': 'Puedes pedirme que suba una imagen o simplemente conversar.',
    'imagen': 'Para subir una imagen, presiona el botón "Subir Imagen".',
    'gracias': '¡De nada! Estoy aquí para ayudarte.',
    'default': 'Lo siento, no entiendo tu mensaje.',
    'cuanto es 2 + 2': 'la respuesta es 4'
  };

  void _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imageBytes = result.files.first.bytes;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _imageBytes = null;
    });
  }

  void _sendMessage(String message) {
    setState(() {
      String trimmedMessage = message.trim().toLowerCase();
      String response;
      
      if (predefinedResponses.containsKey(trimmedMessage)) {
        response = predefinedResponses[trimmedMessage]!;
      } else {
        response = predefinedResponses['default']!;
      }
      
      Map<String, String> messageData = {
        'message': message,
        'response': response,
      };

      chatHistory.add(messageData);
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Container(
        color: Colors.blueGrey[900], // Fondo de color sólido
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              CircularProgressIndicator(),
            if (!_isLoading && _imageBytes == null)
              Text('No se ha subido ninguna imagen', style: TextStyle(color: Colors.white)),
            if (_imageBytes != null)
              Column(
                children: [
                  Image.memory(_imageBytes!),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _clearImage,
                    icon: Icon(Icons.undo),
                    label: Text('Deshacer Imagen'),
                  ),
                ],
              ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.upload_file),
              label: Text('Subir Imagen'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 179, 163, 209),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var item in chatHistory)
                              Container(
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
                                      style: TextStyle(fontSize: 18, color: Colors.black),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Bot: ${item['response']}',
                                      style: TextStyle(fontSize: 18, color: Colors.black),
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
                            Icons.send,
                            color: Colors.blueAccent, // Cambia el color del icono
                            size: 30, // Ajusta el tamaño del icono
                          ),
                          onPressed: () => _sendMessage(_controller.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
