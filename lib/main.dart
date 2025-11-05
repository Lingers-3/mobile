import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/views/auth_gate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocketeer',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}
