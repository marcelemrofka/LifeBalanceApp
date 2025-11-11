import 'package:app/utils/color.dart';
import 'package:app/view/tela_perfil.dart';
import 'package:app/widgets/caixa.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/dashboard.dart';
import 'package:app/widgets/water_circle_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TelaDiarioPaciente extends StatefulWidget {
  final String uidPaciente;

  const TelaDiarioPaciente({super.key, required this.uidPaciente});

  @override
  State<TelaDiarioPaciente> createState() => _TelaDiarioPacienteState();
}

class _TelaDiarioPacienteState extends State<TelaDiarioPaciente> {
  String nomePaciente = '';
  double? metaAgua;
  double? metaCalorias;
  double totalAgua = 0;
  bool carregando = true;
  String uidPaciente = '';

  @override
  void initState() {
    super.initState();
    _carregarDadosPaciente();
  }

  Future<void> _carregarDadosPaciente() async {
    try {
      // Consulta dados do paciente
      final pacienteDoc = await FirebaseFirestore.instance
          .collection('paciente')
          .doc(widget.uidPaciente)
          .get();

      if (pacienteDoc.exists) {
        final data = pacienteDoc.data()!;
        setState(() {
          nomePaciente = data['nome'] ?? 'Paciente';
          metaAgua = (data['meta_agua'] ?? 2000).toDouble();
          uidPaciente = pacienteDoc.id;
        });
      }

      // Consulta o histórico do dia atual (água)
      final dataAtual = DateTime.now();
      final dataFormatada =
          '${dataAtual.year}-${dataAtual.month.toString().padLeft(2, '0')}-${dataAtual.day.toString().padLeft(2, '0')}';
      // Configura stream para atualizações em tempo real do histórico
      final docId = "${uidPaciente}_$dataFormatada";

      final historicoDoc = await FirebaseFirestore.instance
          .collection('historico')
          .doc(docId)
          .collection('agua')
          .doc(dataFormatada)
          .get();

      if (historicoDoc.exists) {
        setState(() {
          totalAgua = (historicoDoc.data()?['total_ingerido'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados do paciente: $e');
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          titulo: nomePaciente.isEmpty ? 'Carregando...' : nomePaciente),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: carregando
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Dashboard(uidPaciente: widget.uidPaciente),
                    const SizedBox(height: 20),
                    const SizedBox(height: 10),
                    Caixa(
                      titulo:
                          'Meta de Água: ${metaAgua?.toStringAsFixed(0)} ml',
                      conteudo: WaterCircleViewModel(
                          scale: 0.8, uidPaciente: widget.uidPaciente),
                      altura: 180,
                      largura: double.infinity,
                    ),
                    const SizedBox(height: 20),

                    Caixa(
                      titulo: 'Exercícios',
                      conteudo: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('exercicios')
                            .where('uidPaciente', isEqualTo: widget.uidPaciente)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                    const SizedBox(height: 30),

                    // Botões inferiores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.laranja, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Plano Alimentar',
                              style: TextStyle(
                                color: AppColors.laranja,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.laranja, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Ficha Completa',
                              style: TextStyle(
                                color: AppColors.laranja,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    ElevatedButton(
                      onPressed: () {
                                                if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                TelaPerfil(uidPaciente: widget.uidPaciente),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.laranja,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Editar Paciente',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }
}
