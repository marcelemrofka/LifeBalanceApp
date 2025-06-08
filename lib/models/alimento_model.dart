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
}
