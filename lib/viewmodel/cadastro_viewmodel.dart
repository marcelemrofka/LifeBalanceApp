import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CadastroViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _carregando = false;
  String? _erro;
  bool get carregando => _carregando;
  String? get erro => _erro;

  // principal
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String
        senhaOuObjetivo, // pode ser senha (cadastro comum) ou objetivo (paciente)
    required String cpf,
    required String data,
    bool? isNutri,
    double? peso,
    double? altura,
    required BuildContext context,
  }) async {
    User? userLogado = _auth.currentUser;

    if (userLogado != null) {
      await cadastrarPaciente(
        nome: nome,
        dataNascimento: data,
        email: email,
        cpf: cpf,
        peso: peso ?? 0.0,
        altura: altura ?? 0.0,
        objetivo: senhaOuObjetivo,
      );
    } else {
      await cadastrarUsuarioGeral(
        nome: nome,
        email: email,
        senha: senhaOuObjetivo,
        cpf: cpf,
        data: data,
        isNutri: isNutri ?? false,
      );
    }
  }

  Future<bool> cadastrarUsuarioGeral({
    required String nome,
    required String email,
    required String senha,
    required String cpf,
    required String data,
    required bool isNutri,
  }) async {
    try {
      _carregando = true;
      notifyListeners();

      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      await _firestore.collection('usuarios').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'nome': nome,
        'email': email,
        'data_nascimento': data,
        'cpf': cpf,
        'createdAt': FieldValue.serverTimestamp(),
        'tp_user': isNutri, // true = nutricionista, false = comum
        'plano': isNutri ? null : 'individual',
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

  Future<bool> cadastrarPaciente({
    required String nome,
    required String email,
    required String cpf,
    required String dataNascimento,
    required double peso,
    required double altura,
    required String objetivo,
  }) async {
    try {
      _carregando = true;
      notifyListeners();

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception("Nutricionista não autenticado");
      }

      // Verifica se já existe usuário com esse email
      final existing = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .get();

      if (existing.docs.isNotEmpty) {
        _erro = "Email já cadastrado em outro usuário.";
        _carregando = false;
        notifyListeners();
        return false;
      }

      // Calcula idade
      final nascimento = DateTime.parse(dataNascimento);
      final idade = DateTime.now().year -
          nascimento.year -
          ((DateTime.now().month < nascimento.month ||
                  (DateTime.now().month == nascimento.month &&
                      DateTime.now().day < nascimento.day))
              ? 1
              : 0);

      // Salva dados no Firestore
      await _firestore.collection('usuarios').add({
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'data_nascimento': dataNascimento,
        'idade': idade,
        'peso': peso,
        'altura': altura,
        'objetivo': objetivo,
        'tp_user': false,
        'status': 'pendente',
        'nutricionista_id': currentUser.uid,
        'criado_em': FieldValue.serverTimestamp(),
      });

      _carregando = false;
      notifyListeners();
      return true;
    } catch (e) {
      _erro = "Erro ao cadastrar paciente: $e";
      _carregando = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> ativarContaPaciente({
    required String email,
    required String senha,
  }) async {
    try {
      _carregando = true;
      _erro = null;
      notifyListeners();

      if (senha.length < 6) {
        throw Exception("A senha deve ter pelo menos 6 caracteres.");
      }

      // Verifica se há um cadastro pendente com o email
      final result = await _firestore
          .collection('usuarios')
          .where('email', isEqualTo: email)
          .where('status', isEqualTo: 'pendente')
          .get();

      if (result.docs.isEmpty) {
        throw Exception("Nenhum cadastro pendente encontrado para este email.");
      }

      // Cria o login no Firebase Authentication
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Atualiza o status no Firestore
      await _firestore.collection('usuarios').doc(result.docs.first.id).update({
        'uid': cred.user!.uid,
        'status': 'ativo',
        'ativado_em': FieldValue.serverTimestamp(),
      });

      _carregando = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _erro = e.message ?? "Erro ao criar conta.";
      _carregando = false;
      notifyListeners();
      return false;
    } catch (e) {
      _erro = e.toString();
      _carregando = false;
      notifyListeners();
      return false;
    }
  }
}
