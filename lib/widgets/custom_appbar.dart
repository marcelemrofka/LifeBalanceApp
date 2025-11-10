import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final VoidCallback? onBack;
  final List<Widget>? acoes;

  const CustomAppBar({
    super.key,
    required this.titulo,
    this.onBack,
    this.acoes,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120); // 🔹 altura aumentada

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        color: AppColors.verdeBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Botão de voltar
          Positioned(
            top: 40, // 🔹 ajustado pra não ficar colado
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack ?? () => Navigator.pop(context),
            ),
          ),

          // 🔹 Título alinhado na parte inferior do verde
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Ações à direita (ex: botão Editar)
          if (acoes != null && acoes!.isNotEmpty)
            Positioned(
              top: 40,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: acoes!,
              ),
            ),
        ],
      ),
    );
  }
}
