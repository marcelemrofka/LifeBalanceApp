import 'package:app/utils/color.dart';
import 'package:app/widgets/barra_navegacao.dart';
import 'package:app/widgets/caixa.dart';
import 'package:app/widgets/carrossel.dart';
import 'package:app/widgets/dashboard.dart';
import 'package:app/widgets/drawer.dart';
import 'package:app/widgets/lembretes.dart';
import 'package:app/widgets/menu.dart';
import 'package:app/widgets/water_circle_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TelaHome extends StatefulWidget {
  const TelaHome({super.key});

  @override
  State<TelaHome> createState() => _TelaHomeState();
}

class _TelaHomeState extends State<TelaHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(size: 45, color: AppColors.midGrey),
        actions: const [Menu()],
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(13),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Dashboard(uidPaciente: FirebaseAuth.instance.currentUser?.uid),
          const SizedBox(height: 20),
          const Carrossel(),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Caixa(titulo: 'Lembretes', conteudo: LembretesWidget()),
            SizedBox(width: 3),
            Caixa(
                titulo: 'Água',
                conteudo: WaterCircleViewModel(
                    scale: 0.95,
                    uidPaciente: FirebaseAuth.instance.currentUser?.uid))
          ]),
          const SizedBox(height: 20),
          // Caixa de Exercícios larga
          Caixa(
            titulo: 'Exercícios',
            conteudo: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('exercicios')
                  .where('uidPaciente',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum exercício registrado',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final exercicios = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: exercicios.length,
                  itemBuilder: (context, index) {
                    final ex = exercicios[index].data();
                    final data = (ex['data'] as Timestamp).toDate();
                    final dataFormatada =
                        '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}';
                    final tipo = ex['tipoExercicio'] ?? 'Exercício';
                    final calorias = ex['gastoCalorico'] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              tipo,
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Text(
                              dataFormatada,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),

                          // 🔹 Coluna 3: calorias
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                '${calorias.toString()} kcal',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            altura: 180,
            largura: double.infinity,
          ),
        ]),
      ),
      bottomNavigationBar: const BarraNavegacao(),
    );
  }
}
