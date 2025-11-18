import 'package:app/widgets/barra_navegacao_nutri.dart';
import 'package:app/widgets/menu.dart';
import 'package:app/widgets/feed_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app/utils/color.dart';

class TelaHomeNutri extends StatefulWidget {
  const TelaHomeNutri({super.key});

  @override
  State<TelaHomeNutri> createState() => _TelaHomeNutriState();
}

class _TelaHomeNutriState extends State<TelaHomeNutri> {
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final uidNutri = _auth.currentUser?.uid;

    if (uidNutri == null) {
      return const Scaffold(
        body: Center(child: Text('Erro: Usuário não autenticado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(size: 30, color: AppColors.midGrey),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: AppColors.midGrey),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        actions: const [Menu()],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('refeicoes')
            .where('uid_nutri', isEqualTo: uidNutri)
            .orderBy('data', descending: true)
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
              child: Text('Nenhuma refeição registrada pelos seus pacientes.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final dados = docs[index].data() as Map<String, dynamic>;
              return FeedCard(
                dados: dados,
                docId: snapshot.data!.docs[index].id,
              );
            },
          );
        },
      ),

      bottomNavigationBar: const BarraNavegacaoNutri(),
    );
  }
}
