import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late html.VideoElement _videoElement;

  @override
  void initState() {
    super.initState();

    // Configurar video de fondo
    _videoElement = html.VideoElement()
      ..src = 'assets/jumpvi.mp4'
      ..autoplay = true
      ..loop = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    // Registrar el video como vista embebida
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'nikeVideoView',
      (int viewId) => _videoElement,
    );
  }

  Widget _buildMenuButton(BuildContext context, String label, String route) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => Navigator.pushNamed(context, route),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 20),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo de video sin animación
          const Positioned.fill(
            child: HtmlElementView(viewType: 'nikeVideoView'),
          ),

          // Menú sobre el video
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'NIKE EXPERIENCE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 80),
                  _buildMenuButton(context, 'ASISTENTE IA', '/asistente'),
                  const SizedBox(height: 20),
                  _buildMenuButton(context, 'GENERAR CAMPAÑA', '/generar-campana-adidas'),
                  const SizedBox(height: 20),
                  _buildMenuButton(context, 'FONDO DINÁMICO', '/dynamic-bg'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
