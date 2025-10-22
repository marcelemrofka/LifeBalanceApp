import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';

class TelaHistoricoRefeicoes extends StatelessWidget {
  const TelaHistoricoRefeicoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomAppBar(titulo: 'Histórico de Refeições'),
      // body:
    );
  }
}
