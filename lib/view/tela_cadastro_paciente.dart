import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cadastro_viewmodel.dart';
import 'package:intl/intl.dart';

class TelaCadastroPaciente extends StatefulWidget {
  const TelaCadastroPaciente({super.key});

  @override
  State<TelaCadastroPaciente> createState() => _TelaCadastroPacienteState();
}

class _TelaCadastroPacienteState extends State<TelaCadastroPaciente> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final cpfController = TextEditingController();
  final dataNascimentoController = TextEditingController();
  final pesoController = TextEditingController();
  final alturaController = TextEditingController();
  final objetivoController = TextEditingController();
  int? idade;

  void calcularIdade(String data) {
    try {
      final nascimento = DateTime.parse(data);
      final hoje = DateTime.now();
      final anos = hoje.year -
          nascimento.year -
          ((hoje.month < nascimento.month ||
                  (hoje.month == nascimento.month && hoje.day < nascimento.day))
              ? 1
              : 0);
      setState(() => idade = anos);
    } catch (_) {
      setState(() => idade = null);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    dataNascimentoController.dispose();
    emailController.dispose();
    cpfController.dispose();
    pesoController.dispose();
    alturaController.dispose();
    objetivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cadastroVM = Provider.of<CadastroViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            const SizedBox(height: 10),
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 80, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Campos de texto
            _buildCampo(nomeController, "Nome completo"),
            _buildCampo(emailController, "Email"),
            _buildCampo(cpfController, "CPF"),
            _buildCampo(
                dataNascimentoController, "Data de nascimento (AAAA-MM-DD)",
                onChanged: calcularIdade),
            if (idade != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text("Idade: $idade anos",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
            _buildCampo(pesoController, "Peso (kg)"),
            _buildCampo(alturaController, "Altura (cm)"),
            _buildCampo(objetivoController, "Objetivo"),
            const SizedBox(height: 40),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: cadastroVM.carregando
                    ? null
                    : () async {
                        final sucesso = await cadastroVM.cadastrarPaciente(
                          nome: nomeController.text.trim(),
                          email: emailController.text.trim(),
                          cpf: cpfController.text.trim(),
                          dataNascimento: dataNascimentoController.text.trim(),
                          peso: double.parse(pesoController.text.trim()),
                          altura: double.parse(alturaController.text.trim()),
                          objetivo: objetivoController.text.trim(),
                        );

                        if (sucesso) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Paciente cadastrado!")),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    cadastroVM.erro ?? "Erro ao cadastrar.")),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: cadastroVM.carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Salvar Perfil",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCampo(TextEditingController controller, String label,
      {Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: Colors.black45),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
