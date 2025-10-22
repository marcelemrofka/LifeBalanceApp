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
    
    // Busca os dados do usuário através do AuthViewModel
    final dadosUsuario = await authViewModel.buscarDadosUsuario();
    
    if (dadosUsuario != null) {
      setState(() {
        _nomeController.text = dadosUsuario['nome'] ?? '';
        _pesoController.text = dadosUsuario['peso']?.toString() ?? '';
        _alturaController.text = dadosUsuario['altura']?.toString() ?? '';
        _objetivo1Controller.text = dadosUsuario['objetivo'] ?? '';
        _emailController.text = authViewModel.email;
        _imagemUrl = dadosUsuario['imagemPerfil'];
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final uid = authViewModel.user?.uid;

    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
          'nome': _nomeController.text.trim(),
          'peso': double.tryParse(_pesoController.text.trim()) ?? 0,
          'altura': double.tryParse(_alturaController.text.trim()) ?? 0,
          'objetivo': _objetivo1Controller.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informações atualizadas com sucesso!')),
        );
      } catch (e) {
        print('Erro ao atualizar perfil: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar perfil.')),
        );
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
                    : const AssetImage('lib/images/logo-folha.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Nome', _nomeController),
            _buildTextField('Email', _emailController, enabled: false),
            _buildTextField('Peso (kg)', _pesoController),
            _buildTextField('Altura (cm)', _alturaController),
            _buildTextField('Objetivo', _objetivo1Controller),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _salvarAlteracoes,
              icon: const Icon(Icons.save),
              label: const Text('Salvar alterações'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdeBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
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
