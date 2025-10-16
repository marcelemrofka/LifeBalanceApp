import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/cadastro_viewmodel.dart';

class AtivarContaView extends StatefulWidget {
  const AtivarContaView({super.key});

  @override
  State<AtivarContaView> createState() => _AtivarContaViewState();
}

class _AtivarContaViewState extends State<AtivarContaView> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cadastroVM = Provider.of<CadastroViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Ativar Conta")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: senhaController,
              decoration: const InputDecoration(labelText: "Nova senha"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: cadastroVM.carregando
                  ? null
                  : () async {
                      final sucesso = await cadastroVM.ativarContaPaciente(
                        email: emailController.text.trim(),
                        senha: senhaController.text.trim(),
                      );

                      if (sucesso) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Conta ativada com sucesso!")),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(cadastroVM.erro ?? "Erro ao ativar conta.")),
                        );
                      }
                    },
              child: cadastroVM.carregando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Ativar Conta"),
            ),
            if (cadastroVM.erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  cadastroVM.erro!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
