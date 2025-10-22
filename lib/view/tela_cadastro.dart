import 'package:app/utils/color.dart';
import 'package:app/viewmodel/cadastro_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TelaCadastro extends StatelessWidget {
  const TelaCadastro({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CadastroViewModel(),
      child: const TelaCadastroForm(),
    );
  }
}

class TelaCadastroForm extends StatefulWidget {
  const TelaCadastroForm({super.key});

  @override
  State<TelaCadastroForm> createState() => _TelaCadastroFormState();
}

class _TelaCadastroFormState extends State<TelaCadastroForm>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // controllers comuns
  final nomeControllerNutri = TextEditingController();
  final emailControllerNutri = TextEditingController();
  final senhaControllerNutri = TextEditingController();
  final confirmarSenhaControllerNutri = TextEditingController();
  final crnController = TextEditingController();
  final contatoController = TextEditingController();

  final nomeControllerUser = TextEditingController();
  final emailControllerUser = TextEditingController();
  final senhaControllerUser = TextEditingController();
  final confirmarSenhaControllerUser = TextEditingController();
  final cpfController = TextEditingController();
  final dataController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();

    nomeControllerNutri.dispose();
    emailControllerNutri.dispose();
    senhaControllerNutri.dispose();
    confirmarSenhaControllerNutri.dispose();
    crnController.dispose();
    contatoController.dispose();

    nomeControllerUser.dispose();
    emailControllerUser.dispose();
    senhaControllerUser.dispose();
    confirmarSenhaControllerUser.dispose();
    cpfController.dispose();
    dataController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CadastroViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.verdeBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.verdeBg,
        title: const Text(
          'Cadastre-se',
          style: TextStyle(fontSize: 26, color: Colors.white),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: "Nutricionista"),
            Tab(text: "Usuário Comum"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildNutriForm(context, viewModel),
            _buildUserForm(context, viewModel),
          ],
        ),
      ),
    );
  }

  Widget _buildNutriForm(BuildContext context, CadastroViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField('Nome', nomeControllerNutri),
          _buildTextField('CRN', crnController),
          _buildTextField('Contato', contatoController),
          _buildTextField('Email', emailControllerNutri),
          _buildTextField('Senha', senhaControllerNutri, obscureText: true),
          _buildTextField('Confirmar Senha', confirmarSenhaControllerNutri,
              obscureText: true),
          const SizedBox(height: 25),
          if (viewModel.erro != null)
            Text(viewModel.erro!, style: const TextStyle(color: Colors.red)),
          viewModel.carregando
              ? const CircularProgressIndicator(color: Colors.white)
              : ElevatedButton(
                  onPressed: () async {
                    // validações específicas nutri
                    if (nomeControllerNutri.text.isEmpty ||
                        crnController.text.isEmpty ||
                        contatoController.text.isEmpty ||
                        emailControllerNutri.text.isEmpty ||
                        senhaControllerNutri.text.isEmpty ||
                        confirmarSenhaControllerNutri.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Preencha todos os campos obrigatórios')),
                      );
                      return;
                    }

                    if (senhaControllerNutri.text !=
                        confirmarSenhaControllerNutri.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Senhas não conferem')),
                      );
                      return;
                    }

                    final plano = 'profissional';

                    try {
                      final sucesso = await viewModel.cadastrarUsuarioGeral(
                        nome: nomeControllerNutri.text.trim(),
                        email: emailControllerNutri.text.trim(),
                        senha: senhaControllerNutri.text.trim(),
                        cpf: '', 
                        data: '', 
                        isNutri: true,
                        crn: crnController.text.trim(),
                        contato: contatoController.text.trim(),
                        plano: plano,
                      );

                      if (sucesso) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    } catch (e) {
                      debugPrint('Erro ao cadastrar nutri: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    elevation: 6,
                  ),
                  child: const Text('Cadastrar',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
        ],
      ),
    );
  }

  Widget _buildUserForm(BuildContext context, CadastroViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField('Nome', nomeControllerUser),
          _buildTextField('Data de Nascimento', dataController,
              hint: 'dd/mm/aaaa'),
          _buildTextField('CPF', cpfController, hint: '000.000.000-00'),
          _buildTextField('Email', emailControllerUser),
          _buildTextField('Senha', senhaControllerUser, obscureText: true),
          _buildTextField('Confirmar Senha', confirmarSenhaControllerUser,
              obscureText: true),
          const SizedBox(height: 25),
          if (viewModel.erro != null)
            Text(viewModel.erro!, style: const TextStyle(color: Colors.red)),
          viewModel.carregando
              ? const CircularProgressIndicator(color: Colors.white)
              : ElevatedButton(
                  onPressed: () async {
                    // validações específicas usuário comum
                    if (nomeControllerUser.text.isEmpty ||
                        cpfController.text.isEmpty ||
                        emailControllerUser.text.isEmpty ||
                        senhaControllerUser.text.isEmpty ||
                        confirmarSenhaControllerUser.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Preencha todos os campos obrigatórios')),
                      );
                      return;
                    }

                    if (senhaControllerUser.text !=
                        confirmarSenhaControllerUser.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Senhas não conferem')),
                      );
                      return;
                    }

                    final plano = 'individual';

                    try {
                      final sucesso = await viewModel.cadastrarUsuarioGeral(
                        nome: nomeControllerUser.text.trim(),
                        email: emailControllerUser.text.trim(),
                        senha: senhaControllerUser.text.trim(),
                        cpf: cpfController.text.trim(),
                        data: dataController.text.trim(),
                        isNutri: false,
                        plano: plano,
                      );

                      if (sucesso) {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    } catch (e) {
                      debugPrint('Erro ao cadastrar usuário: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    elevation: 6,
                  ),
                  child: const Text('Cadastrar',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false, bool enabled = true, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF2F2F2),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
