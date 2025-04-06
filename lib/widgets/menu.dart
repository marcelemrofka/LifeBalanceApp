import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.menu, size: 40, color: Colors.grey),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ) ,

          IconButton(icon: Icon(Icons.account_circle, size: 40, color: Colors.grey),
          onPressed: () {
              Navigator.pushNamed(context, '/tela_perfil');
          },
          )
        ],
      ),
      );
  }
}