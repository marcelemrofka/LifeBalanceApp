import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// CHAVE OPENAI

// === Função para análise da IMAGEM ===
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
      return 'Erro ao analisar a imagem: ${response.statusCode}';
    }
  } catch (e) {
    return 'Erro na requisição: $e';
  }
}

// === Função para análise dos ALIMENTOS MANUAIS ===
Future<String> analisarAlimentosManuais(List<Map<String, dynamic>> alimentos) async {
  final url = Uri.parse('https://api.openai.com/v1/chat/completions');

  // Monta o texto para enviar ao GPT
  String listaAlimentos = alimentos.map((item) {
    return "- ${item['alimento']}: ${item['quantidade']}g";
  }).join("\n");

  final headers = {
    'Content-Type': 'application/json',
    //'Authorization': 'Bearer $openAiApiKey',
  };

  final body = jsonEncode({
    "model": "gpt-4o",
    "messages": [
      {
        "role": "user",
        "content": """
Considere a seguinte lista de alimentos e calcule calorias estimadas:

$listaAlimentos

1. Liste cada alimento com estimativa de calorias,
2. Some ao final,
3. Sempre termine com: CALORIAS TOTAIS: XXXX
"""
      }
    ],
    "max_tokens": 800
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
      return 'Erro ao analisar alimentos: ${response.statusCode}';
    }
  } catch (e) {
    return 'Erro na requisição: $e';
  }
}
