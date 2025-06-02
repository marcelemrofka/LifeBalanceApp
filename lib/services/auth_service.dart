import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream que informa mudanças no estado do usuário (login/logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Retorna usuário atual
  User? get currentUser => _auth.currentUser;

  // Método para criar conta (cadastro)
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Método para login
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // Método para logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
