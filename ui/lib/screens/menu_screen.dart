import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () {
            Navigator.pushNamed(context, '/');
            },
        ),
        ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 340),

            const SizedBox(height: 60),
            _buildMenuButton(context, '', '/asistente'),
            const SizedBox(height: 20),
            _buildMenuButton(context, '', '/generar-campana-adidas'),
            const SizedBox(height: 20),
            _buildMenuButton(context, 'FONDO DINÁMICO', '/dynamic-bg'),
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
