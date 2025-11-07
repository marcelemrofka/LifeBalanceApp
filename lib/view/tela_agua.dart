import 'package:app/utils/color.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/widgets/water_circle.dart';
import '../viewmodel/historico_diario_viewmodel.dart';

class TelaAgua extends StatefulWidget {
  const TelaAgua({Key? key}) : super(key: key);

  @override
  _TelaAguaState createState() => _TelaAguaState();
}

class _TelaAguaState extends State<TelaAgua>
    with SingleTickerProviderStateMixin {
  double totalIngerido = 0;
  double capacidadeTotal = 2000;
  int quantidadeSelecionada = 100;
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 0).animate(_controller);
    _waveAnimation = Tween<double>(begin: 0, end: pi / 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _inicializarMeta();
  }

  Future<void> _inicializarMeta() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final vm = context.read<HistoricoDiarioViewModel>();
    await vm.carregarMetaAgua(uid);

    setState(() {
      capacidadeTotal = vm.metaAgua ?? 2000;
    });

    // Configura stream para atualizações em tempo real do histórico
    final today = DateTime.now();
    final dateStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final docId = "${uid}_$dateStr";

    FirebaseFirestore.instance
        .collection('historico')
        .doc(docId)
        .snapshots()
        .listen((doc) {
      if (doc.exists && mounted) {
        setState(() {
          totalIngerido = (doc.data()?['agua'] ?? 0).toDouble();
          double progresso = (totalIngerido / capacidadeTotal).clamp(0.0, 1.0);
          _animation =
              Tween<double>(begin: 0, end: progresso).animate(_controller);
          _controller.forward(from: 0);
        });
      }
    });
  }

  Future<void> _adicionarAgua() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuário não autenticado')),
        );
        return;
      }

      final uid = user.uid;
      // pega uid do nutricionista vinculado
      final pacienteDoc = await FirebaseFirestore.instance
          .collection('paciente')
          .doc(uid)
          .get();

      if (!pacienteDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados do paciente não encontrados')),
        );
        return;
      }

      final uidNutri = pacienteDoc.data()?['nutricionista_uid'];

      final vm = context.read<HistoricoDiarioViewModel>();
      await vm.registrarAgua(
        uidUsuario: uid,
        uidNutri: uidNutri,
        quantidadeMl: quantidadeSelecionada,
      );

      // Não precisa atualizar o estado manualmente pois temos um listener
      // que será notificado quando o Firestore for atualizado
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao registrar água: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(titulo: 'Consumo de Água'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WaterCircleWidget(
              totalIngerido: totalIngerido,
              capacidadeTotal: capacidadeTotal,
              animation: _animation,
              waveAnimation: _waveAnimation,
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 110,
              height: 45,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: quantidadeSelecionada,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(12),
                    items: [100, 200, 300, 400, 500, 1000].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Center(child: Text("$value ml")),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() => quantidadeSelecionada = newValue!);
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Insira a quantidade ingerida de água hoje!',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.midText),
            ),
            SizedBox(height: 15),
            ElevatedButton(
              onPressed: _adicionarAgua,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.laranja,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text("Adicionar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
