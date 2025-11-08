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
              final proteinas = refeicao['proteinas'] ?? 0;
              final carboidratos = refeicao['carboidratos'] ?? 0;
              final gorduras = refeicao['gorduras'] ?? 0;
              final fibras = refeicao['fibras'] ?? 0;
              final imagemUrl = refeicao['imagemUrl'];

              String dataFormatada = '';
              if (refeicao['hora'] != null && refeicao['hora'] is Timestamp) {
                final dateTime = (refeicao['hora'] as Timestamp).toDate();
                dataFormatada =
                    DateFormat("dd/MM/yyyy • HH:mm").format(dateTime);
              }

              return Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 16 : 6,
                  left: 10,
                  right: 10,
                  bottom: 6,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TelaDetalhesRefeicao(refeicao: refeicao),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Imagem quase quadrada
                          imagemUrl != null
                              ? Container(
                                  width: 100,
                                  height: double.infinity,
                                  child: Image.network(
                                    imagemUrl,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image,
                                      color: Colors.grey),
                                ),

                          // Informações da refeição
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Tipo + data/hora + excluir
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              tipo,
                                              style: const TextStyle(
                                                color: Color(0xFF2E7D32),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (dataFormatada.isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2, bottom: 4),
                                                child: Text(
                                                  dataFormatada,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.grey,
                                          size: 22,
                                        ),
                                        onPressed: () async {
                                          final confirmar =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text(
                                                  "Excluir refeição"),
                                              content: const Text(
                                                  "Tem certeza que deseja excluir esta refeição?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child:
                                                      const Text("Cancelar"),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text(
                                                    "Excluir",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.redAccent),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );

                                          if (confirmar == true) {
                                            await refeicaoVM
                                                .deletarRefeicao(
                                                    refeicao['id']);
                                          }
                                        },
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),

                                  // Nutrientes lado a lado
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Coluna Proteínas + Carboidratos
                                      Flexible(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _item("Proteínas", proteinas),
                                            _item("Carboidratos", carboidratos),
                                          ],
                                        ),
                                      ),
                                      // Coluna Gorduras + Fibras mais próxima
                                      Flexible(
                                        flex: 1,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              _item("Gorduras", gorduras),
                                              _item("Fibras", fibras),
                                            ],
                                          ),
                                        ),
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

  Widget _item(String nome, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(
        "• $nome: $valor g",
        style: const TextStyle(
          fontSize: 11.5,
          color: Colors.black87,
          height: 1.3,
        ),
      ),
    );
  }
}
