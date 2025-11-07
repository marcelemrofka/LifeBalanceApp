// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';

// class NutritionViewModel extends ChangeNotifier {
//   // --- Dados atuais ---
//   double caloriasIngeridas = 0;
//   double carboIngerido = 0;
//   double proteinaIngerida = 0;
//   double gorduraIngerida = 0;
//   double fibraIngerida = 0;

//   // --- Metas (vêm da coleção paciente) ---
//   double caloriasRecomendadas = 0;
//   double carboRecomendado = 0;
//   double proteinaRecomendada = 0;
//   double gorduraRecomendada = 0;
//   double fibraRecomendada = 0;

//   double get caloriasPercentual =>
//       caloriasRecomendadas > 0 ? (caloriasIngeridas / caloriasRecomendadas) * 100 : 0;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   bool _carregando = false;
//   bool get carregando => _carregando;

//   void _setCarregando(bool value) {
//     _carregando = value;
//     notifyListeners();
//   }

//   /// Busca metas do paciente e valores consumidos no histórico do dia
//   Future<void> buscarDadosDoHistorico() async {
//     try {
//       _setCarregando(true);

//       final uid = _auth.currentUser?.uid;
//       if (uid == null) return;

//       // ======================
//       // 🔹 BUSCAR METAS DO PACIENTE
//       // ======================
//       final docPaciente =
//           await _firestore.collection('paciente').doc(uid).get();

//       if (docPaciente.exists) {
//         final meta = docPaciente.data()!;
//         caloriasRecomendadas = (meta['meta_cal'] ?? 0).toDouble();
//         carboRecomendado = (meta['meta_carbo'] ?? 0).toDouble();
//         proteinaRecomendada = (meta['meta_proteina'] ?? 0).toDouble();
//         gorduraRecomendada = (meta['meta_lip'] ?? 0).toDouble();
//         fibraRecomendada = (meta['meta_fibra'] ?? 0).toDouble();
//       }

//       // ======================
//       // 🔹 BUSCAR HISTÓRICO DO DIA
//       // ======================
//       final hoje = DateTime.now();
//       final dataFormatada =
//           "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
//       final docId = "${uid}_${dataFormatada}";

//       final docHistorico =
//           await _firestore.collection('historico').doc(docId).get();

//       if (docHistorico.exists) {
//         final data = docHistorico.data()!;
//         caloriasIngeridas = (data['total_calorias'] ?? 0).toDouble();
//         carboIngerido = (data['total_carboidrato'] ?? 0).toDouble();
//         proteinaIngerida = (data['total_proteina'] ?? 0).toDouble();
//         gorduraIngerida = (data['total_gordura'] ?? 0).toDouble();
//         fibraIngerida = (data['total_fibra'] ?? 0).toDouble();
//       }

//       _setCarregando(false);
//     } catch (e) {
//       if (kDebugMode) print("Erro ao buscar dados de nutrição: $e");
//       _setCarregando(false);
//     }
//   }
// }

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NutritionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Dados atuais ---
  double caloriasIngeridas = 0;
  double carboIngerido = 0;
  double proteinaIngerida = 0;
  double gorduraIngerida = 0;
  double fibraIngerida = 0;
  double aguaConsumida = 0;

  // --- Metas ---
  double caloriasRecomendadas = 0;
  double carboRecomendado = 0;
  double proteinaRecomendada = 0;
  double gorduraRecomendada = 0;
  double fibraRecomendada = 0;

  bool _carregando = false;
  bool get carregando => _carregando;

  StreamSubscription<DocumentSnapshot>? _historicoListener;
  StreamSubscription<DocumentSnapshot>? _metasListener;

  NutritionViewModel() {
    _iniciarListenerHistorico();
    _iniciarListenerMetas();
  }

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }

  void _iniciarListenerHistorico() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final hoje = DateTime.now();
    final dataFormatada =
        "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
    final docId = "${uid}_$dataFormatada";

    await _historicoListener?.cancel();

    _historicoListener = _firestore
        .collection('historico')
        .doc(docId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final data = doc.data()!;
        caloriasIngeridas = (data['total_calorias'] ?? 0).toDouble();
        carboIngerido = (data['total_carboidrato'] ?? 0).toDouble();
        proteinaIngerida = (data['total_proteina'] ?? 0).toDouble();
        gorduraIngerida = (data['total_gordura'] ?? 0).toDouble();
        fibraIngerida = (data['total_fibra'] ?? 0).toDouble();
        aguaConsumida = (data['agua'] ?? 0).toDouble();
        notifyListeners();
      }
    });
  }

  void _iniciarListenerMetas() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _metasListener?.cancel();

    _metasListener = _firestore
        .collection('paciente')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        final meta = doc.data()!;
        caloriasRecomendadas = (meta['meta_cal'] ?? 0).toDouble();
        carboRecomendado = (meta['meta_carbo'] ?? 0).toDouble();
        proteinaRecomendada = (meta['meta_proteina'] ?? 0).toDouble();
        gorduraRecomendada = (meta['meta_lip'] ?? 0).toDouble();
        fibraRecomendada = (meta['meta_fibra'] ?? 0).toDouble();
        notifyListeners();
      }
    });
  }

  /// Método opcional, pode ser mantido para chamadas manuais
  Future<void> buscarMetasDoPaciente() async {
    try {
      _setCarregando(true);

      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final docPaciente =
          await _firestore.collection('paciente').doc(uid).get();

      if (docPaciente.exists) {
        final meta = docPaciente.data()!;
        caloriasRecomendadas = (meta['meta_cal'] ?? 0).toDouble();
        carboRecomendado = (meta['meta_carbo'] ?? 0).toDouble();
        proteinaRecomendada = (meta['meta_proteina'] ?? 0).toDouble();
        gorduraRecomendada = (meta['meta_lip'] ?? 0).toDouble();
        fibraRecomendada = (meta['meta_fibra'] ?? 0).toDouble();
      }

      _setCarregando(false);
    } catch (e) {
      if (kDebugMode) print("Erro ao buscar metas: $e");
      _setCarregando(false);
    }
  }

  double get caloriasPercentual =>
      caloriasRecomendadas > 0
          ? (caloriasIngeridas / caloriasRecomendadas) * 100
          : 0;

  @override
  void dispose() {
    _historicoListener?.cancel();
    _metasListener?.cancel();
    super.dispose();
  }
}
