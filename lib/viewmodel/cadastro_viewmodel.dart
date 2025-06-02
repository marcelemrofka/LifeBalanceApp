import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroViewModel extends ChangeNotifier {
  bool _carregando = false;
  String? _erro;

  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<bool> cadastrarUsuario({
    required String email,
    required String senha,
    required String confirmarSenha,
  }) async {
    _erro = null;

    if (senha != confirmarSenha) {
      _erro = 'As senhas não coincidem';
      notifyListeners();
      return false;
    }

    _carregando = true;
    notifyListeners();

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: senha);
      return true;
    } catch (e) {
      _erro = 'Erro ao cadastrar: ${e.toString()}';
      return false;
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }
}
