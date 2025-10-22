import 'dart:io';
import 'package:app/utils/color.dart';
import 'package:app/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String _nome = 'Usuário';
  String _email = 'usuario@email.com';
  File? _imagemPerfil;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

Future<void> _carregarDados() async {
  final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
  
  // Busca os dados do usuário através do AuthViewModel
  final dadosUsuario = await authViewModel.buscarDadosUsuario();
  
  if (dadosUsuario != null) {
    setState(() {
      _nome = dadosUsuario['nome'] ?? authViewModel.nome;
      _email = dadosUsuario['email'] ?? authViewModel.email;
      final imagemPath = dadosUsuario['imagemPath'] as String?;
      if (imagemPath != null && imagemPath.isNotEmpty) {
        _imagemPerfil = File(imagemPath);
      }
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.principal,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.principal,
            ),
            accountEmail: Text(
              _email, 
              style: TextStyle(color: Colors.white),
            ),
            accountName: Text(
              _nome,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: _imagemPerfil != null
                  ? FileImage(_imagemPerfil!)
                  : AssetImage('lib/images/logo-folha.png') as ImageProvider,
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
            leading: Icon(Icons.info, color: Colors.white),
            title: Text('Sobre Nós', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/tela_sobre');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white),
            title: Text('Sair', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
