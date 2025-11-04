import 'package:app/utils/color.dart';
import 'package:app/view/tela_perfil.dart';
import 'package:app/widgets/barra_navegacao_nutri.dart';
import 'package:app/widgets/menu.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TelaPacientes extends StatelessWidget {
  const TelaPacientes({super.key});

  @override
  Widget build(BuildContext context) {
    final String? nutriUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          iconTheme: IconThemeData(size: 45, color: AppColors.midGrey),
          actions: const [Menu()],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('paciente')
              .where('nutricionista_uid', isEqualTo: nutriUid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Erro ao carregar pacientes"));
            }

            final pacientes = snapshot.data?.docs ?? [];

            if (pacientes.isEmpty) {
              return const Center(child: Text("Nenhum paciente cadastrado."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pacientes.length,
              itemBuilder: (context, index) {
                final paciente =
                    pacientes[index].data() as Map<String, dynamic>;
                final nome = paciente['nome'] ?? 'Sem nome';
                final email = paciente['email'] ?? '';
                final imagem = paciente['imagemPerfil'];

                return Card(
                  elevation: 2,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: imagem != null && imagem.isNotEmpty
                          ? NetworkImage(imagem)
                          : const AssetImage('lib/images/logo-circulo.png')
                              as ImageProvider,
                    ),
                    title: Text(nome,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(email),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        color: AppColors.laranja),
                    onTap: () {
                      final pacienteUid = pacientes[index].id;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TelaPerfil(uidPaciente: pacienteUid),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/tela_cadastro_pacientes');
          },
          backgroundColor: AppColors.laranja,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        bottomNavigationBar: const BarraNavegacaoNutri());
  }
}
