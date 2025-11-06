import 'package:app/view/tela_cadastro_paciente.dart';
import 'package:app/view/tela_home_nutri.dart';
import 'package:app/view/tela_pacientes.dart';
import 'package:app/view/tela_perfil_nutri.dart';
import 'package:app/viewmodel/cadastro_viewmodel.dart';
import 'package:app/widgets/planos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app/viewmodel/nutrition_vm.dart';
import 'package:app/viewmodel/auth_viewmodel.dart';
import 'package:app/viewmodel/refeicao_vm.dart';
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
import 'package:app/view/tela_analise_calorias.dart';
import 'package:app/view/tela_detalhes_refeicao.dart';

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
        ChangeNotifierProvider(create: (_) => RefeicaoViewModel()),
        ChangeNotifierProvider(
          create: (_) => CadastroViewModel(),
          child: TelaCadastroPaciente(),
        )
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
        primaryColor: const Color(0xFF43644A),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF43644A),
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
        '/tela_home_nutri': (context) => TelaHomeNutri(),
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
        '/tela_analise_calorias': (context) => TelaAnaliseCalorias(),
        '/tela_pacientes': (context) => TelaPacientes(),
        '/tela_cadastro_pacientes': (context) => TelaCadastroPaciente(),
        '/tela_perfil_nutri': (context) => TelaPerfilNutri(),
        '/planos': (context) => const Planos('pro'),
        // '/tela_detalhes_refeicao': (context) => const TelaDetalhesRefeicao(refeicaoId: ''), 
      },
    );
  }
}
