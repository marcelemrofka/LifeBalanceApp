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
        iconTheme: IconThemeData( size: 45, color: AppColors.midGrey),
        actions: const [Menu(), ],
      ),
      drawer: CustomDrawer(),
      body: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Dashboard(),
            const SizedBox(height: 35),
            const Carrossel(),
          ],
        ),
        
      ),
      bottomNavigationBar: const BarraNavegacao(),
    );
    
  }
}
