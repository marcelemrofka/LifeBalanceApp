import 'package:app/models/alimento_model.dart';
import 'package:app/models/refeicao_model.dart';
import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/nutrition_vm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaRefeicao extends StatefulWidget {
  const TelaRefeicao({super.key});

  @override
  State<TelaRefeicao> createState() => _TelaRefeicaoState();
}

class _TelaRefeicaoState extends State<TelaRefeicao> {
  final List<String> _tiposRefeicao = [
    'Selecionar',
    'Café da manhã',
    'Almoço',
    'Jantar',
    'Lanche'
  ];
  String _refeicaoSelecionada = 'Selecionar';
  final TextEditingController _controllerBusca = TextEditingController();
  final List<Alimento> _alimentosAdicionados = [];
  final List<Alimento> _resultadosBusca = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _buscarAlimento(String query) async {
    if (query.isEmpty) {
      setState(() {
        _resultadosBusca.clear();
      });
      return;
    }

    try {
      final snapshot = await _firestore.collection('alimentos').get();

      final alimentos = snapshot.docs.map((doc) {
        final data = doc.data();
        final id = doc.id;
        return Alimento(
          nome: id,
          calorias: double.tryParse(data['calorias']?.toString() ?? '0') ?? 0,
          carboidratos:
              double.tryParse(data['carboidrato']?.toString() ?? '0') ?? 0,
          proteinas:
              double.tryParse(data['proteina']?.toString() ?? '0') ?? 0,
          gorduras: double.tryParse(data['gordura']?.toString() ?? '0') ?? 0,
          fibras: double.tryParse(data['fibra']?.toString() ?? '0') ?? 0,
        );
      }).where((alimento) =>
          alimento.nome.toLowerCase().contains(query.toLowerCase())).toList();

      setState(() {
        _resultadosBusca
          ..clear()
          ..addAll(alimentos);
      });
    } catch (e) {
      print('Erro ao buscar alimentos: $e');
    }
  }

  void _adicionarAlimento(Alimento alimento) {
    final viewModel = context.read<NutritionViewModel>();
    viewModel.updateNutrition(
      caloriasIngeridas:
          viewModel.nutrition.caloriasIngeridas + alimento.calorias.toInt(),
      carboIngerido:
          viewModel.nutrition.carboIngerido + alimento.carboidratos.toInt(),
      proteinaIngerida:
          viewModel.nutrition.proteinaIngerida + alimento.proteinas.toInt(),
      gorduraIngerida:
          viewModel.nutrition.gorduraIngerida + alimento.gorduras.toInt(),
      fibraIngerida:
          viewModel.nutrition.fibraIngerida + alimento.fibras.toInt(),
    );
    viewModel.adicionarAlimento(_refeicaoSelecionada, alimento);

    setState(() {
      _alimentosAdicionados.add(alimento);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NutritionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Alimentos', style: TextStyle(color: AppColors.lightText)),
        centerTitle: true,
        backgroundColor: AppColors.principal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightText),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      value: _refeicaoSelecionada,
                      isExpanded: true,
                      items: _tiposRefeicao.map((String tipo) {
                        return DropdownMenuItem<String>(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _refeicaoSelecionada = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controllerBusca,
                      decoration: const InputDecoration(
                        labelText: 'Buscar alimento',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: _buscarAlimento,
                    ),
                    const SizedBox(height: 16),
                    if (_resultadosBusca.isNotEmpty)
                      ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: _resultadosBusca.map((alimento) {
                          return Card(
                            child: ListTile(
                              title: Text(alimento.nome),
                              subtitle: Text('${alimento.calorias} kcal'),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _adicionarAlimento(alimento),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Alimentos adicionados:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _alimentosAdicionados.length,
                      itemBuilder: (context, index) {
                        final alimento = _alimentosAdicionados[index];
                        return ListTile(
                          title: Text(alimento.nome),
                          subtitle: Text('${alimento.calorias} kcal'),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total ingerido: ${viewModel.nutrition.caloriasIngeridas} kcal',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final nome = _refeicaoSelecionada;
                              if (nome != 'Selecionar') {
                                final alimentos = viewModel.alimentosPorRefeicao[nome] ?? [];

                                if (alimentos.isNotEmpty) {
                                  final refeicao = RefeicaoModel(nome: nome, alimentos: alimentos);
                                  await viewModel.salvarRefeicao(refeicao);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Refeição salva com sucesso!')),
                                  );

                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Adicione ao menos um alimento.')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Selecione uma refeição válida.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.principal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                            child: const Text('Salvar'),
                          ),
                        ],
                      ),
                    ),
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
