import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdidasWelcomeScreen extends StatefulWidget {
  const AdidasWelcomeScreen({super.key});

  @override
  State<AdidasWelcomeScreen> createState() => _AdidasWelcomeScreenState();
}

class _AdidasWelcomeScreenState extends State<AdidasWelcomeScreen> {
  html.VideoElement? videoElement;
  html.CanvasElement? canvasElement;
  Timer? snapshotTimer;
  String? detectedAge;
  String? clothingColor;
  String? gesture;

  @override
  void initState() {
    super.initState();
    _startCamera();
    _startProcessing();
  }

  void _startCamera() async {
    final stream = await html.window.navigator.mediaDevices!.getUserMedia({
      'video': {'facingMode': 'user'},
    });
    videoElement = html.VideoElement()
      ..autoplay = true
      ..srcObject = stream
      ..style.display = 'none';

    html.document.body!.append(videoElement!);
    canvasElement = html.CanvasElement(width: 640, height: 480);
  }

  void _startProcessing() {
    snapshotTimer = Timer.periodic(Duration(seconds: 2), (_) async {
      if (videoElement == null || canvasElement == null) return;

      final ctx = canvasElement!.context2D;
      ctx.drawImage(videoElement!, 0, 0);

      final blob = await canvasElement!.toBlob('image/jpeg');
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob!);
      await reader.onLoad.first;
      final imageBytes = reader.result as Uint8List;

      await _sendToServer(imageBytes);
    });
  }

  Future<void> _sendToServer(Uint8List imageBytes) async {
    final uri = Uri.parse('http://localhost:8000/analyze');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'frame.jpg',
        ),
      );

    final response = await request.send();
    if (response.statusCode == 200) {
      final data = jsonDecode(await response.stream.bytesToString());
      setState(() {
        detectedAge = data['age_range'];
        clothingColor = data['color'];
        gesture = data['gesture'];
      });

      if (gesture == 'sign_continue') {
        Navigator.pushNamed(context, '/menu');
      }
    }
  }

  @override
  void dispose() {
    videoElement?.srcObject?.getTracks().forEach((track) => track.stop());
    videoElement?.remove();
    snapshotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/adidas_logo_white.png', height: 100),
            const SizedBox(height: 20),
            Text(
              detectedAge != null && clothingColor != null
                  ? 'Hola $detectedAge! Hoy proyectás energía con ese color $clothingColor.'
                  : 'Detectando perfil con IA...',
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/menu'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 20),
              ),
              child: const Text('Continuar'),
            )
          ],
        ),
      ),
    );
  }
}
