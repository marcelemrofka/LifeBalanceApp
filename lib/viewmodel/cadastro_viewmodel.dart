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
      // se for usuario
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

      final firestore = _firestore;

      // 🔎 1. VERIFICA SE JÁ EXISTE PACIENTE COM ESSE EMAIL
      final existing = await firestore
          .collection('paciente')
          .where('email', isEqualTo: email)
          .get();

      // =====================================================
      // 2️⃣ PACIENTE JÁ EXISTE NO FIRESTORE
      // =====================================================
      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final pacienteRef = doc.reference;
        final dataPac = doc.data();

        final relacaoExistente = dataPac['relacao_nutri_paciente_ref'];

        if (relacaoExistente != null) {
          // ❌ Já tem vínculo com outro nutricionista
          _erro = "Usuário já conveniado a outro nutricionista.";
          _carregando = false;
          notifyListeners();
          return false;
        }

        // ✔ Não tem vínculo → apenas vincular ao nutricionista atual
        final nutricionistaRef =
            firestore.collection('nutricionista').doc(currentUser.uid);

        // Criar nova relação
        final novaRelacao =
            await firestore.collection('relacao_nutri_paciente').add({
          'uid_paciente': pacienteRef,
          'uid_nutricionista': nutricionistaRef,
          'data_inicio': FieldValue.serverTimestamp(),
          'data_fim': null,
          'esta_ativo': true,
        });

        // Atualiza paciente com novo vínculo
        await pacienteRef.update({
          'nutricionista_uid': nutricionistaRef,
          'relacao_nutri_paciente_ref': novaRelacao,
        });

        _carregando = false;
        notifyListeners();
        return true;
      }

      // =====================================================
      // 3️⃣ VERIFICA SE O EMAIL JÁ EXISTE NO AUTH
      // =====================================================
      try {
        final methods = await _auth.fetchSignInMethodsForEmail(email);
        if (methods.isNotEmpty) {
          _erro =
              "Email já cadastrado na autenticação. Use o acesso normal para entrar.";
          _carregando = false;
          notifyListeners();
          return false;
        }
      } catch (_) {
        // se der erro ignora, significa que não existe
      }

      // =====================================================
      // 4️⃣ CRIA UM PACIENTE TOTALMENTE NOVO
      // =====================================================

      final nascimento = DateTime.parse(dataNascimento);
      final idade = DateTime.now().year -
          nascimento.year -
          ((DateTime.now().month < nascimento.month ||
                  (DateTime.now().month == nascimento.month &&
                      DateTime.now().day < nascimento.day))
              ? 1
              : 0);

      final senhaGerada = "${DateTime.now().millisecondsSinceEpoch}";

      // Cria usuário no Auth
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senhaGerada,
      );

      final pacienteRef =
          firestore.collection('paciente').doc(newUser.user!.uid);

      final nutricionistaRef =
          firestore.collection('nutricionista').doc(currentUser.uid);

      // Cria documento do paciente
      await pacienteRef.set({
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
        'nutricionista_uid': nutricionistaRef,
      });

      // Cria relação nutricionista–paciente
      final relacaoRef =
          await firestore.collection('relacao_nutri_paciente').add({
        'uid_paciente': pacienteRef,
        'uid_nutricionista': nutricionistaRef,
        'data_inicio': FieldValue.serverTimestamp(),
        'data_fim': null,
        'esta_ativo': true,
      });

      // Atualiza paciente com a referência
      await pacienteRef.update({
        'relacao_nutri_paciente_ref': relacaoRef,
      });

      // Reautentica nutricionista
      await _auth.signOut();
      await _auth.signInWithEmailAndPassword(
        email: currentUser.email!,
        password: 'SENHA_DO_NUTRICIONISTA_AQUI',
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
