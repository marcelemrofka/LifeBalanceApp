import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoricoDiarioRepository {
  final FirebaseFirestore _db;
  HistoricoDiarioRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Converte DateTime local para chave yyyy-MM-dd
  String _dayKey(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  /// Caminho do doc diário
  DocumentReference<Map<String, dynamic>> _docRef(String uid, DateTime day) {
    final key = _dayKey(day.toLocal());
    return _db.collection('historico').doc('${uid}_$key');
  }

  /// Garante que o documento diário exista.
  /// - Se não existir: cria com campos mínimos e chama onCreate
  /// - Se existir: chama onExists
  Future<DocumentReference<Map<String, dynamic>>> ensureDailyDoc({
    required String uidUsuario,
    String? uidNutri,
    DateTime? day,
    Future<void> Function(DocumentReference<Map<String, dynamic>> docRef)?
        onCreate,
    Future<void> Function(DocumentReference<Map<String, dynamic>> docRef)?
        onExists,
  }) async {
    final now = (day ?? DateTime.now()).toLocal();
    final docRef = _docRef(uidUsuario, now);

    final snap = await docRef.get();

    if (!snap.exists) {
      // cria base do dia
      final base = <String, dynamic>{
        'uid_usuario': _db.doc('paciente/$uidUsuario'),
        'data': Timestamp.fromDate(now),
        // totais do dia começam em 0
        'total_calorias': 0,
        'total_proteina': 0,
        'total_carboidrato': 0,
        'total_gordura': 0,
        'total_fibra': 0,
        // outros agregados diários
        'agua': 0,
        'sono': 0,
      };

      // adiciona uid_nutri apenas se fornecido
      if (uidNutri != null && uidNutri.isNotEmpty) {
        base['uid_nutri'] = _db.doc('nutricionista/$uidNutri');
      }

      await docRef.set(base, SetOptions(merge: true));

      if (onCreate != null) {
        await onCreate(docRef);
      }
    } else {
      if (onExists != null) {
        await onExists(docRef);
      }
    }

    return docRef;
  }

  Future<void> addAgua({
    required String uidUsuario,
    String? uidNutri,
    required int ml,
  }) async {
    // garante que o doc diário existe
    await ensureDailyDoc(
      uidUsuario: uidUsuario,
      uidNutri: uidNutri,
      onCreate: (docRef) async {
        // Usa set com merge para o documento novo
        await docRef.set({'agua': ml}, SetOptions(merge: true));
      },
      onExists: (docRef) async {
        // Usa update para incrementar valor existente
        await docRef.update({
          'agua': FieldValue.increment(ml),
        });
      },
    );
  }

  Future<void> registrarSono({
    required String uidUsuario,
    String? uidNutri,
    required DateTime inicio,
    required DateTime fim,
    required double horasTotais,
    String? observacao,
  }) async {
    await ensureDailyDoc(
      uidUsuario: uidUsuario,
      uidNutri: uidNutri,
      onCreate: (docRef) async {
        await docRef.set({
          'sono': {
            'inicio': Timestamp.fromDate(inicio),
            'fim': Timestamp.fromDate(fim),
            'horas_totais': horasTotais,
            'observacao': observacao,
          }
        }, SetOptions(merge: true));
      },
      onExists: (docRef) async {
        await docRef.update({
          'sono': {
            'inicio': Timestamp.fromDate(inicio),
            'fim': Timestamp.fromDate(fim),
            'horas_totais': horasTotais,
            'observacao': observacao,
          }
        });
      },
    );
  }

  Future<Map<String, dynamic>?> getSono({
    required String uidUsuario,
    DateTime? day,
  }) async {
    final now = (day ?? DateTime.now()).toLocal();
    final docRef = _docRef(uidUsuario, now);
    final snap = await docRef.get();

    if (snap.exists) {
      final data = snap.data();
      return data?['sono'] as Map<String, dynamic>?;
    }
    return null;
  }
}
