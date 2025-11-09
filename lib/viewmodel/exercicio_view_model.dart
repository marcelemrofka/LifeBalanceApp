import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/openai_service_exercicios.dart';

class ExercicioViewModel {
  final OpenAIServiceExercicios openAIService;

  ExercicioViewModel({required this.openAIService});

  Future<double> calcularEAdicionarExercicio({
    required String tipoExercicio,
    required String intensidade,
    required int tempoMinutos,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não logado');

    // Buscar peso do paciente
    final doc = await FirebaseFirestore.instance.collection('paciente').doc(uid).get();
    if (!doc.exists) throw Exception('Paciente não encontrado');
    final peso = (doc.data()?['peso'] ?? 0).toDouble();

    // Calcular gasto via OpenAI
    final gasto = await openAIService.calcularGasto(
      peso: peso,
      tipoExercicio: tipoExercicio,
      intensidade: intensidade,
      tempoMinutos: tempoMinutos,
    );

    // Salvar exercício no Firebase
    await FirebaseFirestore.instance.collection('exercicios').add({
      'uidPaciente': uid,
      'tipoExercicio': tipoExercicio,
      'intensidade': intensidade,
      'tempoMinutos': tempoMinutos,
      'gastoCalorico': gasto,
      'data': Timestamp.now(),
    });

    return gasto;
  }
}
