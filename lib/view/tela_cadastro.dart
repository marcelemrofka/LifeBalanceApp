import 'package:app/utils/color.dart';
import 'package:flutter/material.dart';

class TelaCadastro extends StatelessWidget {
  final _nomeController = TextEditingController();
  final _dataController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.principal,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.principal,
        title: const Text( 'Cadastre-se',  style: TextStyle( fontSize: 26, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField('Nome', _nomeController),
                    _buildTextField('Data de Nascimento', _dataController),
                    _buildTextField('CPF', _cpfController),
                    _buildTextField('Email', _emailController),
                    _buildTextField('Senha', _senhaController, obscureText: true),
                    _buildTextField('Confirmar Senha', _confirmarSenhaController, obscureText: true),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_nomeController.text.isEmpty ||
                            _dataController.text.isEmpty ||
                            _cpfController.text.isEmpty ||
                            _emailController.text.isEmpty ||
                            _senhaController.text.isEmpty ||
                            _confirmarSenhaController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor, preencha todos os campos!'),
                            ),
                          );
                          return;
                        }

                        Navigator.pushNamed(context, '/');
                      },
                      label: const Text(
                        'Cadastrar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdeBg,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        elevation: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
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
