import 'package:app/utils/color.dart';
import 'package:app/view/tela_diario_paciente.dart';
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
        iconTheme: const IconThemeData(size: 45, color: AppColors.midGrey),
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
              final pacienteDoc = pacientes[index];
              final paciente = pacienteDoc.data() as Map<String, dynamic>;
              final nome = paciente['nome'] ?? 'Sem nome';
              final email = paciente['email'] ?? '';
              final imagem = paciente['imagemPerfil'];
              final pacienteUid = pacienteDoc.id;

              return Dismissible(
                key: Key(pacienteUid),
                direction: DismissDirection
                    .endToStart, // deslizar da direita para a esquerda
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red.shade400,
                  child:
                      const Icon(Icons.link_off, color: Colors.white, size: 32),
                ),

                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Desvincular paciente"),
                      content: Text(
                        "Você realmente deseja desvincular o paciente $nome?",
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Cancelar"),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        TextButton(
                          child: const Text(
                            "Desvincular",
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                      ],
                    ),
                  );
                },

                onDismissed: (direction) async {
                  try {
                    final pacienteRef = FirebaseFirestore.instance
                        .collection('paciente')
                        .doc(pacienteUid);

                    final pacienteData = await pacienteRef.get();
                    final relacaoRef =
                        pacienteData['relacao_nutri_paciente_ref'];

                    // 🔹 1. Remove vínculo do paciente
                    await pacienteRef.update({
                      'nutricionista_uid': FieldValue.delete(),
                      'relacao_nutri_paciente_ref': FieldValue.delete(),
                    });

                    // 🔹 2. Atualiza documento da relação (data_fim + esta_ativo=false)
                    if (relacaoRef != null) {
                      await relacaoRef.update({
                        'data_fim': DateTime.now(),
                        'esta_ativo': false,
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Paciente $nome desvinculado."),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erro ao desvincular o paciente."),
                        backgroundColor: Colors.red.shade400,
                      ),
                    );
                  }
                },

                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: imagem != null && imagem.isNotEmpty
                          ? NetworkImage(imagem)
                          : const AssetImage('lib/images/logo-circulo.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(email),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.laranja,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TelaDiarioPaciente(
                            uidPaciente: pacienteUid,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/tela_cadastro_paciente');
        },
        backgroundColor: AppColors.laranja,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BarraNavegacaoNutri(),
    );
  }
}
