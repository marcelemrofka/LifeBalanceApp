import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CadastroViewModel extends ChangeNotifier {
  final FirebaseAuth _auth= FirebaseAuth.instance;
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
    // required bool tp_user,
    // required String plano,
  }) async {
    try {
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
      });
      return true;
    } on FirebaseAuthException catch (e) {
      _erro = 'Erro na criação: ${e.message}';
      notifyListeners();
      return false; // Falha
    } catch (e) {
      _erro = 'Erro inesperado: $e';
      notifyListeners();
      return false; // Falha
    }
    }
}