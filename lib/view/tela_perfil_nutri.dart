import 'package:app/utils/color.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodel/auth_viewmodel.dart';

class TelaPerfilNutri extends StatefulWidget {
  const TelaPerfilNutri({Key? key}) : super(key: key);

  @override
  State<TelaPerfilNutri> createState() => _TelaPerfilNutriState();
}

class _TelaPerfilNutriState extends State<TelaPerfilNutri> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _crnController = TextEditingController();
  final _contatoController = TextEditingController();
  final _bioController = TextEditingController();
  String? _imagemUrl;
  String? _assinaturaPlano;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final dadosUsuario = await authViewModel.buscarDadosUsuario();

    if (dadosUsuario != null) {
      setState(() {
        _nomeController.text = dadosUsuario['nome'] ?? '';
        _emailController.text = authViewModel.email;
        _crnController.text = dadosUsuario['crn'] ?? '';
        _contatoController.text = dadosUsuario['contato'] ?? '';
        _bioController.text = dadosUsuario['bio'] ?? '';
        _imagemUrl = dadosUsuario['foto'];
        _assinaturaPlano = dadosUsuario['assinatura_plano'];
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final uid = authViewModel.user?.uid;

    if (uid != null) {
      try {
        await FirebaseFirestore.instance
            .collection('nutricionista')
            .doc(uid)
            .update({
          'nome': _nomeController.text.trim(),
          'crn': _crnController.text.trim(),
          'contato': _contatoController.text.trim(),
          'bio': _bioController.text.trim(),
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
    _crnController.dispose();
    _contatoController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titulo: 'Perfil'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imagemUrl != null && _imagemUrl!.isNotEmpty
                    ? NetworkImage(_imagemUrl!)
                    : const AssetImage('lib/images/logo-circulo.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField('Nome', _nomeController),
            _buildTextField('Email', _emailController, enabled: false),
            _buildTextField('CRN', _crnController),
            _buildTextField('Contato', _contatoController),
            _buildTextField('Biografia', _bioController, maxLines: 3),
            const SizedBox(height: 10),
            if (_assinaturaPlano != null)
              Text(
                'Plano Assinado: $_assinaturaPlano',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool enabled = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        enabled: enabled,
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
