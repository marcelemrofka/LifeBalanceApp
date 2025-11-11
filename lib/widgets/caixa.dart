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
    // Tamanho da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ajuste dinâmico proporcional
    final responsiveWidth = largura ?? screenWidth * 0.45; // 45% da tela
    final responsiveHeight = altura ?? screenHeight * 0.22; // 22% da tela

    return Container(
      width: responsiveWidth,
      height: responsiveHeight,
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
            padding: EdgeInsets.symmetric(
              vertical: responsiveHeight * 0.08, // proporcional
            ),
            child: Center(
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: screenWidth * 0.04, // texto adaptável
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          // Conteúdo
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.025),
              child: conteudo,
            ),
          ),
        ],
      ),
    );
  }
}
