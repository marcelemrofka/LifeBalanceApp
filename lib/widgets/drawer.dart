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
            accountEmail: Text("maria@email.com", style: TextStyle(color: Colors.white)),
            accountName: Text("Maria da Silva", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset('lib/images/logo-folha.png', width: 35, height: 35),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('Início', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.account_circle, color: Colors.white),
            title: Text('Meu Perfil', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushNamed(context, '/tela_perfil');
            },
          ),
          ListTile(
            leading: Icon(Icons.info , color: Colors.white),
            title: Text('Sobre Nós', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context); 
              Navigator.pushNamed(context, '/tela_sobre');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout , color: Colors.white),
            title: Text('Sair', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
