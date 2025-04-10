import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Menú Adidas', style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              '¿Qué te gustaría hacer?',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            _buildMenuButton(context, 'Hablar con Adidas', '/asistente'),
            const SizedBox(height: 20),
            _buildMenuButton(context, 'Modo experiencia', '/experiencia'),
            const SizedBox(height: 20),
            _buildMenuButton(context, 'Fondo dinámico por color', '/dynamic-bg'),
          ],
        ),
      ),
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
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: Text(label),
      ),
    );
  }
}
