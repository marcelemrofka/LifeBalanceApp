import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'view/tela_inicial.dart';
import 'view/tela_agua.dart';
import 'view/tela_cadastro.dart';
import 'view/tela_senha.dart';
import 'view/tela_home.dart';
import 'view/tela_lembretes.dart';
import 'view/tela_exercicios.dart';

void main() {
  runApp(DevicePreview(enabled: true, builder: (context) => MyApp()));
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
      initialRoute: '/',
      routes: {
        '/': (context) => TelaInicial(),
        '/tela_home': (context) => TelaHome(),
        '/tela_agua': (context) => TelaAgua(),
        '/tela_cadastro': (context) => TelaCadastro(),
        '/tela_senha': (context) => TelaSenha(),
        '/tela_lembretes': (context) => TelaLembretes(), 
        '/tela_exercicios': (context) => TelaExercicios(), 
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => TelaInicial(),
        );
      },
    );
  }
}
