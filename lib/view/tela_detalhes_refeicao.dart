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
    final quantidadeEstimada = refeicao['quantidade'] ?? '';
    String? alimentosIncluidos = refeicao['nome'];

    // ✅ Adiciona ":" após "Alimento" se não tiver
    if (alimentosIncluidos != null &&
        alimentosIncluidos.startsWith("Alimento") &&
        !alimentosIncluidos.contains(":")) {
      alimentosIncluidos = alimentosIncluidos.replaceFirst(
        "Alimento",
        "Alimento:",
      );
    }

    final double alturaBranca = MediaQuery.of(context).size.height * 0.68;

    return Scaffold(
      backgroundColor: AppColors.verdeBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Botão voltar
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () => Navigator.pop(context),
              ),
            ),

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

                            // 🔽 Aumentei o espaçamento aqui
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

                            // Quantidade estimada
                            if (quantidadeEstimada.toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  "Quantidade estimada: $quantidadeEstimada g",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            // Nome (com ":" ajustado se necessário)
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

                            // Total de calorias
                            Text(
                              "Total de Calorias: ${calorias.toString()} kcal",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Botão OK
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const TelaRefeicao()),
                          );
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

  // Linha com bolinha e valor
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
