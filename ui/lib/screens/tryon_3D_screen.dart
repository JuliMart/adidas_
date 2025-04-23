import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:html' as html;

class TryOn3DScreen extends StatelessWidget {
  // 🔗 URL de tu visor 3D en Vite vía ngrok, con bypass del warning
  final String url = "http://localhost:8080";

  TryOn3DScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'camera *; microphone *; fullscreen *; autoplay *';

    // 🧠 Registrar como vista web para Flutter Web
    // (evita duplicar el registro si ya existe)
    // ¡importante para hot reload!
    const viewType = 'tryon-iframe';
    ui.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => iframe,
    );

    return const Scaffold(
      backgroundColor: Colors.black,
      body: HtmlElementView(viewType: viewType),
    );
  }
}
