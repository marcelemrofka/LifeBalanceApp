import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';

class Caixa extends StatelessWidget {
  final String titulo;
  final Widget conteudo;

  const Caixa({
    Key? key,
    required this.titulo,
    required this.conteudo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Cabeçalho
          Container(
            decoration: const BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: conteudo,
          ),
        ],
      ),
    );
  }
}
