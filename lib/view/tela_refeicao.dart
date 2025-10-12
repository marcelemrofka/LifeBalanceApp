import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/refeicao_vm.dart';
import '../utils/color.dart';

class TelaRefeicao extends StatelessWidget {
  const TelaRefeicao({super.key});

  void abrirSubMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...[
            "Café da Manhã",
            "Lanche da Manhã",
            "Almoço",
            "Café da Tarde",
            "Jantar",
            "Ceia"
          ].map(
            (tipo) => ListTile(
              title: Text(tipo),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/tela_analise_calorias',
                  arguments: {'tipoRefeicao': tipo},
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refeicaoVM = Provider.of<RefeicaoViewModel>(context);
    final historico = refeicaoVM.historico;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Histórico de Refeições"),
        backgroundColor: AppColors.verdeBg,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: historico.isEmpty
            ? const Center(
                child: Text(
                  "Nenhuma refeição registrada",
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: historico.length,
                itemBuilder: (context, index) {
                  final refeicao = historico[index];
                  final tipo = refeicao['tipoRefeicao'] ?? 'Refeição';
                  final resultado = refeicao['resultado'] ?? '';
                  final alimentos =
                      refeicao['alimentos'] as List<dynamic>? ?? [];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text(
                        tipo, // Mostra só o tipo de refeição
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      children: [
                        if (resultado.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(resultado),
                          ),
                        ...alimentos.map(
                          (a) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Text(
                                "${a['alimento'] ?? ''}: ${a['quantidade'] ?? ''}g"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirSubMenu(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
