import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

final List<Map<String, String>> carouselItems = [
  {'title': 'Água', 'subtitle': 'Faltam apenas 350ml!', 'icon': '💧', 'route': '/tela_agua'},
  {'title': 'Lembretes', 'subtitle': 'Personalize seus lembretes!', 'icon': '⏰', 'route': '/tela_lembretes'},
  {'title': 'Exercícios', 'subtitle': 'Registre suas atividades físicas!', 'icon': '🏋️', 'route': '/tela_exercicios'},
  {'title': 'Sono', 'subtitle': 'Monitore suas horas de sono!', 'icon': '😴','route': '/tela_sono'},
];

class Carrossel extends StatefulWidget {
  const Carrossel({super.key});

  @override
  State<Carrossel> createState() => _CarrosselState();
}

class _CarrosselState extends State<Carrossel> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Swiper(
        itemBuilder: (context, index){
        final item = carouselItems[index];

        return GestureDetector(
            onTap: () {
              if (item['route'] != null && item['route']!.isNotEmpty) {
                Navigator.pushNamed(context, item['route']!);
              }
            },
            child: Container(
              width: 120,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['icon']!,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['subtitle']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: carouselItems.length,
        pagination: const SwiperPagination(), 
        viewportFraction: 0.5,
        control: SwiperControl(),
        autoplay: false, // Não desliza automaticamente
        loop: false, // Não repete os itens
        scale: 0.7, 
      ),
    );
  }
}
