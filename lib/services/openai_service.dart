import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

//chave
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
    "model": "gpt-4o-mini",
    "messages": [
      {
        "role": "system",
        "content": "Você é um assistente que responde estritamente no formato solicitado, sem explicações extras ou repetições."
      },
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": """
Analise a imagem da refeição e devolva **apenas o resultado estruturado** neste formato exato:

Se houver apenas 1 alimento, devolva no formato:

- Alimento: [nome]
- Quantidade: [valor em gramas]
- Calorias: [valor em kcal]
- Carboidratos: [valor em gramas]
- Proteínas: [valor em gramas]
- Fibras: [valor em gramas]
- Gorduras: [valor em gramas]

CALORIAS TOTAIS: [valor total em kcal]

Se houver mais de 1 alimento, devolva no formato:

- Alimento: [nomes separados por vírgula]
- Quantidade: [valor em gramas, somando todos os alimentos presentes]
- Calorias: [valor total em kcal]
- Carboidratos: [valor em gramas]
- Proteínas: [valor em gramas]
- Fibras: [valor em gramas]
- Gorduras: [valor em gramas]

CALORIAS TOTAIS: [valor total em kcal]

⚠️ Responda **somente** neste formato, nada mais.
⚠️ Caso você identifique que não há um alimento presente, diga que só pode fornecer dados sobre alimentos.

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

  String listaAlimentos = alimentos.map((item) {
    return "- ${item['alimento']}: ${item['quantidade']}g";
  }).join("\n");

  final headers = {
    'Content-Type': 'application/json',
    //'Authorization': 'Bearer $openAiApiKey',
  };

  final body = jsonEncode({
    "model": "gpt-4o-mini",
    "messages": [
      {
        "role": "system",
        "content": "Você é um assistente que responde estritamente no formato solicitado, sem explicações extras ou repetições."
      },
      {
        "role": "user",
        "content": """
Considere os seguintes alimentos com suas quantidades e devolva **apenas o resultado estruturado** neste formato exato:

$listaAlimentos

Formato de resposta:

Se houver apenas 1 alimento, devolva no formato:

- Alimento: [nome]
- Quantidade: [valor em gramas]
- Calorias: [valor em kcal]
- Carboidratos: [valor em gramas]
- Proteínas: [valor em gramas]
- Fibras: [valor em gramas]
- Gorduras: [valor em gramas]

CALORIAS TOTAIS: [valor total em kcal]

Se houver mais de 1 alimento, devolva no formato:

- Alimento: [nomes separados por vírgula]
- Quantidade: [valor em gramas, somando todos os alimentos presentes]
- Calorias: [valor total em kcal]
- Carboidratos: [valor em gramas]
- Proteínas: [valor em gramas]
- Fibras: [valor em gramas]
- Gorduras: [valor em gramas]

CALORIAS TOTAIS: [valor total em kcal]

⚠️ Responda **somente** neste formato, nada mais.
⚠️ Caso você identifique que não há um alimento presente, diga que só pode fornecer dados sobre alimentos.


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
