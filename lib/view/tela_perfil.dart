import 'package:app/utils/color.dart';
import 'package:app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../viewmodel/auth_viewmodel.dart';

class TelaPerfil extends StatefulWidget {
  final String? uidPaciente;

  const TelaPerfil({Key? key, this.uidPaciente}) : super(key: key);

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _pesoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _objetivoController = TextEditingController();
  final _metaCalController = TextEditingController();
  final _metaSonoController = TextEditingController();
  final _metaAguaController = TextEditingController();
  final _idadeController = TextEditingController();
  final _sexoController = TextEditingController();
  String? _nivelAtividade;
  String? _imagemUrl;
  bool _temNutricionista = false;
  bool _isNutricionista = false;
  bool _modoEdicao = false;

  final List<String> _niveisAtividade = [
    'nenhum',
    'leve',
    'moderado',
    'intenso',
    'muito intenso'
  ];

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    // se for o nutricionista visualizando um paciente:
    final String uid = widget.uidPaciente ?? authViewModel.user!.uid;

    final doc =
        await FirebaseFirestore.instance.collection('paciente').doc(uid).get();

    if (!doc.exists) return;

    final dadosUsuario = doc.data()!;
    final bool isNutricionista =
        authViewModel.dadosUsuario?['tipo'] == 'nutricionista';

    setState(() {
      _isNutricionista = isNutricionista;
      _temNutricionista = dadosUsuario['nutricionista_responsavel'] != null;
      _imagemUrl = dadosUsuario['imagemPerfil'];

      _nomeController.text = dadosUsuario['nome'] ?? '';
      _emailController.text = dadosUsuario['email'] ?? authViewModel.email;
      _pesoController.text = dadosUsuario['peso']?.toString() ?? '';
      _alturaController.text = dadosUsuario['altura']?.toString() ?? '';
      _objetivoController.text = dadosUsuario['objetivo'] ?? '';
      _metaCalController.text = dadosUsuario['meta_cal']?.toString() ?? '';
      _metaSonoController.text = dadosUsuario['meta_sono']?.toString() ?? '';
      _metaAguaController.text = dadosUsuario['meta_agua']?.toString() ?? '';
      _nivelAtividade = dadosUsuario['nivel_atividade'] ?? 'nenhum';
      _idadeController.text = dadosUsuario['idade']?.toString() ?? '';
      _sexoController.text = dadosUsuario['sexo'] ?? '';
    });
  }

  Future<void> _salvarAlteracoes() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final uid = widget.uidPaciente ?? authViewModel.user?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('paciente').doc(uid).update({
        'nome': _nomeController.text.trim(),
        'peso': double.tryParse(_pesoController.text.trim()) ?? 0,
        'altura': double.tryParse(_alturaController.text.trim()) ?? 0,
        'objetivo': _objetivoController.text.trim(),
        'meta_cal': double.tryParse(_metaCalController.text.trim()) ?? 0,
        'meta_sono': double.tryParse(_metaSonoController.text.trim()) ?? 0,
        'meta_agua': double.tryParse(_metaAguaController.text.trim()) ?? 0,
        'nivel_atividade': _nivelAtividade,
      });

      setState(() => _modoEdicao = false);

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

  bool get _camposBloqueados {
    // Paciente sem nutricionista: pode editar
    if (!_isNutricionista && !_temNutricionista) return false;

    // Nutricionista no modo de edição: pode editar
    if (_isNutricionista && _modoEdicao) return false;

    // Todos os outros casos: bloqueado
    return true;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    _objetivoController.dispose();
    _metaCalController.dispose();
    _metaSonoController.dispose();
    _metaAguaController.dispose();
    _idadeController.dispose();
    _sexoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titulo: 'Perfil',
        acoes: _isNutricionista
            ? [
                TextButton(
                  onPressed: () {
                    setState(() => _modoEdicao = !_modoEdicao);
                  },
                  child: Text(
                    _modoEdicao ? 'Cancelar' : 'Editar',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50,
                backgroundImage: _imagemUrl != null && _imagemUrl!.isNotEmpty
                    ? NetworkImage(_imagemUrl!)
                    : const AssetImage('lib/images/logo-circulo.png')
                        as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),

            _buildTextField('Nome', _nomeController,
                enabled: !_camposBloqueados),
            _buildTextField('Email', _emailController, enabled: false),
            _buildTextField('Idade', _idadeController, enabled: false),
            _buildTextField('Sexo', _sexoController, enabled: false),
            _buildTextField('Altura (cm)', _alturaController,
                enabled: !_camposBloqueados),
            _buildTextField('Peso (kg)', _pesoController,
                enabled: !_camposBloqueados),
            _buildTextField('Objetivo', _objetivoController,
                enabled: !_camposBloqueados),

            // Dropdown de nível de atividade
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DropdownButtonFormField<String>(
                value: _nivelAtividade,
                decoration: const InputDecoration(
                  labelText: 'Nível de Atividade',
                  border: OutlineInputBorder(),
                ),
                items: _niveisAtividade
                    .map((nivel) =>
                        DropdownMenuItem(value: nivel, child: Text(nivel)))
                    .toList(),
                onChanged: _camposBloqueados
                    ? null
                    : (valor) => setState(() => _nivelAtividade = valor),
              ),
            ),

            const Divider(height: 30),
            const Text(
              'Metas Diárias',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            _buildTextField('Meta de Calorias (kcal)', _metaCalController,
                enabled: !_camposBloqueados),
            _buildTextField('Meta de Sono (h)', _metaSonoController,
                enabled: !_camposBloqueados),
            _buildTextField('Meta de Água (ml)', _metaAguaController,
                enabled: !_camposBloqueados),

            const SizedBox(height: 25),
            Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.laranja, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Plano Alimentar',
                              style: TextStyle(
                                color: AppColors.laranja,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppColors.laranja, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Ficha Completa',
                              style: TextStyle(
                                color: AppColors.laranja,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            const SizedBox(height: 15),
            if (_modoEdicao || (!_temNutricionista && !_isNutricionista))
              ElevatedButton(
                onPressed: _salvarAlteracoes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.laranja,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
