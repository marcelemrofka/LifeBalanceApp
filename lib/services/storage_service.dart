import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Faz upload de uma imagem para o Storage e retorna a URL
  Future<String?> uploadImagem(File imagem, String tipoRefeicao) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final ref = _storage
          .ref()
          .child('users/${user.uid}/$tipoRefeicao/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(imagem);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      return null;
    }
  }
}
