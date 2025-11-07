import 'package:flutter/material.dart';
import 'package:app/utils/color.dart';

class Caixa extends StatelessWidget {
  final String titulo;
  final Widget conteudo;
  final double? largura; // permite controle exato da largura
  final double? altura; // permite altura fixa

  const Caixa({
    Key? key,
    required this.titulo,
    required this.conteudo,
    this.largura,
    this.altura,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          largura ?? 205,
      height: altura ?? 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabeçalho cinza claro
          Container(
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Conteúdo
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: conteudo,
            ),
          ),
        ],
      ),
    );
  }
}
