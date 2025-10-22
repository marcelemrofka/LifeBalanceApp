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

  // principal
  Future<void> cadastrar({
    required String nome,
    required String email,
    required String
        senhaOuObjetivo, // pode ser senha (cadastro comum) ou objetivo (paciente)
    required String cpf,
    required String data,
    required String plano,
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
        plano: plano,
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
    required String plano,
    String? crn,
    String? contato,
  }) async {
    try {
      _carregando = true;
      notifyListeners();

      // 🔹 Cria o login no Firebase Authentication
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // 🔹 Se for nutricionista → adiciona na coleção "nutricionista"
      if (isNutri) {
        await _firestore.collection('nutricionista').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'nome': nome,
          'crn': crn ?? '',
          'contato': contato ?? '',
          'plano': 'profissional',
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // 🔹 Caso contrário → adiciona na coleção "paciente"
      else {
        await _firestore.collection('paciente').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'nome': nome,
          'email': email,
          'cpf': cpf,
          'plano': 'individual',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

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

      // verifica se já existe
      final existingFirestore = await _firestore
          .collection('pacientes')
          .where('email', isEqualTo: email)
          .get();

      if (existingFirestore.docs.isNotEmpty) {
        _erro = "Email já cadastrado em outro paciente.";
        _carregando = false;
        notifyListeners();
        return false;
      }

      // 🔹 Verifica se já existe no Firebase Authentication
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          _erro = "Email já cadastrado na autenticação.";
          _carregando = false;
          notifyListeners();
          return false;
        }
      } catch (e) {
        // ignora se der erro, significa que o email não existe
      }

      final nascimento = DateTime.parse(dataNascimento);
      final idade = DateTime.now().year -
          nascimento.year -
          ((DateTime.now().month < nascimento.month ||
                  (DateTime.now().month == nascimento.month &&
                      DateTime.now().day < nascimento.day))
              ? 1
              : 0);

      final senhaGerada = "${DateTime.now().millisecondsSinceEpoch}";

      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senhaGerada,
      );

      await _firestore.collection('pacientes').doc(newUser.user!.uid).set({
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'data_nascimento': dataNascimento,
        'idade': idade,
        'peso': peso,
        'altura': altura,
        'objetivo': objetivo,
        'tp_user': false,
        'status': 'ativo',
        'nutricionista_id': currentUser.uid,
        'criado_em': FieldValue.serverTimestamp(),
      });

      await _auth.signOut();
      await _auth.signInWithEmailAndPassword(
        email: currentUser.email!,
        password:
            'SENHA_DO_NUTRICIONISTA_AQUI', // ⚠️ Substitua por forma segura de manter a sessão
      );

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
}
