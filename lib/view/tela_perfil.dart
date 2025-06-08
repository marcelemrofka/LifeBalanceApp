import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodel/auth_viewmodel.dart';

class TelaPerfil extends StatefulWidget {
  const TelaPerfil({Key? key}) : super(key: key);

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _objetivo1Controller = TextEditingController();
  String? _imagemUrl;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
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
            _nomeController.text = data['nome'] ?? '';
            _pesoController.text = data['peso']?.toString() ?? '';
            _alturaController.text = data['altura']?.toString() ?? '';
            _objetivo1Controller.text = data['objetivo'] ?? '';
            _emailController.text = authViewModel.email;
            _imagemUrl = data['imagemPerfil'];
          });
        }
      } catch (e) {
        print('Erro ao carregar perfil: $e');
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _objetivo1Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: AppColors.principal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imagemUrl != null && _imagemUrl!.isNotEmpty
                    ? NetworkImage(_imagemUrl!)
                    : const AssetImage('lib/images/logo-folha.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Nome', _nomeController),
            _buildTextField('Email', _emailController, enabled: false),
            _buildTextField('Peso (kg)', _pesoController),
            _buildTextField('Altura (cm)', _alturaController),
            _buildTextField('Objetivo', _objetivo1Controller),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        enabled: enabled,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
