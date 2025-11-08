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
  bool _calculandoManual = false;

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
      _calculandoManual = true;
    });

    final resposta = await analisarAlimentosManuais(alimentos);

    setState(() {
      _resultado = resposta;
      _calculandoManual = false;
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

  void _salvarRefeicao(String tipoRefeicao) async {
    if (alimentosParaSalvar.isEmpty) {
      alimentosParaSalvar = _extrairAlimentosDoResultado(_resultado);
    }

    Provider.of<RefeicaoViewModel>(context, listen: false).adicionarRefeicao(
      tipoRefeicao: tipoRefeicao,
      resultado: _resultado,
      alimentos: alimentosParaSalvar,
    );

    alimentos.clear();
    alimentosParaSalvar.clear();
    _fluxoManualFinalizado = false;
    Navigator.pushReplacementNamed(context, '/tela_refeicao');
  }

  Widget _buildRoundedButton(String label, VoidCallback? onTap,
      {double width = 160, Color? color}) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color ?? AppColors.laranja,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final tipoRefeicao = args?['tipoRefeicao'] ?? 'Refeição';

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
                    // fluxo principal
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
                          "Quantidade de calorias e macronutrientes estimados na refeição: ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF616161),
                          )
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _resultado,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildRoundedButton(
                                "Adicionar Refeição",
                                () => _salvarRefeicao(tipoRefeicao),
                                width: 140),
                            const SizedBox(width: 12),
                            _buildRoundedButton("Editar Refeição", () {
                              setState(() {
                                _naoConcorda = true;
                                _resultado = '';
                                _imagem = null;
                                alimentos.clear();
                                alimentosParaSalvar.clear();
                                _fluxoManualFinalizado = false;
                                _resultadoManualGerado = false;
                                _calculandoManual = false;
                              });
                            }, width: 140),
                          ],
                        ),
                      ],
                    ],
                    // fluxo manual
                    if (_naoConcorda) ...[
                      const SizedBox(height: 16),
                      const Text(
                        "Adicione os alimentos e suas quantidades:",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: alimentoController,
                        cursorColor: AppColors.verdeBg,
                        decoration: InputDecoration(
                          labelText: "Alimento",
                          labelStyle: TextStyle(color: AppColors.verdeBg),
                          border: const OutlineInputBorder(),
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
                          border: const OutlineInputBorder(),
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
                      _buildRoundedButton("+ Adicionar alimento", _adicionarAlimento),
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
                      const SizedBox(height: 10),
                      _buildRoundedButton(
                        _calculandoManual ? "Calculando..." : "Calcular Refeição",
                        _calculandoManual ? null : _recalcular,
                      ),
                      const SizedBox(height: 10),
                      if (_calculandoManual)
                        const Text(
                          "Calculando calorias...",
                          style: TextStyle(color: Colors.grey),
                        ),
                      const SizedBox(height: 10),
                      if (_resultadoManualGerado && _fluxoManualFinalizado) ...[
                        const Text(
                          "Calorias e macronutrientes calculados.\nClique no botão abaixo para adicionar sua refeição.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        _buildRoundedButton(
                            "Adicionar Refeição",
                            () => _salvarRefeicao(tipoRefeicao),
                            color: AppColors.verdeBg),
                      ],
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
