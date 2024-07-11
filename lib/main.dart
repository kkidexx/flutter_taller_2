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

  Future<void> _pickImage() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://static.vecteezy.com/system/resources/previews/012/466/836/non_2x/pretty-nebula-galaxy-astrology-deep-outer-space-cosmos-background-beautiful-abstract-illustration-art-dust-free-photo.jpg'), // Reemplaza con la URL de tu imagen
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Chatbot',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    if (_isLoading)
                      CircularProgressIndicator(), // Icono de cargando
                    if (!_isLoading && _imageBytes == null)
                      Text('No se ha subido ninguna imagen', style: TextStyle(color: Colors.white)),
                    if (_imageBytes != null)
                      Column(
                        children: [
                          Image.memory(_imageBytes!),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _clearImage,
                            icon: Icon(Icons.undo), // Icono de deshacer
                            label: Text('Deshacer Imagen'),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.upload_file),
                      label: Text(
                        'Subir Imagen',
                        style: TextStyle(color: Color.fromARGB(255, 75, 105, 238)), // Color del texto del botón
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
