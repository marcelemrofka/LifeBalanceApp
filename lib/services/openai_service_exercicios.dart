import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIServiceExercicios {
  final String apiKey;

  OpenAIServiceExercicios({required this.apiKey});

  Future<double> calcularGasto({
    required double peso,
    required String tipoExercicio,
    required String intensidade,
    required int tempoMinutos,
  }) async {
    final prompt = '''
Você é um nutricionista virtual. Calcule o gasto calórico aproximado de um exercício usando as informações abaixo:

- Peso da pessoa: $peso kg
- Tipo de exercício: $tipoExercicio
- Intensidade: $intensidade (Baixa, Média ou Alta)
- Tempo: $tempoMinutos minutos

Use valores realistas baseados em METs de atividades físicas. Retorne apenas **o número do gasto calórico em kcal**, sem texto adicional.
''';

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/responses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "input": prompt,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final resultText = data['output'][0]['content'][0]['text'] as String;
      return double.tryParse(RegExp(r'\d+(\.\d+)?').firstMatch(resultText)?.group(0) ?? '0') ?? 0;
    } else {
      throw Exception('Erro ao calcular gasto calórico: ${response.body}');
    }
  }
}
