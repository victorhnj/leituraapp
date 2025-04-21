import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() => runApp(LeituraApp());

class LeituraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leitura App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: MainScreen(), // 👈 Aqui está a correção!
    );
  }
}
