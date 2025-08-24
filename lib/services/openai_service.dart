// lib/services/openai_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; 

// Sua chave OpenAI

Future<String> analisarImagem(File imagem) async {
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final bytes = await imagem.readAsBytes();
  final base64Image = base64Encode(bytes);

  final headers = {
    'Content-Type': 'application/json',
    // 'Authorization': 'Bearer $openAiApiKey',
  };

  final body = jsonEncode({
    "model": "gpt-4o",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text":
                "Considere a imagem de um prato de comida. Liste os alimentos presentes, estimando a quantidade de cada um e as calorias aproximadas com base em porções comuns. Dê uma estimativa total de calorias no prato."
          },
          {
            "type": "image_url",
            "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
          }
        ]
      }
    ],
    "max_tokens": 1000
  });

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['choices'][0]['message']['content'];
  } else {
    print('Erro: ${response.body}');
    return 'Erro ao analisar a imagem: ${response.statusCode}';
  }
}
