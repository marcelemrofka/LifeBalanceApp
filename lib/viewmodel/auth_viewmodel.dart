import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String get nome => _user?.displayName ?? 'Usuário';
  String get email => _user?.email ?? 'usuario@email.com';

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthViewModel() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<String?> login(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _getMessageFromErrorCode(e.code);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signUp(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getMessageFromErrorCode(e.code));
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>?> buscarDadosUsuario() async {
    final uid = _user?.uid;
    if (uid == null) return null;

    final firestore = FirebaseFirestore.instance;

    // Coleção correta: singular
    final docNutri = await firestore.collection('nutricionista').doc(uid).get();
    if (docNutri.exists) {
      final dados = docNutri.data()!;
      dados['tipo'] = 'nutricionista';
      return dados;
    }

    final docPaciente = await firestore.collection('paciente').doc(uid).get();
    if (docPaciente.exists) {
      final dados = docPaciente.data()!;
      dados['tipo'] = 'paciente';
      return dados;
    }

    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_getMessageFromErrorCode(e.code));
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getMessageFromErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'weak-password':
        return 'Senha muito fraca.';
      default:
        return 'Erro desconhecido: $code';
    }
  }
}
