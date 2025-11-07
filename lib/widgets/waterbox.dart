import 'package:app/viewmodel/historico_diario_viewmodel.dart';
import 'package:app/widgets/water_circle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WaterBox extends StatefulWidget {
  final Animation<double> animation;
  final Animation<double> waveAnimation;
  final double scale;

  const WaterBox(
      {Key? key,
      required this.animation,
      required this.waveAnimation,
      this.scale = 1.0})
      : super(key: key);

  @override
  State<WaterBox> createState() => _WaterBoxState();
}

class _WaterBoxState extends State<WaterBox> {
  double capacidadeTotal = 2000;

  @override
  void initState() {
    super.initState();
    _carregarMeta();
  }

  Future<void> _carregarMeta() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final vm = context.read<HistoricoDiarioViewModel>();
    await vm.carregarMetaAgua(uid);
    if (mounted) {
      setState(() {
        capacidadeTotal = vm.metaAgua ?? 2000;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    final today = DateTime.now();
    final dateStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final docId = "${uid}_$dateStr";

    return SizedBox(
      width: 100,
      height: 100,
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('historico')
            .doc(docId)
            .snapshots(),
        builder: (context, snap) {
          double total = 0;
          if (snap.hasData && snap.data!.exists) {
            total = (snap.data!.data()?['agua'] ?? 0).toDouble();
          }

          return Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: WaterCircleWidget(
                totalIngerido: total,
                capacidadeTotal: capacidadeTotal,
                animation: widget.animation,
                waveAnimation: widget.waveAnimation,
              ),
            ),
          );
        },
      ),
    );
  }
}
