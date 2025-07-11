import 'package:app/models/alimento_model.dart';

class RefeicaoModel {
  final String nome;
  final List<Alimento> alimentos;

  RefeicaoModel({
    required this.nome,
    required this.alimentos,
  });

    Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'alimentos': alimentos.map((a) => a.toMap()).toList(),
    };
  }
}
