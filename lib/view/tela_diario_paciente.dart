import 'package:app/utils/color.dart';
import 'package:app/widgets/dashboard.dart';
import 'package:app/widgets/water_circle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TelaDiarioPaciente extends StatefulWidget {
  final String uidPaciente;

  const TelaDiarioPaciente({super.key, required this.uidPaciente});

  @override
  State<TelaDiarioPaciente> createState() => _TelaDiarioPacienteState();
}

class _TelaDiarioPacienteState extends State<TelaDiarioPaciente> {
  double? metaAgua;
  double? metaCalorias;
  double totalAgua = 0;

  @override
  void initState() {
    super.initState();
    _carregarDadosPaciente();
  }

  Future<void> _carregarDadosPaciente() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('paciente')
          .doc(widget.uidPaciente)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          metaAgua = (data['meta_agua'] ?? 2000).toDouble();
          metaCalorias = (data['meta_calorias'] ?? 2000).toDouble();
        });
      }

      // Carrega o histórico diário de água (caso queira exibir o progresso)
      final historico = await FirebaseFirestore.instance
          .collection('historico')
          .doc(widget.uidPaciente)
          .collection('agua')
          .doc(DateTime.now().toIso8601String().substring(0, 10)) // formato YYYY-MM-DD
          .get();

      if (historico.exists) {
        setState(() {
          totalAgua = (historico.data()?['total_ingerido'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar dados do paciente: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: metaAgua == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botão voltar
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.principal,
                          shape: const CircleBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Dashboard(),
                    const SizedBox(height: 20),

                    Text(
                      'Meta Calórica: ${metaCalorias?.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Card de Água
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Água",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 160,
                            child: Center(
                              child: WaterCircleWidget(
                                totalIngerido: totalAgua,
                                capacidadeTotal: metaAgua ?? 2000,
                                animation: const AlwaysStoppedAnimation<double>(0.0),
                                waveAnimation:
                                    const AlwaysStoppedAnimation<double>(0.0),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${totalAgua.toStringAsFixed(0)} / ${metaAgua?.toStringAsFixed(0)} ml',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card de Exercícios
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Exercícios",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.laranja, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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
                              side: BorderSide(color: AppColors.laranja, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
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
                      onPressed: () {},
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
