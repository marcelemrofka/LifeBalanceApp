import 'dart:io';
import 'package:app/utils/color.dart';
import 'package:app/viewmodel/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  final uid = authViewModel.user?.uid;

  if (uid != null) {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          _nome = data['nome'] ?? authViewModel.nome;
          _email = data['email'] ?? authViewModel.email;
          final imagemPath = data['imagemPath'] as String?;
          if (imagemPath != null && imagemPath.isNotEmpty) {
            _imagemPerfil = File(imagemPath);
          }
        });
      }
    } catch (e) {
      print('Erro ao carregar perfil: $e');
    }
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
              color: Color(0xFF43644A),
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
