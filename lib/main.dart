import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:app/viewmodel/nutrition_vm.dart';
import 'package:app/viewmodel/auth_viewmodel.dart';  
import 'package:app/view/tela_inicial.dart';
import 'package:app/view/tela_agua.dart';
import 'package:app/view/tela_cadastro.dart';
import 'package:app/view/tela_senha.dart';
import 'package:app/view/tela_home.dart';
import 'package:app/view/tela_lembretes.dart';
import 'package:app/view/tela_exercicios.dart';
import 'package:app/view/tela_sono.dart';
import 'package:app/view/sobre.dart';
import 'package:app/view/tela_refeicao.dart';
import 'package:app/view/tela_historico_refeicao.dart';
import 'package:app/view/tela_perfil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NutritionViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()), 
      ],
      child: MyApp(),
    ),
  );
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
        '/tela_sono': (context) => TelaSono(),
        '/tela_perfil': (context) => TelaPerfil(),
        '/tela_sobre': (context) => TelaSobre(),
        '/tela_refeicao': (context) => TelaRefeicao(),
        '/tela_historico': (context) => TelaHistoricoRefeicoes(),
      },
    );
  }
}
