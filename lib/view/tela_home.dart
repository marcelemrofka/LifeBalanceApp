import 'package:flutter/material.dart';

class TelaHome extends StatelessWidget {
  final List<Map<String, String>> carouselItems = [
    {'title': 'Água', 'subtitle': 'Faltam apenas 350ml!', 'icon': '💧', 'route': '/tela_agua'}, // Rota para tela de água
    {'title': 'Lembretes', 'subtitle': 'Personalize seus lembretes!', 'icon': '⏰', 'route': '/tela_lembretes'}, // Rota para tela de lembretes
    {'title': 'Exercícios', 'subtitle': 'Registre suas atividades físicas!', 'icon': '🏋️', 'route': '/tela_exercicios'}, // Rota para tela de exercicios
    {'title': 'Sono', 'subtitle': 'Monitore suas horas de sono!', 'icon': '😴'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Tela Inicial"),
      ),
      body: Center(
        child: SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: carouselItems.length,
            itemBuilder: (context, index) {
              final item = carouselItems[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    if (item['route'] != null && item['route']!.isNotEmpty) {
                      Navigator.pushNamed(context, item['route']!);  
                    }
                  },
                  child: Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['icon']!,
                          style: TextStyle(fontSize: 30),
                        ),
                        Text(
                          item['title']!,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          item['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
