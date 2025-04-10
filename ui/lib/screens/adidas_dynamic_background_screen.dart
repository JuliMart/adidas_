import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdidasDynamicBackgroundScreen extends StatefulWidget {
  const AdidasDynamicBackgroundScreen({super.key});

  @override
  State<AdidasDynamicBackgroundScreen> createState() => _AdidasDynamicBackgroundScreenState();
}

class _AdidasDynamicBackgroundScreenState extends State<AdidasDynamicBackgroundScreen> {
  html.VideoElement? videoElement;
  html.CanvasElement? canvasElement;
  Timer? snapshotTimer;
  String? clothingColor;
  String? gesture;
  bool backgroundLocked = false;
  Color fixedColor = Colors.black;
  bool isProcessing = false;
  bool gestureHandled = false;

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
      if (videoElement == null || canvasElement == null || isProcessing) return;

      isProcessing = true;

      final ctx = canvasElement!.context2D;
      ctx.drawImage(videoElement!, 0, 0);

      final blob = await canvasElement!.toBlob('image/jpeg');
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob!);
      await reader.onLoad.first;
      final imageBytes = reader.result as Uint8List;

      await _sendToServer(imageBytes);

      isProcessing = false;
    });
  }

  Future<void> _sendToServer(Uint8List imageBytes) async {
    final uri = Uri.parse('http://localhost:8000/analyze?full_frame=true');
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
      final detectedGesture = data['gesture'];

      setState(() {
        clothingColor = data['color'];

        // solo gestiona thumbs_up y thumbs_down aquí
         
      });
    }
  }

  @override
  void dispose() {
    videoElement?.srcObject?.getTracks().forEach((track) => track.stop());
    videoElement?.remove();
    snapshotTimer?.cancel();
    super.dispose();
  }

  Color _getBackgroundColor() {
    if (clothingColor != null && clothingColor!.startsWith("#")) {
      try {
        return Color(int.parse(clothingColor!.substring(1), radix: 16) + 0xFF000000);
      } catch (_) {
        return Colors.black;
      }
    }
    return Colors.black;
  }

 @override
    Widget build(BuildContext context) {
    final backgroundColor = backgroundLocked ? fixedColor : _getBackgroundColor();

    return Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
        children: [
            Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                AnimatedScale(
                    scale: backgroundLocked ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                    onTap: () {
                        setState(() {
                        backgroundLocked = !backgroundLocked;
                        if (backgroundLocked) {
                            fixedColor = _getBackgroundColor();
                        }
                        });
                    },
                    child: Image.asset(
                        'assets/originals.png',
                        height: 300,
                        color: Colors.white,
                    ),
                    ),
                ),
                const SizedBox(height: 20),
                ],
            ),
            ),
            Positioned(
            top: 20,
            left: 20,
            child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/menu'),
                child: Icon(
                Icons.arrow_back_ios_new,
                color: backgroundColor.withOpacity(0.4), // mimetizado
                size: 28,
                ),
            ),
            ),
        ],
        ),
    );
  }
}


