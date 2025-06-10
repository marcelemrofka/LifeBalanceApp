import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TelaHistoricoRefeicoes extends StatefulWidget {
  const TelaHistoricoRefeicoes({super.key});

  @override
  State<TelaHistoricoRefeicoes> createState() => _TelaHistoricoRefeicoesState();
}

class _TelaHistoricoRefeicoesState extends State<TelaHistoricoRefeicoes> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> historico = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    buscarHistorico();
  }

  Future<void> buscarHistorico() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        historico = [];
        carregando = false;
      });
      return;
    }

    try {
      final usuarioRef = _firestore.doc('usuarios/${user.uid}');

      final snapshot = await _firestore
          .collection('refeicoes')
          .where('usuario', isEqualTo: usuarioRef)
          .get();

      final lista = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'nome': data['nome'] ?? 'Sem nome',
          'alimentos': (data['alimentos'] as List<dynamic>?) ?? [],
        };
      }).toList();

      setState(() {
        historico = lista;
        carregando = false;
      });
    } catch (e) {
      print('Erro ao buscar histórico: $e');
      setState(() {
        historico = [];
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (historico.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Nenhuma refeição registrada.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Refeições')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: historico.length,
        itemBuilder: (context, index) {
          final refeicao = historico[index];
          final alimentos = refeicao['alimentos'] as List<dynamic>;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    refeicao['nome'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...alimentos.map((a) => Text("- ${a['nome'] ?? 'Sem nome'}")).toList(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
