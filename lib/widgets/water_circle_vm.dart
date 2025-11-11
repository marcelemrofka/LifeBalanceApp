import 'package:app/widgets/water_circle.dart';
import 'package:app/viewmodel/historico_diario_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WaterCircleViewModel extends StatefulWidget {
  final double scale;
  final String? uidPaciente;

  const WaterCircleViewModel({
    Key? key,
    this.scale = 1.0,
    this.uidPaciente,
  }) : super(key: key);

  @override
  State<WaterCircleViewModel> createState() => _WaterCircleViewModelState();
}

class _WaterCircleViewModelState extends State<WaterCircleViewModel>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _waveController;

  double capacidadeTotal = 2000;
  double totalIngerido = 0;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _waveController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 20000))
      ..repeat();

    _carregarMeta();
    _ouvirConsumo();
  }

  Future<void> _carregarMeta() async {
    final uid = widget.uidPaciente ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final vm = context.read<HistoricoDiarioViewModel>();
    await vm.carregarMetaAgua(uid);

    if (mounted) {
      setState(() {
        capacidadeTotal = vm.metaAgua ?? 2000;
      });
    }
  }

  void _ouvirConsumo() {
    final uid = widget.uidPaciente ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final today = DateTime.now();
    final dateStr =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final docId = "${uid}_$dateStr";

    FirebaseFirestore.instance
        .collection('historico')
        .doc(docId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;

      final novoValor = (snapshot.data()?['agua'] ?? 0).toDouble();
      if (novoValor != totalIngerido) {
        setState(() => totalIngerido = novoValor);
        _animationController.forward(from: 0); // animação só quando muda
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tamanho = constraints.maxWidth * widget.scale;

        return Center(
          child: SizedBox(
            width: tamanho,
            height: tamanho,
            child: WaterCircleWidget(
              totalIngerido: totalIngerido,
              capacidadeTotal: capacidadeTotal,
              animation: _animationController,
              waveAnimation: _waveController,
            ),
          ),
        );
      },
    );
  }
}
