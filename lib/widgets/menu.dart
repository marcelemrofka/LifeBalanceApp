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

      // Verifica primeiro se o UID está na coleção 'nutricionistas'
      final docNutri =
          await firestore.collection('nutricionista').doc(user.uid).get();

      if (docNutri.exists) {
        Navigator.pushNamed(context, '/tela_perfil_nutri');
        return;
      }

      // Se não for nutricionista, tenta buscar em 'pacientes'
      final docPaciente =
          await firestore.collection('paciente').doc(user.uid).get();

      if (docPaciente.exists) {
        Navigator.pushNamed(context, '/tela_perfil');
      } else {
        // Caso não esteja em nenhuma coleção (erro ou conta nova)
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // fundo branco fixo
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              size: 45,
              color: AppColors.midGrey,
            ),
            onPressed: () => _irParaPerfil(context),
          ),
        ],
      ),
    );
  }
}
