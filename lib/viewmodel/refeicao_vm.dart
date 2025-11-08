// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';

// class RefeicaoViewModel extends ChangeNotifier {
//   final _firestore = FirebaseFirestore.instance;
//   final _auth = FirebaseAuth.instance;

//   List<Map<String, dynamic>> _historico = [];
//   List<Map<String, dynamic>> get historico => _historico;

//   StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listener;

//   RefeicaoViewModel() {
//     _iniciarListenerHistorico();
//   }

//   void _iniciarListenerHistorico() {
//     final usuario = _auth.currentUser;
//     if (usuario == null) return;

//     _listener?.cancel();

//     _listener = _firestore
//         .collection('refeicoes')
//         .where('uid', isEqualTo: usuario.uid)
//         .snapshots()
//         .listen((snapshot) {
//       final lista = snapshot.docs.map((doc) {
//         final dados = doc.data();
//         dados['id'] = doc.id;
//         return dados;
//       }).toList();

//       lista.sort((a, b) {
//         final aHora = a['hora'] as Timestamp?;
//         final bHora = b['hora'] as Timestamp?;
//         if (aHora == null || bHora == null) return 0;
//         return bHora.compareTo(aHora);
//       });

//       _historico = lista;
//       notifyListeners();
//     });
//   }

//   @override
//   void dispose() {
//     _listener?.cancel();
//     super.dispose();
//   }

//   Stream<List<Map<String, dynamic>>> getHistoricoStream() {
//     final usuario = _auth.currentUser;
//     if (usuario == null) return const Stream.empty();

//     return _firestore
//         .collection('refeicoes')
//         .where('uid', isEqualTo: usuario.uid)
//         .snapshots()
//         .map((snapshot) {
//       final lista = snapshot.docs.map((doc) {
//         final dados = doc.data();
//         dados['id'] = doc.id;
//         return dados;
//       }).toList();

//       lista.sort((a, b) {
//         final aHora = a['hora'] as Timestamp?;
//         final bHora = b['hora'] as Timestamp?;
//         if (aHora == null || bHora == null) return 0;
//         return bHora.compareTo(aHora);
//       });

//       return lista;
//     });
//   }

//   // 🔹 Adiciona refeição e atualiza histórico diário completo
//   Future<void> adicionarRefeicao({
//     required String tipoRefeicao,
//     required String resultado,
//     required List<Map<String, dynamic>> alimentos,
//   }) async {
//     final usuario = _auth.currentUser;
//     if (usuario == null) return;

//     final agora = DateTime.now();

//     int _extrairNumero(String chave) {
//       final regex = RegExp('$chave:?\\s*(\\d+)', caseSensitive: false);
//       final match = regex.firstMatch(resultado);
//       return match != null ? int.tryParse(match.group(1) ?? '0') ?? 0 : 0;
//     }

//     String _extrairNome() {
//       final linhas = resultado.split('\n');
//       if (linhas.isNotEmpty) {
//         return linhas.first
//             .replaceAll(RegExp(r'[^\w\sáàâãéèêíïóôõöúçÁÀÂÃÉÈÊÍÏÓÔÕÖÚÇ,]'), '')
//             .trim();
//       }
//       return 'Alimento não identificado';
//     }

//     final refeicao = {
//       "nome": _extrairNome(),
//       "quantidade":
//           alimentos.isNotEmpty ? alimentos.first['quantidade'] ?? 0 : 0,
//       "calorias": _extrairNumero('Calorias'),
//       "carboidratos": _extrairNumero('Carboidratos'),
//       "proteinas": _extrairNumero('Proteínas'),
//       "fibras": _extrairNumero('Fibras'),
//       "gorduras": _extrairNumero('Gorduras'),
//       "hora": Timestamp.fromDate(agora),
//       "tipoRefeicao": tipoRefeicao,
//       "uid": usuario.uid,
//     };

//     await _firestore.collection('refeicoes').add(refeicao);

//     final dataFormatada = DateFormat('yyyy-MM-dd').format(agora);
//     final historicoRef = _firestore
//         .collection('historico')
//         .doc('${usuario.uid}_$dataFormatada');

//     await _firestore.runTransaction((transaction) async {
//       final snapshot = await transaction.get(historicoRef);

//       int calorias = refeicao["calorias"] ?? 0;
//       int carbo = refeicao["carboidratos"] ?? 0;
//       int proteina = refeicao["proteinas"] ?? 0;
//       int fibra = refeicao["fibras"] ?? 0;
//       int gordura = refeicao["gorduras"] ?? 0;

//       if (!snapshot.exists) {
//         transaction.set(historicoRef, {
//           "uid_usuario": _firestore.doc('usuarios/${usuario.uid}'),
//           "uid_nutri": _firestore.doc('usuarios/HlvugqfKuxbBKBvOVo400YqfhUx1'), // Exemplo fixo
//           "data": agora,
//           "agua": 0,
//           "sono": {
//             "inicio": null,
//             "fim": null,
//             "horas_totais": 0,
//             "observacao": "",
//           },
//           "total_calorias": calorias,
//           "total_carboidrato": carbo,
//           "total_proteina": proteina,
//           "total_fibra": fibra,
//           "total_gordura": gordura,
//           "horaAtualizacao": Timestamp.now(),
//         });
//       } else {
//         final dados = snapshot.data()!;
//         transaction.update(historicoRef, {
//           "total_calorias": (dados["total_calorias"] ?? 0) + calorias,
//           "total_carboidrato": (dados["total_carboidrato"] ?? 0) + carbo,
//           "total_proteina": (dados["total_proteina"] ?? 0) + proteina,
//           "total_fibra": (dados["total_fibra"] ?? 0) + fibra,
//           "total_gordura": (dados["total_gordura"] ?? 0) + gordura,
//           "horaAtualizacao": Timestamp.now(),
//         });
//       }
//     });
//   }

//   // 🔹 Deleta refeição e subtrai do histórico
//   Future<void> deletarRefeicao(String refeicaoId) async {
//     try {
//       final usuario = _auth.currentUser;
//       if (usuario == null) return;

//       final refeicaoDoc =
//           await _firestore.collection('refeicoes').doc(refeicaoId).get();

//       if (!refeicaoDoc.exists) return;

//       final dados = refeicaoDoc.data()!;
//       final calorias = dados["calorias"] ?? 0;
//       final carbo = dados["carboidratos"] ?? 0;
//       final proteina = dados["proteinas"] ?? 0;
//       final fibra = dados["fibras"] ?? 0;
//       final gordura = dados["gorduras"] ?? 0;

//       final dataFormatada = DateFormat('yyyy-MM-dd')
//           .format((dados["hora"] as Timestamp).toDate());
//       final historicoRef = _firestore
//           .collection('historico')
//           .doc('${usuario.uid}_$dataFormatada');

//       await _firestore.runTransaction((transaction) async {
//         final snapshot = await transaction.get(historicoRef);
//         if (snapshot.exists) {
//           final hist = snapshot.data()!;
//           transaction.update(historicoRef, {
//             "total_calorias":
//                 ((hist["total_calorias"] ?? 0) - calorias).clamp(0, double.infinity),
//             "total_carboidrato":
//                 ((hist["total_carboidrato"] ?? 0) - carbo).clamp(0, double.infinity),
//             "total_proteina":
//                 ((hist["total_proteina"] ?? 0) - proteina).clamp(0, double.infinity),
//             "total_fibra":
//                 ((hist["total_fibra"] ?? 0) - fibra).clamp(0, double.infinity),
//             "total_gordura":
//                 ((hist["total_gordura"] ?? 0) - gordura).clamp(0, double.infinity),
//             "horaAtualizacao": Timestamp.now(),
//           });
//         }
//       });

//       await _firestore.collection('refeicoes').doc(refeicaoId).delete();
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Erro ao deletar refeição: $e');
//     }
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RefeicaoViewModel extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _historico = [];
  List<Map<String, dynamic>> get historico => _historico;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _listener;

  RefeicaoViewModel() {
    _iniciarListenerHistorico();
  }

  void _iniciarListenerHistorico() {
    final usuario = _auth.currentUser;
    if (usuario == null) return;

    _listener?.cancel();

    _listener = _firestore
        .collection('refeicoes')
        .where('uid', isEqualTo: usuario.uid)
        .snapshots()
        .listen((snapshot) {
      final lista = snapshot.docs.map((doc) {
        final dados = doc.data();
        dados['id'] = doc.id;
        return dados;
      }).toList();

      lista.sort((a, b) {
        final aHora = a['hora'] as Timestamp?;
        final bHora = b['hora'] as Timestamp?;
        if (aHora == null || bHora == null) return 0;
        return bHora.compareTo(aHora);
      });

      _historico = lista;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

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

      lista.sort((a, b) {
        final aHora = a['hora'] as Timestamp?;
        final bHora = b['hora'] as Timestamp?;
        if (aHora == null || bHora == null) return 0;
        return bHora.compareTo(aHora);
      });

      return lista;
    });
  }

  // 🔹 Adiciona refeição e atualiza histórico diário completo
  Future<void> adicionarRefeicao({
    required String tipoRefeicao,
    required String resultado,
    required List<Map<String, dynamic>> alimentos,
    String? imagemUrl, // 🔹 Novo parâmetro opcional
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
            .replaceAll(RegExp(r'[^\w\sáàâãéèêíïóôõöúçÁÀÂÃÉÈÊÍÏÓÔÕÖÚÇ,g,G]'), '')
            .trim();
      }
      return 'Alimento não identificado';
    }

    final refeicao = {
      "nome": _extrairNome(),
      "quantidade":
          alimentos.isNotEmpty ? alimentos.first['quantidade'] ?? 0 : 0,
      "calorias": _extrairNumero('Calorias'),
      "carboidratos": _extrairNumero('Carboidratos'),
      "proteinas": _extrairNumero('Proteínas'),
      "fibras": _extrairNumero('Fibras'),
      "gorduras": _extrairNumero('Gorduras'),
      "hora": Timestamp.fromDate(agora),
      "tipoRefeicao": tipoRefeicao,
      "uid": usuario.uid,
      "imagemUrl": imagemUrl, // 🔹 Salva o link da imagem aqui
    };

    await _firestore.collection('refeicoes').add(refeicao);

    final dataFormatada = DateFormat('yyyy-MM-dd').format(agora);
    final historicoRef = _firestore
        .collection('historico')
        .doc('${usuario.uid}_$dataFormatada');

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(historicoRef);

      int calorias = refeicao["calorias"] ?? 0;
      int carbo = refeicao["carboidratos"] ?? 0;
      int proteina = refeicao["proteinas"] ?? 0;
      int fibra = refeicao["fibras"] ?? 0;
      int gordura = refeicao["gorduras"] ?? 0;

      if (!snapshot.exists) {
        transaction.set(historicoRef, {
          "uid_usuario": _firestore.doc('usuarios/${usuario.uid}'),
          "uid_nutri": _firestore.doc('usuarios/HlvugqfKuxbBKBvOVo400YqfhUx1'),
          "data": agora,
          "agua": 0,
          "sono": {
            "inicio": null,
            "fim": null,
            "horas_totais": 0,
            "observacao": "",
          },
          "total_calorias": calorias,
          "total_carboidrato": carbo,
          "total_proteina": proteina,
          "total_fibra": fibra,
          "total_gordura": gordura,
          "horaAtualizacao": Timestamp.now(),
        });
      } else {
        final dados = snapshot.data()!;
        transaction.update(historicoRef, {
          "total_calorias": (dados["total_calorias"] ?? 0) + calorias,
          "total_carboidrato": (dados["total_carboidrato"] ?? 0) + carbo,
          "total_proteina": (dados["total_proteina"] ?? 0) + proteina,
          "total_fibra": (dados["total_fibra"] ?? 0) + fibra,
          "total_gordura": (dados["total_gordura"] ?? 0) + gordura,
          "horaAtualizacao": Timestamp.now(),
        });
      }
    });
  }

  // 🔹 Deleta refeição e subtrai do histórico
  Future<void> deletarRefeicao(String refeicaoId) async {
    try {
      final usuario = _auth.currentUser;
      if (usuario == null) return;

      final refeicaoDoc =
          await _firestore.collection('refeicoes').doc(refeicaoId).get();

      if (!refeicaoDoc.exists) return;

      final dados = refeicaoDoc.data()!;
      final calorias = dados["calorias"] ?? 0;
      final carbo = dados["carboidratos"] ?? 0;
      final proteina = dados["proteinas"] ?? 0;
      final fibra = dados["fibras"] ?? 0;
      final gordura = dados["gorduras"] ?? 0;

      final dataFormatada = DateFormat('yyyy-MM-dd')
          .format((dados["hora"] as Timestamp).toDate());
      final historicoRef = _firestore
          .collection('historico')
          .doc('${usuario.uid}_$dataFormatada');

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(historicoRef);
        if (snapshot.exists) {
          final hist = snapshot.data()!;
          transaction.update(historicoRef, {
            "total_calorias":
                ((hist["total_calorias"] ?? 0) - calorias).clamp(0, double.infinity),
            "total_carboidrato":
                ((hist["total_carboidrato"] ?? 0) - carbo).clamp(0, double.infinity),
            "total_proteina":
                ((hist["total_proteina"] ?? 0) - proteina).clamp(0, double.infinity),
            "total_fibra":
                ((hist["total_fibra"] ?? 0) - fibra).clamp(0, double.infinity),
            "total_gordura":
                ((hist["total_gordura"] ?? 0) - gordura).clamp(0, double.infinity),
            "horaAtualizacao": Timestamp.now(),
          });
        }
      });

      await _firestore.collection('refeicoes').doc(refeicaoId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao deletar refeição: $e');
    }
  }
}
