import 'package:app/models/alimento_model.dart';
import 'package:app/models/refeicao_model.dart';
import 'package:flutter/material.dart';
import 'package:app/models/nutrition_model.dart';

class NutritionViewModel extends ChangeNotifier {
  // Dados nutricionais
  NutritionModel _nutrition = NutritionModel(
    caloriasIngeridas: 0,
    carboIngerido: 0,
    proteinaIngerida: 0,
    gorduraIngerida: 0,
    fibraIngerida: 0,

    caloriasRecomendada: 1600,
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

  // Atualiza totais nutricionais
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
      caloriasRecomendada: caloriasRecomendada ?? _nutrition.caloriasRecomendada,
      carboIngerido: carboIngerido ?? _nutrition.carboIngerido,
      carboRecomendado: carboRecomendado ?? _nutrition.carboRecomendado,
      proteinaIngerida: proteinaIngerida ?? _nutrition.proteinaIngerida,
      proteinaRecomendada: proteinaRecomendada ?? _nutrition.proteinaRecomendada,
      gorduraIngerida: gorduraIngerida ?? _nutrition.gorduraIngerida,
      gorduraRecomendada: gorduraRecomendada ?? _nutrition.gorduraRecomendada,
      fibraIngerida: fibraIngerida ?? _nutrition.fibraIngerida,
      fibraRecomendada: fibraRecomendada ?? _nutrition.fibraRecomendada,
    );
    notifyListeners();
  }

  // Adiciona alimento a uma refeição e atualiza os totais
  void adicionarAlimento(String refeicao, Alimento alimento) {
    _alimentosPorRefeicao.putIfAbsent(refeicao, () => []);
    _alimentosPorRefeicao[refeicao]!.add(alimento);

    _nutrition = NutritionModel(
      caloriasIngeridas: _nutrition.caloriasIngeridas + alimento.calorias.toInt(),
      carboIngerido: _nutrition.carboIngerido + alimento.carboidratos.toInt(),
      proteinaIngerida: _nutrition.proteinaIngerida + alimento.proteinas.toInt(),
      gorduraIngerida: _nutrition.gorduraIngerida + alimento.gorduras.toInt(),
      fibraIngerida: _nutrition.fibraIngerida + alimento.fibras.toInt(),
      caloriasRecomendada: _nutrition.caloriasRecomendada,
      carboRecomendado: _nutrition.carboRecomendado,
      proteinaRecomendada: _nutrition.proteinaRecomendada,
      gorduraRecomendada: _nutrition.gorduraRecomendada,
      fibraRecomendada: _nutrition.fibraRecomendada,
    );

    notifyListeners();
  }

  // Salva a refeição no histórico
  void registrarRefeicao(String nomeRefeicao) {
    if (!_alimentosPorRefeicao.containsKey(nomeRefeicao)) return;

    final alimentos = List<Alimento>.from(_alimentosPorRefeicao[nomeRefeicao]!);

    _historico.add(
      RefeicaoModel(
        nome: nomeRefeicao,
        alimentos: alimentos,
      ),
    );
    notifyListeners();
  }

}
