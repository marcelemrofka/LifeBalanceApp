import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:app/utils/color.dart';
import 'package:app/view/tela_detalhes_refeicao.dart';

class FeedCard extends StatefulWidget {
  final Map<String, dynamic> dados;
  final String docId; // <-- ID do documento da refeição

  const FeedCard({Key? key, required this.dados, required this.docId})
      : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  final TextEditingController _comentarioController = TextEditingController();
  bool _enviando = false;

  String _tempoDecorrido(DateTime hora) {
    final diff = DateTime.now().difference(hora);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours} h';
    return DateFormat('dd/MM').format(hora);
  }

  Future<void> _salvarComentario() async {
    if (_comentarioController.text.trim().isEmpty) return;

    setState(() => _enviando = true);

    try {
      await FirebaseFirestore.instance
          .collection('refeicoes')
          .doc(widget.docId)
          .update({
        'comentario': _comentarioController.text.trim(),
      });

      _comentarioController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentário adicionado!')),
      );
    } catch (e) {
      debugPrint('Erro ao salvar comentário: $e');
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = widget.dados;
    final tipo = dados['tipoRefeicao'] ?? '';
    final imagem = dados['imagemUrl'] ?? '';
    final proteinas = dados['proteinas'] ?? 0;
    final carboidratos = dados['carboidratos'] ?? 0;
    final gorduras = dados['gorduras'] ?? 0;
    final fibras = dados['fibras'] ?? 0;
    final uidPaciente = dados['uid'];
    final hora = dados['hora'];

    DateTime horaConvertida;
    if (hora is Timestamp) {
      horaConvertida = hora.toDate();
    } else if (hora is String) {
      horaConvertida = DateTime.tryParse(hora) ?? DateTime.now();
    } else {
      horaConvertida = DateTime.now();
    }

    String imagemUrl =
        (dados['imagemUrl'] ?? '').toString().replaceAll('"', '');

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('paciente')
          .doc(uidPaciente)
          .get(),
      builder: (context, pacienteSnap) {
        if (!pacienteSnap.hasData) return const SizedBox();

        final pacienteData = pacienteSnap.data!.data() as Map<String, dynamic>?;
        final nomePaciente = pacienteData?['nome'] ?? 'Paciente';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Área clicável que leva pra detalhes ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TelaDetalhesRefeicao(refeicao: widget.dados),
                    ),
                  );
                },
                child: Column(
                  children: [
                    // Cabeçalho
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: AppColors.laranja, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                nomePaciente,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                          Text(
                            _tempoDecorrido(horaConvertida),
                            style: const TextStyle(
                              color: Colors.black38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Corpo principal
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagem.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imagemUrl,
                                height: 85,
                                width: 85,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 85,
                                  width: 85,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tipo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 4,
                                  children: [
                                    Text('• Proteínas: ${proteinas} g'),
                                    Text('• Carboidratos: ${carboidratos} g'),
                                    Text('• Gorduras: ${gorduras} g'),
                                    Text('• Fibras: ${fibras} g'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Colors.black12),

              // --- Área de comentário ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _comentarioController,
                        decoration: InputDecoration(
                          hintText: 'Adicionar comentário...',
                          hintStyle: const TextStyle(
                              color: Colors.black38, fontSize: 13),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _enviando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send,
                                color: AppColors.principal),
                            onPressed: _salvarComentario,
                          ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
