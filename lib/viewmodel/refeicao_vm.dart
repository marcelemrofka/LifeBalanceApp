import 'package:flutter/material.dart'; // garante que ChangeNotifier esteja disponível

class RefeicaoViewModel extends ChangeNotifier {  // <- precisa estender ChangeNotifier
  // Histórico de refeições
  final List<Map<String, dynamic>> _historico = [];

  List<Map<String, dynamic>> get historico => _historico;

  void adicionarRefeicao({
    required String tipoRefeicao,
    required String resultado,
    required List<Map<String, dynamic>> alimentos,
  }) {
    _historico.add({
      'tipoRefeicao': tipoRefeicao,
      'resultado': resultado,
      'alimentos': alimentos,
    });
    notifyListeners(); // <- agora funciona
  }

  void limparHistorico() {
    _historico.clear();
    notifyListeners();
  }
}
