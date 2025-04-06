import 'package:app/widgets/carrossel.dart';
import 'package:app/widgets/dashboard.dart';
import 'package:app/widgets/drawer.dart';
import 'package:app/widgets/menu.dart';
import 'package:flutter/material.dart';

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      body: Center (
       child: Column(
        children: [
          const SizedBox(height: 45),
          const Menu(),
          const Dashboard(),
          const SizedBox(height: 10),
          const Carrossel(), 
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/tela_refeicao');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF43644A), // cor de fundo (verde, por exemplo)
              foregroundColor: Colors.white, // cor do texto
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // bordas arredondadas
              ),
              elevation: 2, // sombra
            ),
            child: Text('Cadastre sua refeição'),
          )

        ],
      ),
    ),
    );
  }
}
