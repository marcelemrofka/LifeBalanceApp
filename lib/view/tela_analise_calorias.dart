// lib/pages/tela_analise_calorias.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/openai_service.dart';
import '../widgets/image_picker_buttons.dart';
import 'package:app/utils/color.dart';

class TelaAnaliseCalorias extends StatefulWidget {
  const TelaAnaliseCalorias({super.key});

  @override
  State<TelaAnaliseCalorias> createState() => _TelaAnaliseCaloriasState();
}

class _TelaAnaliseCaloriasState extends State<TelaAnaliseCalorias> {
  File? _imagem;
  String _resultado = '';
  bool _carregando = false;
  bool _naoConcorda = false;
  bool _resultadoManualGerado = false;

  List<Map<String, dynamic>> alimentos = [];

  final TextEditingController alimentoController = TextEditingController();
  final TextEditingController quantidadeController = TextEditingController();

  Future<void> _processarImagem(File imagem) async {
    setState(() {
      _imagem = imagem;
      _carregando = true;
      _resultado = '';
      _naoConcorda = false;
      _resultadoManualGerado = false;
      alimentos.clear();
    });

    final resposta = await analisarImagem(imagem);

    setState(() {
      _resultado = resposta;
      _carregando = false;
    });
  }

  void _adicionarAlimento() {
    if (alimentoController.text.isNotEmpty &&
        quantidadeController.text.isNotEmpty) {
      setState(() {
        alimentos.add({
          "alimento": alimentoController.text,
          "quantidade": quantidadeController.text,
        });
        alimentoController.clear();
        quantidadeController.clear();
      });
    }
  }

  Future<void> _recalcular() async {
    if (alimentos.isEmpty) return;

    setState(() {
      _carregando = true;
      _resultado = '';
    });

    final resposta = await analisarAlimentosManuais(alimentos);

    setState(() {
      _resultado = resposta;
      _carregando = false;
      _resultadoManualGerado = true;
      _naoConcorda = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30)),
          child: AppBar(
            backgroundColor: AppColors.verdeBg,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Análise de Calorias',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Botões de escolher imagem
              if (!_carregando && _resultado.isEmpty)
                ImagePickerButtons(onImageSelected: _processarImagem),

              const SizedBox(height: 16),

              // Mostrar imagem selecionada
              if (_imagem != null)
                Center(child: Image.file(_imagem!, height: 200)),

              const SizedBox(height: 16),

              // Loading
              if (_carregando)
                const CircularProgressIndicator()

              // Resultado
              else if (_resultado.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // TEXTO FIXO
                        const Text(
                          "QUANTIDADES DE CALORIAS ESTIMADAS NA REFEIÇÃO",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Resultado da IA
                        Text(
                          _resultado,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),

                        // Botão Adicionar Refeição (aparece se resultado manual gerado ou não concorda processado)
                        if (_resultadoManualGerado)
                          ElevatedButton(
                            onPressed: () {
                              // TODO: salvar a refeição
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdeBg,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Adicionar Refeição"),
                          ),

                        // Campos manuais
                        if (_naoConcorda && !_resultadoManualGerado) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: alimentoController,
                            decoration: const InputDecoration(
                              labelText: "Alimento",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: quantidadeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: "Quantidade (g)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _adicionarAlimento,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdeBg,
                            ),
                            child: const Text("+ Adicionar alimento"),
                          ),
                          const SizedBox(height: 20),
                          if (alimentos.isNotEmpty)
                            Column(
                              children: alimentos.map((item) {
                                return ListTile(
                                  title: Text(item['alimento']),
                                  subtitle: Text("${item['quantidade']} g"),
                                );
                              }).toList(),
                            ),
                          ElevatedButton(
                            onPressed: _recalcular,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verdeBg,
                            ),
                            child: const Text("OK"),
                          ),
                        ],

                        // Botões Concordo / Não Concordo (aparecem apenas se resultado veio da IA da imagem)
                        if (!_resultadoManualGerado && !_naoConcorda)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Resultado confirmado")),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.verdeBg,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Concordo'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _naoConcorda = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.verdeBg,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Não Concordo'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
