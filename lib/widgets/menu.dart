import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(icon: Icon(Icons.account_circle, size: 45, color: AppColors.midGrey),
          onPressed: () {
              Navigator.pushNamed(context, '/tela_perfil');
          },
          )
        ],
      ),
      );
  }
}