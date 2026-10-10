import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() {
  runApp(const ProofPathAI());
}

class ProofPathAI extends StatelessWidget {
  const ProofPathAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'ProofPath AI',

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),

      home: const SplashScreen(),
    );
  }
}