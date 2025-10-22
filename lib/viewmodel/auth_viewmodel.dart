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
      // Carrega os dados do usuário logo após o login
      await buscarDadosUsuario();
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

  Map<String, dynamic>? _dadosUsuario;
  Map<String, dynamic>? get dadosUsuario => _dadosUsuario;
  String get tipoUsuario => _dadosUsuario?['tipo'] ?? '';

  Future<Map<String, dynamic>?> buscarDadosUsuario() async {
    final uid = _user?.uid;
    if (uid == null) return null;

    final firestore = FirebaseFirestore.instance;

    // Busca nas coleções de nutricionista e paciente
    final docNutri = await firestore.collection('nutricionista').doc(uid).get();
    if (docNutri.exists) {
      _dadosUsuario = docNutri.data()!;
      _dadosUsuario!['tipo'] = 'nutricionista';
      notifyListeners();
      return _dadosUsuario;
    }

    final docPaciente = await firestore.collection('paciente').doc(uid).get();
    if (docPaciente.exists) {
      _dadosUsuario = docPaciente.data()!;
      _dadosUsuario!['tipo'] = 'paciente';
      notifyListeners();
      return _dadosUsuario;
    }

    // Busca na coleção geral de usuários
    final docUsuario = await firestore.collection('usuarios').doc(uid).get();
    if (docUsuario.exists) {
      _dadosUsuario = docUsuario.data()!;
      notifyListeners();
      return _dadosUsuario;
    }

    return null;
  }

  Future<void> signOut() async {
    _dadosUsuario = null;
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
