import 'package:app/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/utils/color.dart';
import 'package:app/repository/historico_diario_repository.dart';

class TelaSono extends StatefulWidget {
  @override
  _TelaSonoState createState() => _TelaSonoState();
}

class _TelaSonoState extends State<TelaSono> {
  final user = FirebaseAuth.instance.currentUser;
  final _repository = HistoricoDiarioRepository();
  TimeOfDay? _inicio;
  TimeOfDay? _fim;
  final _obsController = TextEditingController();
  double? _horasTotais;

  @override
  void initState() {
    super.initState();
    if (user != null) _carregarDadosSono();
  }

  Future<void> _carregarDadosSono() async {
    if (user == null) return;

    final dados = await _repository.getSono(uidUsuario: user!.uid);
    if (dados != null) {
      setState(() {
        if (dados['inicio'] != null) {
          final inicio = (dados['inicio'] as DateTime);
          _inicio = TimeOfDay(hour: inicio.hour, minute: inicio.minute);
        }
        if (dados['fim'] != null) {
          final fim = (dados['fim'] as DateTime);
          _fim = TimeOfDay(hour: fim.hour, minute: fim.minute);
        }
        _obsController.text = dados['observacao'] ?? '';

        // Calcula se já houver dados salvos
        if (_inicio != null && _fim != null) {
          final inicioDT = _criarDateTime(_inicio!);
          final fimDT = _criarDateTime(_fim!);
          _horasTotais = _calcularHorasSono(inicioDT, fimDT);
        }
      });
    }
  }

  double _calcularHorasSono(DateTime inicio, DateTime fim) {
    var diferenca = fim.difference(inicio);
    if (diferenca.isNegative) {
      // Caso o sono comece antes da meia-noite e termine depois
      diferenca = diferenca + const Duration(days: 1);
    }
    return diferenca.inMinutes / 60.0;
  }

  DateTime _criarDateTime(TimeOfDay hora) {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day, hora.hour, hora.minute);
  }

  Future<void> _salvarSono() async {
    if (user == null || _inicio == null || _fim == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Por favor, selecione os horários de início e fim do sono")),
      );
      return;
    }

    try {
      final inicio = _criarDateTime(_inicio!);
      final fim = _criarDateTime(_fim!);
      final horasTotais = _horasTotais ?? _calcularHorasSono(inicio, fim);

      await _repository.registrarSono(
        uidUsuario: user!.uid,
        uidNutri: 'default',
        inicio: inicio,
        fim: fim,
        horasTotais: horasTotais,
        observacao: _obsController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Registro de sono salvo com sucesso! Total: ${horasTotais.toStringAsFixed(1)}h"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar o registro de sono: $e")),
      );
    }
  }

  Future<void> _selecionarHora({
    required TimeOfDay initialTime,
    required Function(TimeOfDay) onSelected,
  }) async {
    final selecionada = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selecionada != null) {
      setState(() {
        onSelected(selecionada);
        if (_inicio != null && _fim != null) {
          final inicioDT = _criarDateTime(_inicio!);
          final fimDT = _criarDateTime(_fim!);
          _horasTotais = _calcularHorasSono(inicioDT, fimDT);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(titulo: 'Sono'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Registre suas horas de descanso",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // Campos de horário
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Início",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _selecionarHora(
                            initialTime: TimeOfDay.now(),
                            onSelected: (hora) {
                              _inicio = hora;
                            },
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.white,
                            ),
                            child: Text(
                              _inicio != null
                                  ? _inicio!.format(context)
                                  : "   :   ",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Fim",
                            style:
                                TextStyle(fontSize: 14, color: Colors.black)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => _selecionarHora(
                            initialTime: TimeOfDay.now(),
                            onSelected: (hora) {
                              _fim = hora;
                            },
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.white,
                            ),
                            child: Text(
                              _fim != null ? _fim!.format(context) : "   :   ",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "Observação",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              const SizedBox(height: 6),

              TextField(
                controller: _obsController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  // Corrigido o caminho da imagem
                  Image.asset(
                    'lib/images/sono.png',
                    height: 150,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 60);
                    },
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _horasTotais != null
                            ? "Total de horas de sono: ${_horasTotais!.toStringAsFixed(1)}h"
                            : "Total de horas de sono:    ",
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.laranja,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: _salvarSono,
                        child: const Text(
                          "Salvar",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
