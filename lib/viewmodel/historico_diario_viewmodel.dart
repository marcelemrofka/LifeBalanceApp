import 'package:app/repository/historico_diario_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoricoDiarioViewModel extends ChangeNotifier {
  final HistoricoDiarioRepository repo;
  HistoricoDiarioViewModel({required this.repo});

  bool _loading = false;
  bool get loading => _loading;
  double? metaAgua;
  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  

  /// Função geral: verifica/cria e executa a ação.
  Future<void> ensureAndRun({
    required String uidUsuario,
    String? uidNutri,
    DateTime? day,
    required Future<void> Function(DocumentReference<Map<String, dynamic>> docRef) action,
  }) async {
    _setLoading(true);
    try {
      await repo.ensureDailyDoc(
        uidUsuario: uidUsuario,
        uidNutri: uidNutri,
        day: day,
        // Se criar agora, já executa action
        onCreate: (docRef) => action(docRef),
        // Se já existe, também executa action
        onExists: (docRef) => action(docRef),
      );
    } finally {
      _setLoading(false);
    }
  }

  /// EXEMPLO 1: inserir uma refeição (vindas da IA) e atualizar totais do dia
  Future<void> addRefeicao({
    required String uidUsuario,
    required String uidNutri,
    required Map<String, dynamic> refeicao, // {tipo, itens[], total_*}
    DateTime? day,
  }) async {
    await ensureAndRun(
      uidUsuario: uidUsuario,
      uidNutri: uidNutri,
      day: day,
      action: (docRef) async {
        // 1) adiciona a refeição como subdoc
        await docRef.collection('refeicoes').add(refeicao);

        // 2) atualiza agregados do dia com increment
        await docRef.update({
          'total_calorias'   : FieldValue.increment((refeicao['total_calorias'] ?? 0) as num),
          'total_proteina'   : FieldValue.increment((refeicao['total_proteina'] ?? 0) as num),
          'total_carboidrato': FieldValue.increment((refeicao['total_carboidrato'] ?? 0) as num),
          'total_gordura'    : FieldValue.increment((refeicao['total_lipideo'] ?? refeicao['total_gordura'] ?? 0) as num),
          'total_fibra'      : FieldValue.increment((refeicao['total_fibra'] ?? 0) as num),
        });
      },
    );
  }

  Future<void> carregarMetaAgua(String uidUsuario) async {
    final doc = await FirebaseFirestore.instance
        .collection('paciente')
        .doc(uidUsuario)
        .get();

    if (doc.exists) {
      metaAgua = (doc.data()?['meta_agua'] ?? 2000).toDouble();
      notifyListeners();
    }
  }

  /// Adiciona água ao histórico diário
  Future<void> registrarAgua({
    required String uidUsuario,
    String? uidNutri,
    required int quantidadeMl,
  }) async {
    _setLoading(true);
    try {
      await repo.addAgua(
        uidUsuario: uidUsuario,
        uidNutri: uidNutri,
        ml: quantidadeMl,
      );
    } finally {
      _setLoading(false);
    }
  }
}
