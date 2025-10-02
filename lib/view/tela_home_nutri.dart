import 'package:app/utils/color.dart';
import 'package:app/widgets/barra_navegacao_nutri.dart';
import 'package:app/widgets/drawer.dart';
import 'package:app/widgets/menu.dart';
import 'package:flutter/material.dart';

class TelaHomeNutri extends StatelessWidget {
  const TelaHomeNutri({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(size: 45, color: AppColors.midGrey),
        actions: const [Menu()],
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text('NUTRICIONISTA'),
      ),
      bottomNavigationBar: const BarraNavegacaoNutri(),
    );
  }
}
