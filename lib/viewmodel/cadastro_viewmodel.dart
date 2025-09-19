import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CadastroViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _carregando = false;
  String? _erro;

  bool get carregando => _carregando;
  String? get erro => _erro;

  Future<bool> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    required String data,
    required bool isNutri, // parâmetro para definir nutricionista ou comum
  }) async {
    try {
      _carregando = true;
      notifyListeners();

      // Cria o usuário no FirebaseAuth
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Salva os dados no Firestore
      await _firestore.collection('usuarios').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'nome': nome,
        'email': email,
        'data_nascimento': data,
        'cpf': cpf,
        'createdAt': FieldValue.serverTimestamp(),
        'tp_user': isNutri, // true = nutricionista, false = comum
        'plano': isNutri ? null : 'individual', // null se nutri, individual se comum
      });

      _carregando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _erro = 'Erro na criação: ${e.message}';
      _carregando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _erro = 'Erro inesperado: $e';
      _carregando = false;
      notifyListeners();
      return false;
    }
  }
}
