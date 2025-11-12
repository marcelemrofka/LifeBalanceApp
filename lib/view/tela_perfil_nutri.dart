import 'package:app/utils/color.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:app/widgets/planos.dart';
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
  bool _ehNutri = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final uid = authViewModel.user?.uid;

    if (uid == null) return;

    final firestore = FirebaseFirestore.instance;

    try {
      // 🔹 Verifica se o usuário logado é nutricionista
      final docNutri =
          await firestore.collection('nutricionista').doc(uid).get();

      if (docNutri.exists) {
        _ehNutri = true;
        _preencherCampos(docNutri.data()!, authViewModel.email);
      } else {
        // 🔹 Caso seja paciente, pega o nutricionista vinculado
        final docPaciente =
            await firestore.collection('paciente').doc(uid).get();
        if (docPaciente.exists) {
          final dadosPaciente = docPaciente.data();
          final uidNutri = dadosPaciente?['nutricionista_uid'];
          if (uidNutri != null && uidNutri.toString().isNotEmpty) {
            final docNutriRef =
                await firestore.collection('nutricionista').doc(uidNutri).get();
            if (docNutriRef.exists) {
              _preencherCampos(
                  docNutriRef.data()!, docNutriRef.data()?['email'] ?? '');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar perfil do nutricionista: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar perfil.')),
      );
    }

    setState(() => _carregando = false);
  }

  void _preencherCampos(Map<String, dynamic> dados, String email) {
    setState(() {
      _nomeController.text = dados['nome'] ?? '';
      _emailController.text = email;
      _crnController.text = dados['crn'] ?? '';
      _contatoController.text = dados['contato'] ?? '';
      _bioController.text = dados['bio'] ?? '';
      _imagemUrl = dados['foto'];
      _assinaturaPlano = dados['plano'];
    });
  }

  Future<void> _salvarAlteracoes() async {
    if (!_ehNutri) return; // paciente não edita

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final uid = authViewModel.user?.uid;
    if (uid == null) return;

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
      debugPrint('Erro ao atualizar perfil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar perfil.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(titulo: 'Perfil do Nutricionista'),
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
            _buildTextField('Nome', _nomeController, enabled: _ehNutri),
            _buildTextField('Email', _emailController, enabled: false),
            _buildTextField('CRN', _crnController, enabled: _ehNutri),
            _buildTextField('Contato', _contatoController, enabled: _ehNutri),
            _buildTextField('Biografia', _bioController,
                maxLines: 3, enabled: _ehNutri),
            const SizedBox(height: 10),
            if (_assinaturaPlano != null)
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      barrierColor: Colors.transparent,
                      pageBuilder: (_, __, ___) => const PlanosOverlay(),
                    ),
                  );
                },
                child: Text(
                  'Plano Assinado: $_assinaturaPlano',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (_ehNutri)
              ElevatedButton.icon(
                onPressed: _salvarAlteracoes,
                label: const Text('Salvar alterações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.laranja,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
              ),
            if (!_ehNutri && _nomeController.text.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  'Nenhum nutricionista vinculado ainda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
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
        style: const TextStyle(
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
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
}
