class NutritionModel {
  //ingerido
  final int caloriasIngeridas;
  final int carboIngerido;
  final int proteinaIngerida;
  final int gorduraIngerida;
  final int fibraIngerida;
  //recomendado
  final int caloriasRecomendada;
  final int carboRecomendado;
  final int proteinaRecomendada;
  final int gorduraRecomendada;
  final int fibraRecomendada;

  NutritionModel({
    //ingerido
    required this.caloriasIngeridas,
    required this.carboIngerido,
    required this.proteinaIngerida,
    required this.gorduraIngerida,
    required this.fibraIngerida,
    //recomendado
    required this.caloriasRecomendada,
    required this.carboRecomendado,
    required this.proteinaRecomendada,
    required this.gorduraRecomendada,
    required this.fibraRecomendada,
  });

  double get caloriasPercentual => (caloriasIngeridas / caloriasRecomendada) * 100;
  double get carboPercentual => (carboIngerido / carboRecomendado) * 100;
  double get proteinaPercentual => (proteinaIngerida / proteinaRecomendada) * 100;
  double get gorduraPercentual => (gorduraIngerida / gorduraRecomendada) * 100;
  double get fibraPercentual => (fibraIngerida / fibraRecomendada) * 100;
}
