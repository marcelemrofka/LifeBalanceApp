import 'package:app/models/alimento_model.dart';
import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/nutrition_vm.dart';

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
  List<Alimento> _resultadosBusca = [];

  Future<void> _buscarAlimento(String query) async {
    final viewModel = context.read<NutritionViewModel>();
    if (query.isEmpty) {
      setState(() => _resultadosBusca = []);
      return;
    }
    final resultados = await viewModel.buscarAlimentos(query);
    setState(() {
      _resultadosBusca = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NutritionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Alimentos',
            style: TextStyle(color: AppColors.lightText)),
        centerTitle: true,
        backgroundColor: AppColors.principal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightText),
          onPressed: () => Navigator.pop(context),
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
                        hintText: 'Digite o nome do alimento...',
                      ),
                      onChanged: _buscarAlimento,
                    ),
                    const SizedBox(height: 16),
                    if (_resultadosBusca.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resultados da busca:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _resultadosBusca.length,
                            itemBuilder: (context, index) {
                              final alimento = _resultadosBusca[index];
                              return Card(
                                child: ListTile(
                                  title: Text(alimento.nome),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${alimento.calorias} kcal'),
                                      Text(
                                          'Carb: ${alimento.carboidratos}g | Prot: ${alimento.proteinas}g | Gord: ${alimento.gorduras}g'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      if (_refeicaoSelecionada ==
                                          'Selecionar') {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Selecione uma refeição antes de adicionar.')),
                                        );
                                        return;
                                      }
                                      viewModel.adicionarAlimento(
                                          _refeicaoSelecionada, alimento);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                '${alimento.nome} adicionado à ${_refeicaoSelecionada}')),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    if (_controllerBusca.text.isNotEmpty &&
                        _resultadosBusca.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Nenhum alimento encontrado.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Alimentos adicionados${_refeicaoSelecionada != 'Selecionar' ? ' - $_refeicaoSelecionada' : ''}:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_refeicaoSelecionada != 'Selecionar' &&
                        (viewModel.alimentosPorRefeicao[_refeicaoSelecionada]
                                ?.isNotEmpty ??
                            false))
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel
                                .alimentosPorRefeicao[_refeicaoSelecionada]
                                ?.length ??
                            0,
                        itemBuilder: (context, index) {
                          final alimento = viewModel.alimentosPorRefeicao[
                              _refeicaoSelecionada]![index];
                          return Card(
                            color: Colors.green[50],
                            child: ListTile(
                              title: Text(alimento.nome),
                              subtitle: Text('${alimento.calorias} kcal'),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline,
                                    color: Colors.red),
                                onPressed: () {
                                  viewModel.removerAlimento(
                                      _refeicaoSelecionada, index);
                                },
                              ),
                            ),
                          );
                        },
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Nenhum alimento adicionado ainda.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
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
                              final tipo = _refeicaoSelecionada;
                              if (tipo != 'Selecionar') {
                                final alimentos =
                                    viewModel.alimentosPorRefeicao[tipo] ?? [];
                                if (alimentos.isNotEmpty) {
                                  await viewModel.salvarRefeicao(tipo);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Refeição salva com sucesso!')),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Adicione ao menos um alimento.')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Selecione uma refeição válida.')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.principal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
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
