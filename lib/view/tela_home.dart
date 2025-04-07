import 'package:app/utils/color.dart';
import 'package:app/widgets/barra_navegacao.dart';
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
          ],
        ),
        
      ),
      bottomNavigationBar: const BarraNavegacao(),
    );
    
  }
}
