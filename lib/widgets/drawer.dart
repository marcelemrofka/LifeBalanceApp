import 'package:app/utils/color.dart';
import 'package:app/viewmodel/auth_viewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    final dadosUsuario = await authViewModel.buscarDadosUsuario();

    if (dadosUsuario != null) {
      setState(() {
        _nome = dadosUsuario['nome'] ?? authViewModel.nome;
        _email = dadosUsuario['email'] ?? authViewModel.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Drawer(
      backgroundColor: AppColors.principal,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('paciente')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              String? imagem;

              if (snapshot.hasData && snapshot.data!.exists) {
                final dados =
                    snapshot.data!.data() as Map<String, dynamic>;
                imagem = dados['imagemPerfil'];
              }

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.principal,
                ),
                accountEmail: Text(
                  _email,
                  style: const TextStyle(color: Colors.white),
                ),
                accountName: Text(
                  _nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (imagem != null && imagem.isNotEmpty)
                      ? NetworkImage(imagem)
                      : const AssetImage('lib/images/logo-circulo.png')
                          as ImageProvider,
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Início', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle, color: Colors.white),
            title:
                const Text('Meu Perfil', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/tela_perfil');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title:
                const Text('Sobre Nós', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/tela_sobre');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title:
                const Text('Sair', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
          ),
        ],
      ),
    );
  }
}
