import 'package:app/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Planos extends StatefulWidget {
  final String planoSelecionado;

  const Planos(this.planoSelecionado, {super.key});

  @override
  State<Planos> createState() => _PlanosState();
}

class _PlanosState extends State<Planos> {
  Map<String, dynamic>? dadosPlano;
  bool carregando = true;
  bool selecionado = false;

  @override
  void initState() {
    super.initState();
    buscarPlano();
  }

  Future<void> buscarPlano() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('planos')
          .doc(widget.planoSelecionado)
          .get();

      if (doc.exists) {
        setState(() {
          dadosPlano = doc.data();
          carregando = false;
        });
      }
    } catch (e) {
      debugPrint('Erro ao buscar plano: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (carregando || dadosPlano == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF2B2B2B),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    final nomePlano = dadosPlano!['nome'] ?? '';
    final valor = dadosPlano!['valor'] ?? '';
    final tipo = dadosPlano!['tipo_usuario'] ?? '';
    final recomendacao = dadosPlano!['recomendacao'] ?? '';
    final beneficios = List<String>.from(dadosPlano!['beneficios'] ?? []);
    final limitacoes = List<String>.from(dadosPlano!['limitacoes'] ?? []);
    final imagem = dadosPlano!['imagem'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF2B2B2B),
      body: Center(
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TOPO VERDE
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
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
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
                    Image.asset(
                      'lib/images/$imagem',
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    Text.rich(
                      TextSpan(
                        text: 'R\$ ${valor.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.principal,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(
                            text: "/mês",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      tipo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // BENEFÍCIOS E LIMITAÇÕES
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    for (final b in beneficios)
                      PlanoBeneficio(texto: b, positivo: true),
                    for (final l in limitacoes)
                      PlanoBeneficio(texto: l, positivo: false),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // RECOMENDAÇÃO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  recomendacao,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // BOTÃO
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selecionado = !selecionado;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selecionado ? Colors.grey[400] : AppColors.verdePlanos,
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    selecionado ? "Plano Selecionado" : "Contratar Plano",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// itens inclusos
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
