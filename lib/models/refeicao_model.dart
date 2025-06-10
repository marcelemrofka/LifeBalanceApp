import 'package:app/models/alimento_model.dart';

class RefeicaoModel {
  final String tipo;
  final List<Alimento> alimentos;
  final double totalCalorias;
  final DateTime dataHora;

  RefeicaoModel({
    required this.tipo,
    required this.alimentos,
    required this.totalCalorias,
    required this.dataHora,
  });

    Map<String, dynamic> toMap() {
    return {
      'nome': tipo,
      'alimentos': alimentos.map((a) => a.toMap()).toList(),
      'totalCalorias': totalCalorias,
      'dataHora': dataHora,
    };
  }

  factory RefeicaoModel.fromMap(Map<String, dynamic> map) {
    return RefeicaoModel(
      tipo: map['nome'] ?? '',
      alimentos: (map['alimentos'] as List<dynamic>)
          .map((a) => Alimento.fromMap(a as Map<String, dynamic>))
          .toList(),
      totalCalorias: (map['totalCalorias'] as num).toDouble(),
      dataHora: DateTime.parse(map['dataHora']),
    );
  }
}
