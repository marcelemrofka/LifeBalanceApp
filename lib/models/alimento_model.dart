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


factory Alimento.fromMap(Map<String, dynamic> map) {
  return Alimento(
    nome: map['nome'],
    calorias: (map['calorias'] ?? 0).toDouble(),
    carboidratos: (map['carboidratos'] ?? 0).toDouble(),
    proteinas: (map['proteinas'] ?? 0).toDouble(),
    gorduras: (map['gorduras'] ?? 0).toDouble(),
    fibras: (map['fibras'] ?? 0).toDouble(),
  );
}

}
