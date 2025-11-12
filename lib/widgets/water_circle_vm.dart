import 'dart:async';
import 'package:app/widgets/water_circle.dart';
import 'package:app/viewmodel/historico_diario_viewmodel.dart';
import 'package:app/viewmodel/auth_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WaterCircleViewModel extends StatefulWidget {
  final double scale;
  final String?
      uidPaciente; // usado quando o nutricionista clica em um paciente

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
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  double capacidadeTotal = 2000;
  double totalIngerido = 0;
  String? uidParaBuscar;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _inicializar();
  }

  /// 🔹 Define o UID conforme o tipo de usuário (nutricionista ou paciente)
  Future<void> _inicializar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final authVm = context.read<AuthViewModel>();
      final tipo = authVm.tipoUsuario; // "nutricionista" ou "paciente"

      // 🔸 Se for nutricionista → usa o paciente clicado
      // 🔸 Se for paciente → usa o próprio UID
      if (tipo == 'nutricionista' && widget.uidPaciente != null) {
        uidParaBuscar = widget.uidPaciente;
      } else {
        uidParaBuscar = user.uid;
      }

      await _carregarMeta();
      _ouvirConsumo();
    } catch (e) {
      debugPrint('Erro ao inicializar WaterCircleViewModel: $e');
    }
  }

  /// 🔹 Carrega a meta de água (paciente/{uid}.meta_agua)
  Future<void> _carregarMeta() async {
    if (uidParaBuscar == null) return;

    final vm = context.read<HistoricoDiarioViewModel>();
    await vm.carregarMetaAgua(uidParaBuscar!);

    if (mounted) {
      setState(() {
        capacidadeTotal = vm.metaAgua ?? 2000;
      });
    }
  }

  /// 🔹 Escuta o documento diário do histórico (historico/{uid_yyyy-MM-dd})
  void _ouvirConsumo() {
    if (uidParaBuscar == null) return;

    _sub?.cancel();

    final hoje = DateTime.now();
    final dataFormatada =
        "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
    final docId = "${uidParaBuscar}_$dataFormatada";

    _sub = FirebaseFirestore.instance
        .collection('historico')
        .doc(docId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        if (totalIngerido != 0) setState(() => totalIngerido = 0);
        return;
      }

      final novoValor = (snapshot.data()?['agua'] ?? 0).toDouble();
      if (novoValor != totalIngerido) {
        setState(() => totalIngerido = novoValor);
        _animationController.forward(from: 0); // animação só quando muda
      }
    }, onError: (e) {
      debugPrint('Erro ao escutar histórico de água: $e');
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
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
