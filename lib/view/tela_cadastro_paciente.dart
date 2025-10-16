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
      appBar: AppBar(title: const Text("Cadastrar Paciente")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: "Nome completo")),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: cpfController,
                decoration: const InputDecoration(labelText: "CPF")),
            TextField(
              controller: dataNascimentoController,
              decoration: const InputDecoration(
                  labelText: "Data de nascimento (AAAA-MM-DD)"),
              onChanged: calcularIdade,
            ),
            if (idade != null)
              Text("Idade: $idade anos",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            TextField(
                controller: pesoController,
                decoration: const InputDecoration(labelText: "Peso (kg)")),
            TextField(
                controller: alturaController,
                decoration: const InputDecoration(labelText: "Altura (cm)")),
            TextField(
                controller: objetivoController,
                decoration: const InputDecoration(labelText: "Objetivo")),
            const SizedBox(height: 20),
            ElevatedButton(
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
                          const SnackBar(content: Text("Paciente cadastrado!")),
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
              child: cadastroVM.carregando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Salvar Paciente"),
            ),
          ],
        ),
      ),
    );
  }
}
