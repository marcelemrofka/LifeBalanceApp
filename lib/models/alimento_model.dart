class Alimento {
  final String nome;
  final double calorias;
  final double proteinas;
  final double carboidratos;
  final double gorduras;
  final double fibras;

  Alimento({
    required this.nome,
    required this.calorias,
    required this.proteinas,
    required this.carboidratos,
    required this.gorduras,
    required this.fibras,
  });


  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'calorias': calorias,
      'proteinas': proteinas,
      'carboidratos': carboidratos,
      'gorduras': gorduras,
      'fibras': fibras,
    };
  }

    factory Alimento.fromMap(Map<String, dynamic> map) {
    return Alimento(
      nome: map['nome'] ?? '',
      calorias: (map['calorias'] as num).toDouble(),
      proteinas: (map['proteinas'] as num).toDouble(),
      carboidratos: (map['carboidratos'] as num).toDouble(),
      gorduras: (map['gorduras'] as num).toDouble(),
      fibras: (map['fibras'] as num).toDouble(),
    );
  }
}
