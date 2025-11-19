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

  void _setCarregando(bool value) {
    _carregando = value;
    notifyListeners();
  }

  /// 🔹 Chamado ao logar com um novo usuário
  Future<void> iniciarParaUsuario(String uid) async {
    await _historicoListener?.cancel();
    await _metasListener?.cancel();

    _setCarregando(true);
    _iniciarListenerHistorico(uid);
    _iniciarListenerMetas(uid);
    _setCarregando(false);
  }

  /// 🔹 Compatibilidade (para o Dashboard)
  Future<void> buscarMetasDoPaciente([String? uid]) async {
    final effectiveUid = uid ?? _auth.currentUser?.uid;
    if (effectiveUid == null) {
      await resetarDados();
      return;
    }
    await iniciarParaUsuario(effectiveUid);
  }

  /// 🔹 Chamado ao sair do app
  Future<void> resetarDados() async {
    await _historicoListener?.cancel();
    await _metasListener?.cancel();

    caloriasIngeridas = 0;
    carboIngerido = 0;
    proteinaIngerida = 0;
    gorduraIngerida = 0;
    fibraIngerida = 0;
    aguaConsumida = 0;

    caloriasRecomendadas = 0;
    carboRecomendado = 0;
    proteinaRecomendada = 0;
    gorduraRecomendada = 0;
    fibraRecomendada = 0;

    notifyListeners();
    if (kDebugMode) print('NutritionViewModel: dados resetados');
  }

  void _iniciarListenerHistorico(String uid) {
    final hoje = DateTime.now();
    final dataFormatada =
        "${hoje.year}-${hoje.month.toString().padLeft(2, '0')}-${hoje.day.toString().padLeft(2, '0')}";
    final docId = "${uid}_$dataFormatada";

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
      } else {
        resetarDados();
      }
    });
  }

  void _iniciarListenerMetas(String uid) {
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
