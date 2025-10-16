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

  final nomeController = TextEditingController();
  final dataController = TextEditingController();
  final cpfController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CadastroViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.principal,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.principal,
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
            _buildForm(context, viewModel, isNutri: true),  // Nutricionista
            _buildForm(context, viewModel, isNutri: false), // Usuário comum
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, CadastroViewModel viewModel,
      {required bool isNutri}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField('Nome', nomeController),
          _buildTextField('Data de Nascimento', dataController),
          _buildTextField('CPF', cpfController),
          _buildTextField('Email', emailController),
          _buildTextField('Senha', senhaController, obscureText: true),
          _buildTextField('Confirmar Senha', confirmarSenhaController,
              obscureText: true),
          const SizedBox(height: 25),
          if (viewModel.erro != null)
            Text(
              viewModel.erro!,
              style: const TextStyle(color: Colors.red),
            ),
          viewModel.carregando
              ? const CircularProgressIndicator(color: Colors.white)
              : ElevatedButton(
                  onPressed: () async {
                    if (nomeController.text.isEmpty ||
                        dataController.text.isEmpty ||
                        cpfController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        senhaController.text.isEmpty ||
                        confirmarSenhaController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, preencha todos os campos!'),
                        ),
                      );
                      return;
                    }

                    final sucesso = await viewModel.cadastrarUsuarioGeral(
                      nome: nomeController.text,
                      email: emailController.text.trim(),
                      senha: senhaController.text.trim(),
                      cpf: cpfController.text.trim(),
                      data: dataController.text.trim(),
                      isNutri: isNutri, // passa info da aba
                    );

                    if (sucesso) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verdeBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    elevation: 6,
                  ),
                  child: const Text(
                    'Cadastrar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
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
