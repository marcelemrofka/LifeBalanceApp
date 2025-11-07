import 'dart:math';

import 'package:app/utils/color.dart';
import 'package:app/widgets/barra_navegacao.dart';
import 'package:app/widgets/caixa.dart';
import 'package:app/widgets/carrossel.dart';
import 'package:app/widgets/dashboard.dart';
import 'package:app/widgets/drawer.dart';
import 'package:app/widgets/lembretes.dart';
import 'package:app/widgets/menu.dart';
import 'package:app/widgets/water_circle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // o _animation vai de 0 até 1 (controla o preenchimento do círculo)
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // o _waveAnimation agora só controla um leve movimento inicial
    _waveAnimation = Tween<double>(begin: 0, end: pi / 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // dispara a animação uma vez ao abrir
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Dashboard(),
            const SizedBox(height: 35),
            const Carrossel(),
            const SizedBox(height: 35),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Caixa(titulo: 'Lembretes', conteudo: LembretesWidget()),
              Caixa(titulo: 'Água', conteudo: LembretesWidget())
            ]),
          ],
        ),
      ),
      bottomNavigationBar: const BarraNavegacao(),
    );
  }
}
