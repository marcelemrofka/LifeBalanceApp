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
  bool _fluxoManualFinalizado = false;

  List<Map<String, dynamic>> alimentos = [];
  List<Map<String, dynamic>> alimentosParaSalvar = [];

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
      alimentosParaSalvar.clear();
    });

    final resposta = await analisarImagem(imagem);

    setState(() {
      _resultado = resposta;
      _carregando = false;
      // Não extrair ainda só extrair ao salvar
    });
  }

  void _adicionarAlimento() {
    if (alimentoController.text.isNotEmpty &&
        quantidadeController.text.isNotEmpty) {
      setState(() {
        alimentos.add({
          "alimento": alimentoController.text.trim(),
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
      _fluxoManualFinalizado = true;
      alimentosParaSalvar = _extrairAlimentosDoResultado(_resultado);
    });
  }

  List<Map<String, dynamic>> _extrairAlimentosDoResultado(String resultado) {
    final lista = <Map<String, dynamic>>[];
    final linhas = resultado.split('\n');
    for (var linha in linhas) {
      if (!linha.contains(':')) continue;
      final partes = linha.split(':');
      if (partes.length < 2) continue;
      final nome = partes[0].trim();
      final qtdStr = partes[1].replaceAll(RegExp(r'[^0-9]'), '');
      final quantidade = int.tryParse(qtdStr) ?? 0;
      if (nome.isNotEmpty && quantidade > 0) {
        lista.add({'alimento': nome, 'quantidade': quantidade});
      }
    }
    return lista;
  }

  void _salvarRefeicao(String tipoRefeicao) {
    // Evita duplicação: só extrai uma vez
    if (alimentosParaSalvar.isEmpty) {
      alimentosParaSalvar = _extrairAlimentosDoResultado(_resultado);
    }

    if (alimentosParaSalvar.isEmpty) return;

    Provider.of<RefeicaoViewModel>(context, listen: false).adicionarRefeicao(
      tipoRefeicao: tipoRefeicao,
      resultado: _resultado,
      alimentos: alimentosParaSalvar,
    );

    // Limpa listas para próximo uso
    alimentos.clear();
    alimentosParaSalvar.clear();
    _fluxoManualFinalizado = false;

    Navigator.pushReplacementNamed(context, '/tela_refeicao');
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
                    // Fluxo padrão: imagem + IA
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
                          onPressed: () => _salvarRefeicao(tipoRefeicao),
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
                              alimentosParaSalvar.clear();
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

                    // Fluxo "Não Concordo"
                    if (_naoConcorda && !_fluxoManualFinalizado) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: alimentoController,
                        cursorColor: AppColors.verdeBg,
                        decoration: InputDecoration(
                          labelText: "Alimento",
                          labelStyle: TextStyle(color: AppColors.verdeBg),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.verdeBg),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.verdeBg, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: quantidadeController,
                        keyboardType: TextInputType.number,
                        cursorColor: AppColors.verdeBg,
                        decoration: InputDecoration(
                          labelText: "Quantidade (g)",
                          labelStyle: TextStyle(color: AppColors.verdeBg),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.verdeBg),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: AppColors.verdeBg, width: 2),
                          ),
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
                                  subtitle: Text("${item['quantidade']}"),
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

                    // Fluxo final após análise manual
                    if (_resultadoManualGerado && _fluxoManualFinalizado) ...[
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => _salvarRefeicao(tipoRefeicao),
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
