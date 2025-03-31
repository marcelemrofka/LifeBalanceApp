import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

final List<Map<String, String>> carouselItems = [
  {'title': 'Água', 'subtitle': 'Faltam apenas 350ml!', 'icon': '💧', 'route': '/tela_agua'},
  {'title': 'Lembretes', 'subtitle': 'Personalize seus lembretes!', 'icon': '⏰'},
  {'title': 'Exercícios', 'subtitle': 'Registre suas atividades físicas!', 'icon': '🏋️'},
  {'title': 'Sono', 'subtitle': 'Monitore suas horas de sono!', 'icon': '😴'},
];

class Carrossel extends StatefulWidget {
  const Carrossel({super.key});

  @override
  State<Carrossel> createState() => _CarrosselState();
}

class _CarrosselState extends State<Carrossel> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: carouselItems.map((item) {
        return GestureDetector(
          onTap: () {
            if (item['route'] != null && item['route']!.isNotEmpty) {
              Navigator.pushNamed(context, item['route']!);
            }
          },
          child: Container(
            width: 120,
            height: 15,
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
        );
      }).toList(),
      options: CarouselOptions(
        height: 200,
      ),
    );
  }
}