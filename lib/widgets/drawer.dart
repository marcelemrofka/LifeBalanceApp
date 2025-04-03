import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF43644A), // Fundo verde
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF43644A), // Fundo verde corrigido
            ),
            accountEmail: Text("user@mail.com", style: TextStyle(color: Colors.white)),
            accountName: Text("Seu Zé", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset('assets/images/logo-folha.png', width: 35, height: 35),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Início', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
