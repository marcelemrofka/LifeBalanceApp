import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LembretesWidget extends StatelessWidget {
  const LembretesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text('Faça login para ver seus lembretes'),
      );
    }

    final uid = user.uid;

    return  StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lembretes')
                  .where('uid_usuario', isEqualTo: uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'Erro ao carregar lembretes',
                    style: TextStyle(color: Colors.black54),
                  );
                }

                final lembretes = snapshot.data?.docs ?? [];

                if (lembretes.isEmpty) {
                  return const Text(
                    'Nenhum lembrete próximo.',
                    style: TextStyle(color: Colors.black54),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: lembretes.map((doc) {
                    final dados = doc.data() as Map<String, dynamic>;

                    DateTime? data;
                    final rawData = dados['data'];
                    if (rawData is Timestamp) {
                      data = rawData.toDate();
                    } else if (rawData is String) {
                      try {
                        data = DateTime.parse(rawData);
                      } catch (_) {
                        data = null;
                      }
                    }

                    if (data == null) return const SizedBox.shrink();

                    final titulo = dados['titulo'] ?? '';
                    final hora = dados['hora'] ?? '';
                    final dataFormatada =
                        "${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}";

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Text(
                            '$dataFormatada - $titulo ${hora.isNotEmpty ? '- $hora' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Divider(
                          color: Color(0xFFB9E0C6), // tom verde suave
                          thickness: 0.7,
                          height: 0,
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            );
  }
  }
