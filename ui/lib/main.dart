import 'package:flutter/material.dart';
import 'screens/adidas_welcome_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/adidas_dynamic_background_screen.dart';
import 'screens/adidas_campaign_generator_screen.dart';


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
        '/menu': (context) => const MenuScreen(), 
        '/dynamic-bg': (context) => const AdidasDynamicBackgroundScreen(),
        '/generar-campana-adidas': (context) => const AdidasCampaignGeneratorScreen(),

      },
    );
  }
}
