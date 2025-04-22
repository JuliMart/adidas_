import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker_web/image_picker_web.dart';

class AdidasCampaignGeneratorScreen extends StatefulWidget {
  const AdidasCampaignGeneratorScreen({super.key});

  @override
  State<AdidasCampaignGeneratorScreen> createState() => _AdidasCampaignGeneratorScreenState();
}

class _AdidasCampaignGeneratorScreenState extends State<AdidasCampaignGeneratorScreen> {
  Uint8List? _originalImage;
  Uint8List? _generatedImage;
  bool _isLoading = false;

  final String apiUrl = 'https://8953-34-125-220-68.ngrok-free.app/generar-campana-adidas'; // ← reemplazá por tu URL real

  Future<void> _uploadAndGenerate() async {
    final imageBytes = await ImagePickerWeb.getImageAsBytes();
    if (imageBytes == null) return;

    setState(() {
      _originalImage = imageBytes;
      _isLoading = true;
      _generatedImage = null;
    });

    final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
      ..files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: 'input.jpg'));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        setState(() => _generatedImage = responseData);
      } else {
        print('❌ Error en backend: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error al conectar: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Campaña Adidas con IA'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _uploadAndGenerate,
                icon: const Icon(Icons.upload),
                label: const Text("Subí tu foto"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
              ),
              const SizedBox(height: 20),
              if (_originalImage != null) ...[
                const Text("📷 Imagen original", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                Image.memory(_originalImage!, height: 180),
              ],
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_generatedImage != null) ...[
                const Text("🧢 Versión campaña Adidas", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                Image.memory(_generatedImage!, height: 240),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
