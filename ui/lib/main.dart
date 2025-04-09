import 'package:flutter/material.dart';
import 'screens/adidas_welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adidas Kiosk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const AdidasWelcomeScreen(),
        // '/menu': (context) => const MenuScreen(),  <-- luego agregamos esto
      },
    );
  }
}
