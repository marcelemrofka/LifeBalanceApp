import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/refeicao_vm.dart';
import '../utils/color.dart';
import 'package:intl/intl.dart';
import 'tela_detalhes_refeicao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                        'Histórico de Refeições',
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: refeicaoVM.getHistoricoStream(),
        builder: (context, snapshot) {
          final historico = snapshot.data ?? [];

          if (historico.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma refeição registrada",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: historico.length,
            itemBuilder: (context, index) {
              final refeicao = historico[index];
              final tipo = refeicao['tipoRefeicao'] ?? 'Refeição';
              final dataTimestamp = refeicao['hora'] as Timestamp?;
              final data = dataTimestamp?.toDate() ?? DateTime.now();
              final dataFormatada =
                  DateFormat('dd/MM/yyyy – HH:mm').format(data);

              return Padding(
                padding: EdgeInsets.only(
                top: index == 0 ?  28 : 5, // 👈 o primeiro card desce um pouco mais
                left: 10,
                right: 10,
                bottom: 5,
              ), child: FractionallySizedBox(
                  widthFactor: 0.96, // 👈 deixa o card ligeiramente menor
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        tipo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        dataFormatada,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TelaDetalhesRefeicao(refeicao: refeicao),
                          ),
                        );
                      },

                      // 🔹 Ícone de deletar (mais à direita e cinza claro)
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey, // tom de cinza claro
                          size: 26,
                        ),
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Excluir refeição"),
                              content: const Text(
                                  "Tem certeza que deseja excluir esta refeição?"),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text(
                                    "Excluir",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirmar == true) {
                            await refeicaoVM.deletarRefeicao(refeicao['id']);
                          }
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => abrirSubMenu(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
