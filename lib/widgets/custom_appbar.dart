import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final VoidCallback? onBack;
  final List<Widget>? acoes; // 👈 novo parâmetro opcional

  const CustomAppBar({
    super.key,
    required this.titulo,
    this.onBack,
    this.acoes, // 👈 adicionado
  });

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
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
        alignment: Alignment.center,
        children: [
          // Botão de voltar
          Positioned(
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: onBack ?? () => Navigator.pop(context),
            ),
          ),

          // Título centralizado
          Center(
            child: Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Ações à direita (ex: botão Editar)
          if (acoes != null && acoes!.isNotEmpty)
            Positioned(
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
