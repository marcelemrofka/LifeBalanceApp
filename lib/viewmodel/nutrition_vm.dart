import 'package:app/models/alimento_model.dart';
import 'package:app/models/refeicao_model.dart';
import 'package:flutter/material.dart';
import 'package:app/models/nutrition_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NutritionViewModel extends ChangeNotifier {
  // Dados nutricionais
  NutritionModel _nutrition = NutritionModel(
    caloriasIngeridas: 0,
    carboIngerido: 0,
    proteinaIngerida: 0,
    gorduraIngerida: 0,
    fibraIngerida: 0,
    caloriasRecomendada: 1800,
    carboRecomendado: 185,
    proteinaRecomendada: 100,
    gorduraRecomendada: 53,
    fibraRecomendada: 25,
  );

  NutritionModel get nutrition => _nutrition;

  // Alimentos por refeição (temporários)
  final Map<String, List<Alimento>> _alimentosPorRefeicao = {};
  Map<String, List<Alimento>> get alimentosPorRefeicao => _alimentosPorRefeicao;

  // Histórico de refeições
  final List<RefeicaoModel> _historico = [];
  List<RefeicaoModel> get historico => _historico;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Atualiza dados nutricionais
  void updateNutrition({
    int? caloriasIngeridas,
    int? caloriasRecomendada,
    int? carboIngerido,
    int? carboRecomendado,
    int? proteinaIngerida,
    int? proteinaRecomendada,
    int? gorduraIngerida,
    int? gorduraRecomendada,
    int? fibraIngerida,
    int? fibraRecomendada,
  }) {
    _nutrition = NutritionModel(
      caloriasIngeridas: caloriasIngeridas ?? _nutrition.caloriasIngeridas,
      caloriasRecomendada:
          caloriasRecomendada ?? _nutrition.caloriasRecomendada,
      carboIngerido: carboIngerido ?? _nutrition.carboIngerido,
      carboRecomendado: carboRecomendado ?? _nutrition.carboRecomendado,
      proteinaIngerida: proteinaIngerida ?? _nutrition.proteinaIngerida,
      proteinaRecomendada:
          proteinaRecomendada ?? _nutrition.proteinaRecomendada,
      gorduraIngerida: gorduraIngerida ?? _nutrition.gorduraIngerida,
      gorduraRecomendada: gorduraRecomendada ?? _nutrition.gorduraRecomendada,
      fibraIngerida: fibraIngerida ?? _nutrition.fibraIngerida,
      fibraRecomendada: fibraRecomendada ?? _nutrition.fibraRecomendada,
    );
    notifyListeners();
  }

  void _recalcularTotais() {
    int calorias = 0, carbo = 0, proteina = 0, gordura = 0, fibra = 0;

    _alimentosPorRefeicao.values.expand((list) => list).forEach((alimento) {
      calorias += alimento.calorias.toInt();
      carbo += alimento.carboidratos.toInt();
      proteina += alimento.proteinas.toInt();
      gordura += alimento.gorduras.toInt();
      fibra += alimento.fibras.toInt();
    });

    updateNutrition(
      caloriasIngeridas: calorias,
      carboIngerido: carbo,
      proteinaIngerida: proteina,
      gorduraIngerida: gordura,
      fibraIngerida: fibra,
    );
  }

  Future<List<Alimento>> buscarAlimentos(String query) async {
    final snapshot = await _firestore.collection('alimentos').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Alimento.fromMap({
        ...data,
        'nome': data['nome'] ?? doc.id,
      });
    }).toList();
  }

  /// Lista todos os alimentos disponíveis
  Future<List<String>> listarTodosAlimentos() async {
    try {
      final query = await _firestore.collection('alimentos').get();

      return query.docs.map((doc) => doc.id).toList()..sort();
    } catch (e) {
      return [];
    }
  }

  /// Adiciona um alimento à refeição selecionada (em cadastro)
  Future<void> adicionarAlimento(
      String refeicaoSelecionada, Alimento alimento) async {
    _alimentosPorRefeicao.putIfAbsent(refeicaoSelecionada, () => []);
    _alimentosPorRefeicao[refeicaoSelecionada]!.add(alimento);
    _recalcularTotais();
    notifyListeners();
  }

  /// Remove um alimento da refeição
  void removerAlimento(String refeicaoSelecionada, int index) {
    final alimentos = _alimentosPorRefeicao[refeicaoSelecionada];
    if (alimentos != null && index >= 0 && index < alimentos.length) {
      alimentos.removeAt(index);
      _recalcularTotais();
      notifyListeners();
    }
  }

  /// Salva refeição no Firestore no caminho usuarios/uid/refeicoes
  Future<void> salvarRefeicao(String tipoRefeicao) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      print('Usuário não logado');
      return;
    }

    final alimentos = _alimentosPorRefeicao[tipoRefeicao] ?? [];
    if (alimentos.isEmpty) {
      print('Nenhum alimento para salvar');
      return;
    }

    final totalCalorias =
        alimentos.fold<int>(0, (sum, a) => sum + a.calorias.toInt());

    final refeicao = RefeicaoModel(
      tipo: tipoRefeicao,
      alimentos: alimentos,
      totalCalorias: totalCalorias.toDouble(),
      dataHora: DateTime.now(),
    );

    try {
      await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('refeicoes')
          .add(refeicao.toMap());
      print('Refeição salva com sucesso!');
      _alimentosPorRefeicao.remove(tipoRefeicao);
      _recalcularTotais();
      notifyListeners();
    } catch (e) {
      print('Erro ao salvar refeição: $e');
      rethrow;
    }
  }

  /// Carrega histórico de refeições do usuário logado
  Future<void> carregarHistoricoRefeicoes() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      print('Usuário não logado');
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('usuarios')
          .doc(uid)
          .collection('refeicoes')
          .orderBy('dataHora', descending: true)
          .get();

      _historico.clear();
      for (final doc in snapshot.docs) {
        try {
          _historico.add(RefeicaoModel.fromMap(doc.data()));
        } catch (e) {
          print('Erro ao processar refeição ${doc.id}: $e');
          continue;
        }
      }

      notifyListeners();
    } catch (e) {
      print('Erro ao carregar histórico: $e');
    }
  }
}
