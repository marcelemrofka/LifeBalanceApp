import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'package:app/utils/color.dart';

class TelaSenha extends StatefulWidget {
  @override
  _TelaSenhaState createState() => _TelaSenhaState();
}

class _TelaSenhaState extends State<TelaSenha> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  void _showDialog(String titulo, String mensagem) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarEmailRecuperacao() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showDialog('Erro', 'Digite seu e-mail.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await authVM.resetPassword(email);
      _showDialog('Sucesso', 'Email de recuperação enviado.');
    } catch (e) {
      _showDialog('Erro', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar Senha',
            style: TextStyle(fontSize: 26, color: Colors.white)),
        backgroundColor: AppColors.verdeBg,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      backgroundColor: AppColors.verdeBg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Digite seu e-mail",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _enviarEmailRecuperacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranja,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3),
                        )
                      : Text(
                          "Recuperar",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
