import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/viewmodel/nutrition_vm.dart';

class TelaHistoricoRefeicoes extends StatelessWidget {
  const TelaHistoricoRefeicoes({super.key});

  @override
  Widget build(BuildContext context) {
    final historico = context.watch<NutritionViewModel>().historico;

    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Refeições', style: TextStyle(color: AppColors.lightText),), 
        centerTitle: true, 
        backgroundColor: AppColors.principal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lightText,),onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: historico.isEmpty
          ? const Center(child: Text('Nenhuma refeição registrada.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final refeicao = historico[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          refeicao.nome,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...refeicao.alimentos.map((a) => Text("- ${a.nome}")).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
