import 'package:flutter/material.dart';
import '../utils/color.dart';
import 'tela_refeicao.dart';

class TelaDetalhesRefeicao extends StatelessWidget {
  final Map<String, dynamic> refeicao;

  const TelaDetalhesRefeicao({super.key, required this.refeicao});

  @override
  Widget build(BuildContext context) {
    final tipo = refeicao['tipoRefeicao'] ?? 'Refeição';
    final calorias = refeicao['calorias'] ?? 0;
    final carboidratos = refeicao['carboidratos'] ?? 0;
    final proteinas = refeicao['proteinas'] ?? 0;
    final gorduras = refeicao['gorduras'] ?? 0;
    final fibras = refeicao['fibras'] ?? 0;
    String? alimentosIncluidos = refeicao['nome'];
    final comentario = refeicao['comentario'] ?? '';
    final imagemUrl = refeicao['imagemUrl']; // 🔹 URL da imagem

    if (alimentosIncluidos != null &&
        alimentosIncluidos.startsWith("Alimento") &&
        !alimentosIncluidos.contains(":")) {
      alimentosIncluidos = alimentosIncluidos.replaceFirst(
        "Alimento",
        "Alimentos incluídos:",
      );
    }

    final double alturaBranca = MediaQuery.of(context).size.height * 0.62;

    return Scaffold(
      backgroundColor: AppColors.verdeBg,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔹 Imagem no topo (preenche tudo acima do container branco)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: alturaBranca - 40, // 🔸 sobe um pouco pra cobrir melhor
              child: imagemUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      child: Image.network(
                        imagemUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(color: AppColors.verdeBg),
            ),

            // 🔹 Botão de voltar
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // 🔹 Container branco sobrepondo levemente a imagem
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: alturaBranca,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(35),
                    topRight: Radius.circular(35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                tipo,
                                style: TextStyle(
                                  color: AppColors.verdeClaro,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              "Informações Nutricionais",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              "Composição estimada:",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _itemComposicao("Proteínas", proteinas),
                            _itemComposicao("Carboidratos", carboidratos),
                            _itemComposicao("Gorduras", gorduras),
                            _itemComposicao("Fibras", fibras),
                            const SizedBox(height: 25),
                            if (alimentosIncluidos != null)
                              Text(
                                alimentosIncluidos,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.3,
                                ),
                              ),
                            const SizedBox(height: 25),
                            Text(
                              "Total de Calorias: ${calorias.toString()} kcal",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Divider(height: 1, color: Colors.black12),
                            const SizedBox(height: 15),
                            if (comentario.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Comentário: ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        comentario,
                                        style: const TextStyle(
                                            color: Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.laranja,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _itemComposicao(String nome, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.1),
          ),
          Expanded(
            child: Text(
              "$nome: $valor g",
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
