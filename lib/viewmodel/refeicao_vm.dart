import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RefeicaoViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _historico = [];
  List<Map<String, dynamic>> get historico => _historico;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔹 Stream do histórico de refeições do usuário logado
  Stream<List<Map<String, dynamic>>> getHistoricoStream() {
    final usuario = _auth.currentUser;
    if (usuario == null) return const Stream.empty();

    return _firestore
        .collection('refeicoes')
        .where('uid', isEqualTo: usuario.uid)
        .snapshots()
        .map((snapshot) {
      final lista = snapshot.docs.map((doc) {
        final dados = doc.data();
        dados['id'] = doc.id;
        return dados;
      }).toList();

      // Ordena localmente por hora (descendente)
      lista.sort((a, b) {
        final aHora = a['hora'] as Timestamp?;
        final bHora = b['hora'] as Timestamp?;
        return bHora!.compareTo(aHora!);
      });

      return lista;
    });
  }

  /// 🔹 Adiciona refeição no Firebase
  Future<void> adicionarRefeicao({
    required String tipoRefeicao,
    required String resultado,
    required List<Map<String, dynamic>> alimentos,
  }) async {
    final usuario = _auth.currentUser;
    if (usuario == null) return;

    final agora = DateTime.now();

    int _extrairNumero(String chave) {
      final regex = RegExp('$chave:?\\s*(\\d+)', caseSensitive: false);
      final match = regex.firstMatch(resultado);
      return match != null ? int.tryParse(match.group(1) ?? '0') ?? 0 : 0;
    }

    String _extrairNome() {
      final linhas = resultado.split('\n');
      if (linhas.isNotEmpty) {
        return linhas.first
            .replaceAll(RegExp(r'[^\w\sáàâãéèêíïóôõöúçÁÀÂÃÉÈÊÍÏÓÔÕÖÚÇ]'), '')
            .trim();
      }
      return 'Alimento não identificado';
    }

    final refeicao = {
      "nome": _extrairNome(),
      "quantidade": alimentos.isNotEmpty ? alimentos.first['quantidade'] ?? 0 : 0,
      "calorias": _extrairNumero('Calorias'),
      "carboidratos": _extrairNumero('Carboidratos'),
      "proteinas": _extrairNumero('Proteínas'),
      "fibras": _extrairNumero('Fibras'),
      "gorduras": _extrairNumero('Gorduras'),
      "hora": Timestamp.fromDate(agora),
      "tipoRefeicao": tipoRefeicao,
      "uid": usuario.uid,
    };

    await _firestore.collection('refeicoes').add(refeicao);
  }

  /// 🔹 Deleta refeição do Firebase
  Future<void> deletarRefeicao(String refeicaoId) async {
    try {
      await _firestore.collection('refeicoes').doc(refeicaoId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar refeição: $e');
    }
  }
}
