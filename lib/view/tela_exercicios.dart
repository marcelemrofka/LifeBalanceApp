import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/widgets/custom_appbar.dart';

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

  void calcularGasto() {
    String texto = tempoController.text.toLowerCase().replaceAll(' ', '');
    int minutosTotais = 0;

    final horasMatch = RegExp(r'(\d+)h').firstMatch(texto);
    final minutosMatch = RegExp(r'(\d+)min').firstMatch(texto);

    if (horasMatch != null) minutosTotais += int.parse(horasMatch.group(1)!) * 60;
    if (minutosMatch != null) minutosTotais += int.parse(minutosMatch.group(1)!);

    double fatorIntensidade = 1.0;
    if (intensidade == 'Baixa') fatorIntensidade = 0.8;
    if (intensidade == 'Alta') fatorIntensidade = 1.2;

    gastoCalorico = minutosTotais * fatorIntensidade * 8;
    setState(() {});
  }

  void formatarTempo(String value) {
    if (value.isEmpty) {
      tempoController.value = const TextEditingValue(text: '');
      setState(() {
        gastoCalorico = 0;
      });
      return;
    }

    String digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    String formatado = '';

    if (digits.length <= 2) {
      formatado = '${int.parse(digits)}min';
    } else if (digits.length <= 4) {
      String horas = digits.substring(0, digits.length - 2);
      String minutos = digits.substring(digits.length - 2);
      int h = int.parse(horas);
      int m = int.parse(minutos);
      if (m == 0) {
        formatado = '${h}h';
      } else {
        formatado = '${h}h${m}min';
      }
    } else {
      formatado = '${digits.substring(0, 2)}h${digits.substring(2, 4)}min';
    }

    tempoController.value = TextEditingValue(
      text: formatado,
      selection: TextSelection.collapsed(offset: formatado.length),
    );

    calcularGasto();
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
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 40,
              ),
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
                          color: Colors.black87),
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
                        items: ['Musculação', 'Corrida', 'Caminhada', 'Ciclismo', 'Natação']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
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
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        intensidade = value!;
                                        calcularGasto();
                                      });
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
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: formatarTempo,
                                  decoration: InputDecoration(
                                    hintText: "Ex: 1h15min",
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
                                  "Estimado: ${gastoCalorico.toStringAsFixed(0)} kcal",
                                  style: const TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: 130,
                                height: 45,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF28C28),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "Adicionar",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
