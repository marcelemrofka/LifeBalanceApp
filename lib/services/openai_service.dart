// lib/services/openai_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// SUA CHAVE OPENAI AQUI

Future<String> analisarImagem(File imagem) async {
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');
  final bytes = await imagem.readAsBytes();
  final base64Image = base64Encode(bytes);

  final headers = {
    'Content-Type': 'application/json',
    //'Authorization': 'Bearer $openAiApiKey',
  };

  final body = jsonEncode({
    "model": "gpt-4o",
    "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": """
Considere a imagem de um prato de comida e faça o seguinte:

1. Liste os alimentos presentes, em tópicos e, juntamente, estime quantidade em gramas e calorias de cada item,
2. Ao final, dê uma linha padrão: CALORIAS TOTAIS: XXXX

Use uma linguagem clara, com letras, pontos e quebras de linha. Sempre termine com 'CALORIAS TOTAIS'.
"""
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

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      String conteudo = jsonResponse['choices'][0]['message']['content'];

      if (!conteudo.contains("CALORIAS TOTAIS")) {
        conteudo += "\n\nCALORIAS TOTAIS: estimativa não disponível";
      }

      return conteudo.trim();
    } else {
      print('Erro: ${response.body}');
      return 'Erro ao analisar a imagem: ${response.statusCode}';
    }
  } catch (e) {
    print('Erro na requisição: $e');
    return 'Erro ao analisar a imagem';
  }
}

// Função para parsear texto da IA em lista de mapas
List<Map<String, dynamic>> parseIAResponse(String texto) {
  final linhas = texto.split('\n');
  final pratos = <Map<String, dynamic>>[];

  for (var linha in linhas) {
    linha = linha.trim();
    if (linha.isEmpty || linha.startsWith('CALORIAS TOTAIS')) continue;

    // Exemplo: "- Arroz: 150g, 200 kcal"
    final match = RegExp(r"-\s*(.+):\s*(\d+)g,\s*(\d+)\s*kcal").firstMatch(linha);
    if (match != null) {
      pratos.add({
        "nomePrato": match.group(1),
        "quantidade": int.parse(match.group(2)!),
        "calorias": int.parse(match.group(3)!),
        "proteinas": 0,
        "carboidratos": 0,
        "grasas": 0,
      });
    }
  }

  return pratos;
}
