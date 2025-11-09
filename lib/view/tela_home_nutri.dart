import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:app/utils/color.dart';

class TelaHomeNutri extends StatefulWidget {
  const TelaHomeNutri({Key? key}) : super(key: key);

  @override
  State<TelaHomeNutri> createState() => _TelaHomeNutriState();
}

class _TelaHomeNutriState extends State<TelaHomeNutri> {
  final _auth = FirebaseAuth.instance;

  String _tempoDecorrido(DateTime hora) {
    final diff = DateTime.now().difference(hora);
    if (diff.inMinutes < 60) {
      return 'há ${diff.inMinutes} min';
    } else if (diff.inHours < 24) {
      return 'há ${diff.inHours} h';
    } else {
      return DateFormat('dd/MM').format(hora);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uidNutri = _auth.currentUser?.uid;

    if (uidNutri == null) {
      return const Scaffold(
        body: Center(child: Text('Erro: Usuário não autenticado')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Refeições dos Pacientes',
            style: TextStyle(color: Colors.black87, fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
    .collection('refeicoes')
    .where('uid_nutri', isEqualTo: uidNutri)
    .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar refeições'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
                child: Text('Nenhuma refeição registrada pelos pacientes.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final dados = docs[index].data() as Map<String, dynamic>;

              final nome = dados['nome'] ?? 'Refeição';
              final tipo = dados['tipoRefeicao'] ?? '';
              final imagem = dados['imagemUrl'] ?? '';
              final proteinas = dados['proteinas'] ?? 0;
              final carboidratos = dados['carboidratos'] ?? 0;
              final gorduras = dados['gorduras'] ?? 0;
              final fibras = dados['fibras'] ?? 0;
              final uidPaciente = dados['uid'];
              final hora = dados['hora'];

              DateTime horaConvertida;
              if (hora is Timestamp) {
                horaConvertida = hora.toDate();
              } else if (hora is String) {
                // caso esteja salvo como texto
                horaConvertida = DateTime.tryParse(hora) ?? DateTime.now();
              } else {
                horaConvertida = DateTime.now();
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('paciente')
                    .doc(uidPaciente)
                    .get(),
                builder: (context, pacienteSnap) {
                  if (!pacienteSnap.hasData) {
                    return const SizedBox();
                  }

                  final pacienteData =
                      pacienteSnap.data!.data() as Map<String, dynamic>?;
                  final nomePaciente = pacienteData?['nome'] ?? 'Paciente';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabeçalho
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person,
                                      color: AppColors.principal, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    nomePaciente,
                                    style: const TextStyle(
                                      color: AppColors.principal,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _tempoDecorrido(horaConvertida),
                                style: const TextStyle(
                                    color: Colors.black38, fontSize: 12),
                              ),
                            ],
                          ),
                        ),

                        // Imagem
                        if (imagem.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8)),
                            child: Image.network(
                              imagem,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        // Dados nutricionais
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tipo,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 20,
                                runSpacing: 4,
                                children: [
                                  Text('• Proteínas: ${proteinas} g'),
                                  Text('• Carboidratos: ${carboidratos} g'),
                                  Text('• Gorduras: ${gorduras} g'),
                                  Text('• Fibras: ${fibras} g'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Adicionar comentário
                        const Divider(height: 1, color: Colors.black12),
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            "Adicionar comentário",
                            style: TextStyle(
                                color: Colors.black38, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
