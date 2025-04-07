import 'package:flutter/material.dart';
import 'package:app/utils/color.dart';

final List<Map<String, dynamic>> carouselItems = [
  {'title': 'Água', 'subtitle': 'Registre seu consumo de água!', 'icon': Icons.local_drink_rounded, 'route': '/tela_agua'},
  {'title': 'Lembretes', 'subtitle': 'Personalize seus lembretes!', 'icon': Icons.alarm, 'route': '/tela_lembretes'},
  {'title': 'Exercícios', 'subtitle': 'Registre suas atividades físicas!', 'icon': Icons.fitness_center, 'route': '/tela_exercicios'},
];

class Carrossel extends StatefulWidget {
  const Carrossel({super.key});

  @override
  State<Carrossel> createState() => _CarrosselState();
}

class _CarrosselState extends State<Carrossel> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  void _onScroll() {
    final position = _scrollController.position.pixels;
    final cardWidth = MediaQuery.of(context).size.width * 0.6 + 16; // width + margin
    final index = (position / cardWidth).round();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 180,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: carouselItems.length,
            itemBuilder: (context, index) {
              final item = carouselItems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, item['route']);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == carouselItems.length - 1 ? 16 : 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.verdeNeutro.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        item['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Icon(item['icon'], size: 40, color: AppColors.principal),
                      
                      Text(
                        item['subtitle'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            carouselItems.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index
                    ? AppColors.principal
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
