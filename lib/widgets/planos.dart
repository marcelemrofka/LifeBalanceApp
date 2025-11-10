import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:app/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlanosOverlay extends StatefulWidget {
  const PlanosOverlay({super.key});

  @override
  State<PlanosOverlay> createState() => _PlanosOverlayState();
}

class _PlanosOverlayState extends State<PlanosOverlay> {
  List<Map<String, dynamic>> planos = [];
  bool carregando = true;
  int paginaAtual = 0;

  @override
  void initState() {
    super.initState();
    _carregarPlanos();
  }

  Future<void> _carregarPlanos() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('planos').get();
      setState(() {
        planos = snapshot.docs.map((e) => e.data()).toList();
        carregando = false;
      });
    } catch (e) {
      debugPrint('Erro ao buscar planos: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // fundo com blur
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: carregando
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Escolha seu plano",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // carrossel de planos
                      SizedBox(
                        height: 700,
                        child: PageView.builder(
                          controller: PageController(viewportFraction: 0.85),
                          itemCount: planos.length,
                          onPageChanged: (index) =>
                              setState(() => paginaAtual = index),
                          itemBuilder: (context, index) {
                            final plano = planos[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(
                                horizontal: paginaAtual == index ? 0 : 10,
                                vertical: paginaAtual == index ? 0 : 20,
                              ),
                              child: PlanosCard(plano: plano),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // indicadores de página
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          planos.length,
                          (i) => Container(
                            margin: const EdgeInsets.all(4),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == paginaAtual
                                  ? AppColors.laranja
                                  : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// 🔹 Card de cada plano
class PlanosCard extends StatelessWidget {
  final Map<String, dynamic> plano;
  const PlanosCard({required this.plano, super.key});

  @override
  Widget build(BuildContext context) {
    final nomePlano = plano['nome'] ?? '';
    final valor = plano['valor'] ?? 0.0;
    final recomendacao = plano['recomendacao'] ?? '';
    final beneficios = List<String>.from(plano['beneficios'] ?? []);
    final imagem = plano['imagem'] ?? '';

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.verdePlanos,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(80),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Text(
                  nomePlano,
                  style: const TextStyle(
                    color: AppColors.principal,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                if (imagem.isNotEmpty)
                  Image.asset(
                    'lib/images/$imagem',
                    width: 50,
                    height: 50,
                    fit: BoxFit.contain,
                  ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    text: 'R\$ ${valor.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.principal,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    children: const [
                      TextSpan(
                        text: "/mês",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Benefícios
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: beneficios
                  .map((b) => PlanoBeneficio(texto: b, positivo: true))
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Recomendações
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              recomendacao,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),

          const Spacer(),

          // Botão
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.laranja,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Selecionar Plano",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class PlanoBeneficio extends StatelessWidget {
  final String texto;
  final bool positivo;

  const PlanoBeneficio({
    required this.texto,
    required this.positivo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            positivo ? Icons.check_circle : Icons.cancel,
            color: positivo ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
