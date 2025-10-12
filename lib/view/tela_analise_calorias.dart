// lib/pages/tela_analise_calorias.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/openai_service.dart';
import '../widgets/image_picker_buttons.dart';
import '../utils/color.dart';
import '../viewmodel/refeicao_vm.dart';

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
  bool _fluxoManualFinalizado = false; // NOVO

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
      _fluxoManualFinalizado = false;
      alimentos.clear();
    });

    final resposta = await analisarImagem(imagem);

    setState(() {
      _resultado = resposta;
      _carregando = false;
      alimentos = _extrairAlimentosDoResultado(_resultado);
    });
  }

  void _adicionarAlimento() {
    if (alimentoController.text.isNotEmpty &&
        quantidadeController.text.isNotEmpty) {
      setState(() {
        alimentos.add({
          "alimento": alimentoController.text,
          "quantidade": int.tryParse(quantidadeController.text) ?? 0,
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
      _fluxoManualFinalizado = true; // marca que o fluxo manual terminou
    });
  }

  List<Map<String, dynamic>> _extrairAlimentosDoResultado(String resultado) {
    List<Map<String, dynamic>> lista = [];
    final linhas = resultado.split('\n');
    for (var linha in linhas) {
      if (!linha.contains(':')) continue;
      final partes = linha.split(':');
      final nome = partes[0].trim();
      final qtdStr = partes[1].replaceAll(RegExp(r'[^0-9]'), '');
      final quantidade = int.tryParse(qtdStr) ?? 0;
      lista.add({'alimento': nome, 'quantidade': quantidade});
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final tipoRefeicao = args != null && args['tipoRefeicao'] != null
        ? args['tipoRefeicao'] as String
        : 'Refeição';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.only(bottomLeft: Radius.circular(30)),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Fluxo padrão: tirar foto ou galeria
                    if (!_naoConcorda) ...[
                      if (!_carregando && _resultado.isEmpty)
                        ImagePickerButtons(onImageSelected: _processarImagem),
                      const SizedBox(height: 16),
                      if (_imagem != null)
                        Center(child: Image.file(_imagem!, height: 200)),
                      if (_carregando) const CircularProgressIndicator(),
                      if (_resultado.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          "QUANTIDADES DE CALORIAS ESTIMADAS NA REFEIÇÃO",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _resultado,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (alimentos.isEmpty) {
                              alimentos =
                                  _extrairAlimentosDoResultado(_resultado);
                            }
                            Provider.of<RefeicaoViewModel>(context,
                                    listen: false)
                                .adicionarRefeicao(
                              tipoRefeicao: tipoRefeicao,
                              resultado: _resultado,
                              alimentos: alimentos,
                            );
                            Navigator.pushReplacementNamed(
                                context, '/tela_refeicao');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verdeBg,
                          ),
                          child: const Text("Adicionar Refeição"),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _naoConcorda = true;
                              _resultado = '';
                              _imagem = null;
                              alimentos.clear();
                              _fluxoManualFinalizado = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verdeBg,
                          ),
                          child: const Text('Não Concordo'),
                        ),
                      ],
                    ],

                    // Fluxo "Não Concordo" antes de clicar OK
                    if (_naoConcorda && !_fluxoManualFinalizado) ...[
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
                          children: alimentos
                              .map(
                                (item) => ListTile(
                                  title: Text(item['alimento']),
                                  subtitle: Text("${item['quantidade']} g"),
                                ),
                              )
                              .toList(),
                        ),
                      ElevatedButton(
                        onPressed: _recalcular,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdeBg,
                        ),
                        child: const Text("OK"),
                      ),
                    ],

                    // Fluxo final após análise manual (apenas botão Adicionar Refeição)
                    if (_resultadoManualGerado && _fluxoManualFinalizado) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<RefeicaoViewModel>(context, listen: false)
                              .adicionarRefeicao(
                            tipoRefeicao: tipoRefeicao,
                            resultado: _resultado,
                            alimentos: alimentos,
                          );
                          Navigator.pushReplacementNamed(
                              context, '/tela_refeicao');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.verdeBg,
                        ),
                        child: const Text("Adicionar Refeição"),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
