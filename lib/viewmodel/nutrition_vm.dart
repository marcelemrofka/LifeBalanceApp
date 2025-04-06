import 'package:flutter/material.dart';
import 'package:app/models/nutrition_model.dart';

class NutritionViewModel extends ChangeNotifier {
  NutritionModel _nutrition = NutritionModel(
    caloriasIngeridas: 0,
    carboIngerido: 0,
    proteinaIngerida: 0,
    gorduraIngerida: 0,
    fibraIngerida: 0,

    caloriasRecomendada: 2300,
    carboRecomendado: 250,
    proteinaRecomendada: 100,
    gorduraRecomendada: 70,
    fibraRecomendada: 50,
  );

  NutritionModel get nutrition => _nutrition;

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
}
