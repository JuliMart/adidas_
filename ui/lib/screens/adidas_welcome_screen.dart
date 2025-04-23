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
  bool colorLocked = false;
  String? fixedColor;

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
    snapshotTimer = Timer.periodic(Duration(milliseconds: 50), (_) async {
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
        gesture = data['gesture'];
        if (!colorLocked) {
          clothingColor = data['color'];
        }
      });

      if (gesture == 'sign_hello') {
        Navigator.pushReplacementNamed(context, '/menu');
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

  Color _getAdaptiveLogoColor() {
    final hex = colorLocked ? fixedColor : clothingColor;
    if (hex != null && hex.startsWith("#")) {
      try {
        return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
      } catch (_) {
        return Colors.white;
      }
    }
    return Colors.white;
  }

  void _toggleColorLock() {
    setState(() {
      if (colorLocked) {
        colorLocked = false;
        fixedColor = null;
      } else {
        colorLocked = true;
        fixedColor = clothingColor;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final logoColor = _getAdaptiveLogoColor();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: colorLocked ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: GestureDetector(
                    onTap: _toggleColorLock,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(logoColor, BlendMode.srcIn),
                      child: Image.asset('assets/originals.png', height: 500),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          // ✅ Botón flotante en la esquina inferior derecha
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/menu');
              },
              tooltip: 'Ir al menú',
              child: const Icon(Icons.arrow_forward),
            ),
          ),
        ],
      ),
    );
  }
}
