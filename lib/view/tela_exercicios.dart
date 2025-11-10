import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/widgets/custom_appbar.dart';
import '../services/openai_service_exercicios.dart';
import '../viewmodel/exercicio_view_model.dart';

//CHAVE OPENAI
const String openAiApiKey = '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';

class TelaExercicios extends StatefulWidget {
  const TelaExercicios({super.key});

  @override
  State<TelaExercicios> createState() => _TelaExerciciosState();
}

class _TelaExerciciosState extends State<TelaExercicios> {
  String tipoExercicio = 'Musculação';
  String intensidade = 'Média';
  TextEditingController tempoController = TextEditingController();
  double gastoCalorico = 0;

  int _converterTempoParaMinutos(String texto) {
    if (texto.isEmpty) return 0;
    return int.tryParse(texto) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(titulo: 'Exercícios'),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Cadastre Manualmente",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tipo de Exercício",
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButton<String>(
                        value: tipoExercicio,
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: Colors.white,
                        items: [
                          'Musculação',
                          'Corrida',
                          'Caminhada',
                          'Ciclismo',
                          'Natação'
                        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (value) {
                          setState(() => tipoExercicio = value!);
                        },
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Intensidade",
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 50,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: DropdownButton<String>(
                                    value: intensidade,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    dropdownColor: Colors.white,
                                    items: ['Baixa', 'Média', 'Alta']
                                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() => intensidade = value!);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Tempo de Exercício",
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 50,
                                child: TextField(
                                  controller: tempoController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  decoration: InputDecoration(
                                    hintText: "Ex: 60 min",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(Icons.access_time),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Image.asset(
                              'lib/images/exercicios.png',
                              height: 160,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Gasto Calórico",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF4B5D52),
                                ),
                              ),
                              const SizedBox(height: 5),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  gastoCalorico >= 0
                                      ? "Estimado: ${gastoCalorico.toStringAsFixed(0)} kcal"
                                      : "Calculando...",
                                  style: const TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: 130,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      setState(() => gastoCalorico = -1);

                                      int minutosTotais =
                                          _converterTempoParaMinutos(tempoController.text);

                                      final viewModel = ExercicioViewModel(
                                          openAIService: OpenAIServiceExercicios(
                                              apiKey: openAiApiKey));

                                      final gasto =
                                          await viewModel.calcularEAdicionarExercicio(
                                        tipoExercicio: tipoExercicio,
                                        intensidade: intensidade,
                                        tempoMinutos: minutosTotais,
                                      );

                                      setState(() => gastoCalorico = gasto);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Exercício adicionado com sucesso!')),
                                      );
                                    } catch (e) {
                                      setState(() => gastoCalorico = 0);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Erro: ${e.toString()}')),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF28C28),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: gastoCalorico == -1
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          "Adicionar",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
