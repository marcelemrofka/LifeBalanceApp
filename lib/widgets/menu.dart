import 'package:app/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  Future<void> _irParaPerfil(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final firestore = FirebaseFirestore.instance;

      final docNutri = await firestore.collection('nutricionista').doc(user.uid).get();
      if (docNutri.exists) {
        Navigator.pushNamed(context, '/tela_perfil_nutri');
        return;
      }

      final docPaciente = await firestore.collection('paciente').doc(user.uid).get();
      if (docPaciente.exists) {
        Navigator.pushNamed(context, '/tela_perfil');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não encontrado.')),
        );
      }
    } catch (e) {
      debugPrint('Erro ao verificar tipo de usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar perfil.')),
      );
    }
  }

  Stream<DocumentSnapshot> _getUserStream(String uid) {
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('nutricionista')
        .doc(uid)
        .snapshots()
        .asyncExpand((nutriDoc) {
      if (nutriDoc.exists) {
        return Stream.value(nutriDoc);
      }
      return firestore.collection('paciente').doc(uid).snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => _irParaPerfil(context),
            child: StreamBuilder<DocumentSnapshot>(
              stream: _getUserStream(uid!),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const CircleAvatar(
                    radius: 22,
                    backgroundImage: AssetImage('lib/images/logo-circulo.png'),
                  );
                }

                final dados = snapshot.data!.data() as Map<String, dynamic>;
                final imagem = dados['imagemPerfil'];

                return CircleAvatar(
                  radius: 22,
                  backgroundImage: (imagem != null && imagem.isNotEmpty)
                      ? NetworkImage(imagem)
                      : const AssetImage('lib/images/logo-circulo.png')
                          as ImageProvider,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
