import 'package:flutter/material.dart';
import 'tela_inicial.dart';
import 'tela_agua.dart';
import 'tela_cadastro.dart';
import 'tela_senha.dart';
import 'tela_home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meu App',
      theme: ThemeData(
        primaryColor: Color(0xFF43644A),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF43644A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/',  // Agora começa pela TelaInicial
      routes: {
        '/': (context) => TelaInicial(),
        '/tela_home': (context) => TelaHome(),
        '/tela_agua': (context) => TelaAgua(),
        '/tela_cadastro': (context) => TelaCadastro(),
        '/tela_senha': (context) => TelaSenha(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => TelaInicial(),
        );
      },
    );
  }
}
