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

  Future<void> _processarImagem(File imagem) async {
    setState(() {
      _imagem = imagem;
      _carregando = true;
      _resultado = '';
    });

    final resposta = await analisarImagem(imagem);

    setState(() {
      _resultado = resposta;
      _carregando = false;
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
              // Mostrar os botões de selecionar imagem apenas quando não estiver carregando e não tiver resultado
              if (!_carregando && _resultado.isEmpty)
                ImagePickerButtons(onImageSelected: _processarImagem),
              const SizedBox(height: 16),

              // Mostrar a imagem selecionada
              if (_imagem != null)
                Center(child: Image.file(_imagem!, height: 200)),
              const SizedBox(height: 16),

              // Mostrar carregamento
              if (_carregando)
                const CircularProgressIndicator()
              // Mostrar resultado e botões de concordar/não concordar
              else if (_resultado.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _resultado,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // TODO: ação ao concordar
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.verdeBg,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Concordo'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: ação ao não concordar
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.verdeBg,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
