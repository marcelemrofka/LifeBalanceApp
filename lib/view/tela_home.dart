import 'package:app/utils/color.dart';
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
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.verdeNeutro),
        actions: const [Menu(), ],
      ),
      drawer: CustomDrawer(),
      body: Center(
        child: Column(
          children: [
            const Dashboard(),
            const SizedBox(height: 10),
            const Carrossel(),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {Navigator.pushNamed(context, '/tela_refeicao');},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF43644A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2, // sombra
              ),
              child: Text('Cadastre sua refeição'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {Navigator.pushNamed(context, '/tela_historico');},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF43644A),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: TextStyle(fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2, // sombra
              ),
              child: Text('Histórico de refeições'),
            ),
          ],
        ),
      ),
    );
  }
}
